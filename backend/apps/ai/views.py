import json
import logging

from django.http import StreamingHttpResponse
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .services.pipeline import NdiogoyePipeline

logger = logging.getLogger("apps")


class NdiogoyeChatView(APIView):
    permission_classes = [AllowAny]  # Pour le chatbot public

    def post(self, request, *args, **kwargs):
        """
        Endpoint d'interaction avec l'IA Ndiogoye.
        Attend:
        {
            "message": "Comment obtenir un extrait de naissance ?",
            "conversation_id": "uuid-de-session"
        }
        """
        message = request.data.get("message")
        conversation_id = request.data.get("conversation_id")
        image_base64 = request.data.get("image_base64")

        if not message:
            return Response(
                {"error": "Le champ 'message' est requis."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not conversation_id:
            return Response(
                {
                    "error": "Le champ 'conversation_id' est obligatoire pour le contexte de session."
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            pipeline = NdiogoyePipeline()
            user = request.user if request.user.is_authenticated else None

            def event_stream():
                try:
                    for chunk_dict in pipeline.process_query_stream(
                        message, conversation_id, user, image_base64
                    ):
                        yield f"data: {json.dumps(chunk_dict)}\n\n"
                except Exception as stream_e:
                    logger.error(f"Erreur Streaming: {stream_e}")
                    error_data = {
                        "reply_chunk": "Une erreur est survenue pendant la génération.",
                        "action": "FALLBACK",
                        "is_final": True,
                    }
                    yield f"data: {json.dumps(error_data)}\n\n"

            return StreamingHttpResponse(
                event_stream(), content_type="text/event-stream"
            )

        except Exception as e:
            logger.error(f"Erreur Ndiogoye IA globale: {str(e)}")
            return Response(
                {
                    "reply": "Je rencontre des difficultés techniques actuellement. Veuillez réessayer plus tard."
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class NdiogoyeFeedbackView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        log_id = request.data.get("log_id")
        rating = request.data.get("rating")
        comment = request.data.get("comment", "")

        if not log_id or rating is None:
            return Response(
                {"error": "log_id et rating sont requis."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            from .models import NdiogoyeChatLog

            log = NdiogoyeChatLog.objects.get(id=log_id)
            log.rating = int(rating)
            log.feedback_comment = comment
            log.save()
            return Response({"status": "success"})
        except NdiogoyeChatLog.DoesNotExist:
            return Response(
                {"error": "Log introuvable."}, status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Erreur feedback: {e}")
            return Response(
                {"error": "Erreur serveur."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
