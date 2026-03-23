import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-studente',
  templateUrl: './studente.component.html',
  styleUrls: ['./studente.component.css']
})
export class StudenteComponent implements OnInit {
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
        this.error = 'Errore caricamento voti.';
      }
    );
  }
}
