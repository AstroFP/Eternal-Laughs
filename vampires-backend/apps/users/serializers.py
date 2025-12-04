from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password

from .models import Player


from django.core.mail import send_mail
from django.urls import reverse
from django.conf import settings
from .utils.send_email import generate_email_token


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    password2 = serializers.CharField(write_only=True)

    class Meta:
        model = Player
        fields = ['username', 'email', 'password', 'password2']

    def validate_email(self, value):
        if Player.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email zajęty")
        return value

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError(
                {"password": "hasla są inne"})

        validate_password(data['password'])
        return data

    def create(self, validated_data):
        validated_data.pop('password2')

        user = Player.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )

        # Konto nieaktywne dopóki użytkownik nie potwierdzi emaila
        user.is_active = False
        user.save()

        # generuj token
        token = generate_email_token(user)

        activation_link = f"http://localhost:8000/api/auth/verify-email/?token={token}"

        # wyślij email
        send_mail(
            subject="Aktywuj swoje konto",
            message=f"Kliknij w link aktywacyjny: {activation_link}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
        )

        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data['email']
        password = data['password']

        user = authenticate(email=email, password=password)

        if not user:
            try:
                user_check = Player.objects.get(email=email)
                if not user_check.is_active:
                    raise serializers.ValidationError(
                        "Konto nie zostało aktywowane. Sprawdź email.")
            except Player.DoesNotExist:
                pass
            raise serializers.ValidationError("Nieprawidłowe dane logowania")

        data['user'] = user
        return data
