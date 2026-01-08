from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password

from .models import Player


class RegisterSerializer(serializers.ModelSerializer):

    password = serializers.CharField(write_only=True)

    class Meta:

        model = Player
        fields = ['username', 'email', 'password']

    def validate_password(self, value):
        validate_password(value, user=Player(**self.initial_data))
        return value

    def create(self, validated_data):

        user = Player(
            username=validated_data['username'],
            email=validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.is_active = True

        user.save()
        return user


class LoginSerializer(serializers.Serializer):

    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):

        user = authenticate(
            username=data['username'], password=data['password'])
        if not user:
            raise serializers.ValidationError('Invalid credentials')
        data['user'] = user
        return data
