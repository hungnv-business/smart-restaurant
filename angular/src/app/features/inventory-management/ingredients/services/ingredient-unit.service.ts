import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { CreateUpdatePurchaseUnitDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { UnitDto } from '../../../../proxy/common/units/dto';
import { IngredientUnitFormComponent } from '../ingredient-form/ingredient-unit-form/ingredient-unit-form.component';

/**
 * Interface định nghĩa data truyền vào dialog form đơn vị mua hàng
 * Chứa thông tin cần thiết để quản lý các đơn vị và tỷ lệ quy đổi
 */
export interface IngredientUnitDialogData {
  /** Đơn vị đang chỉnh sửa (null trong mode thêm mới) */
  editingUnit?: CreateUpdatePurchaseUnitDto | null;
  /** Danh sách tất cả đơn vị đo lường từ hệ thống */
  units: UnitDto[];
  /** ID của đơn vị cơ bản đã chọn cho nguyên liệu */
  baseUnitId: string;
  /** Danh sách các đơn vị mua hàng hiện có (để validate trùng lặp) */
  existingUnits: CreateUpdatePurchaseUnitDto[];
}

/**
 * Service quản lý các đơn vị mua hàng của nguyên liệu trong inventory system
 * 
 * Chức năng chính:
 * - Mở dialog thêm mới/chỉnh sửa đơn vị mua hàng
 * - Validate business rules cho multi-unit system
 * - Quản lý đơn vị cơ sở (base unit) - chỉ được có 1
 * - Tính toán tỷ lệ quy đổi giữa các đơn vị
 * - Hiển thị preview chuyển đổi cho user
 * - Utility methods cho unit management
 * 
 * @example
 * // Thêm đơn vị mua hàng mới
 * service.openAddUnitModal(dialogData).subscribe(result => {
 *   if (result) this.purchaseUnits.push(result);
 * });
 * 
 * // Validate đơn vị
 * const errors = service.validatePurchaseUnit(unit, existingUnits);
 */
@Injectable({
  providedIn: 'root'
})
export class IngredientUnitService {
  /** Service để quản lý dynamic dialog */
  private dialogService = inject(DialogService);

  /**
   * Mở dialog thêm đơn vị mua hàng mới
   * Form sẽ có: chọn đơn vị, nhập tỷ lệ quy đổi, giá mua, đánh dấu base unit
   * 
   * @param data - Thông tin cần thiết để hiển thị form
   * @returns Observable với kết quả đơn vị mua hàng mới
   */
  openAddUnitModal(data: IngredientUnitDialogData): Observable<CreateUpdatePurchaseUnitDto> {
    const ref = this.dialogService.open(IngredientUnitFormComponent, {
      header: 'Thêm đơn vị mua',
      width: '500px',
      modal: true,
      closable: true,
      data: { ...data, editingUnit: null } // Đảm bảo mode thêm mới
    });

    return ref.onClose;
  }

  /**
   * Mở dialog chỉnh sửa đơn vị mua hàng hiện có
   * Form sẽ được điền sẵn thông tin của đơn vị đang chỉnh sửa
   * 
   * @param data - Thông tin đơn vị và context cần thiết
   * @returns Observable với kết quả đơn vị mua hàng đã cập nhật
   */
  openEditUnitModal(data: IngredientUnitDialogData): Observable<CreateUpdatePurchaseUnitDto> {
    const ref = this.dialogService.open(IngredientUnitFormComponent, {
      header: 'Chỉnh sửa đơn vị mua',
      width: '500px',
      modal: true,
      closable: true,
      data: data
    });

    return ref.onClose;
  }

  /**
   * Validate business rules cho đơn vị mua hàng
   * Kiểm tra các quy tắc nghiệp vụ của inventory system
   * 
   * @param unit - Đơn vị mua hàng cần validate
   * @param existingUnits - Danh sách các đơn vị hiện có
   * @returns Mảng các thông báo lỗi (rỗng nếu hợp lệ)
   */
  validatePurchaseUnit(unit: CreateUpdatePurchaseUnitDto, existingUnits: CreateUpdatePurchaseUnitDto[]): string[] {
    const errors: string[] = [];

    // Validate các trường bắt buộc
    if (!unit.unitId) {
      errors.push('Đơn vị là bắt buộc');
    }

    if (!unit.conversionRatio || unit.conversionRatio < 1) {
      errors.push('Tỷ lệ chuyển đổi phải >= 1');
    }

    // Kiểm tra trùng lặp đơn vị
    const duplicate = existingUnits.find(existing => 
      existing.unitId === unit.unitId && existing !== unit
    );
    if (duplicate) {
      errors.push('Đơn vị này đã được cấu hình');
    }

    // Validate business rules cho đơn vị cơ sở
    if (unit.isBaseUnit) {
      const otherBaseUnit = existingUnits.find(existing => 
        existing.isBaseUnit && existing !== unit
      );
      if (otherBaseUnit) {
        errors.push('Chỉ được có 1 đơn vị cơ sở');
      }

      // Đơn vị cơ sở luôn có tỷ lệ quy đổi = 1
      if (unit.conversionRatio !== 1) {
        errors.push('Đơn vị cơ sở phải có tỷ lệ chuyển đổi = 1');
      }
    }

    return errors;
  }

  /**
   * Lấy tên đơn vị đo lường theo ID
   * @param unitId - ID của đơn vị đo lường
   * @param units - Danh sách các đơn vị từ hệ thống
   * @returns Tên đơn vị hoặc chuỗi rỗng nếu không tìm thấy
   */
  getUnitName(unitId: string, units: UnitDto[]): string {
    return units.find(u => u.id === unitId)?.name || '';
  }

  /**
   * Kiểm tra xem có đơn vị nào được đánh dấu là đơn vị cơ sở không
   * @param units - Danh sách các đơn vị mua hàng
   * @returns true nếu có đơn vị cơ sở, false nếu chưa có
   */
  hasBaseUnit(units: CreateUpdatePurchaseUnitDto[]): boolean {
    return units.some(unit => unit.isBaseUnit);
  }

  /**
   * Lấy đơn vị cơ sở từ danh sách đơn vị mua hàng
   * @param units - Danh sách các đơn vị mua hàng
   * @returns Đơn vị cơ sở hoặc null nếu chưa có
   */
  getBaseUnit(units: CreateUpdatePurchaseUnitDto[]): CreateUpdatePurchaseUnitDto | null {
    return units.find(unit => unit.isBaseUnit) || null;
  }

  /**
   * Đảm bảo luôn có đúng 1 đơn vị cơ sở trong inventory system
   * Tự động đánh dấu đơn vị đầu tiên là base unit nếu chưa có
   * 
   * @param units - Danh sách các đơn vị mua hàng
   * @param baseUnitId - ID của đơn vị cơ bản đã chọn cho nguyên liệu
   * @returns Danh sách đơn vị đã được cập nhật
   */
  ensureBaseUnit(units: CreateUpdatePurchaseUnitDto[], baseUnitId: string): CreateUpdatePurchaseUnitDto[] {
    const hasBase = this.hasBaseUnit(units);
    
    if (!hasBase && units.length > 0) {
      // Tự động đánh dấu đơn vị đầu tiên là đơn vị cơ sở
      units[0].isBaseUnit = true;
      units[0].conversionRatio = 1; // Base unit luôn có tỷ lệ = 1
      units[0].unitId = baseUnitId;
    }

    return units;
  }

  /**
   * Tạo text preview cho tỷ lệ quy đổi đơn vị
   * Hiển thị thông tin dễ hiểu cho user về cách quy đổi
   * 
   * @param unit - Đơn vị mua hàng
   * @param baseUnitName - Tên đơn vị cơ bản
   * @param units - Danh sách các đơn vị từ hệ thống
   * @returns Text preview VD: "1 thùng = 24 chai" hoặc "chai (đơn vị cơ sở)"
   */
  getConversionPreview(unit: CreateUpdatePurchaseUnitDto, baseUnitName: string, units: UnitDto[]): string {
    const unitName = this.getUnitName(unit.unitId, units);
    if (unit.isBaseUnit) {
      return `${unitName} (đơn vị cơ sở)`;
    }
    return `1 ${unitName} = ${unit.conversionRatio} ${baseUnitName}`;
  }
}