import logging
import re

from apps.dossiers.models import Dossier

from ..models import NdiogoyeChatLog
from .classifier import IntentClassifier
from .guardrails import Guardrails
from .llm import LLMService
from .retriever import RetrieverService, SemanticCache

logger = logging.getLogger("apps")


class NdiogoyePipeline:
    """
    Orchestrateur central du pipeline IA Ndiogoye (les 5 couches).
    """

    def __init__(self):
        self.classifier = IntentClassifier()
        self.retriever = RetrieverService()
        self.llm = LLMService()
        self.guardrails = Guardrails()

    def _build_history(self, session_id: str) -> str:
        """Récupère l'historique récent de la session"""
        logs = NdiogoyeChatLog.objects.filter(session_id=session_id).order_by(
            "-created_at"
        )[:3]
        history = ""
        # On remet dans l'ordre chronologique
        for log in reversed(logs):
            history += (
                f"Citoyen: {log.user_query}\nNdiogoye: {log.ndiogoye_response}\n\n"
            )
        return history

    def process_query_stream(
        self, query: str, session_id: str, user=None, image_base64: str = None
    ):
        """
        Exécute le pipeline en mode Streaming (générateur).
        """
        try:
            # 0. Vérification du Cache Sémantique
            cache = SemanticCache()
            cached_resp = cache.check_cache(query)
            if cached_resp:
                self._save_log(
                    session_id, query, cached_resp["reply"], cached_resp["intent"], 1.0
                )
                return cached_resp

            # 1. Classification
            intent = self.classifier.classify(query)

            # 1.5 Gestion spécifique du suivi de dossier
            if intent == "TRACK_DOSSIER":
                match = re.search(r"(DOS-[A-Z0-9]+)", query, re.IGNORECASE)
                if match:
                    reference = match.group(1).upper()
                    dossier = Dossier.objects.filter(reference=reference).first()
                    if dossier:
                        reply = f"Voici l'état de votre dossier **{reference}** ({dossier.get_type_display()}) :\nStatut actuel : **{dossier.get_status_display()}**."
                        self._save_log(session_id, query, reply, intent, 1.0)
                        return {"reply": reply, "intent": intent, "action": "RESPOND"}
                    else:
                        reply = f"Désolé, je ne trouve aucun dossier correspondant à la référence **{reference}** dans le système."
                        self._save_log(session_id, query, reply, intent, 1.0)
                        return {"reply": reply, "intent": intent, "action": "RESPOND"}
                else:
                    # Si aucune référence n'est fournie, on cherche par utilisateur connecté
                    if user and user.is_authenticated:
                        dossiers = Dossier.objects.filter(citizen=user)
                        count = dossiers.count()
                        if count == 0:
                            reply = "Vous n'avez actuellement aucun dossier en cours dans notre système."
                        elif count == 1:
                            d = dossiers.first()
                            reply = f"J'ai trouvé votre dossier **{d.reference}** ({d.get_type_display()}).\nSon statut actuel est : **{d.get_status_display()}**."
                        else:
                            refs = [
                                f"- **{d.reference}** ({d.get_type_display()})"
                                for d in dossiers
                            ]
                            reply = (
                                "Vous avez plusieurs dossiers en cours :\n"
                                + "\n".join(refs)
                                + "\n\nLequel souhaitez-vous suivre ?"
                            )

                        self._save_log(session_id, query, reply, intent, 1.0)
                        return {"reply": reply, "intent": intent, "action": "RESPOND"}
                    else:
                        reply = "Pour pouvoir vérifier l'état d'avancement de votre dossier, veuillez me fournir sa **référence exacte** (ex: DOS-123456)."
                        log_id = self._save_log(session_id, query, reply, intent, 1.0)
                        yield {
                            "reply_chunk": reply,
                            "intent": intent,
                            "action": "CLARIFY",
                            "is_final": True,
                            "log_id": str(log_id),
                        }
                        return

            # 2. Retrieval (RAG)
            context = ""
            if intent in ["INFORM", "DIAGNOSE", "GUIDE"]:
                context = self.retriever.retrieve_context(query)

            # 3. Historique
            history = self._build_history(session_id)

            # Récupération du prénom de l'utilisateur pour la personnalisation
            user_name = None
            if user and user.is_authenticated:
                user_name = getattr(user, "first_name", "") or getattr(
                    user, "username", ""
                )

            # 4. Raisonnement LLM Streaming
            action = "RESPOND"
            dossier_ref = None
            func_call_final = None
            full_response = ""

            for chunk_text, func_call in self.llm.generate_response_stream(
                intent, query, context, history, image_base64, user_name
            ):
                if chunk_text:
                    full_response += chunk_text
                    yield {
                        "reply_chunk": chunk_text,
                        "intent": intent,
                        "action": action,
                        "is_final": False,
                    }
                if func_call:
                    func_call_final = func_call

            # 5. Interception Function Calling (à la fin du stream)
            if func_call_final:
                action = "SHOW_PAYMENT_AND_DOSSIER"
                from apps.communes.models import Commune

                commune = Commune.objects.first()
                if not commune:
                    commune = Commune.objects.create(
                        code="SIMUL-01", name="Commune Virtuelle"
                    )

                d_type = (
                    Dossier.Type.BIRTH_CERTIFICATE
                    if "naissance" in query.lower()
                    else Dossier.Type.OTHER
                )

                dossier = Dossier.objects.create(
                    type=d_type,
                    status=Dossier.Status.SUBMITTED,
                    commune=commune,
                    citizen=user if user and user.is_authenticated else None,
                    metadata={
                        "source": "chatbot_simulation",
                        "tarif": func_call_final.get("tarif", 500),
                    },
                )
                dossier_ref = dossier.reference

            # Enregistrement en base
            log_id = self._save_log(session_id, query, full_response, intent, 0.9)

            final_data = {
                "reply_chunk": "",
                "intent": intent,
                "action": action,
                "is_final": True,
            }
            if dossier_ref:
                final_data["dossier_reference"] = dossier_ref
            if log_id:
                final_data["log_id"] = str(log_id)

            # Envoi du chunk final avec les métadonnées (log_id, action modifiée, dossier)
            yield final_data

            # Mise en cache sémantique
            if not dossier_ref and action == "RESPOND":
                cache.add_to_cache(
                    query, {"reply": full_response, "intent": intent, "action": action}
                )

        except Exception as e:
            logger.error(f"Pipeline error: {e}")
            yield {
                "reply_chunk": "Je rencontre une difficulté technique.",
                "action": "FALLBACK",
                "is_final": True,
            }

    def _save_log(self, session_id, user_query, response, intent, score):
        try:
            log = NdiogoyeChatLog.objects.create(
                session_id=session_id,
                user_query=user_query,
                ndiogoye_response=response,
                intent=intent,
                confidence_score=score,
            )
            return log.id
        except Exception as e:
            logger.error(f"Erreur sauvegarde historique: {e}")
            return None
