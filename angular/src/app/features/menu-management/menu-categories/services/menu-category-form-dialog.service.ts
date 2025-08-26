import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MenuCategoryFormComponent } from '../menu-category-form/menu-category-form.component';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';

// Interface định nghĩa data truyền vào dialog form
export interface MenuCategoryFormData {
  categoryId?: string; // ID danh mục (có trong Edit mode)
  category?: MenuCategoryDto; // Entity data đã load từ server (Edit mode)
  title?: string; // Tiêu đề dialog
  nextDisplayOrder?: number; // Thứ tự hiển thị tiếp theo (Create mode)
}

@Injectable({
  providedIn: 'root',
})
export class MenuCategoryFormDialogService {
  private dialogService = inject(DialogService);
  private menuCategoryService = inject(MenuCategoryService);

  /**
   * Mở dialog thêm mới - tự động load nextDisplayOrder từ server
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: MenuCategoryFormData = {
      title: 'Thêm mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa - tự động load entity data từ server
   */
  openEditDialog(categoryId: string): Observable<boolean> {
    const dialogData: MenuCategoryFormData = {
      categoryId,
      title: 'Cập nhật',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog - tự động load dữ liệu cần thiết trước khi mở
   */
  private openDialog(data: MenuCategoryFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.categoryId) {
        // Edit mode: load entity data trước
        this.menuCategoryService.get(data.categoryId).subscribe({
          next: (category: MenuCategoryDto) => {
            data.category = category;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading menu category:', error);
            observer.error(error);
          },
        });
      } else {
        // Create mode: load next display order trước
        this.menuCategoryService.getNextDisplayOrder().subscribe({
          next: (nextDisplayOrder: number) => {
            data.nextDisplayOrder = nextDisplayOrder;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error getting next display order:', error);
            observer.error(error);
          },
        });
      }
    });
  }

  private createDialog(
    data: MenuCategoryFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<MenuCategoryFormData> = {
      header: data.title,
      width: '600px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false,
      closeOnEscape: true,
      breakpoints: {
        '960px': '75vw',
        '640px': '90vw',
      },
    };

    const ref: DynamicDialogRef = this.dialogService.open(MenuCategoryFormComponent, config);
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
