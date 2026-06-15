"""
Prompts centralisés pour la détection et l'extraction structurée (JSON) des documents.
"""

DETECT_DOCUMENT_TYPE_PROMPT = """
Tu es un expert en documents administratifs de l'état civil sénégalais.
Ton rôle est de déterminer le type du document fourni à partir de son texte extrait par OCR.
Réponds UNIQUEMENT avec un objet JSON contenant les clés "document_type" et "confidence" (un float entre 0 et 1).

Les types possibles sont :
- acte_naissance
- acte_mariage
- acte_deces
- certificat_residence
- certificat_celibat
- certificat_moralite
- jugement_suppletif
- autorisation_construire
- cni
- inconnu

Exemple de réponse :
{"document_type": "acte_naissance", "confidence": 0.95}
"""

EXTRACT_NAISSANCE_PROMPT = """
Tu dois extraire les informations de l'acte de naissance fourni.
Renvoie UNIQUEMENT un objet JSON avec les clés suivantes (laisse vide "" si introuvable) :
{
  "type_document": "acte_naissance",
  "nom": "",
  "prenom": "",
  "date_naissance": "",
  "lieu_naissance": "",
  "pere": "",
  "mere": ""
}
"""

EXTRACT_DECES_PROMPT = """
Tu dois extraire les informations de l'acte de décès fourni.
Renvoie UNIQUEMENT un objet JSON avec les clés suivantes :
{
  "type_document": "acte_deces",
  "nom_defunt": "",
  "date_deces": "",
  "lieu_deces": ""
}
"""

EXTRACT_MARIAGE_PROMPT = """
Tu dois extraire les informations de l'acte de mariage fourni.
Renvoie UNIQUEMENT un objet JSON avec les clés suivantes :
{
  "type_document": "acte_mariage",
  "epoux": "",
  "epouse": "",
  "date_mariage": "",
  "lieu_mariage": ""
}
"""

EXTRACT_RESIDENCE_PROMPT = """
Tu dois extraire les informations du certificat de résidence fourni.
Renvoie UNIQUEMENT un objet JSON avec les clés suivantes :
{
  "type_document": "certificat_residence",
  "nom": "",
  "prenom": "",
  "adresse": ""
}
"""

EXTRACT_CNI_PROMPT = """
Tu dois extraire les informations de la Carte Nationale d'Identité fournie.
Renvoie UNIQUEMENT un objet JSON avec les clés suivantes :
{
  "type_document": "cni",
  "nom": "",
  "prenom": "",
  "numero_cni": "",
  "date_naissance": "",
  "lieu_naissance": "",
  "date_expiration": ""
}
"""

# Dictionnaire pour facilement récupérer le prompt selon le type
EXTRACTION_PROMPTS = {
    "acte_naissance": EXTRACT_NAISSANCE_PROMPT,
    "acte_deces": EXTRACT_DECES_PROMPT,
    "acte_mariage": EXTRACT_MARIAGE_PROMPT,
    "certificat_residence": EXTRACT_RESIDENCE_PROMPT,
    "cni": EXTRACT_CNI_PROMPT,
}
