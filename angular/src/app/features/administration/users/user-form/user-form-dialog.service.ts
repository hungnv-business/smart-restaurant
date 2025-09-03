import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { UserFormComponent } from './user-form.component';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form người dùng
 */
export interface UserFormDialogData {
  /** ID của người dùng (chỉ có khi chỉnh sửa) */
  userId?: string;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
}

/**
 * Service quản lý dialog cho form người dùng trong hệ thống nhà hàng
 * Chức năng chính:
 * - Mở dialog tạo mới nhân viên nhà hàng
 * - Mở dialog chỉnh sửa thông tin nhân viên
 * - Cấu hình chuẩn cho dialog với các thuộc tính phù hợp
 * 
 * Sử dụng: Quản lý tài khoản nhân viên (thu ngân, phục vụ, bếp, quản lý)
 */
@Injectable({
  providedIn: 'root',
})
export class UserFormDialogService {
  /** Service quản lý dialog của PrimeNG */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo nhân viên mới cho nhà hàng
   * @returns Observable trả về true nếu tạo thành công
   */
  openCreateUserDialog(): Observable<boolean> {
    const dialogData: UserFormDialogData = {
      title: 'Thêm người dùng mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa thông tin nhân viên
   * @param userId ID của nhân viên cần chỉnh sửa
   * @returns Observable trả về true nếu cập nhật thành công
   */
  openEditUserDialog(userId: string): Observable<boolean> {
    const dialogData: UserFormDialogData = {
      userId,
      title: 'Sửa người dùng',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với cấu hình chuẩn cho hệ thống nhà hàng
   * @param data Dữ liệu cấu hình dialog
   * @returns Observable trả về kết quả từ dialog
   */
  private openDialog(data: UserFormDialogData): Observable<boolean> {
    const config: DynamicDialogConfig<UserFormDialogData> = {
      header: data.title,
      width: '600px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      styleClass: 'user-form-dialog',
      maximizable: false,
      dismissableMask: false, // Không đóng khi click bên ngoài để tránh mất dữ liệu
      closeOnEscape: true, // Cho phép đóng bằng phím Esc
    };

    // Mở dialog với component form người dùng và cấu hình đã thiết lập
    const ref: DynamicDialogRef = this.dialogService.open(UserFormComponent, config);
    // Xử lý kết quả đóng dialog, trả về false nếu không có kết quả
    return ref.onClose.pipe(map(result => result || false));
  }
}
