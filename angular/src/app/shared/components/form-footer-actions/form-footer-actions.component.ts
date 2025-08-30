import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-form-footer-actions',
  standalone: true,
  imports: [CommonModule, ButtonModule],
  template: `
    <div class="flex justify-end gap-2 pt-4">
      @if (showSave) {
        <p-button
          [label]="'Lưu'"
          [icon]="'pi pi-check'"
          [disabled]="disabled || loading"
          [loading]="loading"
          (click)="onSave()"
        />
      }

      <p-button
        [label]="'Huỷ'"
        [icon]="'pi pi-times'"
        severity="secondary"
        [disabled]="loading"
        (click)="onCancel()"
      />
    </div>
  `,
})
export class FormFooterActionsComponent {
  @Input() disabled = false;
  @Input() loading = false;
  @Input() showSave = true;

  @Output() formSave = new EventEmitter<void>();
  @Output() formCancel = new EventEmitter<void>();

  onSave(): void {
    this.formSave.emit();
  }

  onCancel(): void {
    this.formCancel.emit();
  }
}
