from django.contrib import admin
from .models import Player


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ['username', 'email',
                    'account_level', 'total_playtime', 'created_at']
    search_fields = ['username', 'email']
