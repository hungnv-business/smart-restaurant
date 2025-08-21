import { Directive, OnDestroy, inject } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';
import { Subject } from 'rxjs';
import { ToastService } from '../services/toast.service';
import { PermissionService } from '@abp/ng.core';

@Directive()
export abstract class ComponentBase implements OnDestroy {
  private destroy$ = new Subject<void>();
  protected toastService = inject(ToastService);
  protected permissionService = inject(PermissionService);

  pageSize = 10;
  rowsPerPageOptions = [10, 20, 30, 50, 100];
  showCurrentPageReport = false;
  paginator = false;
  rowHover = true;
  // Common role labels in Vietnamese
  protected readonly ROLE_LABELS = {
    Admin: 'Quản trị viên',
    Owner: 'Chủ nhà hàng',
    Waiter: 'Nhân viên phục vụ',
    Kitchen: 'Nhân viên bếp',
    Cashier: 'Thu ngân',
    Customer: 'Khách hàng',
  };

  /**
   * Observable to handle component destruction and unsubscribe from observables
   */
  protected get destroyed$() {
    return this.destroy$.asObservable();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  /**
   * Check if a form field is invalid and should show error
   */
  protected isFieldInvalid(form: FormGroup, fieldName: string): boolean {
    const field = form.get(fieldName);
    return !!(field && field.invalid && (field.dirty || field.touched));
  }

  /**
   * Get FormControl from FormGroup with proper typing
   */
  protected getFormControl(form: FormGroup, fieldName: string): FormControl {
    return form.get(fieldName) as FormControl;
  }

  /**
   * Mark all form fields as touched to trigger validation display
   */
  protected markFormGroupTouched(form: FormGroup): void {
    Object.keys(form.controls).forEach(key => {
      const control = form.get(key);
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      } else {
        control?.markAsTouched();
      }
    });
  }

  /**
   * Show success message
   */
  protected showSuccess(summary: string, detail?: string): void {
    this.toastService.showSuccess(summary, detail);
  }

  /**
   * Show error message
   */
  protected showError(summary: string, detail?: string): void {
    this.toastService.showError(summary, detail);
  }

  /**
   * Show warning message
   */
  protected showWarning(summary: string, detail?: string): void {
    this.toastService.showWarning(summary, detail);
  }

  /**
   * Show info message
   */
  protected showInfo(summary: string, detail?: string): void {
    this.toastService.showInfo(summary, detail);
  }

  /**
   * Reset form and clear validation errors
   */
  protected resetForm(form: FormGroup): void {
    form.reset();
    this.clearFormErrors(form);
  }

  /**
   * Clear all validation errors from form
   */
  protected clearFormErrors(form: FormGroup): void {
    Object.keys(form.controls).forEach(key => {
      const control = form.get(key);
      if (control instanceof FormGroup) {
        this.clearFormErrors(control);
      } else {
        control?.markAsUntouched();
        control?.markAsPristine();
      }
    });
  }

  /**
   * Handle API errors with user-friendly messages in Vietnamese
   */
  protected handleApiError(
    error: any,
    defaultMessage: string = 'Có lỗi xảy ra. Vui lòng thử lại.'
  ): void {
    console.error('API Error:', error);

    let errorMessage = defaultMessage;

    // Handle specific error cases
    if (error.error?.error?.message) {
      errorMessage = error.error.error.message;
    } else if (error.status === 400) {
      errorMessage = 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    } else if (error.status === 401) {
      errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (error.status === 403) {
      errorMessage = 'Bạn không có quyền thực hiện thao tác này.';
    } else if (error.status === 404) {
      errorMessage = 'Không tìm thấy dữ liệu yêu cầu.';
    } else if (error.status === 500) {
      errorMessage = 'Lỗi máy chủ. Vui lòng liên hệ quản trị viên.';
    } else if (error.status === 0) {
      errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    }

    this.showError('Có lỗi xảy ra', errorMessage);
  }

  /**
   * Check if form is valid and show error if not
   */
  protected validateForm(
    form: FormGroup,
    errorMessage: string = 'Vui lòng điền đầy đủ thông tin bắt buộc'
  ): boolean {
    if (form.invalid) {
      this.markFormGroupTouched(form);
      this.showWarning('Thông tin chưa đầy đủ', errorMessage);
      return false;
    }
    return true;
  }

  /**
   * Get error message for a specific form field
   */
  protected getFieldErrorMessage(form: FormGroup, fieldName: string, displayName: string): string {
    const control = form.get(fieldName);
    if (!control || !control.errors) {
      return '';
    }

    const errors = control.errors;

    if (errors['required']) {
      return `${displayName} là bắt buộc`;
    }

    if (errors['email']) {
      return 'Email không hợp lệ';
    }

    if (errors['minlength']) {
      const requiredLength = errors['minlength'].requiredLength;
      return `${displayName} phải có ít nhất ${requiredLength} ký tự`;
    }

    if (errors['maxlength']) {
      const requiredLength = errors['maxlength'].requiredLength;
      return `${displayName} không được vượt quá ${requiredLength} ký tự`;
    }

    if (errors['pattern']) {
      return `${displayName} không đúng định dạng`;
    }

    return `${displayName} không hợp lệ`;
  }

  /**
   * Get role label in Vietnamese
   */
  protected getRoleLabel(role: string): string {
    return this.ROLE_LABELS[role as keyof typeof this.ROLE_LABELS] || role;
  }

  /**
   * Get full name from separate name fields
   */
  protected getFullName(name?: string, surname?: string): string {
    const parts = [name, surname].filter(Boolean);
    return parts.length > 0 ? parts.join(' ') : '--';
  }

  /**
   * Check if user has specific permission
   */
  protected hasPermission(permission: string): boolean {
    return this.permissionService.getGrantedPolicy(permission);
  }

  /**
   * Check if user has any of the provided permissions
   */
  protected hasAnyPermission(permissions: string[]): boolean {
    return permissions.some(permission => this.hasPermission(permission));
  }

  /**
   * Check if user has all of the provided permissions
   */
  protected hasAllPermissions(permissions: string[]): boolean {
    return permissions.every(permission => this.hasPermission(permission));
  }
}
