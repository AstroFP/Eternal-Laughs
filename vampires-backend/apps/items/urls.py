from django.urls import path
from .views import BuyItemView


urlpatterns = [
    path('buy/', BuyItemView.as_view()),
]
