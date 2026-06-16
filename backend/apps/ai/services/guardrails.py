class Guardrails:
    """
    Couche 5: Garde-fous et contrôle qualité avant d'envoyer la réponse à l'utilisateur.
    """

    def check_response(self, response: str, context: str) -> str:
        """
        Vérifie qu'aucun tarif fantaisiste n'a été inventé (ex: 5000 FCFA si ce n'est pas dans le contexte).
        Dans un vrai système en prod, on utiliserait des expressions régulières avancées ou un second appel LLM (LLM-as-judge).
        Ici on implémente un filtre basique anti-hallucination.
        """
        response_lower = response.lower()
        context_lower = context.lower()

        # Vérification très basique des prix
        if "fcfa" in response_lower or "francs cfa" in response_lower:
            # Si le contexte ne parle pas de frais, la réponse ne doit pas en parler
            if (
                "fcfa" not in context_lower
                and "francs cfa" not in context_lower
                and "frais" not in context_lower
                and "coût" not in context_lower
            ):
                return "Je suis désolé, je ne dispose pas d'informations certifiées concernant les tarifs. Veuillez vous rapprocher de la mairie."

        return response
