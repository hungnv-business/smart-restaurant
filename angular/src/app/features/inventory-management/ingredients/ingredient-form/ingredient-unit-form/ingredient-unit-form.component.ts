import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, FormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputNumber } from 'primeng/inputnumber';
import { SelectModule } from 'primeng/select';
import { Checkbox } from 'primeng/checkbox';
import { ButtonModule } from 'primeng/button';
import { CreateUpdatePurchaseUnitDto } from '../../../../../proxy/inventory-management/ingredients/dto';
import { UnitDto } from '../../../../../proxy/common/units/dto';
import { ValidationErrorComponent } from '../../../../../shared/components/validation-error/validation-error.component';
import { ComponentBase } from '../../../../../shared/base/component-base';
import { IngredientUnitDialogData } from '../../services/ingredient-unit.service';
import { FormFooterActionsComponent } from '../../../../../shared/components/form-footer-actions/form-footer-actions.component';

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
  private fb = inject(FormBuilder);
  private ref = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig);
  
  unitForm: FormGroup;
  data: IngredientUnitDialogData;

  constructor() {
    super();
    this.data = this.config.data;
    this.unitForm = this.createUnitForm();
  }

  ngOnInit() {
    this.resetUnitForm();
  }


  private createUnitForm(): FormGroup {
    return this.fb.group({
      unitId: ['', [Validators.required]],
      conversionRatio: [1, [Validators.required, Validators.min(1)]],
      purchasePrice: [null],
      isBaseUnit: [false],
      isActive: [true],
    });
  }

  private resetUnitForm() {
    if (this.data.editingUnit) {
      // Edit mode
      this.unitForm.patchValue({
        unitId: this.data.editingUnit.unitId,
        conversionRatio: this.data.editingUnit.conversionRatio,
        purchasePrice: this.data.editingUnit.purchasePrice,
        isBaseUnit: this.data.editingUnit.isBaseUnit,
        isActive: this.data.editingUnit.isActive,
      });
    } else {
      // Add mode
      const hasBaseUnit = this.data.existingUnits.some(unit => unit.isBaseUnit);
      
      this.unitForm.reset({ 
        isActive: true, 
        isBaseUnit: !hasBaseUnit,
        conversionRatio: 1,
        purchasePrice: null,
        unitId: !hasBaseUnit ? this.data.baseUnitId : ''
      });
    }
  }

  onSave() {
    if (!this.validateForm(this.unitForm)) {
      return;
    }

    const unitValue = this.unitForm.value;
    
    // Validation: Chỉ cho phép 1 đơn vị cơ sở
    if (unitValue.isBaseUnit) {
      const hasOtherBaseUnit = this.data.existingUnits.some(unit => 
        unit.isBaseUnit && unit !== this.data.editingUnit
      );
      
      if (hasOtherBaseUnit) {
        this.showError('Chỉ được có 1 đơn vị cơ sở');
        return;
      }
      
      // Đơn vị cơ sở phải có tỷ lệ = 1
      unitValue.conversionRatio = 1;
    }
    
    this.ref.close(unitValue);
  }

  onCancel() {
    this.ref.close();
  }

  get units(): UnitDto[] {
    return this.data.units;
  }

  get isEdit(): boolean {
    return !!this.data.editingUnit;
  }
}