import json
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import ensure_csrf_cookie

@ensure_csrf_cookie
def auth_me(request):
    if request.user.is_authenticated:
        return JsonResponse({'status': 'authenticated', 'username': request.user.username})
    return JsonResponse({'status': 'unauthenticated'}, status=401)

@require_POST
def login_api(request):
    try:
        data = json.loads(request.body)
        # React sends email as username field, but Django models might use username
        username_or_email = data.get('username') or data.get('email')
        password = data.get('password')
        
        # Django's auth model by default uses username. 
        # We try to fetch the username by email if an email was passed.
        from django.contrib.auth.models import User
        if username_or_email and '@' in username_or_email:
            try:
                user_obj = User.objects.get(email=username_or_email)
                username_or_email = user_obj.username
            except User.DoesNotExist:
                pass
                
        user = authenticate(request, username=username_or_email, password=password)
        if user is not None:
            login(request, user)
            return JsonResponse({'status': 'success', 'user': {'username': user.username, 'email': user.email}})
        else:
            return JsonResponse({'error': 'Invalid credentials'}, status=401)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@require_POST
def logout_api(request):
    logout(request)
    return JsonResponse({'status': 'success'})
