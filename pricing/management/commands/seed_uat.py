import os
from django.core.management.base import BaseCommand
from rates.models import CustomerRateLane
from pricing.models import MarketSummary, LaneException, PricingAdjustment
from django.contrib.auth.models import User
from customers.models import Organization

class Command(BaseCommand):
    help = 'Seeds deterministic UAT data for testing.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--confirm-local-demo-seed',
            action='store_true',
            help='Required flag to confirm you are seeding the local demo environment',
        )

    def handle(self, *args, **options):
        if not options['confirm_local_demo_seed']:
            self.stderr.write(self.style.ERROR('You must pass --confirm-local-demo-seed to execute this command.'))
            return

        from django.conf import settings
        
        # Only run against local test/dev db
        if not settings.DEBUG and 'test' not in settings.DATABASES['default']['NAME'] and 'dev' not in settings.DATABASES['default']['NAME'] and 'db.sqlite3' not in str(settings.DATABASES['default']['NAME']):
            self.stderr.write(self.style.ERROR('Cannot run seed_uat against production database!'))
            return

        self.stdout.write("Starting UAT data seed...")

        # Clear existing
        CustomerRateLane.objects.all().delete()
        MarketSummary.objects.all().delete()
        LaneException.objects.all().delete()
        PricingAdjustment.objects.all().delete()
        Organization.objects.all().delete()
        User.objects.filter(username__in=['tenant_a_user', 'tenant_b_user']).delete()

        # Tenants
        org_a, _ = Organization.objects.get_or_create(name='Acme Logistics Corp')
        org_b, _ = Organization.objects.get_or_create(name='Globex Freight')

        uat_password = os.getenv('DEMO_PASSWORD', 'UatPassword123!')

        # Users - Tenant A
        uat_user_a, _ = User.objects.get_or_create(username='tenant_a_user', defaults={'email': 'user_a@example.com'})
        uat_user_a.set_password(uat_password)
        uat_user_a.save()
        org_a.users.add(uat_user_a)

        # Users - Tenant B
        uat_user_b, _ = User.objects.get_or_create(username='tenant_b_user', defaults={'email': 'user_b@example.com'})
        uat_user_b.set_password(uat_password)
        uat_user_b.save()
        org_b.users.add(uat_user_b)

        # 1. Lanes - Tenant A
        CustomerRateLane.objects.create(
            organization=org_a,
            lane_id='UAT-LANE-01',
            customer_name='Acme Corp',
            origin_city='Seattle',
            origin_state='WA',
            destination_city='Portland',
            destination_state='OR',
            base_rate=500.0,
            equipment='53ft Dry Van',
            service_type='Standard',
            miles=173,
            effective_date='2026-01-01',
            expiration_date='2026-12-31',
            fuel_surcharge_percent=14.5,
            fuel_amount=72.50,
            total_billing=572.50,
        )

        # 1. Lanes - Tenant B
        CustomerRateLane.objects.create(
            organization=org_b,
            lane_id='UAT-LANE-02',
            customer_name='Globex',
            origin_city='Los Angeles',
            origin_state='CA',
            destination_city='Las Vegas',
            destination_state='NV',
            base_rate=800.0,
            equipment='53ft Dry Van',
            service_type='Standard',
            miles=270,
            effective_date='2026-01-01',
            expiration_date='2026-12-31',
            fuel_surcharge_percent=14.5,
            fuel_amount=116.0,
            total_billing=916.0,
        )

        # 2. Market Summaries - Tenant A
        MarketSummary.objects.create(
            organization=org_a,
            name='Pacific Northwest',
            region='NW',
            avg_actual=550.0,
            avg_target=500.0,
            variance_dollars=50.0,
            variance_percent=10.0,
            loads=45,
            trend_status='Up',
            status='Active',
        )

        # 2. Market Summaries - Tenant B
        MarketSummary.objects.create(
            organization=org_b,
            name='Southwest',
            region='SW',
            avg_actual=800.0,
            avg_target=825.0,
            variance_dollars=-25.0,
            variance_percent=-3.03,
            loads=120,
            trend_status='Stable',
            status='Active',
        )

        # 3. Exceptions - Tenant A
        LaneException.objects.create(
            organization=org_a,
            origin='Seattle',
            destination='Portland',
            market='NW',
            loads=15,
            current_target=500.0,
            avg_actual=550.0,
            var_dollars=50.0,
            var_percent=10.0,
            confidence='High',
            impact='Medium',
            adjustment_status='Pending',
        )

        # 4. Adjustments - Tenant A
        PricingAdjustment.objects.create(
            organization=org_a,
            title='NW Fuel Surge',
            change_percent=5.0,
            status='Pending Approval',
            effective_date='2026-08-01',
            notes='Fuel surge in NW requires 5% target bump.',
        )

        self.stdout.write(self.style.SUCCESS('Successfully seeded UAT data.'))
