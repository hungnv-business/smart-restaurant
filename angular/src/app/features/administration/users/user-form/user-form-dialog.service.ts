import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { UserFormComponent } from './user-form.component';

export interface UserFormDialogData {
  userId?: string;
  title?: string;
}

@Injectable({
  providedIn: 'root',
})
export class UserFormDialogService {
  private dialogService = inject(DialogService);

  /**
   * Mở dialog tạo người dùng mới
   */
  openCreateUserDialog(): Observable<boolean> {
    const dialogData: UserFormDialogData = {
      title: 'Thêm người dùng mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa người dùng
   */
  openEditUserDialog(userId: string): Observable<boolean> {
    const dialogData: UserFormDialogData = {
      userId,
      title: 'Sửa người dùng',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog với config chuẩn
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
      dismissableMask: false, // Không đóng khi click outside
      closeOnEscape: true,
    };

    const ref: DynamicDialogRef = this.dialogService.open(UserFormComponent, config);
    return ref.onClose.pipe(map(result => result || false));
  }
}
