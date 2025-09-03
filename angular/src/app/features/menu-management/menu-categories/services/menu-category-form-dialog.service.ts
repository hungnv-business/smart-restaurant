import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MenuCategoryFormComponent } from '../menu-category-form/menu-category-form.component';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';

/**
 * Interface định nghĩa dữ liệu truyền vào dialog form danh mục món ăn
 * Đảm bảo type safety và có thể sử dụng cho cả Create và Edit mode
 */
export interface MenuCategoryFormData {
  categoryId?: string; // ID danh mục (có trong Edit mode)
  category?: MenuCategoryDto; // Entity data đã load từ server (Edit mode)
  title?: string; // Tiêu đề dialog
  nextDisplayOrder?: number; // Thứ tự hiển thị tiếp theo (Create mode)
}

/**
 * Service quản lý dialog form cho danh mục món ăn
 * Chức năng chính:
 * - Mở dialog tạo mới danh mục với auto-load nextDisplayOrder
 * - Mở dialog chỉnh sửa với pre-load dữ liệu
 * - Cấu hình responsive dialog cho màn hình khác nhau
 * - Xử lý kết quả dialog và thông báo thành công/lỗi
 */
@Injectable({
  providedIn: 'root',
})
export class MenuCategoryFormDialogService {
  /** Service để mở dialog PrimeNG */
  private dialogService = inject(DialogService);
  /** Service API quản lý danh mục món ăn */
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
   * Xử lý 2 flow khác nhau:
   * - Edit mode: Load thông tin danh mục từ server
   * - Create mode: Load thứ tự hiển thị tiếp theo
   * @param data Cấu hình dialog và dữ liệu ban đầu
   * @returns Observable trả về kết quả dialog (true = thành công, false = hủy)
   */
  private openDialog(data: MenuCategoryFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.categoryId) {
        // Chế độ chỉnh sửa: load dữ liệu danh mục trước khi mở dialog
        this.menuCategoryService.get(data.categoryId).subscribe({
          next: (category: MenuCategoryDto) => {
            data.category = category; // Gán dữ liệu đã load vào data
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading menu category:', error);
            observer.error(error);
          },
        });
      } else {
        // Chế độ tạo mới: load thứ tự hiển thị tiếp theo
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

  /**
   * Tạo và mở dialog với cấu hình responsive
   * @param data Dữ liệu đã được chuẩn bị cho dialog
   * @param observer Observer để trả về kết quả cho caller
   */
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
