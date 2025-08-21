import { TestBed } from '@angular/core/testing';
import { FormBuilder, FormGroup, Validators, FormControl } from '@angular/forms';
import { Subject } from 'rxjs';

import { ComponentBase } from './component-base';
import { ToastService } from '../services/toast.service';
import { PermissionService } from '@abp/ng.core';

// Test component extending ComponentBase
class TestComponent extends ComponentBase {
  testForm: FormGroup;

  constructor(private fb: FormBuilder) {
    super();
    this.testForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.maxLength(15)]],
      nested: this.fb.group({
        field1: ['', Validators.required],
        field2: ['']
      })
    });
  }

  // Expose protected methods for testing
  public testIsFieldInvalid(fieldName: string): boolean {
    return this.isFieldInvalid(this.testForm, fieldName);
  }

  public testGetFormControl(fieldName: string): FormControl {
    return this.getFormControl(this.testForm, fieldName);
  }

  public testMarkFormGroupTouched(): void {
    this.markFormGroupTouched(this.testForm);
  }

  public testShowSuccess(summary: string, detail?: string): void {
    this.showSuccess(summary, detail);
  }

  public testShowError(summary: string, detail?: string): void {
    this.showError(summary, detail);
  }

  public testShowWarning(summary: string, detail?: string): void {
    this.showWarning(summary, detail);
  }

  public testShowInfo(summary: string, detail?: string): void {
    this.showInfo(summary, detail);
  }

  public testResetForm(): void {
    this.resetForm(this.testForm);
  }

  public testClearFormErrors(): void {
    this.clearFormErrors(this.testForm);
  }

  public testHandleApiError(error: any, defaultMessage?: string): void {
    this.handleApiError(error, defaultMessage);
  }

  public testValidateForm(errorMessage?: string): boolean {
    return this.validateForm(this.testForm, errorMessage);
  }

  public testGetFieldErrorMessage(fieldName: string, displayName: string): string {
    return this.getFieldErrorMessage(this.testForm, fieldName, displayName);
  }

  public testGetRoleLabel(role: string): string {
    return this.getRoleLabel(role);
  }

  public testGetFullName(name?: string, surname?: string): string {
    return this.getFullName(name, surname);
  }

  public testHasPermission(permission: string): boolean {
    return this.hasPermission(permission);
  }

  public testHasAnyPermission(permissions: string[]): boolean {
    return this.hasAnyPermission(permissions);
  }

  public testHasAllPermissions(permissions: string[]): boolean {
    return this.hasAllPermissions(permissions);
  }

  public getDestroyedObservable() {
    return this.destroyed$;
  }
}

