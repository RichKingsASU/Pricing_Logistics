from django.contrib import admin
from django.urls import path, include
from .api_views import login_api, logout_api, auth_me

urlpatterns = [
    path('api/auth/me/', auth_me),
    path('api/auth/login/', login_api),
    path('api/auth/logout/', logout_api),
    path('admin/', admin.site.urls),
    path('accounts/', include('django.contrib.auth.urls')),
    path('rates/', include('rates.urls')),
    path('pricing/', include('pricing.urls')),
    path('customers/', include('customers.urls')),
    path('', include('rates.urls')),  # default route
]