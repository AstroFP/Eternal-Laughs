from django.conf import settings
from django.conf.urls.static import static

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

    path('api/payments/', include('apps.payments.urls')),
    path('api/auth/', include('apps.users.urls')),
    path('shop/', include('apps.items.urls')),
    path('inventory/', include('apps.inventory.urls')),

]

urlpatterns += static('/equipment/', document_root='equipment')