from .models import GemPack
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .services import MockPaymentService
from django.contrib.auth.models import User
from django.contrib.auth import get_user_model
from django.db import transaction

import random
from .models import Payment


class MockPaymentService:

    def create_payment(self, user, pack, amount):
        return Payment.objects.create(
            user=user,
            pack=pack,
            amount=amount,
            status="pending"
        )

    def process_payment(self, payment: Payment):
        if payment.status != "pending":
            return payment

        success = random.choice([True, True, False])

        if success:
            payment.mark_success()
        else:
            payment.mark_failed()

        return payment


class CreatePaymentView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        user = get_user_model().objects.first()
        pack_code = request.data.get("pack_code")

        pack = get_object_or_404(GemPack, code=pack_code, active=True)

        service = MockPaymentService()
        payment = service.create_payment(
            user=user,
            pack=pack,
            amount=pack.price
        )

        return Response({
            "payment_id": payment.id,
            "status": payment.status,
            "gems": pack.gems,
            "amount": str(pack.price),
        })


class MockGatewayView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request, payment_id):
        payment = Payment.objects.select_for_update().get(id=payment_id)

        if payment.status != "pending":
            return Response({
                "payment_id": payment.id,
                "status": payment.status,
                "granted": False,
                "message": "Payment already processed"
            })

        service = MockPaymentService()
        payment = service.process_payment(payment)

        granted = False
        if payment.status == "success":
            payment.user.gems += 100
            payment.user.save(update_fields=["gems"])
            granted = True

        return Response({
            "payment_id": payment.id,
            "status": payment.status,
            "granted": granted
        })


class GemPackListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        packs = GemPack.objects.filter(active=True)
        return Response([
            {
                "code": p.code,
                "gems": p.gems,
                "price": str(p.price),
                "currency": p.currency,
            }
            for p in packs
        ])
