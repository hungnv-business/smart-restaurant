import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
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
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientCategoryFormDialogService } from '../services/ingredient-category-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-ingredient-category-list',
  standalone: true,
  imports: [
    CommonModule,
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
  ],
  providers: [],
  templateUrl: './ingredient-category-list.component.html',
  styleUrls: ['./ingredient-category-list.component.scss'],
})
export class IngredientCategoryListComponent extends ComponentBase implements OnInit {
  // Quyền truy cập - Kiểm soát hiển thị các nút theo quyền user
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.INVENTORY.CATEGORIES.CREATE, // Quyền tạo mới danh mục
    edit: PERMISSIONS.RESTAURANT.INVENTORY.CATEGORIES.EDIT, // Quyền chỉnh sửa danh mục
    delete: PERMISSIONS.RESTAURANT.INVENTORY.CATEGORIES.DELETE, // Quyền xóa danh mục
  };

  // Cấu hình bảng - Các field được search khi user nhập tìm kiếm
  filterFields: string[] = ['name', 'description'];

  // Dữ liệu hiển thị
  categories = signal<IngredientCategoryDto[]>([]); // Danh sách danh mục nguyên liệu (client-side filtering)
  selectedCategories: IngredientCategoryDto[] = []; // Các danh mục được chọn để xóa bulk
  loading = false; // Trạng thái loading khi gọi API

  // Hằng số
  private readonly ENTITY_NAME = 'danh mục nguyên liệu'; // Tên entity dùng trong thông báo

  private ingredientCategoryService = inject(IngredientCategoryService);
  private ingredientCategoryFormDialogService = inject(IngredientCategoryFormDialogService);

  constructor() {
    super();
  }

  ngOnInit() {
    this.loadCategories();
  }

  // Xử lý tìm kiếm global trên tất cả các field
  onGlobalFilter(table: Table, event: Event): void {
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  // Mở dialog form để tạo mới hoặc chỉnh sửa danh mục
  openFormDialog(categoryId?: string) {
    const dialog$ = categoryId
      ? this.ingredientCategoryFormDialogService.openEditDialog(categoryId)
      : this.ingredientCategoryFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.loadCategories();

        if (categoryId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  // Xóa nhiều danh mục được chọn (bulk delete)
  deleteSelectedCategories() {
    if (!this.selectedCategories?.length) return;

    this.confirmBulkDelete(() => {
      this.performDeleteSelectedCategories();
    });
  }

  // Xóa một danh mục cụ thể
  deleteCategory(category: IngredientCategoryDto) {
    this.confirmDelete(category.name!, () => {
      this.performDeleteCategory(category);
    });
  }

  // Load danh sách danh mục từ server
  private loadCategories() {
    this.loading = true;

    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      skipCount: 0,
      sorting: 'displayOrder',
    };

    this.ingredientCategoryService
      .getList(request)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: result => {
          this.categories.set(result.items || []);
        },
        error: error => {
          console.error('Error loading ingredient categories:', error);
          this.categories.set([]);
        },
      });
  }

  // Thực hiện xóa một danh mục sau khi user confirm
  private performDeleteCategory(category: IngredientCategoryDto) {
    this.ingredientCategoryService.delete(category.id).subscribe({
      next: () => {
        this.loadCategories();
        this.showDeleteSuccess(this.ENTITY_NAME);
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa danh mục nguyên liệu');
      },
    });
  }

  // Thực hiện xóa nhiều danh mục sau khi user confirm
  private performDeleteSelectedCategories() {
    if (!this.selectedCategories?.length) return;

    const ids = this.selectedCategories.map(category => category.id!);

    // Note: Assuming deleteMany method exists, otherwise use individual deletes
    Promise.all(ids.map(id => this.ingredientCategoryService.delete(id).toPromise()))
      .then(() => {
        this.loadCategories();
        this.selectedCategories = [];
        this.showBulkDeleteSuccess(ids.length, this.ENTITY_NAME);
      })
      .catch(error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa danh mục nguyên liệu');
      });
  }
}