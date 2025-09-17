import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BadgeModule } from 'primeng/badge';

@Component({
  selector: 'app-column-header',
  standalone: true,
  imports: [CommonModule, BadgeModule],
  template: `
    <div class="column-header p-3 border-round mb-3" [ngClass]="backgroundClass">
      <div class="flex">
        <i style="display: flex;" [class]="iconClass" class="text-lg flex items-center"></i>
        <h3 class="text-lg font-bold m-0 line-height-1 ml-2 mr-2" [ngClass]="textClass">{{ title }}</h3>
        <p-badge [value]="count.toString()" [severity]="badgeSeverity" badgeSize="large"> </p-badge>
      </div>
    </div>
  `,
  styles: [
    `
      :host {
        display: block;
      }
    `,
  ],
})
export class ColumnHeaderComponent {
  @Input() title: string = '';
  @Input() icon: string = '';
  @Input() count: number = 0;
  @Input() theme: 'blue' | 'orange' | 'green' = 'blue';
  @Input() badgeSeverity: 'info' | 'warning' | 'success' = 'info';

  get iconClass(): string {
    const colorClass =
      this.theme === 'blue'
        ? 'text-blue-600'
        : this.theme === 'orange'
          ? 'text-orange-600'
          : 'text-green-600';
    return `${this.icon} ${colorClass}`;
  }

  get backgroundClass(): string {
    return this.theme === 'blue'
      ? 'bg-blue-50'
      : this.theme === 'orange'
        ? 'bg-orange-50'
        : 'bg-green-50';
  }

  get textClass(): string {
    return this.theme === 'blue'
      ? 'text-blue-800'
      : this.theme === 'orange'
        ? 'text-orange-800'
        : 'text-green-800';
  }
}
