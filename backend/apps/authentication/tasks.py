from celery import shared_task
import logging

logger = logging.getLogger(__name__)

@shared_task
def send_otp_email_task(email, code):
    try:
        from apps.services.communication import SendGridEmailService
        email_service = SendGridEmailService()
        html_content = f"<h3>Code de vérification — TERANGA CIVIL</h3><p>Votre code de vérification OTP est : <strong>{code}</strong>.</p><p>Il expire dans 10 minutes.</p>"
        email_service.send_email(
            to_email=email,
            subject="Code de vérification — TERANGA CIVIL",
            html_content=html_content
        )
    except Exception as e:
        logger.error(f"Erreur lors de l'envoi de l'email OTP: {e}")

@shared_task
def send_otp_sms_task(phone, code):
    try:
        from apps.services.communication import TwilioSMSService
        sms_service = TwilioSMSService()
        sms_service.send_sms(
            to_phone=phone,
            message=f"TERANGA CIVIL: Votre code de vérification OTP est {code}. Valide 10 minutes."
        )
    except Exception as e:
        logger.error(f"Erreur lors de l'envoi du SMS OTP: {e}")

@shared_task
def send_super_admin_otp_email_task(email, otp):
    try:
        from apps.services.communication import SendGridEmailService
        email_service = SendGridEmailService()
        html_content = f"<h3>Code de validation — Teranga Civil Super Admin</h3><p>Votre code de vérification OTP est : <strong>{otp}</strong>.</p><p>Il expire dans 10 minutes.</p>"
        email_service.send_email(
            to_email=email,
            subject="Code de validation — Teranga Civil Super Admin",
            html_content=html_content
        )
    except Exception as e:
        logger.error(f"Erreur lors de l'envoi de l'email OTP Super Admin: {e}")
