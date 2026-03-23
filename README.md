# Registro Elettronico (Angular + Flask + Keycloak)

Progetto sample per un Registro elettronico con ruoli `docente` e `studente`.

## Struttura
- `backend/`: Flask + PyMySQL + verifica token Keycloak
- `frontend/`: Angular con componenti `Docente`, `Studente`, `AccessoNegato`, guardie e servizi

## Setup (Backend)
1. Crea database MySQL con `backend/setup.sql`.
2. Installa dipendenze Python:
   - `pip install -r backend/requirements.txt`
3. Imposta variabili d'ambiente se serve (default in `backend/config.py`).
4. Avvia con:
   - `python backend/app.py`

## Setup (Frontend)
1. Posizionati in `frontend/`.
2. Installa con `npm install`.
3. Avvia con `npm start`.

## Keycloak
1. Crea Realm `registro-realm`.
2. Crea Client `registro-client` con `Access Type`=public.
3. Crea ruoli Realm `docente` e `studente`.
4. Crea utenti:
   - docente: ruolo `docente`
   - studente: ruolo `studente`
5. Imposta redirect URI del client su `http://localhost:4200/*`.

## Funzionalità
- docente: inserisce voti e visualizza voti di tutti
- studente: visualizza solo i propri voti
- guardie `TeacherGuard` / `StudentGuard` con redirect `/accesso-negato`
- API `/api/votes` protetta, `/api/accesso-negato` pagina simpatica

## NOTE
- Per usare Keycloak dal frontend, includere `silent-check-sso.html` in `src/assets/` (contenuto vuoto o JS).
- Puoi usare import Keycloak da `keycloak-js`.
