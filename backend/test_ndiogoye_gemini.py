import os
import sys
import json
import django

# Setup Django Environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.ai.chatbot import chat_orchestrator
from django.contrib.auth import get_user_model

class MockUser:
    def __init__(self):
        self.email = "testcitizen@example.com"
        self.phone_number = "770000000"
        self.role = "citizen"
        self.is_authenticated = True

user = MockUser()

print(f"=== TEST CHATBOT NDIOGOYE ===")
print(f"Utilisateur : {user.email}")

extraction_context = {
    "missing_fields": ["date_naissance"],
    "structured_data": {
        "nom": "DIALLO",
        "prenom": "Moussa"
    },
    "document_type": "acte_naissance"
}

chat_history = []

print("\n--- Tour 1: Ndiogoye doit demander la date de naissance ---")
user_msg = "Bonjour Ndiogoye, j'aimerais valider mon dossier."
print(f"User: {user_msg}")
res1 = chat_orchestrator(user, user_msg, chat_history, extraction_context)
print(f"Ndiogoye: {json.dumps(res1, indent=2, ensure_ascii=False)}")
chat_history.append({"role": "user", "content": user_msg})
chat_history.append({"role": "model", "content": json.dumps(res1, ensure_ascii=False)})

print("\n--- Tour 2: Le citoyen donne la date de naissance (Ndiogoye doit créer le dossier) ---")
user_msg = "Je suis né le 15 Mars 1990 à Dakar."
print(f"User: {user_msg}")
res2 = chat_orchestrator(user, user_msg, chat_history, extraction_context)
print(f"Ndiogoye: {json.dumps(res2, indent=2, ensure_ascii=False)}")

print("\n=== FIN DU TEST ===")
