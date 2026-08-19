from django.db import models
from django.contrib.auth.models import User

class MarketSummary(models.Model):
    name = models.CharField(max_length=100)
    region = models.CharField(max_length=10)
    avg_actual = models.DecimalField(max_digits=10, decimal_places=2)
    avg_target = models.DecimalField(max_digits=10, decimal_places=2)
    variance_dollars = models.DecimalField(max_digits=10, decimal_places=2)
    variance_percent = models.DecimalField(max_digits=5, decimal_places=2)
    loads = models.IntegerField()
    trend_status = models.CharField(max_length=50)
    status = models.CharField(max_length=50)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_markets')
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='updated_markets')

    def __str__(self):
        return self.name


class LaneException(models.Model):
    origin = models.CharField(max_length=100)
    destination = models.CharField(max_length=100)
    market = models.CharField(max_length=10)
    loads = models.IntegerField()
    current_target = models.DecimalField(max_digits=10, decimal_places=2)
    avg_actual = models.DecimalField(max_digits=10, decimal_places=2)
    var_dollars = models.DecimalField(max_digits=10, decimal_places=2)
    var_percent = models.DecimalField(max_digits=5, decimal_places=2)
    confidence = models.CharField(max_length=20)
    impact = models.CharField(max_length=20)
    adjustment_status = models.CharField(max_length=50, null=True, blank=True)
    last_adjusted_target = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    adjusted_date = models.DateField(null=True, blank=True)
    adjusted_notes = models.TextField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_exceptions')
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='updated_exceptions')

    def __str__(self):
        return f"{self.origin} to {self.destination} Exception"


class PricingAdjustment(models.Model):
    title = models.CharField(max_length=200)
    change_percent = models.DecimalField(max_digits=5, decimal_places=2)
    status = models.CharField(max_length=50)
    effective_date = models.DateField()
    notes = models.TextField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_adjustments')
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='updated_adjustments')

    class Meta:
        constraints = [
            models.CheckConstraint(condition=models.Q(change_percent__gte=-100), name='pricing_change_percent_min'),
        ]

    def __str__(self):
        return self.title
