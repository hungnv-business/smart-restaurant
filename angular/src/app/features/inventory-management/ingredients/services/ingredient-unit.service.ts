import { Injectable, inject } from '@angular/core';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { Observable } from 'rxjs';
import { CreateUpdatePurchaseUnitDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { UnitDto } from '../../../../proxy/common/units/dto';
import { IngredientUnitFormComponent } from '../ingredient-form/ingredient-unit-form/ingredient-unit-form.component';

export interface IngredientUnitDialogData {
  editingUnit?: CreateUpdatePurchaseUnitDto | null;
  units: UnitDto[];
  baseUnitId: string;
  existingUnits: CreateUpdatePurchaseUnitDto[];
}

@Injectable({
  providedIn: 'root'
})
export class IngredientUnitService {
  private dialogService = inject(DialogService);

  /**
   * Open unit form modal for adding new unit
   */
  openAddUnitModal(data: IngredientUnitDialogData): Observable<CreateUpdatePurchaseUnitDto> {
    const ref = this.dialogService.open(IngredientUnitFormComponent, {
      header: 'Thêm đơn vị mua',
      width: '500px',
      modal: true,
      closable: true,
      data: { ...data, editingUnit: null }
    });

    return ref.onClose;
  }

  /**
   * Open unit form modal for editing existing unit
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
   * Validate purchase unit data
   */
  validatePurchaseUnit(unit: CreateUpdatePurchaseUnitDto, existingUnits: CreateUpdatePurchaseUnitDto[]): string[] {
    const errors: string[] = [];

    // Check required fields
    if (!unit.unitId) {
      errors.push('Đơn vị là bắt buộc');
    }

    if (!unit.conversionRatio || unit.conversionRatio < 1) {
      errors.push('Tỷ lệ chuyển đổi phải >= 1');
    }

    // Check for duplicate units
    const duplicate = existingUnits.find(existing => 
      existing.unitId === unit.unitId && existing !== unit
    );
    if (duplicate) {
      errors.push('Đơn vị này đã được cấu hình');
    }

    // Validate base unit rules
    if (unit.isBaseUnit) {
      const otherBaseUnit = existingUnits.find(existing => 
        existing.isBaseUnit && existing !== unit
      );
      if (otherBaseUnit) {
        errors.push('Chỉ được có 1 đơn vị cơ sở');
      }

      if (unit.conversionRatio !== 1) {
        errors.push('Đơn vị cơ sở phải có tỷ lệ chuyển đổi = 1');
      }
    }

    return errors;
  }

  /**
   * Get unit name by ID
   */
  getUnitName(unitId: string, units: UnitDto[]): string {
    return units.find(u => u.id === unitId)?.name || '';
  }

  /**
   * Check if any unit is marked as base unit
   */
  hasBaseUnit(units: CreateUpdatePurchaseUnitDto[]): boolean {
    return units.some(unit => unit.isBaseUnit);
  }

  /**
   * Get base unit from purchase units list
   */
  getBaseUnit(units: CreateUpdatePurchaseUnitDto[]): CreateUpdatePurchaseUnitDto | null {
    return units.find(unit => unit.isBaseUnit) || null;
  }

  /**
   * Ensure exactly one base unit exists
   */
  ensureBaseUnit(units: CreateUpdatePurchaseUnitDto[], baseUnitId: string): CreateUpdatePurchaseUnitDto[] {
    const hasBase = this.hasBaseUnit(units);
    
    if (!hasBase && units.length > 0) {
      // Mark first unit as base unit if none exists
      units[0].isBaseUnit = true;
      units[0].conversionRatio = 1;
      units[0].unitId = baseUnitId;
    }

    return units;
  }

  /**
   * Calculate conversion preview text
   */
  getConversionPreview(unit: CreateUpdatePurchaseUnitDto, baseUnitName: string, units: UnitDto[]): string {
    const unitName = this.getUnitName(unit.unitId, units);
    if (unit.isBaseUnit) {
      return `${unitName} (đơn vị cơ sở)`;
    }
    return `1 ${unitName} = ${unit.conversionRatio} ${baseUnitName}`;
  }
}