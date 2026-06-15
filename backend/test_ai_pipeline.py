import os
import sys
import json

from apps.ai.services.gemini_client import analyze_document_with_gemini
from apps.ai.services.validation_engine import validate_extracted_data

def test_pipeline():
    file_path = "test.jpg"
    print(f"=== TEST PIPELINE GEMINI VISION SUR {file_path} ===")
    
    if not os.path.exists(file_path):
        print(f"Fichier {file_path} introuvable.")
        return

    # 1. OCR + Extraction via Gemini
    print("\n1. Analyse avec Gemini 1.5 Flash en cours...")
    gemini_result = analyze_document_with_gemini(file_path)
    
    raw_text = gemini_result.get("raw_text", "")
    print(f"-> Texte extrait ({len(raw_text)} caracteres) :")
    print("-" * 40)
    print(raw_text[:300] + "..." if len(raw_text) > 300 else raw_text)
    print("-" * 40)

    if not raw_text:
        print("L'analyse a echoue ou la cle API est manquante.")
        return

    # 2. Détection
    doc_type = gemini_result.get("document_type", "inconnu")
    confidence = gemini_result.get("confidence", 0.0)
    print(f"\n2. Type detecte : {doc_type} (Confiance : {confidence})")

    # 3. Extraction Structurée
    structured_data = gemini_result.get("structured_data", {})
    print(f"\n3. Donnees extraites :")
    print(json.dumps(structured_data, indent=2, ensure_ascii=False))

    # 4. Validation
    print("\n4. Validation Metier...")
    validation = validate_extracted_data(doc_type, structured_data)
    print(f"-> Resultat validation :")
    print(json.dumps(validation, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    test_pipeline()
