import { Component, EventEmitter, Input, OnChanges, OnInit, Output } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  Validators,
  ReactiveFormsModule,
} from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DialogModule } from 'primeng/dialog';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { CheckboxModule } from 'primeng/checkbox';
import { TreeModule } from 'primeng/tree';
import { firstValueFrom } from 'rxjs';

import { IdentityRoleService } from '@abp/ng.identity/proxy';
import { IdentityRoleCreateDto, IdentityRoleUpdateDto } from '@abp/ng.identity/proxy';
import { PermissionsService } from '@abp/ng.permission-management/proxy';
import {
  GetPermissionListResultDto,
  UpdatePermissionsDto,
} from '@abp/ng.permission-management/proxy';
import { TreeNode } from 'primeng/api';
import { PermissionTreeService } from '../../services/permission-tree.service';
import { LocalizationPipe } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';

@Component({
  selector: 'app-role-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ButtonModule,
    InputTextModule,
    DialogModule,
    ProgressSpinnerModule,
    CheckboxModule,
    TreeModule,
    ValidationErrorComponent,
  ],
  templateUrl: './role-form.component.html',
})
export class RoleFormComponent extends ComponentBase implements OnInit, OnChanges {
  @Input() visible = false;
  @Input() roleId?: string;
  @Output() visibleChange = new EventEmitter<boolean>();
  @Output() roleSaved = new EventEmitter<void>();

  roleForm!: FormGroup;
  isEditMode = false;
  loading = false;

  // Permission management
  availablePermissions: GetPermissionListResultDto | null = null;
  permissionTreeNodes: TreeNode[] = [];
  selectedTreeNodes: TreeNode[] = [];

  constructor(
    private fb: FormBuilder,
    private identityRoleService: IdentityRoleService,
    private permissionsService: PermissionsService,
    private permissionTreeService: PermissionTreeService
  ) {
    super();
    this.initializeForm();
  }

  ngOnInit() {
    this.loadPermissions();

    if (this.roleId) {
      this.isEditMode = true;
      this.loadRole(this.roleId);
    } else {
      this.isEditMode = false;
      this.resetRoleForm();
    }
  }

  ngOnChanges() {
    if (this.visible && this.roleId) {
      this.isEditMode = true;
      this.loadRole(this.roleId);
    } else if (this.visible && !this.roleId) {
      this.isEditMode = false;
      this.resetRoleForm();
    }
  }

