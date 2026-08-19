from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('django.contrib.auth.urls')),
    path('rates/', include('rates.urls')),
    path('pricing/', include('pricing.urls')),
    path('', include('rates.urls')),  # default route
]
