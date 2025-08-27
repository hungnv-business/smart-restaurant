import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule, Table } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ToolbarModule } from 'primeng/toolbar';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { DropdownModule } from 'primeng/dropdown';
import { IngredientDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { GlobalService } from '../../../../proxy/common';
import { GuidLookupItemDto } from '../../../../proxy/common/dto';
import { VndCurrencyPipe } from '../../../../shared/pipes';
import { IngredientFormDialogService } from '../services/ingredient-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-ingredient-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    ButtonModule,
    RippleModule,
    ToolbarModule,
    InputTextModule,
    TagModule,
    InputIconModule,
    IconFieldModule,
    ConfirmDialogModule,
    TooltipModule,
    DropdownModule,
    VndCurrencyPipe,
  ],
  providers: [],
  templateUrl: './ingredient-list.component.html',
  styleUrls: ['./ingredient-list.component.scss'],
})
export class IngredientListComponent extends ComponentBase implements OnInit {
  // Quyền truy cập
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.CREATE,
    edit: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.EDIT,
    delete: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.DELETE,
  };

  // Cấu hình bảng
  filterFields: string[] = ['name', 'categoryId', 'unitName', 'supplierInfo'];

  // Dữ liệu hiển thị
  ingredients = signal<IngredientDto[]>([]);
  categories = signal<GuidLookupItemDto[]>([]);
  selectedIngredients: IngredientDto[] = [];
  loading = false;

  // Hằng số
  private readonly ENTITY_NAME = 'nguyên liệu';

  private ingredientService = inject(IngredientService);
  private globalService = inject(GlobalService);
  private ingredientFormDialogService = inject(IngredientFormDialogService);

  constructor() {
    super();
  }

  async ngOnInit() {
    await this.loadCategories();
    await this.loadIngredients();
  }

  // Xử lý tìm kiếm global
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  // Xử lý filter theo category
  onCategoryFilter(table: Table, categoryId: string): void {
    table.filterGlobal(categoryId, 'equals');
  }

  // Mở dialog form
  openFormDialog(ingredientId?: string) {
    const dialog$ = ingredientId
      ? this.ingredientFormDialogService.openEditDialog(ingredientId)
      : this.ingredientFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.loadIngredients();

        if (ingredientId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  // Xóa nhiều nguyên liệu
  deleteSelectedIngredients() {
    if (!this.selectedIngredients?.length) return;

    this.confirmBulkDelete(() => {
      this.performDeleteSelectedIngredients();
    });
  }

  // Xóa một nguyên liệu
  deleteIngredient(ingredient: IngredientDto) {
    this.confirmDelete(ingredient.name!, () => {
      this.performDeleteIngredient(ingredient);
    });
  }


  // Load danh sách categories
  private async loadCategories() {
    try {
      const categories = await this.globalService.getCategories().toPromise();
      this.categories.set(categories || []);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  }

  // Load danh sách nguyên liệu
  private loadIngredients() {
    this.loading = true;

    let request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      skipCount: 0,
      sorting: 'name',
    };

    this.ingredientService
      .getList(request)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: result => {
          const ingredients = result.items || [];
          this.ingredients.set(ingredients);
        },
        error: error => {
          console.error('Error loading ingredients:', error);
          this.ingredients.set([]);
        },
      });
  }

  // Thực hiện xóa một nguyên liệu
  private performDeleteIngredient(ingredient: IngredientDto) {
    this.ingredientService.delete(ingredient.id).subscribe({
      next: () => {
        this.loadIngredients();
        this.showDeleteSuccess(this.ENTITY_NAME);
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa nguyên liệu');
      },
    });
  }

  // Thực hiện xóa nhiều nguyên liệu
  private performDeleteSelectedIngredients() {
    if (!this.selectedIngredients?.length) return;

    const ids = this.selectedIngredients.map(ingredient => ingredient.id!);

    Promise.all(ids.map(id => this.ingredientService.delete(id).toPromise()))
      .then(() => {
        this.loadIngredients();
        this.selectedIngredients = [];
        this.showBulkDeleteSuccess(ids.length, this.ENTITY_NAME);
      })
      .catch(error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa nguyên liệu');
      });
  }
}