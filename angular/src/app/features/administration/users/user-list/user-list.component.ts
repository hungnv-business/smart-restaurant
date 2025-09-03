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

import { IdentityUserService } from '@abp/ng.identity/proxy';
import { IdentityUserDto, GetIdentityUsersInput } from '@abp/ng.identity/proxy';
import { UserFormDialogService } from '../user-form/user-form-dialog.service';
import { PermissionDirective } from '@abp/ng.core';
import { PERMISSIONS } from '../../../../shared/constants/permissions';

/**
 * Component hiển thị danh sách người dùng trong hệ thống nhà hàng
 * Chức năng chính:
 * - Hiển thị danh sách tất cả người dùng với thông tin chi tiết
 * - Tạo mới người dùng qua dialog form
 * - Chỉnh sửa thông tin người dùng hiện có
 * - Xóa người dùng với xác nhận
 * - Tìm kiếm và lọc người dùng theo nhiều tiêu chí
 * - Xóa nhiều người dùng cùng lúc
 * - Hiển thị vai trò và trạng thái của từng người dùng
 */
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
    PermissionDirective,
  ],
  templateUrl: './user-list.component.html',
  providers: [],
})
export class UserListComponent extends ComponentBase implements OnInit {
  /** Hằng số quyền để kiểm soát hiển thị các nút chức năng */
  readonly PERMISSIONS = PERMISSIONS;

  /** Danh sách các trường được sử dụng để tìm kiếm */
  filterFields: string[] = ['userName', 'email', 'name', 'surname', 'phoneNumber'];

  /** Signal chứa danh sách người dùng */
  users = signal<IdentityUserDto[]>([]);
  /** Danh sách người dùng được chọn để thực hiện thao tác */
  selectedUsers!: IdentityUserDto[] | null;

  /** Các service được inject */
  private identityUserService = inject(IdentityUserService);
  private userFormDialogService = inject(UserFormDialogService);

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
    this.loadUsers();
  }

  /**
   * Mở dialog tạo người dùng mới
   */
  openCreateDialog() {
    this.userFormDialogService.openCreateUserDialog().subscribe(success => {
      if (success) {
        this.loadUsers();
      }
    });
  }

  /**
   * Mở dialog chỉnh sửa người dùng
   * @param userId ID của người dùng cần chỉnh sửa
   */
  openEditDialog(userId: string) {
    this.userFormDialogService.openEditUserDialog(userId).subscribe(success => {
      if (success) {
        this.loadUsers();
      }
    });
  }

  /**
   * Xóa một người dùng với xác nhận
   * @param user Người dùng cần xóa
   */
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

  /**
   * Xóa các người dùng đã chọn
   */
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

  /**
   * Lấy danh sách vai trò của người dùng dưới dạng chuỗi
   * @param user Người dùng cần lấy vai trò
   * @returns Chuỗi các vai trò phân tách bởi dấu phẩy
   */
  getUserRoles(user: any): string {
    const roles = (user as any).roles as string[];
    if (!roles || roles.length === 0) {
      return '--'; // Hiển thị -- khi không có vai trò nào
    }
    // Chuyển đổi tên vai trò sang tiếng Việt và nối bằng dấu phẩy
    return roles.map(role => this.getRoleLabel(role)).join(', ');
  }

  /**
   * Lấy tên đầy đủ của người dùng
   * @param user Người dùng cần lấy tên
   * @returns Tên đầy đủ (Họ + Tên)
   */
  getUserFullName(user: IdentityUserDto): string {
    return this.getFullName(user.name, user.surname);
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
   * Tải danh sách người dùng từ API
   */
  private loadUsers() {
    const input: GetIdentityUsersInput = {
      maxResultCount: 50,
    };

    this.identityUserService.getList(input).subscribe({
      next: result => {
        this.users.set(result.items || []);

        // Tải vai trò cho từng người dùng
        this.loadUserRoles();
      },
      error: error => {
        console.error('Error loading data:', error);
        this.users.set([]);
      },
    });
  }

  /**
   * Lấy nhãn trạng thái bằng tiếng Việt
   * @param status Trạng thái hoạt động của người dùng
   * @returns Nhãn trạng thái tiếng Việt
   */
  getStatusLabel(status: boolean): string {
    return status ? 'Hoạt động' : 'Vô hiệu';
  }

  /**
   * Tải vai trò cho tất cả người dùng
   */
  private loadUserRoles() {
    const userList = this.users();
    if (userList.length === 0) return;

    // Tạo request lấy vai trò cho từng người dùng
    const roleRequests = userList.map(user => this.identityUserService.getRoles(user.id!));

    forkJoin(roleRequests).subscribe({
      next: userRolesArrays => {
        // Cập nhật danh sách người dùng với vai trò tương ứng
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

  /**
   * Thực hiện xóa một người dùng
   * @param user Người dùng cần xóa
   */
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

  /**
   * Thực hiện xóa nhiều người dùng cùng lúc
   */
  private performDeleteSelectedUsers() {
    if (!this.selectedUsers?.length) return;

    const deleteRequests = this.selectedUsers.map(user =>
      this.identityUserService.delete(user.id!),
    );

    forkJoin(deleteRequests).subscribe({
      next: () => {
        this.loadUsers();
        this.selectedUsers = [];
        this.showSuccess('Thành công', `Đã xóa ${deleteRequests.length} người dùng`);
      },
      error: error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa người dùng');
        this.loadUsers(); // Tải lại danh sách để cập nhật trạng thái
      },
    });
  }
}
