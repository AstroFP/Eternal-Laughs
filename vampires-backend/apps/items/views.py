from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Item
from ..payments.services import PurchaseService


class BuyItemView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, item_id):
        user = request.user
        item = Item.objects.get(id=item_id)

        try:
            inv = PurchaseService.buy_item(user, item)
        except ValueError as e:
            return Response({"error": str(e)}, status=400)

        return Response({
            "status": "success",
            "item": item.name,
            "quantity": inv.quantity
        })
