import os
from threading import Thread
from django.core.signing import TimestampSigner, BadSignature, SignatureExpired
from ..models import Player
from django.core.mail import send_mail
from django.conf import settings
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
signer = TimestampSigner()


def generate_email_token(user):
    return signer.sign(user.pk)


def validate_email_token(token, max_age=60*60*24):

    try:
        pk = signer.unsign(token, max_age=max_age)
        user = Player.objects.get(pk=pk)

        if user.is_active:
            return None
        return user
    except (BadSignature, SignatureExpired, Player.DoesNotExist):
        return None


def send_activation_email(user, token):
    activation_link = f"https://eternal-laughs-1.onrender.com/api/auth/verify-email/?token={token}"

    def _send():
        message = Mail(
            # np. parchatkarobert@gmail.com
            from_email=os.environ.get("DEFAULT_FROM_EMAIL"),
            to_emails=user.email,
            subject="Aktywuj swoje konto",
            html_content=f"""
                <p>Kliknij w link aby aktywować konto:</p>
                <a href="{activation_link}">Aktywuj konto</a>
            """
        )
        try:
            sg = SendGridAPIClient(os.environ.get("SENDGRID_API_KEY"))
            sg.send(message)
        except Exception as e:
            print("SendGrid error:", e)

    Thread(target=_send).start()
