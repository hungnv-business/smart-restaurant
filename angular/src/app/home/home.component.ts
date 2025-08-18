import { Component } from '@angular/core';

@Component({
  selector: 'app-home',
  template: `
    <div class="container mt-4">
      <h2>Welcome to SmartRestaurant</h2>
      <p>This is the home page of the Vietnamese Restaurant Management System.</p>
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">Getting Started</h5>
          <p class="card-text">The application is now running successfully without theme dependencies.</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .container {
      max-width: 800px;
    }
    .card {
      margin-top: 20px;
    }
  `]
})
export class HomeComponent {}
