from rest_framework import serializers
from django.contrib.auth import authenticate
from django.core.exceptions import ValidationError as DjangoValidationError
from django.contrib.auth.password_validation import validate_password as django_validate_password

from .models import Player


from django.core.mail import send_mail
from django.conf import settings
from .utils.send_email import generate_email_token


def validate_password(self, value):

    if len(value) < 8:
        raise serializers.ValidationError(
            "Hasło musi mieć co najmniej 8 znaków.")

    if value.isalpha():
        raise serializers.ValidationError(
            "Hasło nie może składać się tylko z liter.")

    try:
        validate_password(value)
    except DjangoValidationError as e:
        raise serializers.ValidationError("Hasło jest zbyt słabe.")

    return value


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    password2 = serializers.CharField(write_only=True)
    email = serializers.EmailField(
        error_messages={"invalid": "Podaj poprawny adres email."}
    )

    class Meta:
        model = Player
        fields = ['username', 'email', 'password', 'password2']

    def validate_email(self, value):
        if Player.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email zajęty")
        return value

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError(
                "Hasło musi mieć przynajmniej 8 znaków.")

        if value.isdigit():
            raise serializers.ValidationError(
                "Hasło nie może składać się tylko z cyfr.")
        if value.isalpha():
            raise serializers.ValidationError(
                "Hasło nie może składać się tylko z liter.")

        if " " in value:
            raise serializers.ValidationError(
                "Hasło nie może zawierać spacji.")

        return value

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError(
                {"password": "Hasła są różne."})

        # wywołujemy własną funkcję
        self.validate_password(data['password'])

        return data

    def create(self, validated_data):
        validated_data.pop('password2')

        user = Player.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )

        user.is_active = False
        user.save()

        token = generate_email_token(user)
        activation_link = f"http://localhost:8000/api/auth/verify-email/?token={token}"

        send_mail(
            subject="Aktywuj swoje konto",
            message=f"Kliknij w link aktywacyjny: {activation_link}",
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
        )

        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(
        error_messages={"invalid": "Podaj poprawny adres email."}
    )
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
