import { Component, OnInit, signal, inject } from '@angular/core';
import { ConfirmationService } from 'primeng/api';
import { ComponentBase } from '../../../../shared/base/component-base';
import { Table, TableModule } from 'primeng/table';
import { forkJoin } from 'rxjs';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { RippleModule } from 'primeng/ripple';
import { ToolbarModule } from 'primeng/toolbar';
import { InputTextModule } from 'primeng/inputtext';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TooltipModule } from 'primeng/tooltip';
import { PermissionDirective } from '@abp/ng.core';

import { IdentityRoleService } from '@abp/ng.identity/proxy';
import { IdentityRoleDto, GetIdentityRolesInput } from '@abp/ng.identity/proxy';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { RoleFormDialogService } from '../role-form/role-form-dialog.service';

@Component({
  selector: 'app-role-list',
  standalone: true,
  imports: [
    CommonModule,
    TableModule,
    ButtonModule,
    RippleModule,
    ToolbarModule,
    InputTextModule,
    TagModule,
    InputIconModule,
    IconFieldModule,
    ConfirmDialogModule,
    TooltipModule,
    PermissionDirective,
  ],
  templateUrl: './role-list.component.html',
  providers: [ConfirmationService],
})
export class RoleListComponent extends ComponentBase implements OnInit {
  // Permissions constants
  readonly PERMISSIONS = PERMISSIONS;
  
  // Table configuration
  filterFields: string[] = ['name'];

  // Data
  roles = signal<IdentityRoleDto[]>([]);
  selectedRoles!: IdentityRoleDto[] | null;

  // Injected services
  private identityRoleService = inject(IdentityRoleService);
  private confirmationService = inject(ConfirmationService);
  private roleFormDialogService = inject(RoleFormDialogService);

  constructor() {
    super();
  }

  ngOnInit() {
    this.loadRoles();
  }

  // Dialog operations
  openCreateDialog() {
    this.roleFormDialogService.openCreateRoleDialog().subscribe((success) => {
      if (success) {
        this.loadRoles();
      }
    });
  }

  openEditDialog(roleId: string) {
    this.roleFormDialogService.openEditRoleDialog(roleId).subscribe((success) => {
      if (success) {
        this.loadRoles();
      }
    });
  }

  deleteRole(role: IdentityRoleDto) {
    if (role.isStatic) {
      this.showWarning('Không thể xóa', 'Không thể xóa vai trò hệ thống');
      return;
    }

    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa vai trò "${role.name}"?`,
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.performDeleteRole(role);
      },
    });
  }

  deleteSelectedRoles() {
    if (!this.selectedRoles?.length) return;

    // Filter out static roles
    const deletableRoles = this.selectedRoles.filter(role => !role.isStatic);
    const staticRoles = this.selectedRoles.filter(role => role.isStatic);

    if (staticRoles.length > 0) {
      const staticRoleNames = staticRoles.map(role => role.name).join(', ');
      this.showWarning(
        'Không thể xóa', 
        `Không thể xóa các vai trò hệ thống: ${staticRoleNames}`
      );
    }

    if (deletableRoles.length === 0) {
      return;
    }

    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa ${deletableRoles.length} vai trò đã chọn?`,
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.performDeleteSelectedRoles(deletableRoles);
      },
    });
  }

  // Table operations
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  hasDeletableRoles(): boolean {
    if (!this.selectedRoles?.length) return false;
    return this.selectedRoles.some(role => !role.isStatic);
  }

  // Private methods
  private loadRoles() {
    const input: GetIdentityRolesInput = {
      maxResultCount: 50,
    };

    this.identityRoleService.getList(input).subscribe({
      next: (result) => {
        this.roles.set(result.items || []);
      },
      error: (error) => {
        console.error('Error loading roles:', error);
        this.roles.set([]);
      },
    });
  }

  private performDeleteRole(role: IdentityRoleDto) {
    this.identityRoleService.delete(role.id!).subscribe({
      next: () => {
        this.loadRoles();
        this.showSuccess('Thành công', 'Đã xóa vai trò');
      },
      error: (error) => {
        this.handleApiError(error, 'Không thể xóa vai trò');
      },
    });
  }

  private performDeleteSelectedRoles(rolesToDelete: IdentityRoleDto[]) {
    if (!rolesToDelete?.length) return;

    const deleteRequests = rolesToDelete.map(role =>
      this.identityRoleService.delete(role.id!)
    );

    forkJoin(deleteRequests).subscribe({
      next: () => {
        this.loadRoles();
        this.selectedRoles = [];
        this.showSuccess('Thành công', `Đã xóa ${rolesToDelete.length} vai trò`);
      },
      error: (error) => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa vai trò');
        this.loadRoles(); // Reload to refresh the list
      },
    });
  }
}