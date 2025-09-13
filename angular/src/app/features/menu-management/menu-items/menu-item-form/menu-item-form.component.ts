import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumberModule } from 'primeng/inputnumber';
import { CheckboxModule } from 'primeng/checkbox';
import { DropdownModule } from 'primeng/dropdown';
import { TextareaModule } from 'primeng/textarea';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import {
  MenuItemDto,
  CreateUpdateMenuItemDto,
  MenuItemIngredientDto,
} from '../../../../proxy/menu-management/menu-items/dto';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';
import {
  IngredientDto,
  GetIngredientListRequestDto,
} from '../../../../proxy/inventory-management/ingredients/dto';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { MenuItemFormData } from '../services/menu-item-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { take, finalize } from 'rxjs';
import { GlobalService } from '@proxy/common';
import { GuidLookupItemDto } from '@proxy/common/dto';

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
    ButtonModule,
    CardModule,
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
  menuCategories: GuidLookupItemDto[] = [];
  /** Danh sách các danh mục nguyên liệu để lựa chọn */
  ingredientCategories: GuidLookupItemDto[] = [];
  /** Danh sách các nguyên liệu có sẵn */
  ingredients: GuidLookupItemDto[] = [];

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<MenuItemFormData>);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private menuItemService = inject(MenuItemService);
  private globalService = inject(GlobalService);

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
    this.loadMenuCategories();
    this.loadIngredientCCategories();

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
      ingredients: formValue.ingredients || [], // Danh sách nguyên liệu
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
   * Lấy FormArray của ingredients
   */
  get ingredientsFormArray(): FormArray {
    return this.form.get('ingredients') as FormArray;
  }

  /**
   * Thêm nguyên liệu mới vào form
   */
  addIngredient() {
    const ingredientGroup = this.fb.group({
      categoryId: ['', [Validators.required]],
      ingredientId: ['', [Validators.required]],
      requiredQuantity: [1, [Validators.required, Validators.min(1)]],
      displayOrder: [0], // Giá trị mặc định, không hiển thị UI
    });

    this.ingredientsFormArray.push(ingredientGroup);
  }

  /**
   * Xóa nguyên liệu khỏi form
   */
  removeIngredient(index: number) {
    this.ingredientsFormArray.removeAt(index);
  }

  /**
   * Xử lý khi thay đổi danh mục nguyên liệu
   * Load danh sách nguyên liệu thuộc danh mục và reset các field liên quan
   * @param categoryId - ID của danh mục được chọn
   */
  onCategoryChange(categoryId: string | null) {
    if (categoryId) {
      this.loadIngredientsByCategory(categoryId);
    } else {
      // Xóa danh sách nguyên liệu và reset form khi bỏ chọn danh mục
      this.ingredients = [];
    }
  }

  /**
   * Tải danh sách nguyên liệu thuộc danh mục đã chọn
   * @param categoryId - ID của danh mục nguyên liệu
   * @private
   */
  private loadIngredientsByCategory(categoryId: string) {
    this.globalService.getIngredientsByCategoryLookup(categoryId).subscribe({
      next: ingredients => {
        this.ingredients = ingredients;
      },
      error: error => {
        console.error('Lỗi khi tải danh sách nguyên liệu:', error);
      },
    });
  }

  /**
   * Tải danh sách các danh mục món ăn từ server
   */
  private loadMenuCategories() {
    this.globalService.getMenuCategoriesLookup().subscribe({
      next: result => {
        this.menuCategories = result || [];
      },
      error: error => {
        console.error('Error loading categories:', error);
      },
    });
  }

  /**
   * Tải danh sách các danh mục nguyên liệu từ server
   */
  private loadIngredientCCategories() {
    this.globalService.getIngredientCategoriesLookup().subscribe({
      next: result => {
        this.ingredientCategories = result || [];
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
      ingredients: this.fb.array([]), // FormArray cho danh sách nguyên liệu
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
