from django.urls import path
from . import api

urlpatterns = [
    path('api/organizations/current/', api.get_current_organization, name='api_organizations_current'),
]
