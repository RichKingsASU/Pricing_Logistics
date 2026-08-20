import json
from django.http import JsonResponse
from pricing.models import MarketSummary, LaneException, PricingAdjustment
from customers.decorators import resolve_user_organization, OrganizationRequiredError, OrganizationUnauthorizedError

def _resolve_org_helper(request):
    try:
        org_id = request.GET.get('orgId') or (json.loads(request.body).get('organization_id') if request.body else None)
        org = resolve_user_organization(request, supplied_org_id=org_id)
        return org, None
    except (OrganizationRequiredError, ValueError) as e:
        return None, JsonResponse({'error': str(e)}, status=404)
    except OrganizationUnauthorizedError as e:
        if not request.user.is_authenticated:
            return None, JsonResponse({'error': 'Not authenticated'}, status=401)
        return None, JsonResponse({'error': str(e)}, status=404)

def market_summaries_api(request, pk=None):
    org, err_resp = _resolve_org_helper(request)
    if err_resp:
        return err_resp
        
    if request.method == 'GET':
        qs = MarketSummary.objects.filter(organization=org)
        data = []
        for ms in qs:
            data.append({
                'id': str(ms.id),
                'organization_id': str(ms.organization_id),
                'name': ms.name,
                'region': ms.region,
                'avg_actual': float(ms.avg_actual),
                'avg_target': float(ms.avg_target),
                'variance_dollars': float(ms.variance_dollars),
                'variance_percent': float(ms.variance_percent),
                'loads': ms.loads,
                'trend_status': ms.trend_status,
                'status': ms.status
            })
        return JsonResponse(data, safe=False)
    
    elif request.method == 'PATCH':
        if not pk:
            return JsonResponse({'error': 'Missing ID for update'}, status=400)
        try:
            ms = MarketSummary.objects.get(pk=pk, organization=org)
            body = json.loads(request.body)
            if 'organization_id' in body and body['organization_id'] != str(org.id):
                return JsonResponse({'error': 'Cannot change organization'}, status=400)
            for k, v in body.items():
                if hasattr(ms, k) and k != 'id' and k != 'organization_id':
                    setattr(ms, k, v)
            ms.save()
            return JsonResponse({'status': 'success'})
        except MarketSummary.DoesNotExist:
            return JsonResponse({'error': 'Not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
            
    return JsonResponse({'error': 'Method not allowed'}, status=405)


def lane_exceptions_api(request, pk=None):
    org, err_resp = _resolve_org_helper(request)
    if err_resp:
        return err_resp
        
    if request.method == 'GET':
        qs = LaneException.objects.filter(organization=org)
        data = []
        for le in qs:
            data.append({
                'id': str(le.id),
                'organization_id': str(le.organization_id),
                'origin': le.origin,
                'destination': le.destination,
                'market': le.market,
                'loads': le.loads,
                'current_target': float(le.current_target),
                'avg_actual': float(le.avg_actual),
                'var_dollars': float(le.var_dollars),
                'var_percent': float(le.var_percent),
                'confidence': le.confidence,
                'impact': le.impact,
                'adjustment_status': le.adjustment_status
            })
        return JsonResponse(data, safe=False)
        
    elif request.method == 'PATCH':
        if not pk:
            return JsonResponse({'error': 'Missing ID for update'}, status=400)
        try:
            le = LaneException.objects.get(pk=pk, organization=org)
            body = json.loads(request.body)
            if 'organization_id' in body and body['organization_id'] != str(org.id):
                return JsonResponse({'error': 'Cannot change organization'}, status=400)
            for k, v in body.items():
                if hasattr(le, k) and k != 'id' and k != 'organization_id':
                    setattr(le, k, v)
            le.save()
            return JsonResponse({'status': 'success'})
        except LaneException.DoesNotExist:
            return JsonResponse({'error': 'Not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
            
    return JsonResponse({'error': 'Method not allowed'}, status=405)


def pricing_adjustments_api(request):
    org, err_resp = _resolve_org_helper(request)
    if err_resp:
        return err_resp
        
    if request.method == 'GET':
        qs = PricingAdjustment.objects.filter(organization=org)
        data = []
        for pa in qs:
            data.append({
                'id': str(pa.id),
                'organization_id': str(pa.organization_id),
                'title': pa.title,
                'change_percent': float(pa.change_percent),
                'status': pa.status,
                'effective_date': pa.effective_date.isoformat() if pa.effective_date else None,
                'notes': pa.notes
            })
        return JsonResponse(data, safe=False)
        
    elif request.method == 'POST':
        try:
            body = json.loads(request.body)
            if str(org.id) != body.get('organization_id') and 'organization_id' in body:
                return JsonResponse({'error': 'Cannot create for different org'}, status=404)
            pa = PricingAdjustment.objects.create(
                organization=org,
                title=body.get('title', ''),
                change_percent=body.get('change_percent', 0.0),
                status=body.get('status', 'Pending'),
                effective_date=body.get('effective_date'),
                notes=body.get('notes', '')
            )
            return JsonResponse({'id': str(pa.id), 'status': 'success'}, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=400)
            
    return JsonResponse({'error': 'Method not allowed'}, status=405)
