import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { LayoutSectionFormComponent } from './layout-section-form.component';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form khu vực bố cục
 */
export interface LayoutSectionFormDialogData {
  /** ID của khu vực (chỉ có khi chỉnh sửa) */
  sectionId?: string;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
}

/**
 * Service quản lý dialog cho form khu vực bố cục trong hệ thống nhà hàng
 * Chức năng chính:
 * - Mở dialog tạo mới khu vực (Dãy 1, Khu VIP, Sân vườn...)
 * - Mở dialog chỉnh sửa khu vực hiện có
 * - Cấu hình chuẩn cho dialog với các thuộc tính phù hợp
 *
 * Sử dụng: Quản lý bố cục không gian nhà hàng theo khu vực
 */
@Injectable({
  providedIn: 'root',
})
export class LayoutSectionFormDialogService {
  /** Service quản lý dialog của PrimeNG */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo khu vực bố cục mới (VD: "Khu VIP", "Sân vườn")
   * @returns Observable trả về true nếu tạo thành công
   */
  openCreateSectionDialog(): Observable<boolean> {
    const dialogData: LayoutSectionFormDialogData = {
      title: 'Thêm Khu vực mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa khu vực bố cục hiện có
   * @param sectionId ID của khu vực cần chỉnh sửa
   * @returns Observable trả về true nếu cập nhật thành công
   */
  openEditSectionDialog(sectionId: string): Observable<boolean> {
    const dialogData: LayoutSectionFormDialogData = {
      sectionId,
      title: 'Chỉnh sửa Khu vực',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với cấu hình chuẩn cho hệ thống nhà hàng
   * @param data Dữ liệu cấu hình dialog
   * @returns Observable trả về kết quả từ dialog
   */
  private openDialog(data: LayoutSectionFormDialogData): Observable<boolean> {
    const config: DynamicDialogConfig<LayoutSectionFormDialogData> = {
      header: data.title,
      width: '500px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      styleClass: 'layout-section-form-dialog p-fluid',
      maximizable: false,
      dismissableMask: false, // Không đóng khi click bên ngoài để tránh mất dữ liệu
      closeOnEscape: true, // Cho phép đóng bằng phím Esc
    };

    // Mở dialog với component form khu vực và cấu hình đã thiết lập
    const ref: DynamicDialogRef = this.dialogService.open(LayoutSectionFormComponent, config);
    // Xử lý kết quả đóng dialog, trả về false nếu không có kết quả
    return ref.onClose.pipe(map(result => result || false));
  }
}
