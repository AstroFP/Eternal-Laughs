from inventory.models import Inventory


class PurchaseService:
    @staticmethod
    def buy_item(user, item):
        if user.gems < item.price:
            print(user.gems, item.price)
            raise ValueError("Not enough gems")

        user.gems -= item.price
        user.save()

        inv, created = Inventory.objects.get_or_create(
            user=user, item=item, defaults={"quantity": 1}
        )
        if not created:
            inv.quantity += 1
            inv.save()

        return inv
