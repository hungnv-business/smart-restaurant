import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  FormsModule,
  Validators,
} from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputNumber } from 'primeng/inputnumber';
import { SelectModule } from 'primeng/select';
import { Checkbox } from 'primeng/checkbox';
import { ButtonModule } from 'primeng/button';
import { CreateUpdatePurchaseUnitDto } from '../../../../../proxy/inventory-management/ingredients/dto';
import { ValidationErrorComponent } from '../../../../../shared/components/validation-error/validation-error.component';
import { ComponentBase } from '../../../../../shared/base/component-base';
import { IngredientUnitDialogData } from '../../services/ingredient-unit.service';
import { FormFooterActionsComponent } from '../../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { GuidLookupItemDto } from '@proxy/common/dto';

/**
 * Component quản lý form thêm/chỉnh sửa đơn vị mua hàng cho nguyên liệu
 *
 * Chức năng chính:
 * - Thêm mới đơn vị mua hàng (VD: thùng, bao, kiện, gói...)
 * - Chỉnh sửa đơn vị mua hàng hiện có
 * - Thiết lập tỷ lệ quy đổi với đơn vị cơ bản (1 thùng = 24 chai)
 * - Thiết lập giá mua cho từng đơn vị
 * - Quản lý đơn vị cơ sở (base unit) - chỉ được có 1 đơn vị
 * - Validation business rules cho inventory system
 *
 * @example
 * // Ví dụ quy đổi đơn vị:
 * // Đơn vị cơ bản: chai (1 chai = 1 chai)
 * // Đơn vị mua: thùng (1 thùng = 24 chai, conversionRatio = 24)
 * // Đơn vị mua: lốc (1 lốc = 6 chai, conversionRatio = 6)
 */
@Component({
  selector: 'app-ingredient-unit-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    FormsModule,
    InputNumber,
    SelectModule,
    Checkbox,
    ButtonModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './ingredient-unit-form.component.html',
  styleUrls: ['./ingredient-unit-form.component.scss'],
})
export class IngredientUnitFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin đơn vị mua hàng */
  unitForm: FormGroup;
  /** Data truyền từ parent component */
  data: IngredientUnitDialogData;

  /** Form builder service */
  private fb = inject(FormBuilder);
  /** Dialog reference để đóng dialog */
  private ref = inject(DynamicDialogRef);
  /** Cấu hình dialog với data truyền vào */
  private config = inject(DynamicDialogConfig);

  /**
   * Khởi tạo component và tạo form
   */
  constructor() {
    super();
    this.data = this.config.data;
    this.unitForm = this.createUnitForm();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   * Reset form với dữ liệu phù hợp cho mode Create/Edit
   */
  ngOnInit() {
    this.resetUnitForm();
  }

  /**
   * Xử lý lưu thông tin đơn vị mua hàng
   * Validate business rules và đóng dialog với kết quả
   */
  onSave() {
    if (!this.validateForm(this.unitForm)) {
      return;
    }

    const unitValue = this.unitForm.value;

    // Business rule: Chỉ được có 1 đơn vị cơ sở trong inventory system
    if (unitValue.isBaseUnit) {
      const hasOtherBaseUnit = this.data.existingUnits.some(
        unit => unit.isBaseUnit && unit !== this.data.editingUnit,
      );

      if (hasOtherBaseUnit) {
        this.showError('Chỉ được có 1 đơn vị cơ sở');
        return;
      }

      // Đơn vị cơ sở luôn có tỷ lệ quy đổi = 1
      unitValue.conversionRatio = 1;
    }

    // Đóng dialog và trả về dữ liệu đơn vị với id
    const result: CreateUpdatePurchaseUnitDto = {
      id: this.data.editingUnit?.id || this.generateGuid(),
      unitId: unitValue.unitId,
      conversionRatio: unitValue.conversionRatio,
      isBaseUnit: unitValue.isBaseUnit,
      purchasePrice: unitValue.purchasePrice,
      isActive: unitValue.isActive,
    };

    this.ref.close(result);
  }

  /**
   * Xử lý hủy thao tác và đóng dialog
   */
  onCancel() {
    this.ref.close();
  }

  /**
   * Getter trả về danh sách các đơn vị đo lường có thể chọn
   * @returns Mảng các đơn vị đo lường từ hệ thống
   */
  get units(): GuidLookupItemDto[] {
    return this.data.units;
  }

  /**
   * Kiểm tra xem có phải đang ở mode chỉnh sửa không
   * @returns true nếu đang chỉnh sửa, false nếu đang thêm mới
   */
  get isEdit(): boolean {
    return !!this.data.editingUnit;
  }

  /**
   * Tạo reactive form với validation rules cho đơn vị mua hàng
   * @private
   * @returns FormGroup với các control và validator
   */
  private createUnitForm(): FormGroup {
    return this.fb.group({
      unitId: ['', [Validators.required]], // Bắt buộc chọn đơn vị
      conversionRatio: [1, [Validators.required, Validators.min(1)]], // Tỷ lệ quy đổi >= 1
      purchasePrice: [null], // Giá mua (có thể để trống)
      isBaseUnit: [false], // Có phải đơn vị cơ sở không
      isActive: [true], // Trạng thái hoạt động
    });
  }

  /**
   * Reset form với dữ liệu phù hợp cho mode Create/Edit
   * Xử lý logic đặc biệt cho đơn vị cơ sở (base unit)
   * @private
   */
  private resetUnitForm() {
    if (this.data.editingUnit) {
      // Mode chỉnh sửa: điền dữ liệu hiện có vào form
      this.unitForm.patchValue({
        unitId: this.data.editingUnit.unitId,
        conversionRatio: this.data.editingUnit.conversionRatio,
        purchasePrice: this.data.editingUnit.purchasePrice,
        isBaseUnit: this.data.editingUnit.isBaseUnit,
        isActive: this.data.editingUnit.isActive,
      });
    } else {
      // Mode thêm mới: thiết lập giá trị mặc định
      const hasBaseUnit = this.data.existingUnits.some(unit => unit.isBaseUnit);

      this.unitForm.reset({
        isActive: true,
        isBaseUnit: !hasBaseUnit, // Nếu chưa có base unit thì đặt là base unit
        conversionRatio: 1, // Mặc định tỷ lệ quy đổi = 1
        purchasePrice: null,
        unitId: !hasBaseUnit ? this.data.baseUnitId : '', // Tự động chọn base unit nếu chưa có
      });
    }
  }

  /**
   * Tạo GUID mới cho PurchaseUnit
   * @private
   * @returns GUID string
   */
  private generateGuid(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      const r = (Math.random() * 16) | 0;
      const v = c == 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }
}
