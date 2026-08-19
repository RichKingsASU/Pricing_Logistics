from django.db import models
from django.contrib.auth.models import User

class CustomerRateLane(models.Model):
    STATUS_CHOICES = [
        ('AWARDED', 'AWARDED'),
        ('BACKUP', 'BACKUP'),
        ('SPOT', 'SPOT'),
    ]
    ACTIVE_STATE_CHOICES = [
        ('Active', 'Active'),
        ('Future', 'Future'),
        ('Expired', 'Expired'),
    ]

    lane_id = models.CharField(max_length=100, unique=True)
    customer_name = models.CharField(max_length=200)
    
    origin_city = models.CharField(max_length=100)
    origin_state = models.CharField(max_length=2)
    raw_origin = models.CharField(max_length=200)
    
    destination_city = models.CharField(max_length=100)
    destination_state = models.CharField(max_length=2)
    raw_destination = models.CharField(max_length=200)
    
    base_rate = models.DecimalField(max_digits=10, decimal_places=2)
    equipment = models.CharField(max_length=100)
    service_type = models.CharField(max_length=100)
    miles = models.IntegerField()
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='AWARDED')
    active_state = models.CharField(max_length=20, choices=ACTIVE_STATE_CHOICES, default='Active')
    
    effective_date = models.DateField()
    expiration_date = models.DateField()
    review_date = models.DateField(null=True, blank=True)
    
    fuel_surcharge_percent = models.DecimalField(max_digits=5, decimal_places=2)
    fuel_amount = models.DecimalField(max_digits=10, decimal_places=2)
    total_billing = models.DecimalField(max_digits=10, decimal_places=2)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_lanes')
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='updated_lanes')
    
    class Meta:
        constraints = [
            models.CheckConstraint(condition=models.Q(base_rate__gte=0), name='rates_base_rate_non_negative'),
            models.CheckConstraint(condition=models.Q(miles__gte=0), name='rates_miles_non_negative'),
        ]

    def __str__(self):
        return f"{self.customer_name}: {self.origin_city} to {self.destination_city}"
