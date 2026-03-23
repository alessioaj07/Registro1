import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-docente',
  templateUrl: './docente.component.html',
  styleUrls: ['./docente.component.css']
})
export class DocenteComponent implements OnInit {
  studentName = '';
  subject = '';
  grade = '';
  grades: any[] = [];
  error = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadGrades();
  }

  loadGrades() {
    this.api.getVotes().subscribe(
      (res) => {
        this.grades = res.grades;
      },
      (err) => {
        this.error = 'Errore caricamento voti';
      }
    );
  }

  addVote() {
    this.error = '';
    if (!this.studentName || !this.subject || !this.grade) {
      this.error = 'Compila tutti i campi prima di salvare.';
      return;
    }

    this.api.addVote(this.studentName, this.subject, this.grade).subscribe(
      () => {
        this.studentName = '';
        this.subject = '';
        this.grade = '';
        this.loadGrades();
      },
      (err) => {
        this.error = 'Errore durante salvataggio voto.';
      }
    );
  }
}
