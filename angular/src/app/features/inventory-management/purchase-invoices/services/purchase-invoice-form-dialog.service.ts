import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { DialogService } from 'primeng/dynamicdialog';
import { PurchaseInvoiceFormComponent } from '../purchase-invoice-form/purchase-invoice-form.component';

/**
 * Interface định nghĩa data truyền vào dialog form quản lý hóa đơn mua nguyên liệu
 * Hỗ trợ 3 mode: tạo mới, chỉnh sửa và xem chi tiết
 */
export interface PurchaseInvoiceFormData {
  /** ID của hóa đơn mua (chỉ có khi edit/view) */
  purchaseInvoiceId?: string;
  /** Mode hoạt động của dialog */
  mode: 'create' | 'edit' | 'view';
}

/**
 * Service quản lý dialog form cho hóa đơn mua nguyên liệu trong hệ thống kho nhà hàng
 * 
 * Chức năng chính:
 * - Mở dialog tạo mới hóa đơn mua với form đầy đủ tính năng
 * - Mở dialog chỉnh sửa hóa đơn mua với dữ liệu được load từ server
 * - Mở dialog xem chi tiết hóa đơn mua (read-only mode)
 * - Cấu hình dialog large size để chứa form phức tạp với nhiều items
 * - Responsive breakpoints cho mobile và tablet
 * - Hỗ trợ maximizable để có thể fullscreen
 * 
 * @example
 * // Tạo mới hóa đơn mua
 * dialogService.openCreateDialog().subscribe(result => {
 *   if (result) this.refreshList();
 * });
 * 
 * // Chỉnh sửa hóa đơn mua
 * dialogService.openEditDialog(invoiceId).subscribe(result => {
 *   if (result) this.refreshList();
 * });
 * 
 * // Xem chi tiết hóa đơn mua
 * dialogService.openViewDialog(invoiceId).subscribe();
 */
@Injectable({
  providedIn: 'root',
})
export class PurchaseInvoiceFormDialogService {
  /** Service để quản lý dynamic dialog */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo mới hóa đơn mua
   * Form có mã hóa đơn tự động sinh, mặc định có 1 item trống để nhập
   * 
   * @returns Observable<boolean> - true nếu tạo thành công, false nếu hủy
   */
  openCreateDialog(): Observable<boolean> {
    const ref = this.dialogService.open(PurchaseInvoiceFormComponent, {
      header: 'Tạo hóa đơn mua mới',
      width: '95vw', // Dialog rất rộng để chứa bảng items
      height: '95vh', // Dialog cao để chứa nhiều items
      modal: true,
      maximizable: true, // Cho phép fullscreen
      breakpoints: {
        '960px': '95vw', // Tablet: 95% viewport width
        '640px': '100vw', // Mobile: fullscreen
      },
      data: {
        purchaseInvoiceId: null,
        mode: 'create',
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog',
    });

    return ref.onClose;
  }

  /**
   * Mở dialog chỉnh sửa hóa đơn mua
   * Tự động load dữ liệu hóa đơn và tất cả items từ server
   * 
   * @param purchaseInvoiceId - ID của hóa đơn mua cần chỉnh sửa
   * @returns Observable<boolean> - true nếu cập nhật thành công, false nếu hủy
   */
  openEditDialog(purchaseInvoiceId: string): Observable<boolean> {
    const ref = this.dialogService.open(PurchaseInvoiceFormComponent, {
      header: 'Chỉnh sửa hóa đơn mua',
      width: '95vw',
      height: '95vh',
      modal: true,
      maximizable: true,
      breakpoints: {
        '960px': '95vw',
        '640px': '100vw',
      },
      data: {
        purchaseInvoiceId,
        mode: 'edit',
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog',
    });

    return ref.onClose;
  }

  /**
   * Mở dialog xem chi tiết hóa đơn mua (chế độ chỉ đọc)
   * Form sẽ được disable và ẩn các nút action
   * 
   * @param purchaseInvoiceId - ID của hóa đơn mua cần xem
   * @returns Observable<boolean> - luôn false vì không có thao tác lưu
   */
  openViewDialog(purchaseInvoiceId: string): Observable<boolean> {
    const ref = this.dialogService.open(PurchaseInvoiceFormComponent, {
      header: 'Chi tiết hóa đơn mua',
      width: '95vw',
      height: '95vh',
      modal: true,
      maximizable: true,
      breakpoints: {
        '960px': '95vw',
        '640px': '100vw',
      },
      data: {
        purchaseInvoiceId,
        mode: 'view',
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog purchase-invoice-view-dialog',
    });

    return ref.onClose;
  }
}
