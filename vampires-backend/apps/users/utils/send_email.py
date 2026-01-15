from threading import Thread
from django.core.signing import TimestampSigner, BadSignature, SignatureExpired
from ..models import Player
from django.core.mail import send_mail
from django.conf import settings
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


def send_activation_email(user, request):
    token = generate_email_token(user)
    activation_link = f"https://eternal-laughs-1.onrender.com/api/auth/verify-email/?token={token}"

    def _send():
        send_mail(
            subject="Aktywuj swoje konto",
            message=f"Kliknij w link aby aktywować konto:\n{activation_link}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            fail_silently=False,
        )

    Thread(target=_send).start()
