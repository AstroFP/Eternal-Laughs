from django.urls import path
from .views import BuyItemView

urlpatterns = [
    path('buy/<str:item_id>/', BuyItemView.as_view(), name='buy_item'),
]
