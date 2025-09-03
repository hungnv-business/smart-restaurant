import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { CheckboxModule } from 'primeng/checkbox';
import { TreeModule } from 'primeng/tree';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { firstValueFrom } from 'rxjs';

import { IdentityRoleService } from '@abp/ng.identity/proxy';
import {
  IdentityRoleCreateDto,
  IdentityRoleUpdateDto,
  IdentityRoleDto,
} from '@abp/ng.identity/proxy';
import { PermissionsService } from '@abp/ng.permission-management/proxy';
import { RoleFormDialogData } from './role-form-dialog.service';
import {
  GetPermissionListResultDto,
  UpdatePermissionsDto,
} from '@abp/ng.permission-management/proxy';
import { TreeNode } from 'primeng/api';
import { PermissionTreeService } from '../../services/permission-tree.service';
import { LocalizationPipe } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';

/**
 * Component quản lý form tạo/chỉnh sửa vai trò trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới vai trò với các quyền tương ứng
 * - Chỉnh sửa thông tin vai trò hiện có
 * - Quản lý phân quyền chi tiết cho từng vai trò
 * - Hiển thị cây quyền theo dạng phân cấp
 */
@Component({
  selector: 'app-role-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ButtonModule,
    InputTextModule,
    ProgressSpinnerModule,
    CheckboxModule,
    TreeModule,
    ValidationErrorComponent,
  ],
  templateUrl: './role-form.component.html',
})
export class RoleFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin vai trò */
  roleForm!: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** ID của vai trò đang chỉnh sửa (nếu có) */
  roleId?: string;
  /** Thông tin chi tiết của vai trò */
  role: IdentityRoleDto | null = null;

  /** Danh sách tất cả quyền có sẵn trong hệ thống */
  availablePermissions: GetPermissionListResultDto | null = null;
  /** Cây quyền dưới dạng phân cấp để hiển thị */
  permissionTreeNodes: TreeNode[] = [];
  /** Danh sách các node quyền đã được chọn */
  selectedTreeNodes: TreeNode[] = [];

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private identityRoleService = inject(IdentityRoleService);
  private permissionsService = inject(PermissionsService);
  private permissionTreeService = inject(PermissionTreeService);
  private dialogRef = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig);

  /**
   * Khởi tạo component với cấu hình dialog
   */
  constructor() {
    super();
    const data = this.config.data as RoleFormDialogData;
    this.roleId = data?.roleId;
    this.initializeForm();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    this.loadPermissions();

    if (this.roleId) {
      this.loadRole(this.roleId);
    } else {
      this.resetRoleForm();
    }
  }

  /**
   * Khởi tạo form với các validation rules
   */
  private initializeForm() {
    this.roleForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]],
      isDefault: [false],
      isPublic: [false],
    });
  }

  /**
   * Tải thông tin chi tiết của vai trò theo ID
   * @param id ID của vai trò cần tải
   */
  async loadRole(id: string) {
    this.loading = true;

    try {
      const role = await firstValueFrom(this.identityRoleService.get(id));
      this.role = role;

      this.roleForm.patchValue({
        name: role.name,
        isDefault: role.isDefault,
        isPublic: role.isPublic,
      });

      // Load permissions using role name instead of id
      await this.loadRolePermissions(role.name);

      // Disable name field in edit mode for system roles
      this.roleForm.get('name')?.disable();

      this.loading = false;
    } catch (error) {
      this.handleApiError(error, 'Không thể tải thông tin vai trò');
      this.loading = false;
    }
  }

  /**
   * Xử lý submit form - tạo mới hoặc cập nhật vai trò
   */
  async onSubmit() {
    if (!this.validateForm(this.roleForm)) {
      return;
    }

    const formValue = this.roleForm.getRawValue();
    this.loading = true;

    if (this.roleId) {
      await this.updateRole(formValue);
    } else {
      await this.createRole(formValue);
    }
  }

  /**
   * Tạo vai trò mới với các quyền được chọn
   * @param formValue Dữ liệu từ form
   */
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
      this.dialogRef.close(true);
    } catch (error) {
      this.handleApiError(error, 'Không thể tạo vai trò');
      this.loading = false;
    }
  }

  /**
   * Cập nhật thông tin vai trò và quyền
   * @param formValue Dữ liệu từ form
   */
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
      this.dialogRef.close(true);
    } catch (error) {
      this.handleApiError(error, 'Không thể cập nhật vai trò');
      this.loading = false;
    }
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

  /**
   * Tải danh sách tất cả quyền có sẵn và xây dựng cây quyền
   */
  async loadPermissions() {
    try {
      this.availablePermissions = await firstValueFrom(this.permissionsService.get('R', ''));
      if (this.availablePermissions) {
        this.permissionTreeNodes = this.permissionTreeService.buildPermissionTree(
          this.availablePermissions,
        );
      }
    } catch (error) {
      console.error('Error loading permissions:', error);
    }
  }

  /**
   * Tải danh sách quyền của vai trò và cập nhật trạng thái cây quyền
   * @param roleName Tên vai trò cần tải quyền
   */
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
        this.selectedTreeNodes,
      );
    } catch (error) {
      console.error('Error loading role permissions:', error);
    }
  }

  /**
   * Tìm node trong tất cả các nhóm quyền
   * @param key Key của quyền cần tìm
   * @returns TreeNode nếu tìm thấy, null nếu không
   */
  private findNodeInAllGroups(key: string): TreeNode | null {
    for (const groupNode of this.permissionTreeNodes) {
      const found = this.findNode([groupNode], key);
      if (found) return found;
    }
    return null;
  }

  /**
   * Tìm node trong cây quyền theo key
   * @param nodes Danh sách node cần tìm
   * @param key Key của quyền
   * @returns TreeNode nếu tìm thấy
   */
  private findNode(nodes: TreeNode[], key: string): TreeNode | null {
    for (const node of nodes) {
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

  /**
   * Cập nhật quyền cho vai trò dựa trên các node đã chọn
   * @param roleName Tên vai trò cần cập nhật quyền
   */
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
