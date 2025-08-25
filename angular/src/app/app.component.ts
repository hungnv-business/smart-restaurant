import { Component, inject, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { LayoutService } from './layout/service/layout.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterModule],
  template: `<router-outlet></router-outlet>`,
})
export class AppComponent implements OnInit {
  layoutService = inject(LayoutService);

  ngOnInit() {
    this.layoutService.updateBodyBackground(this.layoutService.layoutConfig().primary);
  }
}
