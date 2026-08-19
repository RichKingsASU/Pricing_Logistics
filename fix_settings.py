import sys

with open('config/settings.py', 'r') as f:
    content = f.read()

content = content.replace("'ENGINE': 'django.db.backends.postgresql',", "'ENGINE': 'django.db.backends.sqlite3',")
content = content.replace("'NAME': 'pricing_logistics_dev',", "'NAME': str(BASE_DIR / 'db.sqlite3'),")
content = content.replace("'NAME': BASE_DIR / 'test_db.sqlite3',", "'NAME': str(BASE_DIR / 'test_db.sqlite3'),")

with open('config/settings.py', 'w') as f:
    f.write(content)
