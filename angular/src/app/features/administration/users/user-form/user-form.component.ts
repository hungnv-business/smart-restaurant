import { Component, EventEmitter, Input, OnChanges, OnInit, Output } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DialogModule } from 'primeng/dialog';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { forkJoin } from 'rxjs';

import { IdentityUserService } from '@abp/ng.identity/proxy';
import { IdentityUserCreateDto, IdentityUserUpdateDto } from '@abp/ng.identity/proxy';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ButtonModule,
    InputTextModule,
    DialogModule,
    ProgressSpinnerModule,
    ValidationErrorComponent,
  ],
  templateUrl: './user-form.component.html',
})
export class UserFormComponent extends ComponentBase implements OnInit, OnChanges {
  @Input() visible = false;
  @Input() userId?: string;
  @Output() visibleChange = new EventEmitter<boolean>();
  @Output() userSaved = new EventEmitter<void>();

  userForm!: FormGroup;
  isEditMode = false;
  loading = false;
  availableRoles: string[] = [];

  constructor(private fb: FormBuilder, private identityUserService: IdentityUserService) {
    super();
    this.initializeForm();
  }

  ngOnInit() {
    // Watch for userId changes to load user data
    this.identityUserService.getAssignableRoles().subscribe(res => {
      this.availableRoles = res.items.map(e => e.name);
      if (this.userId) {
        this.isEditMode = true;
        this.loadUser(this.userId);
      } else {
        this.isEditMode = false;
        this.resetUserForm();
      }
    });
  }

  ngOnChanges() {
    if (this.visible && this.userId) {
      this.isEditMode = true;
      this.loadUser(this.userId);
    } else if (this.visible && !this.userId) {
      this.isEditMode = false;
      this.resetUserForm();
    }
  }

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

  loadUser(id: string) {
    this.loading = true;
    
    // Load user info and roles in parallel
    forkJoin({
      user: this.identityUserService.get(id),
      userRoles: this.identityUserService.getRoles(id)
    }).subscribe({
      next: ({ user, userRoles }) => {
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
        if (this.isEditMode) {
          this.userForm.get('userName')?.disable();
        }

        this.loading = false;
      },
      error: (error) => {
        this.handleApiError(error, 'Không thể tải thông tin người dùng');
        this.loading = false;
      }
    });
  }

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

  isRoleSelected(role: string): boolean {
    const roles = this.userForm.get('roles')?.value || [];
    return roles.includes(role);
  }

  onSubmit() {
    if (!this.validateForm(this.userForm)) {
      return;
    }

    const formValue = this.userForm.getRawValue();
    this.loading = true;

    if (this.isEditMode) {
      this.updateUser(formValue);
    } else {
      this.createUser(formValue);
    }
  }

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
        this.hideDialog();
        this.userSaved.emit();
      },
      error: error => {
        this.handleApiError(error, 'Không thể tạo người dùng');
        this.loading = false;
      },
    });
  }

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
        this.hideDialog();
        this.userSaved.emit();
      },
      error: error => {
        this.handleApiError(error, 'Không thể cập nhật người dùng');
        this.loading = false;
      },
    });
  }

  hideDialog() {
    this.visible = false;
    this.visibleChange.emit(false);
    this.resetUserForm();
  }

  cancel() {
    this.hideDialog();
  }

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
