import { Component, OnInit, signal, inject } from '@angular/core';
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

/**
 * Component hiển thị danh sách vai trò trong hệ thống nhà hàng
 * Chức năng chính:
 * - Hiển thị danh sách tất cả vai trò với thông tin chi tiết
 * - Tạo mới vai trò qua dialog form
 * - Chỉnh sửa thông tin vai trò hiện có
 * - Xóa vai trò (không cho phép xóa vai trò hệ thống)
 * - Tìm kiếm và lọc vai trò theo tên
 * - Xóa nhiều vai trò cùng lúc
 */
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
  providers: [],
})
export class RoleListComponent extends ComponentBase implements OnInit {
  /** Hằng số quyền để kiểm soát hiển thị các nút chức năng */
  readonly PERMISSIONS = PERMISSIONS;

  /** Danh sách các trường được sử dụng để tìm kiếm */
  filterFields: string[] = ['name'];

  /** Signal chứa danh sách vai trò */
  roles = signal<IdentityRoleDto[]>([]);
  /** Danh sách vai trò được chọn để thực hiện thao tác */
  selectedRoles!: IdentityRoleDto[] | null;

  /** Các service được inject */
  private identityRoleService = inject(IdentityRoleService);
  private roleFormDialogService = inject(RoleFormDialogService);

  /**
   * Khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    this.loadRoles();
  }

  /**
   * Mở dialog tạo vai trò mới
   */
  openCreateDialog() {
    this.roleFormDialogService.openCreateRoleDialog().subscribe(success => {
      if (success) {
        this.loadRoles();
      }
    });
  }

  /**
   * Mở dialog chỉnh sửa vai trò
   * @param roleId ID của vai trò cần chỉnh sửa
   */
  openEditDialog(roleId: string) {
    this.roleFormDialogService.openEditRoleDialog(roleId).subscribe(success => {
      if (success) {
        this.loadRoles();
      }
    });
  }

  /**
   * Xóa một vai trò (không cho phép xóa vai trò hệ thống)
   * @param role Vai trò cần xóa
   */
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

  /**
   * Xóa các vai trò đã chọn (loại bỏ vai trò hệ thống)
   */
  deleteSelectedRoles() {
    if (!this.selectedRoles?.length) return;

    // Filter out static roles
    const deletableRoles = this.selectedRoles.filter(role => !role.isStatic);
    const staticRoles = this.selectedRoles.filter(role => role.isStatic);

    if (staticRoles.length > 0) {
      const staticRoleNames = staticRoles.map(role => role.name).join(', ');
      this.showWarning('Không thể xóa', `Không thể xóa các vai trò hệ thống: ${staticRoleNames}`);
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

  /**
   * Xử lý tìm kiếm global trên bảng
   * @param table Tham chiếu đến PrimeNG Table
   * @param event Event từ input search
   */
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  /**
   * Kiểm tra có vai trò nào có thể xóa được trong danh sách đã chọn
   * @returns true nếu có ít nhất một vai trò có thể xóa
   */
  hasDeletableRoles(): boolean {
    if (!this.selectedRoles?.length) return false;
    return this.selectedRoles.some(role => !role.isStatic);
  }

  /**
   * Tải danh sách vai trò từ API
   */
  private loadRoles() {
    const input: GetIdentityRolesInput = {
      maxResultCount: 50,
    };

    this.identityRoleService.getList(input).subscribe({
      next: result => {
        this.roles.set(result.items || []);
      },
      error: error => {
        console.error('Error loading roles:', error);
        this.roles.set([]);
      },
    });
  }

  /**
   * Thực hiện xóa một vai trò
   * @param role Vai trò cần xóa
   */
  private performDeleteRole(role: IdentityRoleDto) {
    this.identityRoleService.delete(role.id!).subscribe({
      next: () => {
        this.loadRoles();
        this.showSuccess('Thành công', 'Đã xóa vai trò');
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa vai trò');
      },
    });
  }

  /**
   * Thực hiện xóa nhiều vai trò cùng lúc
   * @param rolesToDelete Danh sách vai trò cần xóa
   */
  private performDeleteSelectedRoles(rolesToDelete: IdentityRoleDto[]) {
    if (!rolesToDelete?.length) return;

    const deleteRequests = rolesToDelete.map(role => this.identityRoleService.delete(role.id!));

    forkJoin(deleteRequests).subscribe({
      next: () => {
        this.loadRoles();
        this.selectedRoles = [];
        this.showSuccess('Thành công', `Đã xóa ${rolesToDelete.length} vai trò`);
      },
      error: error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa vai trò');
        this.loadRoles(); // Reload to refresh the list
      },
    });
  }
}
