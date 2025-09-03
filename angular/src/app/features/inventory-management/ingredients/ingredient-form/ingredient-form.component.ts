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
  form: FormGroup;
  loading = false;
  isEdit = false;
  ingredient?: IngredientDto;
  categories: IngredientCategoryDto[] = [];
  units: UnitDto[] = [];
  purchaseUnits: CreateUpdatePurchaseUnitDto[] = [];

  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<IngredientFormData>);
  private ingredientUnitService = inject(IngredientUnitService);

  private fb = inject(FormBuilder);
  private ingredientService = inject(IngredientService);
  private ingredientCategoryService = inject(IngredientCategoryService);
  private globalService = inject(GlobalService);

  constructor() {
    super();
    this.form = this.createForm();
  }

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

  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    const formValue = this.form.value;
    const dto: CreateUpdateIngredientDto = {
      categoryId: formValue.categoryId,
      name: formValue.name,
      unitId: formValue.unitId,
      costPerUnit: formValue.costPerUnit || null,
      supplierInfo: formValue.supplierInfo || '',
      isActive: formValue.isActive,
      purchaseUnits: this.preparePurchaseUnits(),
    };

    this.loading = true;
    this.saveIngredient(dto);
  }

  onCancel() {
    this.ref.close(false);
  }

  private loadCategories() {
    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      sorting: 'displayOrder',
    };

    this.ingredientCategoryService.getList(request).subscribe({
      next: result => {
        this.categories = result?.items?.filter(c => c.isActive) || [];
      },
      error: error => {
        console.error('Error loading categories:', error);
      },
    });
  }

  private loadUnits() {
    this.globalService.getUnits().subscribe({
      next: units => {
        this.units = units || [];
      },
      error: error => {
        console.error('Error loading units:', error);
      },
    });
  }

  private saveIngredient(dto: CreateUpdateIngredientDto) {
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
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  private createForm(): FormGroup {
    return this.fb.group({
      categoryId: ['', [Validators.required]],
      name: ['', [Validators.required, Validators.maxLength(100)]],
      unitId: ['', [Validators.required]],
      costPerUnit: [null],
      supplierInfo: ['', [Validators.maxLength(200)]],
      isActive: [true],
    });
  }

  private populateForm(ingredient: IngredientDto) {
    this.form.patchValue({
      categoryId: ingredient.categoryId ?? '',
      name: ingredient.name ?? '',
      unitId: ingredient.unitId ?? '',
      costPerUnit: ingredient.costPerUnit,
      supplierInfo: ingredient.supplierInfo ?? '',
      isActive: ingredient.isActive ?? true,
    });

    this.form.markAsPristine();
  }

  private loadPurchaseUnits() {
    if (!this.ingredient?.purchaseUnits) return;
    
    // Lấy từ data có sẵn trong ingredient.purchaseUnits
    this.purchaseUnits = this.ingredient.purchaseUnits
      .filter(unit => unit.isActive)
      .map(unit => ({
        unitId: unit.unitId!,
        conversionRatio: unit.conversionRatio,
        isBaseUnit: unit.isBaseUnit,
        purchasePrice: unit.purchasePrice,
        isActive: unit.isActive,
      }));
  }


  private preparePurchaseUnits(): CreateUpdatePurchaseUnitDto[] {
    return this.purchaseUnits.map(unit => ({
      unitId: unit.unitId!,
      conversionRatio: unit.conversionRatio,
      isBaseUnit: unit.isBaseUnit,
      purchasePrice: unit.purchasePrice,
      isActive: unit.isActive,
    }));
  }

  onAddUnit() {
    const dialogData = {
      units: this.units,
      baseUnitId: this.form.get('unitId')?.value || '',
      existingUnits: this.purchaseUnits
    };

    this.ingredientUnitService.openAddUnitModal(dialogData).subscribe({
      next: (result) => {
        if (result) {
          this.purchaseUnits.push(result);
        }
      }
    });
  }

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
          const index = this.purchaseUnits.findIndex(u => u === unit);
          if (index > -1) {
            this.purchaseUnits[index] = result;
          }
        }
      }
    });
  }

  onDeleteUnit(unit: CreateUpdatePurchaseUnitDto) {
    const index = this.purchaseUnits.findIndex(u => u === unit);
    if (index > -1) {
      this.purchaseUnits.splice(index, 1);
    }
  }


  getUnitName(unitId: string): string {
    return this.units.find(u => u.id === unitId)?.name || 'N/A';
  }
}
