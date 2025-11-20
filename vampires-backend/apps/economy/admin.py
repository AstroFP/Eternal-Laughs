from django.contrib import admin
from .models import Currency


@admin.register(Currency)
class CurrencyAdmin(admin.ModelAdmin):
    list_display = ['player', 'gems', 'coins', 'updated_at']
    search_fields = ['player__username']
