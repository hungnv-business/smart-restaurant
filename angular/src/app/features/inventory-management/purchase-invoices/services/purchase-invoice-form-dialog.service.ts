import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { DialogService } from 'primeng/dynamicdialog';
import { PurchaseInvoiceFormComponent } from '../purchase-invoice-form/purchase-invoice-form.component';

export interface PurchaseInvoiceFormData {
  purchaseInvoiceId?: string;
  mode: 'create' | 'edit' | 'view';
}

@Injectable({
  providedIn: 'root'
})
export class PurchaseInvoiceFormDialogService {
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo mới hóa đơn mua
   */
  openCreateDialog(): Observable<boolean> {
    const ref = this.dialogService.open(PurchaseInvoiceFormComponent, {
      header: 'Tạo hóa đơn mua mới',
      width: '95vw',
      height: '95vh',
      modal: true,
      maximizable: true,
      breakpoints: {
        '960px': '95vw',
        '640px': '100vw'
      },
      data: {
        purchaseInvoiceId: null,
        mode: 'create'
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog'
    });

    return ref.onClose;
  }

  /**
   * Mở dialog chỉnh sửa hóa đơn mua
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
        '640px': '100vw'
      },
      data: {
        purchaseInvoiceId,
        mode: 'edit'
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog'
    });

    return ref.onClose;
  }

  /**
   * Mở dialog xem chi tiết (read-only)
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
        '640px': '100vw'
      },
      data: {
        purchaseInvoiceId,
        mode: 'view'
      } as PurchaseInvoiceFormData,
      styleClass: 'purchase-invoice-dialog purchase-invoice-view-dialog'
    });

    return ref.onClose;
  }
}