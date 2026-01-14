from django.contrib import admin
from .models import InventoryItem


@admin.register(InventoryItem)
class InventoryItemAdmin(admin.ModelAdmin):
    list_display = ('player', 'item', 'quantity', 'is_equipped', 'created_at')
    list_filter = ('is_equipped', 'created_at')
    search_fields = ('player__username', 'item__name')
