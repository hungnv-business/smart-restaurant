import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, FormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { SelectModule } from 'primeng/select';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { TooltipModule } from 'primeng/tooltip';
import {
  IngredientDto,
  CreateUpdateIngredientDto,
  IngredientPurchaseUnitDto,
  CreateUpdatePurchaseUnitDto,
} from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { UnitDto } from '../../../../proxy/common/units/dto';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { IngredientFormData } from '../services/ingredient-form-dialog.service';
import { IngredientUnitListComponent } from './ingredient-unit-list/ingredient-unit-list.component';
import { IngredientUnitService } from '../services/ingredient-unit.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { take, finalize } from 'rxjs';
import { GlobalService } from '@proxy/common';

/**
 * Component quản lý form tạo/chỉnh sửa nguyên liệu trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới nguyên liệu (VD: "Thịt bò", "Cà rốt", "Hành tây")
 * - Chỉnh sửa thông tin nguyên liệu hiện có
 * - Chọn danh mục cho nguyên liệu (Thịt, Rau củ, Gia vị...)
 * - Thiết lập đơn vị cơ bản (kg, g, lít...)
 * - Quản lý các đơn vị mua hàng khác nhau (thùng, bao, kiện...)
 * - Thiết lập giá cá và thông tin nhà cung cấp
 * - Bật/tắt trạng thái hoạt động
 * - Validation dữ liệu đầu vào
 */
