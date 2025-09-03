import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MenuItemFormComponent } from '../menu-item-form/menu-item-form.component';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form món ăn
 * Hỗ trợ cả chế độ tạo mới và chỉnh sửa
 */
export interface MenuItemFormData {
  menuItemId?: string; // ID món ăn (có trong Edit mode)
  menuItem?: MenuItemDto; // Dữ liệu món ăn đã load từ server (Edit mode)
  title?: string; // Tiêu đề dialog
}

/**
 * Service quản lý dialog form cho món ăn trong thực đơn
 * Chức năng chính:
 * - Mở dialog tạo mới món ăn (Phở Bò, Bún Chả, Cơm Tấm...)
 * - Mở dialog chỉnh sửa với pre-load dữ liệu món ăn
 * - Cấu hình dialog kích thước lớn cho form phức tạp
 * - Xử lý kết quả và thông báo thành công
 */
@Injectable({
  providedIn: 'root',
})
export class MenuItemFormDialogService {
  /** Service để mở dialog PrimeNG */
  private dialogService = inject(DialogService);
  /** Service API quản lý món ăn */
  private menuItemService = inject(MenuItemService);

  /**
   * Mở dialog tạo mới món ăn
   * @returns Observable kết quả dialog (true = lưu thành công, false = hủy)
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: MenuItemFormData = {
      title: 'Thêm món ăn',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa món ăn hiện có
   * Tự động tải dữ liệu món ăn trước khi mở form
   * @param menuItemId ID món ăn cần chỉnh sửa
   * @returns Observable kết quả dialog
   */
  openEditDialog(menuItemId: string): Observable<boolean> {
    const dialogData: MenuItemFormData = {
      menuItemId,
      title: 'Cập nhật món ăn',
    };

    return this.openDialog(dialogData);
  }

  private openDialog(data: MenuItemFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.menuItemId) {
        // Edit mode: load entity data
        this.menuItemService.get(data.menuItemId).subscribe({
          next: (menuItem: MenuItemDto) => {
            data.menuItem = menuItem;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading menu item:', error);
            observer.error(error);
          },
        });
      } else {
        // Create mode: no additional data needed
        this.createDialog(data, observer);
      }
    });
  }

  private createDialog(
    data: MenuItemFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<MenuItemFormData> = {
      header: data.title,
      width: '700px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false,
      closeOnEscape: true,
      breakpoints: {
        '960px': '80vw',
        '640px': '95vw',
      },
    };

    const ref: DynamicDialogRef = this.dialogService.open(MenuItemFormComponent, config);
    ref.onClose.pipe(map(result => result || false)).subscribe({
      next: result => {
        observer.next(result);
        observer.complete();
      },
      error: error => {
        observer.error(error);
      },
    });
  }
}
