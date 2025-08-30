import { Directive, OnDestroy, inject } from '@angular/core';
import { FormGroup, FormControl } from '@angular/forms';
import { Subject } from 'rxjs';
import { ToastService } from '../services/toast.service';
import { PermissionService } from '@abp/ng.core';
import { ConfirmationService } from 'primeng/api';
import { Table, TableLazyLoadEvent } from 'primeng/table';

@Directive()
export abstract class ComponentBase implements OnDestroy {
  pageSize = 10;
  rowsPerPageOptions = [3, 10, 20, 30, 50, 100];
  showCurrentPageReport = true;
  paginator = true;
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

  protected toastService = inject(ToastService);
  protected permissionService = inject(PermissionService);
  protected confirmationService = inject(ConfirmationService);

  private destroy$ = new Subject<void>();

  constructor() {}

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
    error: {
      error?: { error?: { message?: string } };
      status?: number;
      message?: string;
    },
    defaultMessage: string = 'Có lỗi xảy ra. Vui lòng thử lại.',
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
    errorMessage: string = 'Vui lòng điền đầy đủ thông tin bắt buộc',
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

  // ==================== CRUD Success Messages ====================

  /**
   * Show success message for create operation
   */
  protected showCreateSuccess(entityName: string = 'bản ghi'): void {
    this.showSuccess('Thành công', `Đã tạo ${entityName} mới`);
  }

  /**
   * Show success message for update operation
   */
  protected showUpdateSuccess(entityName: string = 'bản ghi'): void {
    this.showSuccess('Thành công', `Đã cập nhật ${entityName}`);
  }

  /**
   * Show success message for delete operation
   */
  protected showDeleteSuccess(entityName: string = 'bản ghi'): void {
    this.showSuccess('Thành công', `Đã xóa ${entityName}`);
  }

  /**
   * Show success message for bulk delete operation
   */
  protected showBulkDeleteSuccess(count: number, entityName: string = 'bản ghi'): void {
    this.showSuccess('Thành công', `Đã xóa ${count} ${entityName}`);
  }

  /**
   * Show success message for generic save operation
   */
  protected showSaveSuccess(entityName: string = 'bản ghi'): void {
    this.showSuccess('Thành công', `Đã lưu ${entityName}`);
  }

  // ==================== CONFIRMATION DIALOGS ====================

  /**
   * Show confirmation dialog for deleting a single item
   */
  protected confirmDelete(itemName: string, onConfirm: () => void): void {
    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa "${itemName}"?`,
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      rejectButtonStyleClass: 'p-button-secondary',
      accept: onConfirm,
    });
  }

  /**
   * Show confirmation dialog for bulk delete operation
   */
  protected confirmBulkDelete(onConfirm: () => void): void {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa các mục đã chọn không?',
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      rejectButtonStyleClass: 'p-button-secondary',
      accept: onConfirm,
    });
  }

  // ==================== IMAGE UTILITIES ====================

  /**
   * Get default image URL if provided URL is null/empty
   */
  protected getImageUrl(
    imageUrl?: string | null,
    defaultImage: string = '/assets/layout/images/empty.jpg',
  ): string {
    return imageUrl && imageUrl.trim() ? imageUrl : defaultImage;
  }

  /**
   * Check if image URL is valid (not null/empty/whitespace)
   */
  protected hasValidImage(imageUrl?: string | null): boolean {
    return !!(imageUrl && imageUrl.trim());
  }

  // ==================== PAGINATION UTILITIES ====================

  /**
   * Tính skipCount từ TableLazyLoadEvent
   */
  protected getSkipCount(event?: TableLazyLoadEvent): number {
    return event?.first || 0;
  }

  /**
   * Tính maxResultCount từ TableLazyLoadEvent
   */
  protected getMaxResultCount(event?: TableLazyLoadEvent): number {
    return event?.rows || this.pageSize;
  }

  /**
   * Tính sorting từ TableLazyLoadEvent
   */
  protected getSorting(event?: TableLazyLoadEvent, defaultSort?: string): string | undefined {
    if (event?.sortField) {
      return `${event.sortField} ${event.sortOrder === 1 ? 'asc' : 'desc'}`;
    }
    return defaultSort;
  }

  /**
   * Reset pagination về trang đầu
   */
  protected resetPagination(dt: Table): void {
    dt.reset();
  }
}
