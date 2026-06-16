# Guide d'Intégration Frontend : Ndiogoye IA (Gemini 2.5 Flash)

Ce document décrit comment l'équipe Frontend doit intégrer le chatbot Ndiogoye dans l'interface utilisateur de **Teranga Civil**. 
Le backend IA a été entièrement refait, sécurisé, et propulsé par Gemini 2.5 Flash avec RAG (Retrieval-Augmented Generation) et un système natif de suivi de dossiers.

## 1. Endpoint API

L'unique point d'entrée pour communiquer avec Ndiogoye est la route POST suivante :

```http
POST /api/ai/ndiogoye/chat/
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>
```

> **Note :** L'authentification par JWT est requise car l'historique conversationnel est sauvegardé côté backend pour chaque session.

## 2. Payload Attendue (Request)

L'API attend un objet JSON avec le message de l'utilisateur et un identifiant de session unique.

```json
{
  "message": "Bonjour Ndiogoye",
  "conversation_id": "session-xyz-123",
  "image_base64": "iVBORw0KGgoAAAANSUhEUgAA..." // Optionnel: Envoyez l'image en base64
}
```

### Paramètres
* `message` (string, **requis**) : Le texte envoyé par l'utilisateur.
* `conversation_id` (string, **requis**) : L'identifiant unique de la session pour maintenir l'historique (ex: un UUID ou le token utilisateur).
* `image_base64` (string, *optionnel*) : L'image encodée en base64. Idéal si l'utilisateur prend en photo un document. Ndiogoye lira le document.

## 3. Structure de la Réponse (Streaming SSE)

⚠️ **ATTENTION CHANGEMENT MAJEUR : STREAMING SSE** ⚠️
L'API ne renvoie plus un simple JSON unique à la fin, mais un flux continu **Server-Sent Events (SSE)**. Cela permet d'afficher la réponse de l'IA au fur et à mesure (effet machine à écrire).

**En-tête de réponse :** `Content-Type: text/event-stream`

Le backend enverra des "chunks" (morceaux) au format suivant :
```
data: {"reply_chunk": "Bonjour ", "intent": "INFORM", "action": "RESPOND", "is_final": false}

data: {"reply_chunk": "je suis ", "intent": "INFORM", "action": "RESPOND", "is_final": false}

data: {"reply_chunk": "Ndiogoye.", "intent": "INFORM", "action": "RESPOND", "is_final": false}

data: {"reply_chunk": "", "intent": "INFORM", "action": "SHOW_PAYMENT_AND_DOSSIER", "is_final": true, "dossier_reference": "DOS-1234", "log_id": "uuid-123"}
```

### Paramètres de chaque "Chunk"
1. **`reply_chunk`** (string) : Le morceau de texte à concaténer (ajouter) au message affiché à l'écran. Ne remplacez pas le message, ajoutez ce chunk à la fin.
2. **`is_final`** (boolean) : Si `true`, c'est le dernier événement. Le message est terminé.
3. **`intent`** (string) : L'intention détectée (ex: `INFORM`, `GREETING`).
4. **`action`** (string) : L'action à effectuer. (À traiter principalement lors du chunk final).
   * `RESPOND` : Continuer d'afficher le texte.
   * `SHOW_PAYMENT_AND_DOSSIER` : Afficher les boutons Wave/Orange Money et le bouton "Voir dossier".
   * `FALLBACK` : Afficher un message d'erreur.
5. **`dossier_reference`** (string, *optionnel*) : Présent dans le chunk final si l'action est `SHOW_PAYMENT_AND_DOSSIER`.
6. **`log_id`** (string, *optionnel*) : Présent dans le chunk final. À utiliser pour envoyer un feedback.

## 4. Endpoint de Feedback (Nouveau)

Pour améliorer l'IA, l'utilisateur peut noter une réponse.

**URL** : `POST /api/ai/ndiogoye/feedback/`

**Payload :**
```json
{
  "log_id": "123e4567-e89b-12d3-a456-426614174000",
  "rating": 1, // 1 pour positif, -1 pour négatif
  "comment": "Très rapide merci !" // Optionnel
}
```

## 5. Recommandations d'Intégration pour l'Équipe Flutter (Best Practices)

Pour intégrer Ndiogoye de manière optimale, voici la marche à suivre recommandée pas à pas :

