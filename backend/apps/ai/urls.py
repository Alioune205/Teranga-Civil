from django.urls import path

from .views import NdiogoyeChatView, NdiogoyeFeedbackView

urlpatterns = [
    path("ndiogoye/chat/", NdiogoyeChatView.as_view(), name="ndiogoye-chat"),
    path(
        "ndiogoye/feedback/", NdiogoyeFeedbackView.as_view(), name="ndiogoye-feedback"
    ),
]
