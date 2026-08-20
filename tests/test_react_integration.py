import unittest
import subprocess
import time
import os
import requests
import socket
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def wait_for_port(port, host='127.0.0.1', timeout=15):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            with socket.create_connection((host, port), timeout=1):
                return True
        except (socket.timeout, ConnectionRefusedError):
            time.sleep(0.5)
    return False

class ReactIntegrationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # 1. Seed DB
        print("Seeding UAT DB...")
        subprocess.run(
            ['.venv\\Scripts\\python', 'manage.py', 'seed_uat', '--confirm-local-demo-seed'], 
            check=True,
            env={**os.environ, 'DEMO_PASSWORD': 'DemoPassword123!'}
        )
        
        # 2. Start Django
        print("Starting Django server on 8000...")
        cls.django_log = open('django.log', 'w')
        cls.django_proc = subprocess.Popen(
            ['.venv\\Scripts\\python', 'manage.py', 'runserver', '8000'],
            stdout=cls.django_log,
            stderr=cls.django_log
        )
        wait_for_port(8000)
        
        # 3. Start Vite
        print("Starting Vite server on 5173...")
        cls.vite_log = open('vite.log', 'w')
        cls.vite_proc = subprocess.Popen(
            'npm run dev',
            stdout=cls.vite_log,
            stderr=cls.vite_log,
            shell=True
        )
        print("Waiting 10 seconds for Vite to start...")
        time.sleep(10)
        
        # 4. Setup Chrome
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--window-size=1920,1080')
        # We explicitly don't provide Supabase env variables!
        cls.driver = webdriver.Chrome(options=options)
        cls.driver.implicitly_wait(5)
        
    @classmethod
    def tearDownClass(cls):
        cls.driver.quit()
        cls.django_proc.terminate()
        # npm run dev starts a tree, on windows we might need taskkill
        subprocess.run(['taskkill', '/F', '/T', '/PID', str(cls.vite_proc.pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
    def test_end_to_end_tenant_isolation(self):
        driver = self.driver
        
        # ---- Log in as Tenant A ----
        driver.get('http://127.0.0.1:3000')
        
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "email"))
        ).send_keys("tenant_a_user")
        
        driver.find_element(By.ID, "password").send_keys("DemoPassword123!")
        driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
        
        try:
            WebDriverWait(driver, 10).until(
                EC.text_to_be_present_in_element((By.TAG_NAME, "body"), "Pacific Northwest")
            )
        except Exception as e:
            driver.save_screenshot('timeout_screenshot_1.png')
            print("Failed to find Pacific Northwest! Body text:", driver.find_element(By.TAG_NAME, "body").text)
            print("Browser logs:")
            for entry in driver.get_log('browser'):
                print(entry)
            raise e
        
        # Verify Tenant A data (Acme Corp / Pacific Northwest)
        body_text = driver.find_element(By.TAG_NAME, "body").text
        self.assertIn("Pacific Northwest", body_text)
        self.assertNotIn("Globex", body_text)
        
        # ---- Log out ----
        driver.find_element(By.XPATH, "//span[text()='Log Out']").click()
        WebDriverWait(driver, 10).until(EC.alert_is_present()).accept()
        
        # Wait for login page
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "email"))
        )
        
        # ---- Log in as Tenant B ----
        driver.find_element(By.ID, "email").send_keys("tenant_b_user")
        driver.find_element(By.ID, "password").send_keys("DemoPassword123!")
        driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
        
        # Wait for control tower dashboard to load
        WebDriverWait(driver, 10).until(
            EC.text_to_be_present_in_element((By.TAG_NAME, "body"), "Southwest")
        )
        
        # Verify Tenant B data (Globex / Southwest)
        body_text = driver.find_element(By.TAG_NAME, "body").text
        self.assertIn("Southwest", body_text)
        self.assertNotIn("Acme Corp", body_text)

if __name__ == '__main__':
    unittest.main()
