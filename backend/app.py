from flask import Flask, request, jsonify
from jose import jwt
import requests
from db_wrapper import DBWrapper
from config import KEYCLOAK_SERVER_URL, KEYCLOAK_REALM, KEYCLOAK_CLIENT_ID

app = Flask(__name__)

DB = DBWrapper()

KEYCLOAK_JWKS_URL = f"{KEYCLOAK_SERVER_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect/certs"
KEYCLOAK_ISS = f"{KEYCLOAK_SERVER_URL}/realms/{KEYCLOAK_REALM}"

_cached_jwks = None


def get_jwks():
    global _cached_jwks
    if _cached_jwks is None:
        r = requests.get(KEYCLOAK_JWKS_URL, timeout=5)
        r.raise_for_status()
        _cached_jwks = r.json()
    return _cached_jwks


def validate_token(token):
    jwks = get_jwks()
    try:
        claims = jwt.decode(
            token,
            jwks,
            algorithms=['RS256'],
            audience=KEYCLOAK_CLIENT_ID,
            issuer=KEYCLOAK_ISS,
        )
        return claims
    except Exception as e:
        raise ValueError(str(e))


def get_auth_info():
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Bearer '):
        return None
    token = auth.split(' ', 1)[1]
    claims = validate_token(token)

    roles = []
    realm_access = claims.get('realm_access', {})
    if isinstance(realm_access, dict):
        roles = realm_access.get('roles', [])

    username = claims.get('preferred_username') or claims.get('sub')
    return {'username': username, 'roles': roles}


def require_role(required):
    auth = get_auth_info()
    if not auth:
        return None, (jsonify({'error': 'Authorization header mancante o token non valido'}), 401)

    if required not in auth['roles']:
        return None, (jsonify({'error': 'Accesso negato, ruolo mancante'}), 403)
    return auth, None


@app.route('/api/votes', methods=['GET'])
def get_votes():
    auth, error = require_role('docente')
    if error:
        if auth is None:
            # maybe studente visibility
            auth = get_auth_info()
            if auth and 'studente' in auth['roles']:
                grades = DB.get_grades_for_student(auth['username'])
                return jsonify({'grades': grades})
            return error
        if isinstance(error, tuple) and error[1][1] == 403:
            # if docente role missing, maybe studente
            auth = get_auth_info()
            if auth and 'studente' in auth['roles']:
                grades = DB.get_grades_for_student(auth['username'])
                return jsonify({'grades': grades})
        return error

    grades = DB.get_all_grades()
    return jsonify({'grades': grades})


@app.route('/api/votes', methods=['POST'])
def post_vote():
    auth, error = require_role('docente')
    if error:
        return error

    data = request.get_json() or {}
    student_name = data.get('student_name')
    subject = data.get('subject')
    grade = data.get('grade')

    if not student_name or not subject or not grade:
        return jsonify({'error': 'Campi mancanti'}), 400

    inserted_id = DB.add_grade(student_name, subject, grade)
    return jsonify({'message': 'Voto aggiunto', 'id': inserted_id}), 201


@app.route('/api/accesso-negato')
def accesso_negato():
    return jsonify({'error': 'Accesso negato. Sei finito su /accesso-negato'}), 403


@app.route('/api/health')
def health():
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
