import { Component, OnInit, signal } from '@angular/core';
import { ConfirmationService } from 'primeng/api';
import { ComponentBase } from '../../../../shared/base/component-base';
import { Table, TableModule } from 'primeng/table';
import { forkJoin } from 'rxjs';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { RippleModule } from 'primeng/ripple';
import { ToastModule } from 'primeng/toast';
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
import { RoleFormComponent } from '../role-form/role-form.component';

@Component({
  selector: 'app-role-list',
  standalone: true,
  imports: [
    CommonModule,
    TableModule,
    ButtonModule,
    RippleModule,
    ToastModule,
    ToolbarModule,
    InputTextModule,
    TagModule,
    InputIconModule,
    IconFieldModule,
    ConfirmDialogModule,
    TooltipModule,
    PermissionDirective,
    RoleFormComponent,
  ],
  templateUrl: './role-list.component.html',
  styleUrl: './role-list.component.scss',
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

  // Dialog state
  roleDialogVisible = false;
  selectedRoleId?: string;

  constructor(
    private identityRoleService: IdentityRoleService,
    private confirmationService: ConfirmationService
  ) {
    super();
  }

  ngOnInit() {
    this.loadRoles();
  }

  // Dialog operations
  openCreateDialog() {
    this.selectedRoleId = undefined;
    this.roleDialogVisible = true;
  }

  openEditDialog(roleId: string) {
    this.selectedRoleId = roleId;
    this.roleDialogVisible = true;
  }

  onRoleSaved() {
    this.loadRoles();
    this.roleDialogVisible = false;
  }

  deleteRole(role: IdentityRoleDto) {
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

    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa các vai trò đã chọn?',
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.performDeleteSelectedRoles();
      },
    });
  }

  // Table operations
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
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

  private performDeleteSelectedRoles() {
    if (!this.selectedRoles?.length) return;

    for (const role of this.selectedRoles) {
      this.identityRoleService.delete(role.id!).subscribe({
        next: () => {
          this.loadRoles();
        },
        error: (error) => {
          this.handleApiError(error, `Không thể xóa vai trò ${role.name}`);
        },
      });
    }

    this.selectedRoles = [];
    this.showSuccess('Thành công', 'Đã xóa các vai trò đã chọn');
  }
}