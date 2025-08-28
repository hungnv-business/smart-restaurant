import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { Checkbox } from 'primeng/checkbox';
import { DropdownModule } from 'primeng/dropdown';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import {
  IngredientDto,
  CreateUpdateIngredientDto,
} from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { UnitDto } from '../../../../proxy/common/units/dto';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { IngredientFormData } from '../services/ingredient-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { take, finalize } from 'rxjs';
import { GlobalService } from '@proxy/common';

@Component({
  selector: 'app-ingredient-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumber,
    Checkbox,
    DropdownModule,
    ProgressSpinnerModule,
    ValidationErrorComponent,
    FormFooterActionsComponent,
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

  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<IngredientFormData>);

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
}