describe('ComponentBase', () => {
  let component: TestComponent;
  let toastService: jasmine.SpyObj<ToastService>;
  let permissionService: jasmine.SpyObj<PermissionService>;
  let formBuilder: FormBuilder;

  beforeEach(async () => {
    const toastServiceSpy = jasmine.createSpyObj('ToastService', [
      'showSuccess',
      'showError',
      'showWarning',
      'showInfo'
    ]);
    const permissionServiceSpy = jasmine.createSpyObj('PermissionService', [
      'getGrantedPolicy'
    ]);

    await TestBed.configureTestingModule({
      providers: [
        FormBuilder,
        { provide: ToastService, useValue: toastServiceSpy },
        { provide: PermissionService, useValue: permissionServiceSpy }
      ]
    }).compileComponents();

    formBuilder = TestBed.inject(FormBuilder);
    toastService = TestBed.inject(ToastService) as jasmine.SpyObj<ToastService>;
    permissionService = TestBed.inject(PermissionService) as jasmine.SpyObj<PermissionService>;
    
    component = new TestComponent(formBuilder);
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('Component Initialization', () => {
    it('should initialize with default pagination settings', () => {
      expect(component.pageSize).toBe(10);
      expect(component.rowsPerPageOptions).toEqual([10, 20, 30, 50, 100]);
      expect(component.showCurrentPageReport).toBe(false);
      expect(component.paginator).toBe(false);
      expect(component.rowHover).toBe(true);
    });

    it('should have Vietnamese role labels', () => {
      expect(component['ROLE_LABELS']).toEqual({
        Admin: 'Quản trị viên',
        Owner: 'Chủ nhà hàng',
        Waiter: 'Nhân viên phục vụ',
        Kitchen: 'Nhân viên bếp',
        Cashier: 'Thu ngân',
        Customer: 'Khách hàng'
      });
    });

    it('should expose destroyed$ observable', () => {
      const destroyed$ = component['destroyed$'];
      expect(destroyed$).toBeDefined();
    });
  });

  describe('Component Lifecycle', () => {
    it('should complete destroy subject on ngOnDestroy', () => {
      const destroyed$ = component.getDestroyedObservable();
      let completed = false;
      
      destroyed$.subscribe({
        complete: () => completed = true
      });
      
      component.ngOnDestroy();
      
      expect(completed).toBe(true);
    });
  });

  describe('Form Validation', () => {
    beforeEach(() => {
      component.testForm.patchValue({
        name: '',
        email: 'invalid-email',
        phone: ''
      });
    });

    it('should detect invalid fields correctly', () => {
      component.testForm.get('name')?.markAsTouched();
      
      expect(component.testIsFieldInvalid('name')).toBe(true);
      expect(component.testIsFieldInvalid('email')).toBe(false); // not touched yet
    });

    it('should detect invalid fields when dirty', () => {
      component.testForm.get('email')?.markAsDirty();
      
      expect(component.testIsFieldInvalid('email')).toBe(true);
    });

    it('should return false for valid fields', () => {
      component.testForm.patchValue({ name: 'Valid Name' });
      component.testForm.get('name')?.markAsTouched();
      
      expect(component.testIsFieldInvalid('name')).toBe(false);
    });

    it('should return FormControl for given field name', () => {
      const control = component.testGetFormControl('name');
      
      expect(control).toBeInstanceOf(FormControl);
      expect(control.value).toBe(component.testForm.get('name')?.value);
    });

    it('should mark all form controls as touched', () => {
      component.testMarkFormGroupTouched();
      
      expect(component.testForm.get('name')?.touched).toBe(true);
      expect(component.testForm.get('email')?.touched).toBe(true);
      expect(component.testForm.get('phone')?.touched).toBe(true);
      expect(component.testForm.get('nested.field1')?.touched).toBe(true);
      expect(component.testForm.get('nested.field2')?.touched).toBe(true);
    });

    it('should validate form and return false for invalid form', () => {
      const result = component.testValidateForm();
      
      expect(result).toBe(false);
      expect(toastService.showWarning).toHaveBeenCalledWith(
        'Thông tin chưa đầy đủ',
        'Vui lòng điền đầy đủ thông tin bắt buộc'
      );
    });

    it('should validate form and return true for valid form', () => {
      component.testForm.patchValue({
        name: 'Valid Name',
        email: 'valid@email.com',
        nested: {
          field1: 'Valid Field'
        }
      });
      
      const result = component.testValidateForm();
      
      expect(result).toBe(true);
      expect(toastService.showWarning).not.toHaveBeenCalled();
    });

    it('should validate form with custom error message', () => {
      const customMessage = 'Custom validation message';
      
      component.testValidateForm(customMessage);
      
      expect(toastService.showWarning).toHaveBeenCalledWith(
        'Thông tin chưa đầy đủ',
        customMessage
      );
    });
  });

  describe('Form Error Messages', () => {
    beforeEach(() => {
      component.testForm.patchValue({
        name: '',
        email: 'invalid-email',
        phone: '12345678901234567890' // too long
      });
      component.testMarkFormGroupTouched();
    });

    it('should return required error message', () => {
      const message = component.testGetFieldErrorMessage('name', 'Tên');
      expect(message).toBe('Tên là bắt buộc');
    });

    it('should return email error message', () => {
      const message = component.testGetFieldErrorMessage('email', 'Email');
      expect(message).toBe('Email không hợp lệ');
    });

    it('should return minlength error message', () => {
      component.testForm.patchValue({ name: 'ab' }); // less than 3 chars
      const message = component.testGetFieldErrorMessage('name', 'Tên');
      expect(message).toBe('Tên phải có ít nhất 3 ký tự');
    });

    it('should return maxlength error message', () => {
      const message = component.testGetFieldErrorMessage('phone', 'Số điện thoại');
      expect(message).toBe('Số điện thoại không được vượt quá 15 ký tự');
    });

    it('should return empty string for valid field', () => {
      component.testForm.patchValue({
        name: 'Valid Name',
        email: 'valid@email.com'
      });
      
      const message = component.testGetFieldErrorMessage('name', 'Tên');
      expect(message).toBe('');
    });

    it('should return generic error message for unknown error', () => {
      // Add custom validator that returns custom error
      component.testForm.get('name')?.setErrors({ customError: true });
      
      const message = component.testGetFieldErrorMessage('name', 'Tên');
      expect(message).toBe('Tên không hợp lệ');
    });

    it('should handle pattern error', () => {
      component.testForm.get('name')?.setErrors({ pattern: true });
      
      const message = component.testGetFieldErrorMessage('name', 'Tên');
      expect(message).toBe('Tên không đúng định dạng');
    });
  });

  describe('Form Management', () => {
    beforeEach(() => {
      component.testForm.patchValue({
        name: 'Test Name',
        email: 'test@email.com'
      });
      component.testMarkFormGroupTouched();
    });

    it('should reset form', () => {
      component.testResetForm();
      
      expect(component.testForm.get('name')?.value).toBeNull();
      expect(component.testForm.get('email')?.value).toBeNull();
      expect(component.testForm.get('name')?.untouched).toBe(true);
      expect(component.testForm.get('name')?.pristine).toBe(true);
    });

    it('should clear form errors', () => {
      component.testClearFormErrors();
      
      expect(component.testForm.get('name')?.untouched).toBe(true);
      expect(component.testForm.get('email')?.untouched).toBe(true);
      expect(component.testForm.get('name')?.pristine).toBe(true);
      expect(component.testForm.get('email')?.pristine).toBe(true);
      expect(component.testForm.get('nested.field1')?.untouched).toBe(true);
      expect(component.testForm.get('nested.field2')?.untouched).toBe(true);
    });
  });

  describe('Toast Messages', () => {
    it('should show success message', () => {
      component.testShowSuccess('Success', 'Detail message');
      
      expect(toastService.showSuccess).toHaveBeenCalledWith('Success', 'Detail message');
    });

    it('should show error message', () => {
      component.testShowError('Error', 'Error detail');
      
      expect(toastService.showError).toHaveBeenCalledWith('Error', 'Error detail');
    });

    it('should show warning message', () => {
      component.testShowWarning('Warning', 'Warning detail');
      
      expect(toastService.showWarning).toHaveBeenCalledWith('Warning', 'Warning detail');
    });

    it('should show info message', () => {
      component.testShowInfo('Info', 'Info detail');
      
      expect(toastService.showInfo).toHaveBeenCalledWith('Info', 'Info detail');
    });

    it('should show messages without detail', () => {
      component.testShowSuccess('Success');
      component.testShowError('Error');
      component.testShowWarning('Warning');
      component.testShowInfo('Info');
      
      expect(toastService.showSuccess).toHaveBeenCalledWith('Success', undefined);
      expect(toastService.showError).toHaveBeenCalledWith('Error', undefined);
      expect(toastService.showWarning).toHaveBeenCalledWith('Warning', undefined);
      expect(toastService.showInfo).toHaveBeenCalledWith('Info', undefined);
    });
  });

  describe('API Error Handling', () => {
    beforeEach(() => {
      spyOn(console, 'error');
    });

    it('should handle error with specific message', () => {
      const error = {
        error: {
          error: {
            message: 'Specific error message'
          }
        }
      };
      
      component.testHandleApiError(error);
      
      expect(console.error).toHaveBeenCalledWith('API Error:', error);
      expect(toastService.showError).toHaveBeenCalledWith('Có lỗi xảy ra', 'Specific error message');
    });

    it('should handle 400 Bad Request error', () => {
      const error = { status: 400 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.'
      );
    });

    it('should handle 401 Unauthorized error', () => {
      const error = { status: 401 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
      );
    });

    it('should handle 403 Forbidden error', () => {
      const error = { status: 403 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Bạn không có quyền thực hiện thao tác này.'
      );
    });

    it('should handle 404 Not Found error', () => {
      const error = { status: 404 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Không tìm thấy dữ liệu yêu cầu.'
      );
    });

    it('should handle 500 Internal Server Error', () => {
      const error = { status: 500 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Lỗi máy chủ. Vui lòng liên hệ quản trị viên.'
      );
    });

    it('should handle network error (status 0)', () => {
      const error = { status: 0 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.'
      );
    });

    it('should use default message for unknown errors', () => {
      const error = { status: 999 };
      
      component.testHandleApiError(error);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        'Có lỗi xảy ra. Vui lòng thử lại.'
      );
    });

    it('should use custom default message', () => {
      const error = { status: 999 };
      const customMessage = 'Custom error message';
      
      component.testHandleApiError(error, customMessage);
      
      expect(toastService.showError).toHaveBeenCalledWith(
        'Có lỗi xảy ra',
        customMessage
      );
    });
  });

  describe('Role and Name Utilities', () => {
    it('should get Vietnamese role labels', () => {
      expect(component.testGetRoleLabel('Admin')).toBe('Quản trị viên');
      expect(component.testGetRoleLabel('Owner')).toBe('Chủ nhà hàng');
      expect(component.testGetRoleLabel('Waiter')).toBe('Nhân viên phục vụ');
      expect(component.testGetRoleLabel('Kitchen')).toBe('Nhân viên bếp');
      expect(component.testGetRoleLabel('Cashier')).toBe('Thu ngân');
      expect(component.testGetRoleLabel('Customer')).toBe('Khách hàng');
    });

    it('should return original role for unknown roles', () => {
      expect(component.testGetRoleLabel('UnknownRole')).toBe('UnknownRole');
    });

    it('should get full name from name and surname', () => {
      expect(component.testGetFullName('John', 'Doe')).toBe('John Doe');
      expect(component.testGetFullName('John', '')).toBe('John');
      expect(component.testGetFullName('', 'Doe')).toBe('Doe');
      expect(component.testGetFullName('', '')).toBe('--');
      expect(component.testGetFullName()).toBe('--');
      expect(component.testGetFullName(undefined, undefined)).toBe('--');
    });

    it('should handle null and undefined names', () => {
      expect(component.testGetFullName(null as any, 'Doe')).toBe('Doe');
      expect(component.testGetFullName('John', null as any)).toBe('John');
      expect(component.testGetFullName(null as any, null as any)).toBe('--');
    });
  });

  describe('Permission Checking', () => {
    beforeEach(() => {
      permissionService.getGrantedPolicy.and.returnValue(false);
    });

    it('should check single permission', () => {
      permissionService.getGrantedPolicy.and.returnValue(true);
      
      const result = component.testHasPermission('UserManagement.Users.Create');
      
      expect(result).toBe(true);
      expect(permissionService.getGrantedPolicy).toHaveBeenCalledWith('UserManagement.Users.Create');
    });

    it('should return false for denied permission', () => {
      const result = component.testHasPermission('UserManagement.Users.Create');
      
      expect(result).toBe(false);
    });

    it('should check if user has any of multiple permissions', () => {
      permissionService.getGrantedPolicy.and.callFake((permission: string) => {
        return permission === 'UserManagement.Users.Update';
      });
      
      const permissions = ['UserManagement.Users.Create', 'UserManagement.Users.Update'];
      const result = component.testHasAnyPermission(permissions);
      
      expect(result).toBe(true);
    });

    it('should return false when user has none of the permissions', () => {
      const permissions = ['UserManagement.Users.Create', 'UserManagement.Users.Update'];
      const result = component.testHasAnyPermission(permissions);
      
      expect(result).toBe(false);
    });

    it('should check if user has all permissions', () => {
      permissionService.getGrantedPolicy.and.returnValue(true);
      
      const permissions = ['UserManagement.Users.Create', 'UserManagement.Users.Update'];
      const result = component.testHasAllPermissions(permissions);
      
      expect(result).toBe(true);
    });

    it('should return false when user is missing some permissions', () => {
      permissionService.getGrantedPolicy.and.callFake((permission: string) => {
        return permission === 'UserManagement.Users.Create';
      });
      
      const permissions = ['UserManagement.Users.Create', 'UserManagement.Users.Update'];
      const result = component.testHasAllPermissions(permissions);
      
      expect(result).toBe(false);
    });

    it('should handle empty permission arrays', () => {
      expect(component.testHasAnyPermission([])).toBe(false);
      expect(component.testHasAllPermissions([])).toBe(true);
    });
  });
});