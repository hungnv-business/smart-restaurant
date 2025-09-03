import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { RoleFormComponent } from './role-form.component';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form vai trò
 */
export interface RoleFormDialogData {
  /** ID của vai trò (chỉ có khi chỉnh sửa) */
  roleId?: string;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
}

/**
 * Service quản lý dialog cho form vai trò trong hệ thống nhà hàng
 * Chức năng chính:
 * - Mở dialog tạo mới vai trò
 * - Mở dialog chỉnh sửa vai trò existante
 * - Cấu hình chuẩn cho dialog với các thuộc tính phù hợp
 */
@Injectable({
  providedIn: 'root',
})
export class RoleFormDialogService {
  /** Service quản lý dialog của PrimeNG */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo vai trò mới
   */
  openCreateRoleDialog(): Observable<boolean> {
    const dialogData: RoleFormDialogData = {
      title: 'Thêm vai trò mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa vai trò
   */
  openEditRoleDialog(roleId: string): Observable<boolean> {
    const dialogData: RoleFormDialogData = {
      roleId,
      title: 'Sửa vai trò',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với config chuẩn
   */
  private openDialog(data: RoleFormDialogData): Observable<boolean> {
    const config: DynamicDialogConfig<RoleFormDialogData> = {
      header: data.title,
      width: '500px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      styleClass: 'role-form-dialog',
      maximizable: false,
      dismissableMask: false, // Không đóng khi click outside
      closeOnEscape: true,
    };

    const ref: DynamicDialogRef = this.dialogService.open(RoleFormComponent, config);
    return ref.onClose.pipe(map(result => result || false));
  }
}
