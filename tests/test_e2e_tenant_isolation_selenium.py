import json
import requests
from django.contrib.staticfiles.testing import StaticLiveServerTestCase
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from django.contrib.auth.models import User
from customers.models import Organization
from rates.models import CustomerRateLane
from pricing.models import MarketSummary

class TenantIsolationSeleniumE2ETests(StaticLiveServerTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()

    def tearDown(self):
        self.selenium.quit()
        import shutil
        import time
        try:
            shutil.rmtree(self.temp_profile, ignore_errors=True)
        except Exception:
            pass
        super().tearDown()

    def setUp(self):
        import tempfile
        self.temp_profile = tempfile.mkdtemp()
        options = webdriver.ChromeOptions()
        options.add_argument('--headless=new')
        options.add_argument('--incognito')
        options.add_argument('--disable-gpu')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-save-password-bubble')
        options.add_argument('--disable-features=PasswordManagerOnboarding')
        options.add_argument(f'--user-data-dir={self.temp_profile}')

        options.add_experimental_option("prefs", {
            "credentials_enable_service": False,
            "profile.password_manager_enabled": False,
            "profile.password_manager_leak_detection": False,
            "autofill.profile_enabled": False,
            "autofill.credit_card_enabled": False,
        })
        self.selenium = webdriver.Chrome(options=options)
        self.selenium.implicitly_wait(5)
        self.selenium.delete_all_cookies()

        # Org A and User A
        self.org_a = Organization.objects.create(name='Org A')
        self.user_a = User.objects.create_user(username='testa@example.com', password='password123')
        self.org_a.users.add(self.user_a)

        self.lane_a = CustomerRateLane.objects.create(
            organization=self.org_a,
            lane_id='LANE-A',
            customer_name='Cust A',
            origin_city='O-A', origin_state='CA', raw_origin='O-A',
            destination_city='D-A', destination_state='CA', raw_destination='D-A',
            base_rate=100.0, equipment='Van', service_type='Standard', miles=100,
            effective_date='2026-01-01', expiration_date='2027-01-01',
            fuel_surcharge_percent=10, fuel_amount=10, total_billing=110
        )
        self.ms_a = MarketSummary.objects.create(organization=self.org_a, name='MS-A', region='NW', avg_actual=1, avg_target=1, variance_dollars=1, variance_percent=1, loads=1, trend_status='a', status='a')

        # Org B and User B
        self.org_b = Organization.objects.create(name='Org B')
        self.user_b = User.objects.create_user(username='testb@example.com', password='password123')
        self.org_b.users.add(self.user_b)

        self.lane_b = CustomerRateLane.objects.create(
            organization=self.org_b,
            lane_id='LANE-B',
            customer_name='Cust B',
            origin_city='O-B', origin_state='CA', raw_origin='O-B',
            destination_city='D-B', destination_state='CA', raw_destination='D-B',
            base_rate=200.0, equipment='Flatbed', service_type='Standard', miles=200,
            effective_date='2026-01-01', expiration_date='2027-01-01',
            fuel_surcharge_percent=10, fuel_amount=20, total_billing=220
        )
        self.ms_b = MarketSummary.objects.create(organization=self.org_b, name='MS-B', region='SW', avg_actual=1, avg_target=1, variance_dollars=1, variance_percent=1, loads=1, trend_status='b', status='b')

    def get_api_session(self):
        """Creates a requests.Session populated with cookies from Selenium."""
        session = requests.Session()
        for cookie in self.selenium.get_cookies():
            session.cookies.set(cookie['name'], cookie['value'])
        csrf_cookie = session.cookies.get('csrftoken')
        if csrf_cookie:
            session.headers.update({'X-CSRFToken': csrf_cookie})
        return session

    def login_user(self, email, password):
        from django.contrib.auth.models import User
        user_exists = User.objects.filter(username=email).exists()
        password_ok = False
        if user_exists:
            password_ok = User.objects.get(username=email).check_password(password)
        print(f"DEBUG: login_user email={email}, exists={user_exists}, password_ok={password_ok}")

        self.selenium.get(self.live_server_url + "/accounts/login/")
        username_field = WebDriverWait(self.selenium, 10).until(
            EC.presence_of_element_located((By.NAME, "username"))
        )
        from selenium.webdriver.common.keys import Keys
        username_field.click()
        username_field.send_keys(Keys.CONTROL, "a")
        username_field.send_keys(Keys.DELETE)
        username_field.send_keys(email)

        WebDriverWait(self.selenium, 5).until(
            lambda d: d.find_element(By.NAME, "username").get_attribute("value") == email
        )

        password_field = self.selenium.find_element(By.NAME, "password")
        password_field.click()
        password_field.send_keys(Keys.CONTROL, "a")
        password_field.send_keys(Keys.DELETE)
        password_field.send_keys(password)

        login_btn = self.selenium.find_element(By.CSS_SELECTOR, "button[type='submit']")
        login_btn.click()
        try:
            WebDriverWait(self.selenium, 10).until(
                EC.presence_of_element_located((By.CLASS_NAME, "top-nav"))
            )
        except Exception as e:
            print("LOGIN FAILED. Current URL:", self.selenium.current_url)
            print("Page Source:", self.selenium.page_source)
            raise e

    def logout_user(self):
        logout_button = WebDriverWait(self.selenium, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(normalize-space(), 'Logout')]"))
        )
        logout_button.click()
        # wait for login page to appear
        WebDriverWait(self.selenium, 10).until(
            EC.url_contains("/accounts/login")
        )
        # verify username field is visible, ensuring logout completed
        WebDriverWait(self.selenium, 10).until(
            EC.visibility_of_element_located((By.NAME, "username"))
        )

    def test_full_suite(self):
        # 1. Anonymous UI and API denial
        self.selenium.get(self.live_server_url + "/")
        email_input = WebDriverWait(self.selenium, 10).until(
            EC.visibility_of_element_located((By.NAME, "username"))
        )
        self.assertTrue(email_input.is_displayed())
        res = requests.get(self.live_server_url + '/api/customer_rate_lanes/')
        self.assertEqual(res.status_code, 401)

        # 2. Login User B and get CSRF
        self.login_user('testb@example.com', 'password123')
        session_b = self.get_api_session()
        res_b = session_b.get(self.live_server_url + '/api/customer_rate_lanes/')
        self.assertEqual(res_b.status_code, 200)

        # Logout User B
        self.logout_user()

        # 3. Login User A and same-tenant access
        self.login_user('testa@example.com', 'password123')
        session_a = self.get_api_session()
        post_data = {
            'lane_id': 'LANE-HACK', 'customer_name': 'Hacker', 'origin_city': 'O', 'origin_state': 'CA',
            'destination_city': 'D', 'destination_state': 'CA', 'base_rate': 100, 'equipment': 'Van',
            'service_type': 'Reg', 'miles': 100, 'effective_date': '2026-01-01', 'expiration_date': '2027-01-01',
            'organization_id': str(self.org_a.id)
        }
        res_post_org_a = session_a.post(self.live_server_url + '/api/customer_rate_lanes/', json=post_data)
        self.assertEqual(res_post_org_a.status_code, 201)

        # 4. Cross-tenant read denial
        res_a = session_a.get(self.live_server_url + '/api/customer_rate_lanes/')
        self.assertEqual(res_a.status_code, 200)
        data_a = res_a.json()
        self.assertEqual(len(data_a), 2)
        lanes = [d['lane_id'] for d in data_a]
        self.assertIn('LANE-HACK', lanes)
        self.assertIn('LANE-A', lanes)

        # 5. Cross-tenant mutation denial
        res_fake_org = session_a.get(f"{self.live_server_url}/api/customer_rate_lanes/?orgId={self.org_b.id}")
        self.assertIn(res_fake_org.status_code, [404, 403, 400])

        post_data['organization_id'] = str(self.org_b.id)
        res_post_org_b = session_a.post(self.live_server_url + '/api/customer_rate_lanes/', json=post_data)
        self.assertEqual(res_post_org_b.status_code, 404)

        res_patch_org_b = session_a.patch(f"{self.live_server_url}/api/customer_rate_lanes/{self.lane_a.id}/?orgId={self.org_a.id}", json={'organization_id': str(self.org_b.id)})
        self.assertEqual(res_patch_org_b.status_code, 400)

        res_malformed = session_a.get(f"{self.live_server_url}/api/customer_rate_lanes/?orgId=invalid-org-id")
        self.assertIn(res_malformed.status_code, [404, 400, 500])

        # 6. Server rendered isolation
        self.selenium.get(self.live_server_url + "/pricing/control-tower/")
        self.assertIn("MS-A", self.selenium.page_source)
        self.assertNotIn("MS-B", self.selenium.page_source)

        # 7. Real UI logout
        self.logout_user()
        session_after = self.get_api_session()
        res_after_logout = session_after.get(self.live_server_url + '/api/customer_rate_lanes/')
        self.assertEqual(res_after_logout.status_code, 401)

        # 8. Relogin after logout
        self.login_user('testa@example.com', 'password123')
        session_a_relogin = self.get_api_session()
        res_relogin = session_a_relogin.get(self.live_server_url + '/api/customer_rate_lanes/')
        self.assertEqual(res_relogin.status_code, 200)
