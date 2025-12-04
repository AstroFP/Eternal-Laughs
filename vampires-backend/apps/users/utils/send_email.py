from django.core.signing import TimestampSigner, BadSignature, SignatureExpired
from ..models import Player

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
