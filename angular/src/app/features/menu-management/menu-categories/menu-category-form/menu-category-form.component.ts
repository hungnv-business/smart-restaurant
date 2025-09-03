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

/**
 * Component quản lý form tạo/chỉnh sửa danh mục món ăn trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới danh mục món ăn (VD: "Món chính", "Thức uống", "Trang miệng")
 * - Chỉnh sửa thông tin danh mục hiện có
 * - Quản lý thứ tự hiển thị trên menu
 * - Upload hình ảnh cho danh mục
 * - Bật/tắt trạng thái hoạt động
 * - Validation dữ liệu đầu vào
 */
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
  /** Form quản lý thông tin danh mục món ăn */
  form: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Chế độ chỉnh sửa (true) hay tạo mới (false) */
  isEdit = false;
  /** Thông tin danh mục đang được chỉnh sửa */
  category?: MenuCategoryDto;

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<MenuCategoryFormData>);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private menuCategoryService = inject(MenuCategoryService);

  /**
   * Khởi tạo component và tạo form
   */
  constructor() {
    super();
    this.form = this.createForm();
  }

  /**
   * Khởi tạo form và load dữ liệu dựa trên chế độ (Tạo mới/Chỉnh sửa)
   */
  ngOnInit() {
    const data = this.config.data;
    if (data) {
      // Chuyển đổi categoryId thành boolean để xác định chế độ
      this.isEdit = !!data.categoryId;
      this.category = data.category;

      if (this.isEdit && this.category) {
        // Chế độ chỉnh sửa: dữ liệu đã được tải sẵn bởi dialog service
        this.populateForm(this.category);
      } else if (data.nextDisplayOrder) {
        // Chế độ tạo mới: chỉ thiết lập thứ tự hiển thị từ server
        this.form.patchValue({
          displayOrder: data.nextDisplayOrder,
        });
      }
    }
  }

  /**
   * Xử lý submit form - validate và gửi dữ liệu lên server
   */
  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    // Chuyển đổi giá trị form sang DTO, xử lý giá trị null/undefined
    const formValue = this.form.value;
    const dto: CreateUpdateMenuCategoryDto = {
      name: formValue.name,
      description: formValue.description || '', // Chuyển đổi null/undefined thành chuỗi rỗng
      displayOrder: formValue.displayOrder,
      isEnabled: formValue.isEnabled,
      imageUrl: formValue.imageUrl || '', // Chuyển đổi null/undefined thành chuỗi rỗng
    };

    this.loading = true;
    this.saveCategory(dto);
  }

  /**
   * Hủy form và đóng dialog
   */
  onCancel() {
    this.ref.close(false); // false = không có thay đổi, component cha không tải lại dữ liệu
  }

  /**
   * Gửi request tạo mới/cập nhật danh mục lên server
   * @param dto Dữ liệu danh mục cần lưu
   */
  private saveCategory(dto: CreateUpdateMenuCategoryDto) {
    // Pattern điều kiện: chọn API call dựa trên chế độ
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
          this.ref.close(true); // true = có thay đổi, component cha sẽ tải lại dữ liệu
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  /**
   * Tạo reactive form với các quy tắc validation
   * @returns FormGroup đã được cấu hình
   */
  private createForm(): FormGroup {
    return this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(128)]],
      description: ['', [Validators.maxLength(512)]],
      displayOrder: [1, [Validators.required, Validators.min(1)]],
      isEnabled: [true],
      imageUrl: ['', [Validators.maxLength(2048), CustomValidators.url()]],
    });
  }

  /**
   * Điền dữ liệu vào form khi ở chế độ chỉnh sửa
   * @param category Dữ liệu danh mục cần điền vào form
   */
  private populateForm(category: MenuCategoryDto) {
    this.form.patchValue({
      name: category.name ?? '', // Nullish coalescing: null/undefined thành chuỗi rỗng
      description: category.description ?? '',
      displayOrder: category.displayOrder ?? 1, // Giá trị mặc định là 1 nếu null
      isEnabled: category.isEnabled ?? true, // Giá trị mặc định là true nếu null
      imageUrl: category.imageUrl ?? '',
    });

    // Đánh dấu form là "sạch" để tránh hiển thị trạng thái dirty sau khi load
    this.form.markAsPristine();
  }
}
