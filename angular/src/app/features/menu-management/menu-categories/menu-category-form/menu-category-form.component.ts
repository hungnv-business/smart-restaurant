import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { TextareaModule } from 'primeng/textarea';
import { InputNumberModule } from 'primeng/inputnumber';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import {
  MenuCategoryDto,
  CreateUpdateMenuCategoryDto,
} from '../../../../proxy/menu-management/menu-categories/dto';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { MenuCategoryFormData } from '../services/menu-category-form-dialog.service';
import { CustomValidators } from '../../../../shared/validators/custom-validators';
import { take, finalize } from 'rxjs';

@Component({
  selector: 'app-menu-category-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    TextareaModule,
    InputNumberModule,
    ProgressSpinnerModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './menu-category-form.component.html',
  styleUrls: ['./menu-category-form.component.scss'],
})
export class MenuCategoryFormComponent extends ComponentBase implements OnInit {
  form: FormGroup;
  loading = false;
  isEdit = false;
  category?: MenuCategoryDto;

  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<MenuCategoryFormData>);

  private fb = inject(FormBuilder);
  private menuCategoryService = inject(MenuCategoryService);

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
    const dto: CreateUpdateMenuCategoryDto = {
      name: formValue.name,
      description: formValue.description || '', // Convert null/undefined thành empty string
      displayOrder: formValue.displayOrder,
      isEnabled: formValue.isEnabled,
      imageUrl: formValue.imageUrl || '', // Convert null/undefined thành empty string
    };

    this.loading = true;
    this.saveCategory(dto);
  }

  // Hủy form và đóng dialog
  onCancel() {
    this.ref.close(false); // false = không có thay đổi, parent component không reload data
  }

  // Gửi request Create/Update lên server
  private saveCategory(dto: CreateUpdateMenuCategoryDto) {
    // Conditional operation pattern: chọn API call dựa trên mode
    const operation =
      this.isEdit && this.category
        ? this.menuCategoryService.update(this.category.id, dto)
        : this.menuCategoryService.create(dto);

    const errorMessage = this.isEdit ? 'Không thể cập nhật danh mục' : 'Không thể tạo danh mục';

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
      name: ['', [Validators.required, Validators.maxLength(128)]],
      description: ['', [Validators.maxLength(512)]],
      displayOrder: [1, [Validators.required, Validators.min(1)]],
      isEnabled: [true],
      imageUrl: ['', [Validators.maxLength(2048), CustomValidators.url()]],
    });
  }

  // Điền data vào form khi Edit mode
  private populateForm(category: MenuCategoryDto) {
    this.form.patchValue({
      name: category.name ?? '', // Nullish coalescing: null/undefined thành empty string
      description: category.description ?? '',
      displayOrder: category.displayOrder ?? 1, // Fallback về 1 nếu null
      isEnabled: category.isEnabled ?? true, // Fallback về true nếu null
      imageUrl: category.imageUrl ?? '',
    });

    // Đánh dấu form là "clean" để tránh hiển thị dirty state sau khi load
    this.form.markAsPristine();
  }
}
