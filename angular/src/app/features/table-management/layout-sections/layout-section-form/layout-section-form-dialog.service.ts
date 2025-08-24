import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { LayoutSectionFormComponent } from './layout-section-form.component';

export interface LayoutSectionFormDialogData {
  sectionId?: string;
  title?: string;
}

@Injectable({
  providedIn: 'root',
})
export class LayoutSectionFormDialogService {
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo khu vực bố cục mới
   */
  openCreateSectionDialog(): Observable<boolean> {
    const dialogData: LayoutSectionFormDialogData = {
      title: 'Thêm Khu vực mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa khu vực bố cục
   */
  openEditSectionDialog(sectionId: string): Observable<boolean> {
    const dialogData: LayoutSectionFormDialogData = {
      sectionId,
      title: 'Chỉnh sửa Khu vực',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với config chuẩn
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
      dismissableMask: false, // Không đóng khi click outside
      closeOnEscape: true,
    };

    const ref: DynamicDialogRef = this.dialogService.open(LayoutSectionFormComponent, config);
    return ref.onClose.pipe(
      map(result => result || false)
    );
  }
}