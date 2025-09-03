import { Component, OnInit, signal, inject, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule, Table, TableLazyLoadEvent } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ToolbarModule } from 'primeng/toolbar';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { SelectModule } from 'primeng/select';
import { IngredientDto, IngredientPurchaseUnitDto, GetIngredientListRequestDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { GlobalService } from '../../../../proxy/common';
import { GuidLookupItemDto } from '../../../../proxy/common/dto';
import { VndCurrencyPipe } from '../../../../shared/pipes';
import { IngredientFormDialogService } from '../services/ingredient-form-dialog.service';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize, debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { Subject } from 'rxjs';

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
    SelectModule,
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

  // Dữ liệu hiển thị
  ingredients = signal<IngredientDto[]>([]);
  categories = signal<GuidLookupItemDto[]>([]);
  loading = false;
  totalRecords = 0;
  
  // Filter parameters
  searchText = '';
  selectedCategoryId: string | null = null;
  
  // Debounce search
  private searchSubject = new Subject<string>();
  
  // Stock display unit toggle tracking
  stockDisplayUnits = new Map<string, { unitId: string; unitName: string; isBaseUnit: boolean }>();
  ingredientPurchaseUnits = new Map<string, IngredientPurchaseUnitDto[]>();

  // Hằng số
  private readonly ENTITY_NAME = 'nguyên liệu';

  private ingredientService = inject(IngredientService);
  private globalService = inject(GlobalService);
  private ingredientFormDialogService = inject(IngredientFormDialogService);

  @ViewChild('dt') dt!: Table;

  constructor() {
    super();
  }

  async ngOnInit() {
    await this.loadCategories();
    
    // Setup debounced search
    this.searchSubject.pipe(
      debounceTime(300),
      distinctUntilChanged()
    ).subscribe(() => {
      this.resetPagination(this.dt);
    });
  }

  // Xử lý tìm kiếm với debounce
  onFilterChange(): void {
    this.searchSubject.next(this.searchText);
  }

  // Xử lý filter theo category
  onCategoryFilter(categoryId: string): void {
    this.selectedCategoryId = categoryId || null;
    this.resetPagination(this.dt);
  }

  // Mở dialog form
  openFormDialog(ingredientId?: string) {
    const dialog$ = ingredientId
      ? this.ingredientFormDialogService.openEditDialog(ingredientId)
      : this.ingredientFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.resetPagination(this.dt);

        if (ingredientId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
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

  // Load danh sách nguyên liệu với lazy loading
  loadIngredients(event?: TableLazyLoadEvent) {
    this.loading = true;

    const request: GetIngredientListRequestDto = {
      maxResultCount: this.getMaxResultCount(event),
      skipCount: this.getSkipCount(event),
      sorting: this.getSorting(event, 'name'),
      filter: this.searchText?.trim() || undefined,
      categoryId: this.selectedCategoryId || undefined,
      includeInactive: false,
    };

    this.ingredientService
      .getList(request)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: result => {
          const ingredients = result.items || [];
          this.ingredients.set(ingredients);
          this.totalRecords = result.totalCount || 0;
          
          // Setup unit toggle từ data có sẵn trong ingredient.purchaseUnits
          ingredients.forEach(ingredient => {
            if (ingredient.id && ingredient.purchaseUnits) {
              const activeUnits = ingredient.purchaseUnits.filter(u => u.isActive);
              this.ingredientPurchaseUnits.set(ingredient.id, activeUnits);
              
              // Set default display unit to base unit
              const baseUnit = activeUnits.find(u => u.isBaseUnit);
              if (baseUnit) {
                this.stockDisplayUnits.set(ingredient.id, {
                  unitId: baseUnit.unitId!,
                  unitName: baseUnit.unitName!,
                  isBaseUnit: true
                });
              }
            }
          });
        },
        error: error => {
          console.error('Error loading ingredients:', error);
          this.ingredients.set([]);
          this.totalRecords = 0;
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

  
  
  toggleStockUnit(ingredientId: string, unitId: string) {
    const purchaseUnits = this.ingredientPurchaseUnits.get(ingredientId) || [];
    const selectedUnit = purchaseUnits.find(u => u.unitId === unitId);
    
    if (selectedUnit) {
      this.stockDisplayUnits.set(ingredientId, {
        unitId: selectedUnit.unitId!,
        unitName: selectedUnit.unitName!,
        isBaseUnit: selectedUnit.isBaseUnit
      });
    }
  }
  
  getDisplayUnit(ingredientId: string): string {
    const displayUnit = this.stockDisplayUnits.get(ingredientId);
    return displayUnit?.unitName || 'N/A';
  }
  
  getDisplayStock(ingredient: IngredientDto): number {
    if (!ingredient.currentStock || !ingredient.id) return 0;
    
    const displayUnit = this.stockDisplayUnits.get(ingredient.id);
    const purchaseUnits = this.ingredientPurchaseUnits.get(ingredient.id) || [];
    
    if (!displayUnit || displayUnit.isBaseUnit) {
      // Hiển thị theo base unit
      return ingredient.currentStock;
    }
    
    // Convert từ base unit sang display unit
    const targetUnit = purchaseUnits.find(u => u.unitId === displayUnit.unitId);
    if (!targetUnit) return ingredient.currentStock;
    
    return Math.floor(ingredient.currentStock / targetUnit.conversionRatio);
  }

  getIngredientPurchaseUnits(ingredientId: string): IngredientPurchaseUnitDto[] {
    return this.ingredientPurchaseUnits.get(ingredientId) || [];
  }

  isSelectedUnit(ingredientId: string, unitId: string): boolean {
    const displayUnit = this.stockDisplayUnits.get(ingredientId);
    return displayUnit?.unitId === unitId;
  }
}
