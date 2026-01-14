from django.db import models
from django.conf import settings


class GemPack(models.Model):
    code = models.CharField(max_length=30, unique=True)
    gems = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=6, decimal_places=2)
    currency = models.CharField(max_length=3, default="PLN")
    active = models.BooleanField(default=True)


class Payment(models.Model):
    STATUS = (
        ("pending", "Pending"),
        ("success", "Success"),
        ("failed", "Failed"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL,
                             on_delete=models.CASCADE)
    pack = models.ForeignKey(GemPack, on_delete=models.PROTECT)

    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)

    def mark_success(self):
        self.status = "success"
        self.save(update_fields=["status"])

    def mark_failed(self):
        self.status = "failed"
        self.save(update_fields=["status"])

    def __str__(self):
        return f"{self.user} - {self.pack.code} - {self.status}"
