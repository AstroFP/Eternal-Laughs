from django.urls import path
from .views import CreatePaymentView, MockGatewayView, GemPackListView

urlpatterns = [
    path("packs/", GemPackListView.as_view(), name="gem-packs"),

    path("create/", CreatePaymentView.as_view(), name="create-payment"),

    path("mock-gateway/<int:payment_id>/",
         MockGatewayView.as_view(), name="mock-gateway"),
]
