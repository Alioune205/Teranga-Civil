# BILAN MISSION : Refonte et Professionnalisation du Module OCR (DEV 1D)

## 1. Audit de l'existant

**Forces :**
- L'utilisation de Gemini 2.5 Flash permettait déjà une extraction robuste sur des images complexes et floues (particulièrement adapté aux documents sénégalais parfois abîmés ou raturés).
- Le fallback sur EasyOCR permettait une approche sans API externe en cas d'indisponibilité.

**Faiblesses :**
- Architecture couplée : les vues (endpoints) appelaient directement le service Gemini sans couche d'abstraction, empêchant tout changement de moteur transparent.
- Sortie de l'IA (JSON) très limitative : ne retournait que les champs de base sans séparer les données extraites, les métadonnées globales du document ou sa validité.
- Validation rigide et binaire (présent ou absent), sans score précis tenant compte de tous les nouveaux types de documents (certificats de vie, d'hérédité, etc.).
- Aucune logique de "compatibilité" (savoir à quelle démarche sert tel document).

**Risques et Limites sur documents sénégalais :**
- La qualité de l'OCR traditionnel (EasyOCR) est souvent insuffisante pour les anciens registres d'état civil sénégalais écrits à la main ou imprimés avec des tampons baveux.
- Les erreurs de "confidence" peuvent bloquer un citoyen.

---

## 2. Architecture Cible et Nouveaux Services

Nous avons introduit une **Couche d'Abstraction OCR** et un **Moteur de validation & procédures**.

**Nouveaux fichiers créés :**
- `backend/apps/ai/services/document_analyzer.py` : Le point d'entrée unique (`analyze_document()`). Il s'occupe de router vers Gemini ou EasyOCR, puis de standardiser le JSON.
- `backend/apps/ai/services/procedure_engine.py` : Un moteur qui, pour un document donné, identifie les démarches compatibles (`get_compatible_procedures()`) et détecte les pièces manquantes selon des règles métier (`check_missing_documents()`).

**Fichiers modifiés :**
- `backend/apps/ai/services/gemini_client.py` : Le prompt a été largement enrichi pour classer parmi 15 types de documents (incluant certificats d'hérédité, jugement supplétif, mutation de parcelle, etc.) et extraire un bloc "metadata".
- `backend/apps/ai/services/validation_engine.py` : Les règles ont été étendues pour inclure de nouveaux champs (ex: numéro de registre pour décès et mariage). La sortie renvoie `is_valid`, `completeness_score`, `missing_fields`, `warnings`.
- `backend/apps/ai/views.py` : Les endpoints `OcrExtractView` et `OcrCameraView` ont été factorisés pour utiliser uniquement le `document_analyzer.py` et retourner le JSON normalisé complet.

---

## 3. Justification du moteur OCR retenu

**Moteur Principal : Gemini 2.5 Flash**
- *Raisonnement :* L'état civil sénégalais comporte de nombreux documents non standardisés, remplis à la main, scannés de travers, ou comportant des sceaux complexes. Un LLM visuel (VLM) comme Gemini est capable d'inférer le sens, de lire l'écriture manuscrite et de classifier sans avoir besoin de templates fixes (là où un moteur comme PaddleOCR ou DocTR demanderait un post-processing Regex lourd et fragile).

**Fallback : EasyOCR**
- Reste disponible via le `document_analyzer.py` pour un premier passage basique.

---

## 4. Normalisation JSON (Exemple d'API)

Chaque appel renvoie désormais cette structure :

```json
{
  "success": true,
  "source": "upload",
  "document_type": "acte_naissance",
  "confidence": 0.98,
  "raw_text": "REPUBLIQUE DU SENEGAL...",
  "structured_data": {
    "nom": "GUEYE",
    "prenom": "MAME DIARRA",
    "sexe": "Féminin",
    "date_naissance": "04/03/2003",
    "pere": "IBRA",
    "mere": "BOUSSO DIAW"
  },
  "metadata": {
    "numero_registre": "345",
    "annee_registre": "2014",
    "centre_etat_civil": "Secondaire de COLOBANE"
  },
  "validation": {
    "is_valid": true,
    "completeness_score": 100,
    "missing_fields": [],
    "warnings": []
  },
  "usable_for": [
    "declaration_naissance",
    "certificat_vie",
    "prise_en_charge_familiale"
  ],
  "processing_time": 3.45
}
```

---

## 5. Respect du Périmètre DEV 1D

**Respect strict de la mission :**
- ✅ Aucune modification sur le frontend ou les formulaires.
- ✅ Aucune modification sur le chatbot conversationnel (les vues RAG/FAQ n'ont pas été touchées).
- ✅ L'intégration avec les "Dossiers" se fera en aval, le JSON fourni au Frontend lui permettant le pré-remplissage. L'OCR ne modifie pas lui-même la base de données métier `Dossier`.

---

## 6. Plan de Migration si abandon de l'API Gemini

Grâce à `document_analyzer.py`, le changement de moteur est transparent.
1. Remplacer le bloc `elif engine == "easyocr":` ou créer un nouveau fichier `doctr_client.py`.
2. L'appel à l'API via `analyze_document(file, engine="doctr")` continuera de passer par le `validation_engine` et le `procedure_engine` sans modifier une seule ligne du fichier `views.py`.

---

## 7. Recommandations Futures

1. **Extraction de signatures et de tampons :** Former un modèle de vision (YOLO) spécifique pour détecter la simple *présence* du sceau du maire/officier pour lutter contre la fraude basique avant même la vérification avancée.
2. **Auto-crop intelligent :** Si le document contient de l'arrière-plan (table, doigts de l'utilisateur), l'application mobile devrait faire du cropping "edge detection" avant l'envoi pour accélérer le traitement et réduire les hallucinations.
