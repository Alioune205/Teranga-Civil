import json
import logging
from .llm_client import ask_llama
from apps.ai.prompts import DETECT_DOCUMENT_TYPE_PROMPT, EXTRACTION_PROMPTS

logger = logging.getLogger(__name__)

def detect_document_type(raw_text: str) -> dict:
    """
    Utilise Llama 3.3 pour détecter le type du document basé sur le texte OCR.
    Retourne un dict ex: {"document_type": "acte_naissance", "confidence": 0.95}
    """
    if not raw_text.strip():
        return {"document_type": "inconnu", "confidence": 0.0}

    user_prompt = f"Voici le texte brut extrait par OCR :\n\n{raw_text}\n\nQuel est le type de ce document ?"
    
    response_str = ask_llama(
        system_prompt=DETECT_DOCUMENT_TYPE_PROMPT,
        user_prompt=user_prompt,
        json_mode=True
    )
    
    try:
        data = json.loads(response_str)
        return {
            "document_type": data.get("document_type", "inconnu"),
            "confidence": data.get("confidence", 0.0)
        }
    except Exception as e:
        logger.error(f"Erreur de parsing JSON pour la détection de document: {e}")
        return {"document_type": "inconnu", "confidence": 0.0}


def extract_structured_data(document_type: str, raw_text: str) -> dict:
    """
    Extrait les données structurées spécifiques au type de document.
    """
    if document_type not in EXTRACTION_PROMPTS:
        logger.warning(f"Pas de prompt d'extraction pour le type: {document_type}")
        return {}

    system_prompt = EXTRACTION_PROMPTS[document_type]
    user_prompt = f"Voici le texte brut extrait par OCR :\n\n{raw_text}\n\nExtraits les informations demandées."
    
    response_str = ask_llama(
        system_prompt=system_prompt,
        user_prompt=user_prompt,
        json_mode=True
    )
    
    try:
        data = json.loads(response_str)
        return data
    except Exception as e:
        logger.error(f"Erreur de parsing JSON pour l'extraction de données: {e}")
        return {}
