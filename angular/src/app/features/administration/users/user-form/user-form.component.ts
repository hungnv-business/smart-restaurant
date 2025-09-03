import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { forkJoin } from 'rxjs';

import { IdentityUserService } from '@abp/ng.identity/proxy';
import {
  IdentityUserCreateDto,
  IdentityUserUpdateDto,
  IdentityUserDto,
} from '@abp/ng.identity/proxy';
import { ComponentBase } from '../../../../shared/base/component-base';
import { UserFormDialogData } from './user-form-dialog.service';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';

/**
 * Component quản lý form tạo/chỉnh sửa người dùng trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới người dùng với thông tin cơ bản
 * - Chỉnh sửa thông tin người dùng hiện có
 * - Phân vai trò cho người dùng
 * - Quản lý trạng thái kích hoạt tài khoản
 * - Validation dữ liệu đầu vào
 */
@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    ProgressSpinnerModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './user-form.component.html',
})
export class UserFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin người dùng */
  userForm!: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Danh sách vai trò có thể gán cho người dùng */
  availableRoles: string[] = [];
  /** ID của người dùng đang chỉnh sửa (nếu có) */
  userId?: string;
  /** Thông tin chi tiết của người dùng */
  user: IdentityUserDto | null = null;

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private identityUserService = inject(IdentityUserService);
  private dialogRef = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig);

  /**
   * Khởi tạo component với cấu hình dialog
   */
  constructor() {
    super();
    const data = this.config.data as UserFormDialogData;
    this.userId = data?.userId;
    this.initializeForm();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    this.identityUserService.getAssignableRoles().subscribe(res => {
      this.availableRoles = res.items.map(e => e.name);
      if (this.userId) {
        this.loadUser(this.userId);
      } else {
        this.resetUserForm();
      }
    });
  }

  /**
   * Khởi tạo form với các validation rules
   */
  private initializeForm() {
    this.userForm = this.fb.group({
      userName: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      name: [''],
      surname: [''],
      phoneNumber: [''],
      isActive: [true],
      roles: [[]],
    });
  }

  /**
   * Tải thông tin chi tiết của người dùng và vai trò
   * @param id ID của người dùng cần tải
   */
  loadUser(id: string) {
    this.loading = true;

    // Load user info and roles in parallel
    forkJoin({
      user: this.identityUserService.get(id),
      userRoles: this.identityUserService.getRoles(id),
    }).subscribe({
      next: ({ user, userRoles }) => {
        this.user = user;
        this.userForm.patchValue({
          userName: user.userName,
          email: user.email,
          name: user.name,
          surname: user.surname,
          phoneNumber: user.phoneNumber,
          isActive: user.isActive,
          roles: userRoles.items.map(role => role.name) || [],
        });

        // Disable username in edit mode
        this.userForm.get('userName')?.disable();

        this.loading = false;
      },
      error: error => {
        this.handleApiError(error, 'Không thể tải thông tin người dùng');
        this.loading = false;
      },
    });
  }

  /**
   * Chuyển đổi trạng thái vai trò của người dùng
   * @param role Tên vai trò cần chuyển đổi
   * @param event Event từ checkbox
   */
  toggleRole(role: string, event: any) {
    const currentRoles = this.userForm.get('roles')?.value || [];
    let updatedRoles: string[];

    if (event.target.checked) {
      updatedRoles = [...currentRoles, role];
    } else {
      updatedRoles = currentRoles.filter((r: string) => r !== role);
    }

    this.userForm.patchValue({ roles: updatedRoles });
  }

  /**
   * Kiểm tra vai trò có được chọn hay không
   * @param role Tên vai trò cần kiểm tra
   * @returns true nếu vai trò được chọn
   */
  isRoleSelected(role: string): boolean {
    const roles = this.userForm.get('roles')?.value || [];
    return roles.includes(role);
  }

  /**
   * Xử lý submit form - tạo mới hoặc cập nhật người dùng
   */
  onSubmit() {
    if (!this.validateForm(this.userForm)) {
      return;
    }

    const formValue = this.userForm.getRawValue();
    this.loading = true;

    if (this.userId) {
      this.updateUser(formValue);
    } else {
      this.createUser(formValue);
    }
  }

  /**
   * Tạo người dùng mới với mật khẩu mặc định
   * @param formValue Dữ liệu từ form
   */
  private createUser(formValue: any) {
    const createInput: IdentityUserCreateDto = {
      userName: formValue.userName,
      email: formValue.email,
      password: 'Password@123', // Default password - user should change on first login
      name: formValue.name,
      surname: formValue.surname,
      phoneNumber: formValue.phoneNumber,
      isActive: formValue.isActive,
      lockoutEnabled: false,
      roleNames: formValue.roles,
    };

    this.identityUserService.create(createInput).subscribe({
      next: () => {
        this.showSuccess('Thành công', 'Đã tạo người dùng mới');
        this.dialogRef.close(true);
      },
      error: error => {
        this.handleApiError(error, 'Không thể tạo người dùng');
        this.loading = false;
      },
    });
  }

  /**
   * Cập nhật thông tin người dùng và vai trò
   * @param formValue Dữ liệu từ form
   */
  private updateUser(formValue: any) {
    const updateInput: IdentityUserUpdateDto = {
      userName: formValue.userName,
      email: formValue.email,
      name: formValue.name,
      surname: formValue.surname,
      phoneNumber: formValue.phoneNumber,
      isActive: formValue.isActive,
      lockoutEnabled: false,
      roleNames: formValue.roles,
    };

    this.identityUserService.update(this.userId!, updateInput).subscribe({
      next: () => {
        this.showSuccess('Thành công', 'Đã cập nhật người dùng');
        this.dialogRef.close(true);
      },
      error: error => {
        this.handleApiError(error, 'Không thể cập nhật người dùng');
        this.loading = false;
      },
    });
  }

  /**
   * Hủy thao tác và đóng dialog
   */
  cancel() {
    this.dialogRef.close(false);
  }

  /**
   * Reset form về trạng thái ban đầu cho chế độ tạo mới
   */
  private resetUserForm() {
    this.userForm.reset({
      isActive: true,
      roles: [],
    });
    this.userForm.markAsUntouched();
    this.userForm.markAsPristine();

    // Enable username field for create mode
    this.userForm.get('userName')?.enable();

    this.loading = false;
  }
}
