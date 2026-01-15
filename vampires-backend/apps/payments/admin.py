
from django.contrib import admin
from .models import GemPack, Payment


@admin.register(GemPack)
class GemPackAdmin(admin.ModelAdmin):
    list_display = (
        "code",
        "gems",
        "price",
        "currency",
        "active",
    )
    list_filter = ("active", "currency")
    search_fields = ("code",)
    ordering = ("price",)
    list_editable = ("active",)

    fieldsets = (
        ("Basic info", {
            "fields": ("code", "gems")
        }),
        ("Pricing", {
            "fields": ("price", "currency")
        }),
        ("Status", {
            "fields": ("active",)
        }),
    )


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "pack",
        "amount",
        "status",
        "created_at",
    )
    list_filter = ("status", "pack", "created_at")
    search_fields = ("user__username", "pack__code")
    ordering = ("-created_at",)
    readonly_fields = (
        "user",
        "pack",
        "amount",
        "status",
        "created_at",
    )

    fieldsets = (
        ("User & Pack", {
            "fields": ("user", "pack")
        }),
        ("Payment info", {
            "fields": ("amount", "status")
        }),
        ("Metadata", {
            "fields": ("created_at",)
        }),
    )

    def has_add_permission(self, request):
        # Płatności NIE tworzymy ręcznie z admina
        return False

    def has_delete_permission(self, request, obj=None):
        # Nie pozwalamy usuwać płatności (audyt)
        return False
