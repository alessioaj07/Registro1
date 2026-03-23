import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { KeycloakService } from './services/keycloak.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'Registro Elettronico';
  roles: string[] = [];

  constructor(public keycloakService: KeycloakService, private router: Router) {}

  async ngOnInit() {
    await this.keycloakService.init();

    if (!this.keycloakService.isLoggedIn()) {
      this.keycloakService.login();
      return;
    }

    this.roles = this.keycloakService.getUserRoles();
    if (this.roles.includes('docente')) {
      this.router.navigate(['/docente']);
    } else if (this.roles.includes('studente')) {
      this.router.navigate(['/studente']);
    } else {
      this.router.navigate(['/accesso-negato']);
    }
  }

  login() {
    this.keycloakService.login();
  }

  logout() {
    this.keycloakService.logout();
  }
}