### Étape 1 : Gérer le Streaming (Effet Machine à Écrire)
Ne faites plus de simples appels HTTP `POST` qui bloquent l'interface. Utilisez un package spécialisé pour lire les flux SSE.
*   **Package recommandé :** [`flutter_client_sse`](https://pub.dev/packages/flutter_client_sse) ou la méthode `send()` de la classe `http.Request`.
*   **Logique de l'UI :** Créez une bulle de message vide pour Ndiogoye. À chaque fois qu'un événement SSE arrive avec un `reply_chunk`, ajoutez-le (append) à l'état de votre message (`setState` ou bloc/provider). Cela donnera l'impression que Ndiogoye réfléchit et tape en temps réel.

### Étape 2 : Formatage Markdown
Les réponses de Gemini contiennent du Markdown (titres, puces, gras).
*   **Package recommandé :** [`flutter_markdown`](https://pub.dev/packages/flutter_markdown).
*   Enveloppez le texte reçu dans un widget `MarkdownBody` pour qu'il soit propre et lisible.

### Étape 3 : Vision (Envoi de photos)
Si l'utilisateur veut uploader un document (ex: carte d'identité).
*   Utilisez [`image_picker`](https://pub.dev/packages/image_picker) pour prendre la photo.
*   Convertissez l'image en Base64 avant de l'envoyer dans le payload JSON (champ `image_base64`).
*   **Astuce :** Compressez légèrement l'image avant de l'encoder pour éviter d'envoyer des payloads JSON trop lourds.

### Étape 4 : Le système de Feedback
À la fin d'une réponse de Ndiogoye (quand `is_final: true` est reçu), récupérez le `log_id`.
*   Affichez deux petits boutons discrets (👍 et 👎) sous la bulle du message.
*   Si le citoyen clique, faites un appel asynchrone (en arrière-plan, sans bloquer l'UI) vers l'endpoint `/api/ai/ndiogoye/feedback/`.
*   Une fois cliqué, colorisez le pouce ou cachez les boutons pour indiquer que le vote est pris en compte.

### Étape 5 : Les Boutons d'Action (Paiement)
Quand le chunk final contient `"action": "SHOW_PAYMENT_AND_DOSSIER"`, l'IA a fini son travail.
*   Affichez des boutons clairs pour Wave et Orange Money.
*   Stockez la `dossier_reference` pour pouvoir rediriger le citoyen vers la page de suivi une fois le paiement validé.

## 4. Fonctionnalité Spéciale : Suivi de Dossier

Le backend intègre une fonctionnalité autonome pour le suivi de dossier.
**Il n'y a plus besoin de rediriger le citoyen vers la mairie pour le suivi de dossier !**

Le comportement côté backend est le suivant :
- Si l'utilisateur demande "Je veux suivre mon dossier" : Ndiogoye renverra une action `CLARIFY` avec le texte *"Veuillez me fournir votre référence exacte (ex: DOS-123456)"*.
- Si l'utilisateur tape "Où en est mon dossier DOS-98765" : Ndiogoye interrogera la base de données et renverra directement son statut formel, par exemple : *"Le statut de votre dossier est : En cours de vérification."*

Le frontend n'a rien à programmer de particulier pour cela, le backend s'occupe de renvoyer le texte final dans `reply`.

## 5. Création de dossier & Paiement Intégré

Ndiogoye est programmé pour demander à l'utilisateur des informations (ex: numéro d'acte, année). 
Dès que l'utilisateur fournit les informations requises, Ndiogoye :
1. Estime le tarif (entre 300 et 1000 FCFA).
2. Le backend crée **automatiquement** le dossier en base de données.
3. L'API renvoie l'action `SHOW_PAYMENT_AND_DOSSIER` avec le champ `dossier_reference`.

**Ce que l'équipe Frontend doit faire à la réception de `SHOW_PAYMENT_AND_DOSSIER` :**
- Afficher la réponse texte de Ndiogoye (qui annoncera le prix simulé).
- Afficher en dessous de la bulle de chat des boutons de paiement (Wave, Orange Money).
- Afficher un bouton "Voir le dossier" qui redirige l'utilisateur vers la page de détail du dossier en utilisant la `dossier_reference` fournie.

## 6. Gestion des États UI Recommandée

* **Loading State :** Affichez un indicateur "Ndiogoye est en train de réfléchir..." (typing indicator) dès l'envoi de la requête.
* **Markdown :** L'IA génère souvent du Markdown (ex: les `**` pour le gras). Comme vous êtes sur Flutter, utilisez le package officiel `flutter_markdown` pour que le texte s'affiche correctement (gras, listes à puces) au lieu d'afficher des astérisques.
* **Erreurs (HTTP 400 / 500) :** Si l'API renvoie une erreur, affichez "Ndiogoye est actuellement indisponible, veuillez réessayer plus tard."
