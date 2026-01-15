from rest_framework.views import APIView
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction

from apps.items.models import Item
from apps.inventory.models import InventoryItem
from apps.items.serializer import ItemSerializer, InventoryItemSerializer


# GET /shop/items/
class ShopItemListView(generics.ListAPIView):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = []

    def get_queryset(self):
        user = self.request.user
        owned_item_ids = InventoryItem.objects.filter(
            player=user).values_list('item_id', flat=True)
        return Item.objects.exclude(id__in=owned_item_ids)


class BuyItemView(APIView):
    permission_classes = []

    @transaction.atomic
    def post(self, request, item_id):
        player = request.user
        item = Item.objects.filter(id=item_id).first()

        if not item:
            return Response({"error": "Item not found"}, status=404)

        if player.gems < item.price:
            return Response({"error": "Not enough gems"}, status=400)

        # Odejmij walutę
        player.gems -= item.price
        player.save()

        # Dodaj do ekwipunku
        inventory_item = InventoryItem.objects.create(
            player=player,
            item=item,
            quantity=1
        )

        return Response({
            "success": True,
            "gems_after": player.gems,
            "item": InventoryItemSerializer(inventory_item).data
        }, status=201)
