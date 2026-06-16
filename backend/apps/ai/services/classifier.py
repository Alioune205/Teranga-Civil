import re


class IntentClassifier:
    """
    Couche 2: Classification d'intention (Heuristique rapide avant RAG).
    Intentions possibles: INFORM, GUIDE, DIAGNOSE, VERIFY, CLARIFY, OUT_OF_SCOPE, EMERGENCY
    """

    def classify(self, query: str) -> str:
        q_lower = query.lower()

        # 0. Salutations
        if re.search(
            r"\b(bonjour|salut|hello|bonsoir|coucou|salam|na nga def|nuyu)\b", q_lower
        ):
            return "GREETING"

        # 1. Suivi de dossier (Dossier en cours)
        if re.search(
            r"\b(suivre|suivi|etat|état|avancement|dossier|ou en est|reference|référence)\b",
            q_lower,
        ):
            return "TRACK_DOSSIER"

        # 2. Détection d'urgence (décès très récent)
        if re.search(r"\b(mort|décédé|deces|urgence|hier|ce matin)\b", q_lower):
            return "EMERGENCY"

        # 3. Demande d'information (pièces, prix, délai)
        if re.search(
            r"\b(comment|combien|delai|prix|pieces|documents|faut-il|faut il|papier)\b",
            q_lower,
        ):
            return "INFORM"

        # 4. Diagnostic de situation
        if re.search(r"\b(que faire|je suis ne|mon pere|je veux|besoin de)\b", q_lower):
            return "DIAGNOSE"

        # 5. Guidage étape par étape
        if re.search(r"\b(etape|procedure|demarche)\b", q_lower):
            return "GUIDE"

        # Par défaut, on traite comme une demande d'info générale (INFORM)
        return "INFORM"
