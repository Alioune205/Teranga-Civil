"""
Chatbot Orchestrator via Gemini 2.5 Flash API (Agentic RAG+).
"""
import os
import json
import logging
from decouple import config
from google import genai
from google.genai import types
from .tools import get_dossier_status, get_procedure, create_dossier_draft

logger = logging.getLogger(__name__)

def get_gemini_client():
    api_key = config("GEMINI_API_KEY", default=None)
    if not api_key:
        raise ValueError("La clé GEMINI_API_KEY n'est pas configurée.")
    return genai.Client(api_key=api_key)

SYSTEM_PROMPT = """Tu es Ndiogoye, l'assistant administratif intelligent de TERANGA CIVIL (système d'état civil du Sénégal).
Ton rôle est d'aider les citoyens avec leurs démarches et de suivre leurs dossiers.
Tu es poli, professionnel, concis et tu parles français.
RÈGLE D'OR: Ne JAMAIS inventer de statut de dossier ni de documents. Si on te demande des informations spécifiques, utilise TOUJOURS les outils (tools) à ta disposition.
Si tu ne trouves pas la réponse avec les outils, dis simplement que tu ne sais pas et conseille de se rapprocher de la mairie.

IMPORTANT: Tu dois TOUJOURS formater ta réponse finale (lorsque tu t'adresses à l'utilisateur) UNIQUEMENT sous forme d'un objet JSON valide contenant 3 clés :
- "intent": l'intention détectée ("salutation", "creer_dossier", "suivre_dossier", "info_procedure", ou "inconnu").
- "action": l'action à déclencher côté frontend ("none", "start_dossier", "check_status").
- "reply": ton message texte en français pour le citoyen.
N'ajoute aucun texte avant ou après l'objet JSON. Réponds UNIQUEMENT avec le JSON."""

def chat_orchestrator(user, user_message, chat_history=None, extraction_context=None):
    """
    Orchestre la discussion avec l'utilisateur, et décide s'il faut appeler un sous-agent.
    """
    if chat_history is None:
        chat_history = []
        
    current_system_prompt = SYSTEM_PROMPT
    if extraction_context:
        current_system_prompt += f"\n\nCONTEXTE D'EXTRACTION OCR EN COURS:\nL'utilisateur est en train de soumettre un document. Des champs n'ont pas pu être lus automatiquement.\nVoici l'état actuel de l'extraction : {json.dumps(extraction_context, ensure_ascii=False)}\nTon objectif prioritaire est de guider poliment l'utilisateur pour qu'il te fournisse les informations listées dans 'missing_fields'. Une fois que tu as obtenu TOUTES les informations manquantes, appelle l'outil create_dossier_draft pour sauvegarder le brouillon."

    try:
        client = get_gemini_client()
        
        def tool_get_dossier_status(reference: str) -> str:
            """Récupère le statut actuel d'un dossier administratif via sa référence (ex: DOS-123456)."""
            return get_dossier_status(user, reference)
            
        def tool_get_procedure(sujet: str) -> str:
            """Récupère les informations et les documents requis pour une procédure spécifique (mariage, naissance, deces, delai, prix)."""
            return get_procedure(sujet)
            
        def tool_create_dossier_draft(dossier_type: str, commune_nom: str, metadata_json: str) -> str:
            """Crée un brouillon de dossier lorsque toutes les informations (y compris celles manquantes de l'OCR) ont été collectées."""
            return create_dossier_draft(user, dossier_type, commune_nom, metadata_json)

        my_tools = [tool_get_dossier_status, tool_get_procedure, tool_create_dossier_draft]

        # Convert history to Gemini format
        formatted_history = []
        for msg in chat_history:
            role = "user" if msg["role"] == "user" else "model"
            content = msg.get("content", "")
            if content:
                formatted_history.append(
                    types.Content(role=role, parts=[types.Part.from_text(text=content)])
                )

        chat = client.chats.create(
            model='gemini-2.5-flash',
            config=types.GenerateContentConfig(
                system_instruction=current_system_prompt,
                tools=my_tools,
                temperature=0.1,
            ),
            history=formatted_history
        )
        
        response = chat.send_message(user_message)
        final_content = response.text

        # Si le modèle renvoie du JSON, on le nettoie et on le parse
        try:
            clean_content = final_content.strip()
            if clean_content.startswith('```json'):
                clean_content = clean_content[7:]
            if clean_content.endswith('```'):
                clean_content = clean_content[:-3]
            clean_content = clean_content.strip()
            
            return json.loads(clean_content)
        except (json.JSONDecodeError, TypeError, AttributeError):
            return {
                "intent": "inconnu",
                "action": "none",
                "reply": final_content or "Désolé, je n'ai pas pu générer une réponse valide."
            }
            
    except Exception as e:
        logger.error(f"Erreur Chatbot Gemini : {e}")
        return {
            "intent": "erreur",
            "action": "none",
            "reply": f"Désolé, j'ai rencontré une erreur lors de la réflexion: {str(e)}"
        }
