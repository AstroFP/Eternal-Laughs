from django.urls import path
from .views import PlayerInventoryView, UseItemView

urlpatterns = [
    path('my/', PlayerInventoryView.as_view()),
    path('<int:id>/use/', UseItemView.as_view()),
]
