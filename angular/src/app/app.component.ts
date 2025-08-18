import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  template: `
    <div>
      <h1>SmartRestaurant App</h1>
      <router-outlet></router-outlet>
    </div>
  `,
  imports: [RouterOutlet],
})
export class AppComponent {}
