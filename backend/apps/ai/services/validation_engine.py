import logging

logger = logging.getLogger(__name__)

# Règles de validation : quels champs sont strictement requis par type de document
VALIDATION_RULES = {
    "acte_naissance": ["nom", "prenom", "date_naissance", "lieu_naissance"],
    "acte_deces": ["nom_defunt", "date_deces", "lieu_deces"],
    "acte_mariage": ["epoux", "epouse", "date_mariage", "lieu_mariage"],
    "certificat_residence": ["nom", "prenom", "adresse"],
    "cni": ["nom", "prenom", "numero_cni", "date_naissance"],
}

def validate_extracted_data(document_type: str, extracted_data: dict) -> dict:
    """
    Vérifie la complétude des données extraites en fonction des règles métiers.
    Retourne un dictionnaire contenant le score de complétude, les champs manquants et la validité.
    """
    if document_type not in VALIDATION_RULES:
        # Si on ne connait pas le type, on ne peut pas vraiment valider
        return {
            "valid": True,
            "completeness_score": 100,
            "missing_fields": [],
            "errors": []
        }

    required_fields = VALIDATION_RULES[document_type]
    missing_fields = []
    
    for field in required_fields:
        val = extracted_data.get(field)
        if not val or str(val).strip() == "":
            missing_fields.append(field)
            
    total = len(required_fields)
    missing_count = len(missing_fields)
    
    if total == 0:
        score = 100
    else:
        score = int(((total - missing_count) / total) * 100)
        
    return {
        "valid": missing_count == 0,
        "completeness_score": score,
        "missing_fields": missing_fields,
        "errors": [f"Le champ obligatoire '{m}' est manquant ou illisible." for m in missing_fields]
    }
