import os
import json
import logging
from groq import Groq
from decouple import config

logger = logging.getLogger(__name__)

# Initialisation du client Groq.
client = None
try:
    api_key = config("GROQ_API_KEY", default=None)
    if api_key:
        client = Groq(api_key=api_key)
    else:
        logger.warning("GROQ_API_KEY non trouvée dans le fichier .env")
except Exception as e:
    logger.error(f"Erreur d'initialisation de Groq : {e}")

def ask_llama(system_prompt: str, user_prompt: str, json_mode: bool = False, temperature: float = 0.1) -> str:
    """
    Service centralisé pour interroger Llama 3.3 via Groq.
    Si json_mode est True, force le modèle à retourner un JSON valide.
    """
    if not client:
        logger.error("Client Groq non initialisé.")
        return "{}" if json_mode else ""
        
    try:
        # Modèle Llama 3.3 recommandé (utilisation de llama-3.3-70b-versatile sur Groq)
        model = "llama-3.3-70b-versatile"
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
        
        response_format = {"type": "json_object"} if json_mode else None
        
        completion = client.chat.completions.create(
            messages=messages,
            model=model,
            temperature=temperature,
            response_format=response_format
        )
        
        return completion.choices[0].message.content
    except Exception as e:
        logger.error(f"Erreur lors de l'appel Llama 3.3 : {e}")
        return "{}" if json_mode else ""
