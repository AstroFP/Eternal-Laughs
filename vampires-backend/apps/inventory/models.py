from django.db import models
from items.models import Item
from ..users.models import Player


class Inventory(models.Model):
    user = models.ForeignKey(
        Player, on_delete=models.CASCADE, related_name="inventory")
    item = models.ForeignKey(Item, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=1)
    acquired_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'item')
