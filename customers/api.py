import json
from django.http import JsonResponse
from customers.models import Organization

def get_current_organization(request):
    if not request.user.is_authenticated:
        return JsonResponse({'error': 'Not authenticated'}, status=401)
    
    orgs = request.user.organizations.all()
    if not orgs:
        return JsonResponse({'error': 'User has no organization'}, status=404)
    
    data = []
    for org in orgs:
        data.append({
            'id': str(org.id),
            'name': org.name
        })
        
    return JsonResponse(data, safe=False)
