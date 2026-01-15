from django.urls import path
from .views import BuyItemView
from .views import ShopItemListView, BuyItemView


urlpatterns = [
    path('items/', ShopItemListView.as_view()),
    path('buy/<int:item_id>/', BuyItemView.as_view()),
]
