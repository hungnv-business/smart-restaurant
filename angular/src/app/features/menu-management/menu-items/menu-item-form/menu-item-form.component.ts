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
  form: FormGroup;
  loading = false;
  isEdit = false;
  menuItem?: MenuItemDto;
  categories: MenuCategoryDto[] = [];

  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<MenuItemFormData>);

  private fb = inject(FormBuilder);
  private menuItemService = inject(MenuItemService);
  private menuCategoryService = inject(MenuCategoryService);

  constructor() {
    super();
    this.form = this.createForm();
  }

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

  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    const formValue = this.form.value;
    const dto: CreateUpdateMenuItemDto = {
      categoryId: formValue.categoryId,
      name: formValue.name,
      description: formValue.description || '',
      price: formValue.price || 0,
      imageUrl: formValue.imageUrl || '',
      isAvailable: formValue.isAvailable,
    };

    this.loading = true;
    this.saveMenuItem(dto);
  }

  onCancel() {
    this.ref.close(false);
  }

  getCategoryOptions() {
    return this.categories.map(category => ({
      label: category.name,
      value: category.id,
    }));
  }

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
