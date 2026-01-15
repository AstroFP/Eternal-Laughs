from rest_framework import serializers
from apps.items.models import Item
from apps.inventory.models import InventoryItem


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = '__all__'


class InventoryItemSerializer(serializers.ModelSerializer):
    item = ItemSerializer()

    class Meta:
        model = InventoryItem
        fields = ['id', 'item', 'quantity', 'is_equipped', 'created_at']