@Component({
  selector: 'app-ingredient-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    InputTextModule,
    InputNumber,
    SelectModule,
    ProgressSpinnerModule,
    TableModule,
    ButtonModule,
    DialogModule,
    TooltipModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
    IngredientUnitListComponent,
  ],
  templateUrl: './ingredient-form.component.html',
  styleUrls: ['./ingredient-form.component.scss'],
})
export class IngredientFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin nguyên liệu */
  form: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Chế độ chỉnh sửa (true) hay tạo mới (false) */
  isEdit = false;
  /** Thông tin nguyên liệu đang được chỉnh sửa */
  ingredient?: IngredientDto;
  /** Danh sách các danh mục nguyên liệu để lựa chọn */
  categories: IngredientCategoryDto[] = [];
  /** Danh sách các đơn vị đo lường (kg, g, lít...) */
  units: UnitDto[] = [];
  /** Danh sách các đơn vị mua hàng (thùng, bao, kiện...) */
  purchaseUnits: CreateUpdatePurchaseUnitDto[] = [];

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<IngredientFormData>);
  private ingredientUnitService = inject(IngredientUnitService);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private ingredientService = inject(IngredientService);
  private ingredientCategoryService = inject(IngredientCategoryService);
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
    this.loadCategories();
    this.loadUnits();

    const data = this.config.data;
    if (data) {
      this.isEdit = !!data.ingredientId;
      this.ingredient = data.ingredient;

      if (this.isEdit && this.ingredient) {
        this.populateForm(this.ingredient);
        this.loadPurchaseUnits();
      }
    }
  }

  /**
   * Xử lý submit form - validate và lưu nguyên liệu
   */
  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    // Chuyển đổi giá trị form sang DTO
    const formValue = this.form.value;
    const dto: CreateUpdateIngredientDto = {
      categoryId: formValue.categoryId, // Danh mục nguyên liệu
      name: formValue.name, // Tên nguyên liệu (VD: "Thịt bò")
      unitId: formValue.unitId, // Đơn vị cơ bản (kg, g...)
      costPerUnit: formValue.costPerUnit || null, // Giá trên đơn vị
      supplierInfo: formValue.supplierInfo || '', // Thông tin nhà cung cấp
      isActive: formValue.isActive, // Trạng thái hoạt động
      purchaseUnits: this.preparePurchaseUnits(), // Các đơn vị mua hàng
    };

    this.loading = true;
    this.saveIngredient(dto);
  }

  /**
   * Hủy thao tác và đóng dialog
   */
  onCancel() {
    this.ref.close(false);
  }

  /**
   * Tải danh sách các danh mục nguyên liệu hoạt động
   * Sắp xếp theo thứ tự hiển thị để hiển thị đúng thứ tự trong dropdown
   * @private
   */
  private loadCategories() {
    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      sorting: 'displayOrder', // Sắp xếp theo thứ tự hiển thị
    };

    this.ingredientCategoryService.getList(request).subscribe({
      next: result => {
        // Chỉ lấy các danh mục đang hoạt động
        this.categories = result?.items?.filter(c => c.isActive) || [];
      },
      error: error => {
        console.error('Lỗi khi tải danh sách danh mục nguyên liệu:', error);
      },
    });
  }

  /**
   * Tải danh sách các đơn vị đo lường từ hệ thống
   * Bao gồm các đơn vị cơ bản như kg, g, lít, ml, cái, gói...
   * @private
   */
  private loadUnits() {
    this.globalService.getUnits().subscribe({
      next: units => {
        this.units = units || [];
      },
      error: error => {
        console.error('Lỗi khi tải danh sách đơn vị đo lường:', error);
      },
    });
  }

  /**
   * Lưu thông tin nguyên liệu (tạo mới hoặc cập nhật)
   * Bao gồm cả thông tin các đơn vị mua hàng và quy đổi
   * 
   * @param dto - Dữ liệu nguyên liệu cần lưu
   * @private
   */
  private saveIngredient(dto: CreateUpdateIngredientDto) {
    // Chọn operation phù hợp dựa vào mode (create/edit)
    const operation =
      this.isEdit && this.ingredient
        ? this.ingredientService.update(this.ingredient.id, dto)
        : this.ingredientService.create(dto);

    const errorMessage = this.isEdit
      ? 'Không thể cập nhật nguyên liệu'
      : 'Không thể tạo nguyên liệu';

    operation
      .pipe(
        take(1),
        finalize(() => (this.loading = false)),
      )
      .subscribe({
        next: () => {
          // Đóng dialog với kết quả thành công
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  /**
   * Tạo reactive form với các validation rules
   * @private
   * @returns FormGroup với các control và validator
   */
  private createForm(): FormGroup {
    return this.fb.group({
      categoryId: ['', [Validators.required]], // Bắt buộc chọn danh mục
      name: ['', [Validators.required, Validators.maxLength(100)]], // Tên nguyên liệu
      unitId: ['', [Validators.required]], // Bắt buộc chọn đơn vị cơ bản
      costPerUnit: [null], // Giá trên đơn vị (có thể để trống)
      supplierInfo: ['', [Validators.maxLength(200)]], // Thông tin nhà cung cấp
      isActive: [true], // Mặc định là hoạt động
    });
  }

  /**
   * Điền dữ liệu nguyên liệu vào form (mode chỉnh sửa)
   * @param ingredient - Dữ liệu nguyên liệu cần hiển thị
   * @private
   */
  private populateForm(ingredient: IngredientDto) {
    this.form.patchValue({
      categoryId: ingredient.categoryId ?? '',
      name: ingredient.name ?? '',
      unitId: ingredient.unitId ?? '',
      costPerUnit: ingredient.costPerUnit,
      supplierInfo: ingredient.supplierInfo ?? '',
      isActive: ingredient.isActive ?? true,
    });

    // Đánh dấu form là chưa thay đổi (pristine)
    this.form.markAsPristine();
  }

  /**
   * Tải danh sách các đơn vị mua hàng của nguyên liệu (mode chỉnh sửa)
   * Chuyển đổi từ IngredientPurchaseUnitDto sang CreateUpdatePurchaseUnitDto
   * @private
   */
  private loadPurchaseUnits() {
    if (!this.ingredient?.purchaseUnits) return;
    
    // Chỉ lấy các đơn vị đang hoạt động và chuyển đổi format
    this.purchaseUnits = this.ingredient.purchaseUnits
      .filter(unit => unit.isActive)
      .map(unit => ({
        id: unit.id!,
        unitId: unit.unitId!,
        conversionRatio: unit.conversionRatio,
        isBaseUnit: unit.isBaseUnit,
        purchasePrice: unit.purchasePrice,
        isActive: unit.isActive,
      }));
  }


  /**
   * Chuẩn bị dữ liệu các đơn vị mua hàng để gửi lên server
   * @private
   * @returns Mảng các đơn vị mua hàng đã được format
   */
  private preparePurchaseUnits(): CreateUpdatePurchaseUnitDto[] {
    return this.purchaseUnits.map((unit, index) => ({
      id: unit.id || this.generateGuid(),
      unitId: unit.unitId!,
      conversionRatio: unit.conversionRatio,
      isBaseUnit: unit.isBaseUnit,
      purchasePrice: unit.purchasePrice,
      isActive: unit.isActive,
    }));
  }

  /**
   * Xử lý thêm đơn vị mua hàng mới
   * Mở dialog cho phép nhập đơn vị, tỷ lệ quy đổi và giá mua
   */
  onAddUnit() {
    const dialogData = {
      units: this.units,
      baseUnitId: this.form.get('unitId')?.value || '',
      existingUnits: this.purchaseUnits
    };

    this.ingredientUnitService.openAddUnitModal(dialogData).subscribe({
      next: (result) => {
        if (result) {
          // Gán id cho đơn vị mới và thêm vào danh sách
          result.id = this.generateGuid();
          this.purchaseUnits.push(result);
        }
      }
    });
  }

  /**
   * Xử lý chỉnh sửa đơn vị mua hàng
   * Mở dialog với thông tin hiện tại của đơn vị để chỉnh sửa
   * 
   * @param unit - Đơn vị mua hàng cần chỉnh sửa
   */
  onEditUnit(unit: CreateUpdatePurchaseUnitDto) {
    const dialogData = {
      editingUnit: unit,
      units: this.units,
      baseUnitId: this.form.get('unitId')?.value || '',
      existingUnits: this.purchaseUnits
    };
    this.ingredientUnitService.openEditUnitModal(dialogData).subscribe({
      next: (result) => {
        if (result) {
          // Cập nhật đơn vị trong danh sách
          const index = this.purchaseUnits.findIndex(u => u === unit);
          if (index > -1) {
            this.purchaseUnits[index] = result;
          }
        }
      }
    });
  }

  /**
   * Xử lý xóa đơn vị mua hàng khỏi danh sách
   * @param unit - Đơn vị mua hàng cần xóa
   */
  onDeleteUnit(unit: CreateUpdatePurchaseUnitDto) {
    const index = this.purchaseUnits.findIndex(u => u === unit);
    if (index > -1) {
      this.purchaseUnits.splice(index, 1);
    }
  }

  /**
   * Lấy tên đơn vị đo lường theo ID
   * @param unitId - ID của đơn vị đo lường
   * @returns Tên đơn vị hoặc 'N/A' nếu không tìm thấy
   */
  getUnitName(unitId: string): string {
    return this.units.find(u => u.id === unitId)?.name || 'N/A';
  }

  /**
   * Tạo GUID mới cho PurchaseUnit
   * @private
   * @returns GUID string
   */
  private generateGuid(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}
