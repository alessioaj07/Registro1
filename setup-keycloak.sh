#!/bin/bash
set -e

KEYCLOAK_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
REALM_NAME="registro-realm"
CLIENT_ID="registro-client"

echo "=== Configurazione automatica Keycloak ==="

# Step 1: Get admin token
echo "1. Ottenere admin token..."
ADMIN_TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASSWORD" \
  | jq -r '.access_token')

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" = "null" ]; then
  echo "ERRORE: Non riesco a ottenere il token admin"
  exit 1
fi
echo "✓ Token ottenuto"

# Step 2: Crea il Realm
echo "2. Creazione Realm '$REALM_NAME'..."
REALM_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
  -H "Authorization: Bearer $ADMIN_TOKEN")

if [ "$REALM_CHECK" = "404" ]; then
  curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "realm": "'$REALM_NAME'",
      "enabled": true,
      "accessTokenLifespan": 3600
    }' > /dev/null
  echo "✓ Realm creato"
else
  echo "✓ Realm già esiste"
fi

# Step 3: Crea il Client
echo "3. Creazione Client '$CLIENT_ID'..."
CLIENT_CHECK=$(curl -s "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq ".[] | select(.clientId==\"$CLIENT_ID\") | .id" -r)

if [ -z "$CLIENT_CHECK" ] || [ "$CLIENT_CHECK" = "null" ]; then
  curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "realm": "'$REALM_NAME'",
      "clientId": "'$CLIENT_ID'",
      "enabled": true,
      "publicClient": true,
      "redirectUris": ["http://localhost:4200/*"],
      "webOrigins": ["http://localhost:4200"],
      "directAccessGrantsEnabled": true,
      "standardFlowEnabled": true,
      "implicitFlowEnabled": false
    }' > /dev/null
  echo "✓ Client creato"
else
  echo "✓ Client già esiste"
fi

# Step 4: Crea i ruoli
echo "4. Creazione ruoli..."
for ROLE in "docente" "studente"; do
  ROLE_CHECK=$(curl -s "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" \
    -H "Authorization: Bearer $ADMIN_TOKEN" | jq ".[] | select(.name==\"$ROLE\") | .name" -r)
  
  if [ -z "$ROLE_CHECK" ] || [ "$ROLE_CHECK" = "null" ]; then
    curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "'$ROLE'",
        "enabled": true
      }' > /dev/null
    echo "  ✓ Ruolo '$ROLE' creato"
  else
    echo "  ✓ Ruolo '$ROLE' già esiste"
  fi
done

# Step 5: Crea gli utenti
echo "5. Creazione utenti..."
declare -A users=( ["docente_test"]="docente" ["studente_test"]="studente" )

for username in "${!users[@]}"; do
  role="${users[$username]}"
  
  USER_CHECK=$(curl -s "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
    -H "Authorization: Bearer $ADMIN_TOKEN" | jq ".[] | select(.username==\"$username\") | .id" -r)
  
  if [ -z "$USER_CHECK" ] || [ "$USER_CHECK" = "null" ]; then
    USER_RESPONSE=$(curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "username": "'$username'",
        "email": "'$username'@test.it",
        "enabled": true,
        "firstName": "'${username%_*}'",
        "credentials": [{
          "type": "password",
          "value": "password123",
          "temporary": false
        }]
      }')
    
    USER_ID=$(echo "$USER_RESPONSE" | jq -r '.id // .id' 2>/dev/null)
    
    # Se la risposta è 409 o esiste già, cerchiamo l'ID
    if [ -z "$USER_ID" ] || [ "$USER_ID" = "null" ]; then
      USER_ID=$(curl -s "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=$username" \
        -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.[0].id')
    fi
    
    # Assegna il ruolo
    if [ ! -z "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
      curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$USER_ID/role-mappings/realm" \
        -H "Authorization: Bearer $ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d '[{"name": "'$role'"}]' > /dev/null
      echo "  ✓ Utente '$username' creato con ruolo '$role'"
    fi
  else
    echo "  ✓ Utente '$username' già esiste"
  fi
done

echo ""
echo "=== ✓ SETUP COMPLETATO ==="
echo ""
echo "Accesso Keycloak Admin:"
echo "  URL: http://localhost:8080"
echo "  User: admin"
echo "  Password: admin"
echo ""
echo "Utenti di test:"
echo "  docente_test / password123 (ruolo: docente)"
echo "  studente_test / password123 (ruolo: studente)"
echo ""
echo "Accedi a: http://localhost:4200"
