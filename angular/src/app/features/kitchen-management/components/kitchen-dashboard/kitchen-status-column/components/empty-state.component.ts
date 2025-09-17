import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-empty-state',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="text-center p-4 text-600">
      <i [class]="iconClass" class="text-2xl mb-2"></i>
      <p class="m-0">{{ message }}</p>
    </div>
  `,
  styles: [`
    :host {
      display: block;
    }
  `]
})
export class EmptyStateComponent {
  @Input() message: string = 'Không có dữ liệu';
  @Input() icon: string = 'pi pi-check';

  get iconClass(): string {
    return `pi ${this.icon}`;
  }
}