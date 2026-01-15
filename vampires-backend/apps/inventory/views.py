from django.db import transaction
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from apps.inventory.models import InventoryItem
from apps.items.serializer import InventoryItemSerializer


class PlayerInventoryView(generics.ListAPIView):
    serializer_class = InventoryItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return InventoryItem.objects.filter(player=self.request.user)


class UseItemView(APIView):
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def post(self, request, id):
        player = request.user
        inv = InventoryItem.objects.filter(id=id, player=player).first()

        if not inv:
            return Response({"error": "Item not found"}, status=404)

        item = inv.item

        if item.category in ['consumable', 'misc']:
            # Zużywalne itemy
            player.gems += getattr(item, 'gems_bonus', 0)
            player.save()

            inv.quantity -= 1
            if inv.quantity <= 0:
                inv.delete()
            else:
                inv.save()
        else:
            # Niezużywalne – toggle is_equipped
            if not inv.is_equipped:
                # odznacz wszystkie inne w tym samym slocie
                InventoryItem.objects.filter(
                    player=player,
                    item__category=item.category,
                    is_equipped=True
                ).update(is_equipped=False)

            inv.is_equipped = not inv.is_equipped
            inv.save()

        return Response({"success": True, "is_equipped": inv.is_equipped})
