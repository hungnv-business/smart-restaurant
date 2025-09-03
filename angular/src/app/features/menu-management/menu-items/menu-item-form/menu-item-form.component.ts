import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumberModule } from 'primeng/inputnumber';
import { CheckboxModule } from 'primeng/checkbox';
import { DropdownModule } from 'primeng/dropdown';
import { TextareaModule } from 'primeng/textarea';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import {
  MenuItemDto,
  CreateUpdateMenuItemDto,
} from '../../../../proxy/menu-management/menu-items/dto';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { MenuItemFormData } from '../services/menu-item-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { take, finalize } from 'rxjs';

/**
 * Component quản lý form tạo/chỉnh sửa món ăn trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới món ăn với thông tin đầy đủ (VD: "Phở Bò", "Bún Chả Hà Nội")
 * - Chỉnh sửa thông tin món ăn hiện có
 * - Chọn danh mục cho món ăn (Món chính, Thức uống, Trang miệng...)
 * - Thiết lập giá tiền theo VND
 * - Upload hình ảnh món ăn
 * - Quản lý trạng thái có sẵn/hết hàng
 * - Validation dữ liệu đầu vào
 */
@Component({
  selector: 'app-menu-item-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumberModule,
    CheckboxModule,
    DropdownModule,
    TextareaModule,
    ProgressSpinnerModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './menu-item-form.component.html',
  styleUrls: ['./menu-item-form.component.scss'],
})
export class MenuItemFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin món ăn */
  form: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Chế độ chỉnh sửa (true) hay tạo mới (false) */
  isEdit = false;
  /** Thông tin món ăn đang được chỉnh sửa */
  menuItem?: MenuItemDto;
  /** Danh sách các danh mục món ăn để lựa chọn */
  categories: MenuCategoryDto[] = [];

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<MenuItemFormData>);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private menuItemService = inject(MenuItemService);
  private menuCategoryService = inject(MenuCategoryService);

  /**
   * Khởi tạo component và tạo form
   */
  constructor() {
    super();
    this.form = this.createForm();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    this.loadCategories();

    const data = this.config.data;
    if (data) {
      this.isEdit = !!data.menuItemId;
      this.menuItem = data.menuItem;

      if (this.isEdit && this.menuItem) {
        this.populateForm(this.menuItem);
      }
    }
  }

  /**
   * Xử lý submit form - validate và lưu món ăn
   */
  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    // Chuyển đổi giá trị form sang DTO
    const formValue = this.form.value;
    const dto: CreateUpdateMenuItemDto = {
      categoryId: formValue.categoryId,
      name: formValue.name,
      description: formValue.description || '', // Mô tả món ăn (tùy chọn)
      price: formValue.price || 0, // Giá tiền VND
      imageUrl: formValue.imageUrl || '', // Đường dẫn hình ảnh (tùy chọn)
      isAvailable: formValue.isAvailable, // Trạng thái có sẵn
    };

    this.loading = true;
    this.saveMenuItem(dto);
  }

  /**
   * Hủy thao tác và đóng dialog
   */
  onCancel() {
    this.ref.close(false);
  }

  /**
   * Lấy danh sách tùy chọn danh mục cho dropdown
   * @returns Mảng các option cho PrimeNG Dropdown
   */
  getCategoryOptions() {
    return this.categories.map(category => ({
      label: category.name, // Hiển thị: "Món chính", "Thức uống", etc.
      value: category.id,   // Giá trị: UUID của danh mục
    }));
  }

  /**
   * Tải danh sách các danh mục món ăn từ server
   */
  private loadCategories() {
    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      sorting: 'displayOrder',
    };

    this.menuCategoryService.getList(request).subscribe({
      next: result => {
        this.categories = result?.items || [];
      },
      error: error => {
        console.error('Error loading categories:', error);
      },
    });
  }

  /**
   * Lưu món ăn (tạo mới hoặc cập nhật)
   * @param dto Dữ liệu món ăn cần lưu
   */
  private saveMenuItem(dto: CreateUpdateMenuItemDto) {
    const operation =
      this.isEdit && this.menuItem
        ? this.menuItemService.update(this.menuItem.id, dto)
        : this.menuItemService.create(dto);

    const errorMessage = this.isEdit ? 'Không thể cập nhật món ăn' : 'Không thể tạo món ăn';

    operation
      .pipe(
        take(1),
        finalize(() => (this.loading = false)),
      )
      .subscribe({
        next: () => {
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  /**
   * Tạo reactive form với các validation rules
   * @returns FormGroup đã cấu hình
   */
  private createForm(): FormGroup {
    return this.fb.group({
      categoryId: ['', [Validators.required]],
      name: ['', [Validators.required, Validators.maxLength(200)]],
      description: ['', [Validators.maxLength(1000)]],
      price: [0, [Validators.required, Validators.min(0)]],
      imageUrl: ['', [Validators.maxLength(500)]],
      isAvailable: [true],
    });
  }

  /**
   * Điền dữ liệu món ăn vào form khi chỉnh sửa
   * @param menuItem Dữ liệu món ăn cần điền vào form
   */
  private populateForm(menuItem: MenuItemDto) {
    this.form.patchValue({
      categoryId: menuItem.categoryId ?? '',
      name: menuItem.name ?? '',
      description: menuItem.description ?? '',
      price: menuItem.price ?? 0,
      imageUrl: menuItem.imageUrl ?? '',
      isAvailable: menuItem.isAvailable ?? true,
    });

    this.form.markAsPristine();
  }
}
