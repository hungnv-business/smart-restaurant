import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { Checkbox } from 'primeng/checkbox';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import {
  IngredientCategoryDto,
  CreateUpdateIngredientCategoryDto,
} from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { IngredientCategoryFormData } from '../services/ingredient-category-form-dialog.service';
import { take, finalize } from 'rxjs';
import { TextareaModule } from 'primeng/textarea';

/**
 * Component quản lý form tạo/chỉnh sửa danh mục nguyên liệu trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới danh mục nguyên liệu (VD: "Thịt", "Rau củ", "Gia vị")
 * - Chỉnh sửa thông tin danh mục hiện có
 * - Quản lý thứ tự hiển thị trong hệ thống kho
 * - Bật/tắt trạng thái hoạt động
 * - Validation dữ liệu đầu vào
 * - Tự động tính toán thứ tự hiển thị tiếp theo
 */
@Component({
  selector: 'app-ingredient-category-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    TextareaModule,
    InputNumber,
    Checkbox,
    ProgressSpinnerModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './ingredient-category-form.component.html',
  styleUrls: ['./ingredient-category-form.component.scss'],
})
export class IngredientCategoryFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin danh mục nguyên liệu */
  form: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Chế độ chỉnh sửa (true) hay tạo mới (false) */
  isEdit = false;
  /** Thông tin danh mục đang được chỉnh sửa */
  category?: IngredientCategoryDto;

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<IngredientCategoryFormData>);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private ingredientCategoryService = inject(IngredientCategoryService);

  /**
   * Khởi tạo component và tạo form
   */
  constructor() {
    super();
    this.form = this.createForm();
  }

  // Khởi tạo form và load data dựa trên mode (Create/Edit)
  ngOnInit() {
    const data = this.config.data;
    if (data) {
      // Convert categoryId thành boolean để xác định mode
      this.isEdit = !!data.categoryId;
      this.category = data.category;

      if (this.isEdit && this.category) {
        // Edit mode: data đã được pre-load bởi dialog service
        this.populateForm(this.category);
      } else if (data.nextDisplayOrder) {
        // Create mode: chỉ set display order từ server
        this.form.patchValue({
          displayOrder: data.nextDisplayOrder,
        });
      }
    }
  }

  // Xử lý submit form - validate và gửi data lên server
  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    // Map form values sang DTO, xử lý empty string thành empty string
    const formValue = this.form.value;
    const dto: CreateUpdateIngredientCategoryDto = {
      name: formValue.name,
      description: formValue.description || '', // Convert null/undefined thành empty string
      displayOrder: formValue.displayOrder,
      isActive: formValue.isActive,
    };

    this.loading = true;
    this.saveCategory(dto);
  }

  // Hủy form và đóng dialog
  onCancel() {
    this.ref.close(false); // false = không có thay đổi, parent component không reload data
  }

  // Gửi request Create/Update lên server
  private saveCategory(dto: CreateUpdateIngredientCategoryDto) {
    // Conditional operation pattern: chọn API call dựa trên mode
    const operation =
      this.isEdit && this.category
        ? this.ingredientCategoryService.update(this.category.id, dto)
        : this.ingredientCategoryService.create(dto);

    const errorMessage = this.isEdit
      ? 'Không thể cập nhật danh mục nguyên liệu'
      : 'Không thể tạo danh mục nguyên liệu';

    operation
      .pipe(
        take(1), // Chỉ lấy 1 emission rồi auto-unsubscribe
        finalize(() => (this.loading = false)), // Cleanup: luôn tắt loading dù success hay error
      )
      .subscribe({
        next: () => {
          this.ref.close(true); // true = có thay đổi, parent component sẽ reload data
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  // Tạo reactive form với validation rules
  private createForm(): FormGroup {
    return this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(100)]],
      description: ['', [Validators.maxLength(500)]],
      displayOrder: [1, [Validators.required, Validators.min(1)]],
      isActive: [true],
    });
  }

  // Điền data vào form khi Edit mode
  private populateForm(category: IngredientCategoryDto) {
    this.form.patchValue({
      name: category.name ?? '', // Nullish coalescing: null/undefined thành empty string
      description: category.description ?? '',
      displayOrder: category.displayOrder ?? 1, // Fallback về 1 nếu null
      isActive: category.isActive ?? true, // Fallback về true nếu null
    });

    // Đánh dấu form là "clean" để tránh hiển thị dirty state sau khi load
    this.form.markAsPristine();
  }
}
