import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';

import { TableFormDialogComponent } from './table-form-dialog.component';
import { map } from 'rxjs/operators';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form bàn ăn
 */
export interface TableFormDialogData {
  /** ID khu vực (chỉ có khi tạo bàn mới) */
  sectionId?: string;
  /** ID bàn (chỉ có khi chỉnh sửa) */
  tableId?: string;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
}

/**
 * Service quản lý dialog cho form bàn ăn trong hệ thống nhà hàng
 * Chức năng chính:
 * - Mở dialog tạo mới bàn ăn trong khu vực cụ thể
 * - Mở dialog chỉnh sửa bàn ăn hiện có
 * - Cấu hình chuẩn cho dialog với các thuộc tính phù hợp
 *
 * Sử dụng: Quản lý bàn ăn trong các khu vực nhà hàng
 */
@Injectable({
  providedIn: 'root',
})
export class TableFormDialogService {
  /** Service quản lý dialog của PrimeNG */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo bàn ăn mới trong khu vực cụ thể
   * @param sectionId ID của khu vực để tạo bàn
   * @returns Observable trả về true nếu tạo thành công
   */
  openCreateTableDialog(sectionId: string): Observable<boolean> {
    const dialogData: TableFormDialogData = {
      sectionId: sectionId,
      title: 'Thêm Bàn Mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa thông tin bàn ăn hiện có
   * @param tableId ID của bàn cần chỉnh sửa
   * @returns Observable trả về true nếu cập nhật thành công
   */
  openEditTableDialog(tableId: string): Observable<boolean> {
    const dialogData: TableFormDialogData = {
      tableId,
      title: 'Chỉnh Sửa Bàn',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với cấu hình chuẩn cho hệ thống nhà hàng
   * @param data Dữ liệu cấu hình dialog
   * @returns Observable trả về kết quả từ dialog
   */
  private openDialog(data: TableFormDialogData): Observable<boolean> {
    const config: DynamicDialogConfig<TableFormDialogData> = {
      header: data.title,
      width: '450px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      styleClass: 'table-form-dialog',
      maximizable: false,
      dismissableMask: false, // Không đóng khi click bên ngoài để tránh mất dữ liệu
      closeOnEscape: true, // Cho phép đóng bằng phím Esc
    };

    // Mở dialog với component form bàn ăn và cấu hình đã thiết lập
    const ref: DynamicDialogRef = this.dialogService.open(TableFormDialogComponent, config);
    // Xử lý kết quả đóng dialog, trả về false nếu không thành công
    return ref.onClose.pipe(map(result => result?.success || false));
  }
}
