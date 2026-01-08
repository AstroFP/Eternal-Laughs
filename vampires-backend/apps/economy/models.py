from django.db import models
from apps.users.models import Player


class Currency(models.Model):
    """Waluty gracza"""
    player = models.OneToOneField(
        Player, on_delete=models.CASCADE, related_name='currency')
    gems = models.IntegerField(default=0)      # premium currency
    coins = models.IntegerField(default=500)   # free currency
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = "Currencies"

    def __str__(self):
        return f"{self.player.username}: {self.gems} gems, {self.coins} coins"
