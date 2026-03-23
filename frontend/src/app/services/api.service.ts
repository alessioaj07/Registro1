import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  getVotes() {
    return this.http.get<{ grades: any[] }>(`${this.baseUrl}/votes`);
  }

  addVote(student_name: string, subject: string, grade: string) {
    return this.http.post(`${this.baseUrl}/votes`, { student_name, subject, grade });
  }
}
