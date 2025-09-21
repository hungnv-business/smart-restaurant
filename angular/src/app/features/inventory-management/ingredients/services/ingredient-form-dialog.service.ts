import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { IngredientFormComponent } from '../ingredient-form/ingredient-form.component';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientDto } from '../../../../proxy/inventory-management/ingredients/dto';

/**
 * Interface định nghĩa data truyền vào dialog form quản lý nguyên liệu
 * Sử dụng để truyền thông tin cần thiết từ parent component đến form dialog
 */
export interface IngredientFormData {
  /** ID của nguyên liệu (chỉ có khi edit) */
  ingredientId?: string;
  /** Dữ liệu nguyên liệu đã load từ server (mode edit) */
  ingredient?: IngredientDto;
  /** Tiêu đề hiển thị trên dialog */
  title?: string;
}

/**
 * Service quản lý dialog form cho nguyên liệu trong hệ thống kho nhà hàng
 *
 * Chức năng chính:
 * - Mở dialog tạo mới nguyên liệu với form đầy đủ tính năng
 * - Mở dialog chỉnh sửa nguyên liệu với dữ liệu được load từ server
 * - Quản lý đơn vị cơ bản và các đơn vị mua hàng (multi-unit system)
 * - Cấu hình dialog responsive cho các thiết bị khác nhau
 * - Xử lý data flow giữa list component và complex form component
 *
 * @example
 * // Tạo mới nguyên liệu
 * dialogService.openCreateDialog().subscribe(result => {
 *   if (result) this.refreshList();
 * });
 *
 * // Chỉnh sửa nguyên liệu
 * dialogService.openEditDialog(ingredientId).subscribe(result => {
 *   if (result) this.refreshList();
 * });
 */
@Injectable({
  providedIn: 'root',
})
export class IngredientFormDialogService {
  /** Service để quản lý dynamic dialog */
  private dialogService = inject(DialogService);
  /** Service API để thao tác với nguyên liệu */
  private ingredientService = inject(IngredientService);

  /**
   * Mở dialog tạo mới nguyên liệu
   * Form sẽ có các trường: tên, danh mục, đơn vị cơ bản, giá, nhà cung cấp
   * Và danh sách đơn vị mua hàng với tỷ lệ quy đổi
   *
   * @returns Observable<boolean> - true nếu tạo thành công, false nếu hủy
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: IngredientFormData = {
      title: 'Thêm nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa nguyên liệu
   * Tự động load dữ liệu nguyên liệu và các đơn vị mua hàng từ server
   *
   * @param ingredientId - ID của nguyên liệu cần chỉnh sửa
   * @returns Observable<boolean> - true nếu cập nhật thành công, false nếu hủy
   */
  openEditDialog(ingredientId: string): Observable<boolean> {
    const dialogData: IngredientFormData = {
      ingredientId,
      title: 'Cập nhật nguyên liệu',
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
  private openDialog(data: IngredientFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.ingredientId) {
        // Mode chỉnh sửa: Load thông tin nguyên liệu và đơn vị mua hàng
        this.ingredientService.get(data.ingredientId).subscribe({
          next: (ingredient: IngredientDto) => {
            data.ingredient = ingredient;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Lỗi khi tải thông tin nguyên liệu:', error);
            observer.error(error);
          },
        });
      } else {
        // Mode tạo mới: Không cần load thêm dữ liệu
        this.createDialog(data, observer);
      }
    });
  }

  /**
   * Tạo và hiển thị dialog với cấu hình responsive
   * Dialog rộng hơn do có nhiều trường và bảng đơn vị mua hàng
   *
   * @param data - Dữ liệu truyền vào dialog
   * @param observer - Observer để notify kết quả
   * @private
   */
  private createDialog(
    data: IngredientFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    // Cấu hình dialog rộng hơn để chứa form phức tạp và bảng đơn vị
    const config: DynamicDialogConfig<IngredientFormData> = {
      header: data.title,
      width: '700px', // Rộng hơn so với category form
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false, // Không cho phép đóng khi click overlay
      closeOnEscape: true, // Cho phép đóng bằng phím Escape
      breakpoints: {
        '960px': '80vw', // Tablet: 80% viewport width
        '640px': '95vw', // Mobile: 95% viewport width
      },
    };

    // Mở dialog và lắng nghe kết quả
    const ref: DynamicDialogRef = this.dialogService.open(IngredientFormComponent, config);

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
