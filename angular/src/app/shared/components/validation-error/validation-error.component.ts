import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AbstractControl, FormControl } from '@angular/forms';

@Component({
  selector: 'app-validation-error',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (shouldShowError()) {
      <small class="text-red-500 text-sm flex items-center gap-1 mt-1">
        <i class="pi pi-exclamation-triangle"></i>
        {{ getErrorMessage() }}
      </small>
    }
  `,
})
export class ValidationErrorComponent {
  @Input() control!: AbstractControl | FormControl | null;
  @Input() fieldName: string = '';

  shouldShowError(): boolean {
    return !!(this.control && this.control.invalid && (this.control.dirty || this.control.touched));
  }

  getErrorMessage(): string {
    if (!this.control || !this.control.errors) {
      return '';
    }

    const errors = this.control.errors;

    // Default Vietnamese error messages
    if (errors['required']) {
      return `${this.fieldName} là bắt buộc`;
    }

    if (errors['email']) {
      return 'Email không hợp lệ';
    }

    if (errors['minlength']) {
      const requiredLength = errors['minlength'].requiredLength;
      return `${this.fieldName} phải có ít nhất ${requiredLength} ký tự`;
    }

    if (errors['maxlength']) {
      const requiredLength = errors['maxlength'].requiredLength;
      return `${this.fieldName} không được vượt quá ${requiredLength} ký tự`;
    }

    if (errors['min']) {
      return `${this.fieldName} phải lớn hơn hoặc bằng ${errors['min'].min}`;
    }

    if (errors['max']) {
      return `${this.fieldName} phải nhỏ hơn hoặc bằng ${errors['max'].max}`;
    }

    if (errors['pattern']) {
      return `${this.fieldName} không đúng định dạng`;
    }

    if (errors['phoneNumber']) {
      return 'Số điện thoại không hợp lệ';
    }

    if (errors['passwordMismatch']) {
      return 'Mật khẩu xác nhận không khớp';
    }

    // Generic fallback
    return `${this.fieldName} không hợp lệ`;
  }
}
