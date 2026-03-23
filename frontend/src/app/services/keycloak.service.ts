import { Injectable } from '@angular/core';
import Keycloak from 'keycloak-js';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class KeycloakService {
  private keycloak: Keycloak.KeycloakInstance;

  constructor() {
    this.keycloak = new Keycloak({
      url: environment.keycloak.url,
      realm: environment.keycloak.realm,
      clientId: environment.keycloak.clientId
    });
  }

  async init(): Promise<void> {
    try {
      await this.keycloak.init({ onLoad: 'check-sso', silentCheckSsoRedirectUri: window.location.origin + '/assets/silent-check-sso.html' });
    } catch (err) {
      console.error('Errore inizializzazione Keycloak', err);
    }
  }

  login(): void {
    this.keycloak.login();
  }

  logout(): void {
    this.keycloak.logout({ redirectUri: window.location.origin });
  }

  isLoggedIn(): boolean {
    return this.keycloak.authenticated || false;
  }

  getToken(): Promise<string> {
    return this.keycloak.updateToken(30).then(() => this.keycloak.token as string);
  }

  getUserRoles(): string[] {
    const realmRoles = this.keycloak.realmAccess?.roles || [];
    return realmRoles;
  }

  getUsername(): string {
    return this.keycloak.tokenParsed?.preferred_username || this.keycloak.tokenParsed?.sub || '';
  }
}
