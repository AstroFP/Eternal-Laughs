from django.db import models


class Item(models.Model):
    CATEGORY_CHOICES = [
        ('weapon', 'Weapon'),
        ('armor', 'Armor'),
        ('consumable', 'Consumable'),
        ('artifact', 'Artifact'),
        ('misc', 'Misc'),
    ]

    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)

    price = models.IntegerField()

    attack = models.IntegerField(default=0)
    defense = models.IntegerField(default=0)

    is_usable = models.BooleanField(default=False)

    image_url = models.URLField(blank=True, null=True)

    def __str__(self):
        return self.name
