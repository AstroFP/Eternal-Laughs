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
            # Zużywalne itemy – zmniejszamy quantity
            # Tutaj możesz dodać efekt np. player.blood += item.blood_bonus
            player.gems += getattr(item, 'gems_bonus', 0)  # przykładowy efekt
            player.save()

            inv.quantity -= 1
            if inv.quantity <= 0:
                inv.delete()
            else:
                inv.save()
        else:
            # Niezużywalne (weapon, armor, artifact)
            # Nie zmieniamy quantity, można ustawić is_equipped
            inv.is_equipped = not inv.is_equipped
            inv.save()

        return Response({"success": True})
