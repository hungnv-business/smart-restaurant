import { Component, OnInit, signal } from '@angular/core';
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

import { IdentityUserService } from '@abp/ng.identity/proxy';
import { IdentityUserDto, GetIdentityUsersInput } from '@abp/ng.identity/proxy';
import { UserFormComponent } from '../user-form/user-form.component';
import { PermissionDirective } from '@abp/ng.core';
import { PERMISSIONS } from '../../../../shared/constants/permissions';

@Component({
  selector: 'app-user-list',
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
    UserFormComponent,
    PermissionDirective,
  ],
  templateUrl: './user-list.component.html',
  providers: [ConfirmationService],
})
export class UserListComponent extends ComponentBase implements OnInit {
  // Permissions constants
  readonly PERMISSIONS = PERMISSIONS;

  // Table configuration
  filterFields: string[] = ['userName', 'email', 'name', 'surname', 'phoneNumber'];

  // Data
  users = signal<IdentityUserDto[]>([]);
  selectedUsers!: IdentityUserDto[] | null;

  // Dialog state
  userDialogVisible = false;
  selectedUserId?: string;

  constructor(
    private identityUserService: IdentityUserService,
    private confirmationService: ConfirmationService
  ) {
    super();
  }

  ngOnInit() {
    this.loadUsers();
  }

  // Dialog operations
  openCreateDialog() {
    this.selectedUserId = undefined;
    this.userDialogVisible = true;
  }

  openEditDialog(userId: string) {
    this.selectedUserId = userId;
    this.userDialogVisible = true;
  }

  onUserSaved() {
    this.loadUsers();
    this.userDialogVisible = false;
  }

  deleteUser(user: IdentityUserDto) {
    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa ${user.userName}?`,
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xoá',
      rejectLabel: 'Huỷ',
      accept: () => {
        this.performDeleteUser(user);
      },
    });
  }

  deleteSelectedUsers() {
    if (!this.selectedUsers?.length) return;

    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa các người dùng đã chọn?',
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xoá',
      rejectLabel: 'Huỷ',
      accept: () => {
        this.performDeleteSelectedUsers();
      },
    });
  }

  // Display helpers
  getUserRoles(user: any): string {
    const roles = (user as any).roles as string[];
    if (!roles || roles.length === 0) {
      return '--';
    }
    return roles.map(role => this.getRoleLabel(role)).join(', ');
  }

  getUserFullName(user: IdentityUserDto): string {
    return this.getFullName(user.name, user.surname);
  }

  // Table operations
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  // Private methods
  private loadUsers() {
    const input: GetIdentityUsersInput = {
      maxResultCount: 50,
    };

    this.identityUserService.getList(input).subscribe({
      next: result => {
        this.users.set(result.items || []);

        // Load roles for each user
        this.loadUserRoles();
      },
      error: error => {
        console.error('Error loading data:', error);
        this.users.set([]);
      },
    });
  }

  /**
   * Get status label in Vietnamese
   */
  getStatusLabel(status: boolean): string {
    return status ? 'Hoạt động' : 'Vô hiệu';
  }

  private loadUserRoles() {
    const userList = this.users();
    if (userList.length === 0) return;

    // Load roles for each user using getRoles API
    const roleRequests = userList.map(user => this.identityUserService.getRoles(user.id!));

    forkJoin(roleRequests).subscribe({
      next: userRolesArrays => {
        const updatedUsers = userList.map((user, index) => {
          const userRoles = userRolesArrays[index];
          return {
            ...user,
            roles: userRoles.items.map(role => role.name) || [],
          };
        });
        this.users.set(updatedUsers as any);
      },
      error: error => {
        console.error('Error loading user roles:', error);
      },
    });
  }

  private performDeleteUser(user: IdentityUserDto) {
    this.identityUserService.delete(user.id!).subscribe({
      next: () => {
        this.loadUsers();
        this.showSuccess('Thành công', 'Đã xóa người dùng');
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa người dùng');
      },
    });
  }

  private performDeleteSelectedUsers() {
    if (!this.selectedUsers?.length) return;

    const deleteRequests = this.selectedUsers.map(user =>
      this.identityUserService.delete(user.id!)
    );

    forkJoin(deleteRequests).subscribe({
      next: () => {
        this.loadUsers();
        this.selectedUsers = [];
        this.showSuccess('Thành công', `Đã xóa ${deleteRequests.length} người dùng`);
      },
      error: (error) => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa người dùng');
        this.loadUsers(); // Reload to refresh the list
      },
    });
  }
}
