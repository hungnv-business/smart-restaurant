import { Injectable } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';

import { TableFormDialogComponent } from './table-form-dialog.component';
import { map } from 'rxjs/operators';

export interface TableFormDialogData {
  sectionId?: string;
  id?: string;
  isEditMode: boolean;
  title?: string;
}


@Injectable({
  providedIn: 'root',
})
export class TableFormDialogService {
  constructor(private dialogService: DialogService) {}

  /**
   * Mở dialog tạo bàn mới
   */
  openCreateTableDialog(sectionId: string): Observable<boolean> {
    const dialogData: TableFormDialogData = {
      sectionId: sectionId,
      isEditMode: false,
      title: 'Thêm Bàn Mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa bàn
   */
  openEditTableDialog(id: string): Observable<boolean> {
    const dialogData: TableFormDialogData = {
      id,
      isEditMode: true,
      title: 'Chỉnh Sửa Bàn',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với config chuẩn
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
      dismissableMask: false, // Không đóng khi click outside
      closeOnEscape: true,
    };

    const ref: DynamicDialogRef = this.dialogService.open(TableFormDialogComponent, config);
    return ref.onClose.pipe(
      map(result => result?.success || false)
    );
  }
}
