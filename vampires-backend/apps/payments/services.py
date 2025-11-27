from .models import Payment
import time


class PaymentService:
    def create_payment(self, user, item_id, amount):
        raise NotImplementedError


class MockPaymentService(PaymentService):
    def create_payment(self, user, item_id, amount):
        payment = Payment.objects.create(
            user=user,
            item_id=item_id,
            amount=amount,
            status="pending"
        )

        time.sleep(1.5)

        payment.status = "success"
        payment.save()

        return payment
