from django.db import models


class Item(models.Model):
    name = models.CharField(max_length=100)
    price = models.IntegerField()
    # reszta do przemyslenia

    def __str__(self):
        return self.name
