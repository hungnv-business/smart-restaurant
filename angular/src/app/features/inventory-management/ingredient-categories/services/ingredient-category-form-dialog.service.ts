import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { IngredientCategoryFormComponent } from '../ingredient-category-form/ingredient-category-form.component';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';

// Interface định nghĩa data truyền vào dialog form
export interface IngredientCategoryFormData {
  categoryId?: string; // ID danh mục (có trong Edit mode)
  category?: IngredientCategoryDto; // Entity data đã load từ server (Edit mode)
  title?: string; // Tiêu đề dialog
  nextDisplayOrder?: number; // Thứ tự hiển thị tiếp theo (Create mode)
}

@Injectable({
  providedIn: 'root',
})
export class IngredientCategoryFormDialogService {
  private dialogService = inject(DialogService);
  private ingredientCategoryService = inject(IngredientCategoryService);

  /**
   * Mở dialog thêm mới - tự động load nextDisplayOrder từ server
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: IngredientCategoryFormData = {
      title: 'Thêm danh mục nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa - tự động load entity data từ server
   */
  openEditDialog(categoryId: string): Observable<boolean> {
    const dialogData: IngredientCategoryFormData = {
      categoryId,
      title: 'Cập nhật danh mục nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog - tự động load dữ liệu cần thiết trước khi mở
   */
  private openDialog(data: IngredientCategoryFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.categoryId) {
        // Edit mode: load entity data trước
        this.ingredientCategoryService.get(data.categoryId).subscribe({
          next: (category: IngredientCategoryDto) => {
            data.category = category;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading ingredient category:', error);
            observer.error(error);
          },
        });
      } else {
        // Create mode: load next display order trước
        this.ingredientCategoryService.getNextDisplayOrder().subscribe({
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
    data: IngredientCategoryFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<IngredientCategoryFormData> = {
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

    const ref: DynamicDialogRef = this.dialogService.open(IngredientCategoryFormComponent, config);
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