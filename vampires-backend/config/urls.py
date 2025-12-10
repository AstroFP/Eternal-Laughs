
from django.contrib import admin
from django.urls import path
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/token/', TokenObtainPairView.as_view(),
         name='token_obtain_pair'),
    path('api/auth/token/refresh/',
         TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/token/verify/', TokenVerifyView.as_view(), name='token_verify'),

    # App endpoints
    # path('api/users/', include('apps.users.urls')),
    path('api/economy/', include('apps.economy.urls')),
    path('api/metagame/', include('apps.metagame.urls')),
    path('api/payments/', include('apps.payments.urls')),
    path('api/auth/', include('apps.users.urls')),
    path('shop/', include('apps.items.urls')),
    path('inventory/', include('apps.inventory.urls')),

]
