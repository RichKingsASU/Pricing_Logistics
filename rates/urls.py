from django.urls import path
from . import views

urlpatterns = [
    path('', views.rate_directory, name='rate_directory'),
    path('add/', views.add_rate_lane, name='add_rate_lane'),
]
