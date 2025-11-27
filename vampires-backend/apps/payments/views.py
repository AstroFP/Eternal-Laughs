from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .services import MockPaymentService
from django.contrib.auth.models import User
from django.contrib.auth import get_user_model


@method_decorator(csrf_exempt, name='dispatch')
class BuyItemView(APIView):
    permission_classes = [AllowAny]  # na czas testów
    authentication_classes = []      # brak weryfikacji sesji

    def post(self, request, item_id):
        User = get_user_model()
        user = User.objects.first()

        payment_service = MockPaymentService()
        payment = payment_service.create_payment(user, item_id, 5.0)

        granted = False
        if payment.status == "success":
            user.gems += 100
            user.save()
            granted = True

        return Response({
            "payment_id": payment.id,
            "status": payment.status,
            "item_id": payment.item_id,
            "amount": float(payment.amount),
            "granted": granted,
            "user": user.username,
            "message": "Płatność zakończona sukcesem" if granted else "Płatność nieudana"
        })
