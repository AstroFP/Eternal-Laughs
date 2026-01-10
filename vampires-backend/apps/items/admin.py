
# Register your models here.
from django.contrib import admin
from .models import Item


@admin.register(Item)
class ItemAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'is_usable',
                    'attack', 'defense', 'image_url')
