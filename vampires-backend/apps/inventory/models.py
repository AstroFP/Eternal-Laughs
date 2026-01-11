from django.db import models
from ..users.models import Player
from ..items.models import Item


class InventoryItem(models.Model):
    player = models.ForeignKey(
        Player, on_delete=models.CASCADE, related_name="inventory")
    item = models.ForeignKey(Item, on_delete=models.CASCADE)

    quantity = models.IntegerField(default=1)  
    is_equipped = models.BooleanField(default=False)  # dla broni / armoru

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.player} owns {self.item}"
