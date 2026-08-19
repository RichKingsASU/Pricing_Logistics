from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from pricing.models import LaneException, PricingAdjustment
from rates.models import CustomerRateLane
from pricing.forms import LaneExceptionForm, PricingAdjustmentForm, CustomerRateLaneForm

@login_required
def data_management(request):
    tab = request.GET.get('tab', 'lanes')
    
    # Base querysets
    lanes = CustomerRateLane.objects.all()
    adjustments = PricingAdjustment.objects.all()
    exceptions = LaneException.objects.all()
    
    context = {
        'tab': tab,
        'lanes': lanes,
        'adjustments': adjustments,
        'exceptions': exceptions,
    }
    return render(request, 'pricing/data_management.html', context)

from django.db import transaction

@login_required
@transaction.atomic
def edit_lane(request, lane_id):
    lane = get_object_or_404(CustomerRateLane, pk=lane_id)
    if request.method == 'POST':
        form = CustomerRateLaneForm(request.POST, instance=lane)
        if form.is_valid():
            form.save()
            messages.success(request, 'Lane updated successfully.')
            return redirect('/pricing/data-management/?tab=lanes')
    else:
        form = CustomerRateLaneForm(instance=lane)
    
    return render(request, 'pricing/generic_form.html', {'form': form, 'title': 'Edit Lane', 'back_url': '/pricing/data-management/?tab=lanes'})

@login_required
def edit_adjustment(request, pk):
    adjustment = get_object_or_404(PricingAdjustment, pk=pk)
    if request.method == 'POST':
        form = PricingAdjustmentForm(request.POST, instance=adjustment)
        if form.is_valid():
            form.save()
            messages.success(request, 'Adjustment updated successfully.')
            return redirect('/pricing/data-management/?tab=adjustments')
    else:
        form = PricingAdjustmentForm(instance=adjustment)
        
    return render(request, 'pricing/generic_form.html', {'form': form, 'title': 'Edit Adjustment', 'back_url': '/pricing/data-management/?tab=adjustments'})

@login_required
def edit_exception(request, pk):
    exception = get_object_or_404(LaneException, pk=pk)
    if request.method == 'POST':
        form = LaneExceptionForm(request.POST, instance=exception)
        if form.is_valid():
            form.save()
            messages.success(request, 'Exception updated successfully.')
            return redirect('/pricing/data-management/?tab=exceptions')
    else:
        form = LaneExceptionForm(instance=exception)
        
    return render(request, 'pricing/generic_form.html', {'form': form, 'title': 'Edit Exception', 'back_url': '/pricing/data-management/?tab=exceptions'})
