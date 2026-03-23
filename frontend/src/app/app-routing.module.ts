import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DocenteComponent } from './components/docente/docente.component';
import { StudenteComponent } from './components/studente/studente.component';
import { AccessoNegatoComponent } from './components/accesso-negato/accesso-negato.component';
import { TeacherGuard } from './guards/teacher.guard';
import { StudentGuard } from './guards/student.guard';

const routes: Routes = [
  { path: '', redirectTo: 'home', pathMatch: 'full' },
  { path: 'docente', component: DocenteComponent, canActivate: [TeacherGuard] },
  { path: 'studente', component: StudenteComponent, canActivate: [StudentGuard] },
  { path: 'accesso-negato', component: AccessoNegatoComponent },
  { path: '**', redirectTo: 'accesso-negato' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
