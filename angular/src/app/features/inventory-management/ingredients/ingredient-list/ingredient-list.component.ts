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
import {
  IngredientDto,
  IngredientPurchaseUnitDto,
  GetIngredientListRequestDto,
} from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { GlobalService } from '../../../../proxy/common';
import { GuidLookupItemDto } from '../../../../proxy/common/dto';
import { VndCurrencyPipe } from '../../../../shared/pipes';
import { IngredientFormDialogService } from '../services/ingredient-form-dialog.service';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize, debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { Subject } from 'rxjs';

/**
 * Component quản lý danh sách nguyên liệu trong hệ thống nhà hàng
 * Chức năng chính:
 * - Hiển thị danh sách nguyên liệu với phân trang server-side
 * - Tìm kiếm theo tên và lọc theo danh mục (Cà chua, Thịt bò, Hành tây...)
 * - Hiển thị tồn kho với chuyển đổi đa đơn vị (kg -> gram, lít -> ml)
 * - Thêm, sửa, xóa nguyên liệu
 * - Kiểm soát quyền truy cập theo role
 */
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
  /** Quyền truy cập - Kiểm soát hiển thị các nút theo quyền user */
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.CREATE, // Quyền tạo mới nguyên liệu
    edit: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.EDIT, // Quyền chỉnh sửa nguyên liệu
    delete: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.DELETE, // Quyền xóa nguyên liệu
  };

  /** Dữ liệu hiển thị trên bảng */
  ingredients = signal<IngredientDto[]>([]); // Danh sách nguyên liệu (server-side paging)
  categories = signal<GuidLookupItemDto[]>([]); // Danh sách danh mục cho dropdown filter
  loading = false; // Trạng thái loading khi gọi API
  totalRecords = 0; // Tổng số record cho phân trang

  /** Tham số bộ lọc */
  searchText = ''; // Văn bản tìm kiếm
  selectedCategoryId: string | null = null; // ID danh mục được chọn

  /** Tham chiếu đến PrimeNG Table */
  @ViewChild('dt') dt!: Table;

  /** Quản lý hiển thị tồn kho theo đa đơn vị */
  stockDisplayUnits = new Map<string, { unitId: string; unitName: string; isBaseUnit: boolean }>(); // Đơn vị hiển thị hiện tại
  ingredientPurchaseUnits = new Map<string, IngredientPurchaseUnitDto[]>(); // Các đơn vị mua hàng của từng nguyên liệu

  /** Xử lý debounce cho tìm kiếm */
  private searchSubject = new Subject<string>();

  /** Tên entity dùng trong thông báo */
  private readonly ENTITY_NAME = 'nguyên liệu';

  /** Các service được inject */
  private ingredientService = inject(IngredientService);
  private globalService = inject(GlobalService);
  private ingredientFormDialogService = inject(IngredientFormDialogService);

  /**
   * Constructor - khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo component - tải danh mục và thiết lập debounce search
   */
  async ngOnInit() {
    await this.loadCategories();

    // Thiết lập tìm kiếm debounce để giảm tải API calls
    this.searchSubject
      .pipe(
        debounceTime(300), // Chờ 300ms sau ký tự cuối
        distinctUntilChanged(), // Chỉ gọi nếu giá trị thay đổi
      )
      .subscribe(() => {
        this.resetPagination(this.dt); // Reset về trang đầu và tải lại
      });
  }

  /**
   * Xử lý thay đổi text tìm kiếm với debounce
   * Chờ 300ms sau ký tự cuối để giảm tải API calls
   */
  onFilterChange(): void {
    this.searchSubject.next(this.searchText);
  }

  /**
   * Xử lý filter theo danh mục nguyên liệu
   * @param categoryId ID danh mục được chọn (hoặc empty để xem tất cả)
   */
  onCategoryFilter(categoryId: string): void {
    this.selectedCategoryId = categoryId || null;
    this.resetPagination(this.dt); // Reset về trang đầu và tải lại
  }

  /**
   * Mở dialog form tạo mới hoặc chỉnh sửa nguyên liệu
   * @param ingredientId ID nguyên liệu cần sửa (nếu có), undefined để tạo mới
   */
  openFormDialog(ingredientId?: string) {
    // Conditional dialog pattern: chọn dialog dựa trên mode
    const dialog$ = ingredientId
      ? this.ingredientFormDialogService.openEditDialog(ingredientId)
      : this.ingredientFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.resetPagination(this.dt); // Tải lại dữ liệu

        // Hiển thị thông báo thành công tương ứng
        if (ingredientId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  /**
   * Xóa một nguyên liệu sau khi xác nhận
   * Hiển thị dialog xác nhận trước khi xóa
   * @param ingredient Nguyên liệu cần xóa
   */
  deleteIngredient(ingredient: IngredientDto) {
    this.confirmDelete(ingredient.name!, () => {
      this.performDeleteIngredient(ingredient);
    });
  }

  // Load danh sách categories
  private async loadCategories() {
    try {
      const categories = await this.globalService.getMenuCategoriesLookup().toPromise();
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
                  isBaseUnit: true,
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
        isBaseUnit: selectedUnit.isBaseUnit,
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
