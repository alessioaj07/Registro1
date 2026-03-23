import os

DB_HOST = os.getenv('DB_HOST', '127.0.0.1')
DB_PORT = int(os.getenv('DB_PORT', '3306'))
DB_USER = os.getenv('DB_USER', 'registro_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'registro_pass')
DB_NAME = os.getenv('DB_NAME', 'registro')

KEYCLOAK_SERVER_URL = os.getenv('KEYCLOAK_SERVER_URL', 'http://localhost:8080')
KEYCLOAK_REALM = os.getenv('KEYCLOAK_REALM', 'registro-realm')
KEYCLOAK_CLIENT_ID = os.getenv('KEYCLOAK_CLIENT_ID', 'registro-client')

CORS_ORIGINS = os.getenv('CORS_ORIGINS', 'http://localhost:4200').split(',')