  private initializeForm() {
    this.roleForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]],
      isDefault: [false],
      isPublic: [false],
    });
  }

  async loadRole(id: string) {
    this.loading = true;

    try {
      const role = await firstValueFrom(this.identityRoleService.get(id));

      this.roleForm.patchValue({
        name: role.name,
        isDefault: role.isDefault,
        isPublic: role.isPublic,
      });

      // Load permissions using role name instead of id
      await this.loadRolePermissions(role.name);

      // Disable name field in edit mode for system roles
      if (this.isEditMode) {
        this.roleForm.get('name')?.disable();
      }

      this.loading = false;
    } catch (error) {
      this.handleApiError(error, 'Không thể tải thông tin vai trò');
      this.loading = false;
    }
  }

  async onSubmit() {
    if (!this.validateForm(this.roleForm)) {
      return;
    }

    const formValue = this.roleForm.getRawValue();
    this.loading = true;

    if (this.isEditMode) {
      await this.updateRole(formValue);
    } else {
      await this.createRole(formValue);
    }
  }

  private async createRole(formValue: any) {
    const createInput: IdentityRoleCreateDto = {
      name: formValue.name,
      isDefault: formValue.isDefault,
      isPublic: formValue.isPublic,
    };

    try {
      // Create role first
      await firstValueFrom(this.identityRoleService.create(createInput));

      // Then save permissions for the new role
      await this.updateRolePermissions(formValue.name);

      this.showSuccess('Thành công', 'Đã tạo vai trò mới');
      this.hideDialog();
      this.roleSaved.emit();
    } catch (error) {
      this.handleApiError(error, 'Không thể tạo vai trò');
      this.loading = false;
    }
  }

  private async updateRole(formValue: any) {
    const updateInput: IdentityRoleUpdateDto = {
      name: formValue.name,
      isDefault: formValue.isDefault,
      isPublic: formValue.isPublic,
      concurrencyStamp: null, // Will be handled by ABP
    };

    try {
      // Update role first
      await firstValueFrom(this.identityRoleService.update(this.roleId!, updateInput));

      // Then update permissions for the role
      await this.updateRolePermissions(formValue.name);

      this.showSuccess('Thành công', 'Đã cập nhật vai trò');
      this.hideDialog();
      this.roleSaved.emit();
    } catch (error) {
      this.handleApiError(error, 'Không thể cập nhật vai trò');
      this.loading = false;
    }
  }

  hideDialog() {
    this.visible = false;
    this.visibleChange.emit(false);
    this.resetRoleForm();
  }

  cancel() {
    this.hideDialog();
  }

  private resetRoleForm() {
    this.roleForm.reset({
      isDefault: false,
      isPublic: false,
    });
    this.roleForm.markAsUntouched();
    this.roleForm.markAsPristine();

    // Enable name field for create mode
    this.roleForm.get('name')?.enable();

    this.loading = false;
  }

  // Permission management methods
  async loadPermissions() {
    try {
      this.availablePermissions = await firstValueFrom(this.permissionsService.get('R', ''));
      if (this.availablePermissions) {
        this.permissionTreeNodes = this.permissionTreeService.buildPermissionTree(
          this.availablePermissions
        );
      }
    } catch (error) {
      console.error('Error loading permissions:', error);
    }
  }

  async loadRolePermissions(roleName: string) {
    try {
      const rolePermissions = await firstValueFrom(this.permissionsService.get('R', roleName));

      // Collect all granted permission keys
      const grantedPermissionKeys: string[] = [];
      rolePermissions.groups.forEach((group: any) => {
        group.permissions.forEach((permission: any) => {
          if (permission.isGranted) {
            grantedPermissionKeys.push(permission.name);
          }
        });
      });

      // Find all nodes for granted permissions (both leaf and non-leaf)
      this.selectedTreeNodes = grantedPermissionKeys
        .map(key => this.findNodeInAllGroups(key))
        .filter(node => node !== null) as TreeNode[];

      // Set partialSelected state for parent nodes using service
      this.selectedTreeNodes = this.permissionTreeService.updateParentStates(
        this.permissionTreeNodes,
        this.selectedTreeNodes
      );
    } catch (error) {
      console.error('Error loading role permissions:', error);
    }
  }

  private findNodeInAllGroups(key: string): TreeNode | null {
    for (let groupNode of this.permissionTreeNodes) {
      const found = this.findNode([groupNode], key);
      if (found) return found;
    }
    return null;
  }

  private findNode(nodes: TreeNode[], key: string): TreeNode | null {
    for (let node of nodes) {
      if (node.key === key) {
        return node;
      }
      if (node.children && node.children.length) {
        const found = this.findNode(node.children, key);
        if (found) {
          return found;
        }
      }
    }
    return null;
  }

  async updateRolePermissions(roleName: string) {
    if (!this.availablePermissions) return;

    // Extract ALL selected permission keys (both leaf and non-leaf nodes)
    const selectedPermissionKeys = this.selectedTreeNodes
      .map(node => node.key || '')
      .filter(key => key !== '');

    // Build permissions array for update
    const permissions: any[] = [];
    this.availablePermissions.groups.forEach((group: any) => {
      group.permissions.forEach((permission: any) => {
        const isGranted = selectedPermissionKeys.includes(permission.name);
        permissions.push({
          name: permission.name,
          isGranted: isGranted,
        });
      });
    });

    const updateInput: UpdatePermissionsDto = {
      permissions: permissions,
    };

    try {
      await firstValueFrom(this.permissionsService.update('R', roleName, updateInput));
    } catch (error) {
      console.error('Error updating role permissions:', error);
      throw error;
    }
  }

}
