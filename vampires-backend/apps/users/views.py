from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import LoginSerializer, RegisterSerializer
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .utils.send_email import validate_email_token, send_activation_email


@method_decorator(csrf_exempt, name='dispatch')
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.save()

        send_activation_email(user, request)

        return Response(
            {"message": "Rejestracja zakończona. Sprawdź email."},
            status=201
        )


@method_decorator(csrf_exempt, name='dispatch')
class VerifyEmailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        token = request.query_params.get("token")

        if not token:
            return Response({"detail": "Brak tokena"}, status=400)

        user = validate_email_token(token)

        if not user:
            return Response({"detail": "Błąd tokena"}, status=400)

        user.is_active = True
        user.save()

        return Response({"detail": "Konto aktywowane pomyślnie"}, status=200)


@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data['user']

        refresh = RefreshToken.for_user(user)

        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'email': user.email,
            'username': user.username

        })
