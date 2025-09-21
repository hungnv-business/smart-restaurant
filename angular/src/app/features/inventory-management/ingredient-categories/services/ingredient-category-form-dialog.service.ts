import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { IngredientCategoryFormComponent } from '../ingredient-category-form/ingredient-category-form.component';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';

/**
 * Interface định nghĩa data truyền vào dialog form quản lý danh mục nguyên liệu
 * Sử dụng để truyền thông tin cần thiết từ parent component đến form dialog
 */
export interface IngredientCategoryFormData {
  /** ID của danh mục nguyên liệu (chỉ có khi edit) */
  categoryId?: string;
  /** Dữ liệu danh mục đã load từ server (mode edit) */
  category?: IngredientCategoryDto;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
  /** Thứ tự hiển thị tiếp theo cho danh mục mới (mode create) */
  nextDisplayOrder?: number;
}

/**
 * Service quản lý dialog form cho danh mục nguyên liệu trong hệ thống kho nhà hàng
 *
 * Chức năng chính:
 * - Mở dialog tạo mới danh mục nguyên liệu với thứ tự hiển thị tự động
 * - Mở dialog chỉnh sửa danh mục với dữ liệu được load từ server
 * - Cấu hình dialog responsive cho các thiết bị khác nhau
 * - Xử lý data flow giữa list component và form component
 *
 * @example
 * // Tạo mới danh mục
 * dialogService.openCreateDialog().subscribe(result => {
 *   if (result) this.refreshList();
 * });
 *
 * // Chỉnh sửa danh mục
 * dialogService.openEditDialog(categoryId).subscribe(result => {
 *   if (result) this.refreshList();
 * });
 */
@Injectable({
  providedIn: 'root',
})
export class IngredientCategoryFormDialogService {
  /** Service để quản lý dynamic dialog */
  private dialogService = inject(DialogService);
  /** Service API để thao tác với danh mục nguyên liệu */
  private ingredientCategoryService = inject(IngredientCategoryService);

  /**
   * Mở dialog tạo mới danh mục nguyên liệu
   * Tự động lấy thứ tự hiển thị tiếp theo từ server để đảm bảo tính nhất quán
   *
   * @returns Observable<boolean> - true nếu tạo thành công, false nếu hủy
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: IngredientCategoryFormData = {
      title: 'Thêm danh mục nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa danh mục nguyên liệu
   * Tự động load dữ liệu danh mục từ server trước khi hiển thị form
   *
   * @param categoryId - ID của danh mục nguyên liệu cần chỉnh sửa
   * @returns Observable<boolean> - true nếu cập nhật thành công, false nếu hủy
   */
  openEditDialog(categoryId: string): Observable<boolean> {
    const dialogData: IngredientCategoryFormData = {
      categoryId,
      title: 'Cập nhật danh mục nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method core để mở dialog - xử lý logic load dữ liệu trước khi hiển thị
   * Tự động phân biệt mode Create/Edit và load dữ liệu tương ứng
   *
   * @param data - Thông tin cấu hình dialog
   * @returns Observable<boolean> - Kết quả thao tác
   * @private
   */
  private openDialog(data: IngredientCategoryFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.categoryId) {
        // Mode chỉnh sửa: Load thông tin danh mục từ server
        this.ingredientCategoryService.get(data.categoryId).subscribe({
          next: (category: IngredientCategoryDto) => {
            data.category = category;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Lỗi khi tải thông tin danh mục nguyên liệu:', error);
            observer.error(error);
          },
        });
      } else {
        // Mode tạo mới: Lấy số thứ tự hiển thị tiếp theo
        this.ingredientCategoryService.getNextDisplayOrder().subscribe({
          next: (nextDisplayOrder: number) => {
            data.nextDisplayOrder = nextDisplayOrder;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Lỗi khi lấy thứ tự hiển thị tiếp theo:', error);
            observer.error(error);
          },
        });
      }
    });
  }

  /**
   * Tạo và hiển thị dialog với cấu hình responsive
   * Xử lý kết quả trả về từ dialog và notify observer
   *
   * @param data - Dữ liệu truyền vào dialog
   * @param observer - Observer để notify kết quả
   * @private
   */
  private createDialog(
    data: IngredientCategoryFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    // Cấu hình dialog với responsive breakpoints
    const config: DynamicDialogConfig<IngredientCategoryFormData> = {
      header: data.title,
      width: '600px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false, // Không cho phép đóng khi click overlay
      closeOnEscape: true, // Cho phép đóng bằng phím Escape
      breakpoints: {
        '960px': '75vw', // Tablet: 75% viewport width
        '640px': '90vw', // Mobile: 90% viewport width
      },
    };

    // Mở dialog và lắng nghe kết quả
    const ref: DynamicDialogRef = this.dialogService.open(IngredientCategoryFormComponent, config);

    // Transform kết quả: null/undefined thành false, các giá trị khác giữ nguyên
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
