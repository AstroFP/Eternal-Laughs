from django.db import models
from django.contrib.auth.models import AbstractUser


class Player(AbstractUser):
    total_playtime = models.IntegerField(default=0)  # sekundy gry
    account_level = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    email = models.EmailField(unique=True)

    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return self.username
