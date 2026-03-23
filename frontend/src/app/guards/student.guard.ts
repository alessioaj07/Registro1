import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { KeycloakService } from '../services/keycloak.service';

@Injectable({ providedIn: 'root' })
export class StudentGuard implements CanActivate {
  constructor(private keycloak: KeycloakService, private router: Router) {}

  canActivate(): boolean {
    const roles = this.keycloak.getUserRoles();
    if (this.keycloak.isLoggedIn() && roles.includes('studente')) {
      return true;
    }
    this.router.navigate(['/accesso-negato']);
    return false;
  }
}
