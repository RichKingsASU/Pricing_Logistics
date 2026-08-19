from django import forms
from .models import LaneException, PricingAdjustment
from rates.models import CustomerRateLane

class LaneExceptionForm(forms.ModelForm):
    class Meta:
        model = LaneException
        fields = '__all__'
        widgets = {
            'adjusted_date': forms.DateInput(attrs={'type': 'date'}),
        }

class PricingAdjustmentForm(forms.ModelForm):
    class Meta:
        model = PricingAdjustment
        fields = '__all__'
        widgets = {
            'effective_date': forms.DateInput(attrs={'type': 'date'}),
        }

class CustomerRateLaneForm(forms.ModelForm):
    class Meta:
        model = CustomerRateLane
        fields = '__all__'
        widgets = {
            'effective_date': forms.DateInput(attrs={'type': 'date'}),
            'expiration_date': forms.DateInput(attrs={'type': 'date'}),
            'review_date': forms.DateInput(attrs={'type': 'date'}),
        }
