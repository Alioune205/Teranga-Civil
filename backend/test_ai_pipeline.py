import os
import sys
import json

from apps.ai.services.document_analyzer import analyze_document

def test_pipeline():
    file_path = "test.jpg"
    print(f"=== TEST PIPELINE DOCUMENT ANALYZER SUR {file_path} ===")
    
    if not os.path.exists(file_path):
        print(f"Fichier {file_path} introuvable.")
        return

    # 1. Analyse complète
    print("\n1. Analyse avec le moteur unifié en cours...")
    result = analyze_document(file_path, engine="gemini")
    
    # 2. Affichage
    print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    test_pipeline()
