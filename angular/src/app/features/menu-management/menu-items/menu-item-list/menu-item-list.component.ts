import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule, Table } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TagModule } from 'primeng/tag';
import { ImageModule } from 'primeng/image';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ToolbarModule } from 'primeng/toolbar';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { DropdownModule } from 'primeng/dropdown';
import { MenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';
import { MenuItemFormDialogService } from '../services/menu-item-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-menu-item-list',
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
    ImageModule,
    InputIconModule,
    IconFieldModule,
    ConfirmDialogModule,
    TooltipModule,
    DropdownModule,
  ],
  providers: [],
  templateUrl: './menu-item-list.component.html',
  styleUrls: ['./menu-item-list.component.scss'],
})
export class MenuItemListComponent extends ComponentBase implements OnInit {
  // Quyền truy cập
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.MENU.ITEMS.CREATE,
    edit: PERMISSIONS.RESTAURANT.MENU.ITEMS.EDIT,
    delete: PERMISSIONS.RESTAURANT.MENU.ITEMS.DELETE,
    updateAvailability: PERMISSIONS.RESTAURANT.MENU.ITEMS.UPDATE_AVAILABILITY,
  };

  // Cấu hình bảng
  filterFields: string[] = ['name', 'categoryId', 'description'];

  // Dữ liệu hiển thị
  menuItems = signal<MenuItemDto[]>([]);
  categories = signal<MenuCategoryDto[]>([]);
  selectedMenuItems: MenuItemDto[] = [];
  loading = false;

  // Hằng số
  private readonly ENTITY_NAME = 'món ăn';

  private menuItemService = inject(MenuItemService);
  private menuCategoryService = inject(MenuCategoryService);
  private menuItemFormDialogService = inject(MenuItemFormDialogService);

  constructor() {
    super();
  }

  async ngOnInit() {
    await this.loadCategories();
    await this.loadMenuItems();
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
  openFormDialog(menuItemId?: string) {
    const dialog$ = menuItemId
      ? this.menuItemFormDialogService.openEditDialog(menuItemId)
      : this.menuItemFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.loadMenuItems();

        if (menuItemId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  // Xóa nhiều món ăn
  deleteSelectedMenuItems() {
    if (!this.selectedMenuItems?.length) return;

    this.confirmBulkDelete(() => {
      this.performDeleteSelectedMenuItems();
    });
  }

  // Xóa một món ăn
  deleteMenuItem(menuItem: MenuItemDto) {
    this.confirmDelete(menuItem.name!, () => {
      this.performDeleteMenuItem(menuItem);
    });
  }

  // Toggle trạng thái có sẵn của món ăn
  toggleAvailability(menuItem: MenuItemDto) {
    const newStatus = !menuItem.isAvailable;
    const statusText = newStatus ? 'có sẵn' : 'hết hàng';

    this.confirmationService.confirm({
      message: `Đánh dấu món "${menuItem.name}" là ${statusText}?`,
      header: 'Xác nhận thay đổi trạng thái',
      icon: 'pi pi-question-circle',
      acceptLabel: 'Xác nhận',
      rejectLabel: 'Hủy',
      rejectButtonStyleClass: 'p-button-secondary',
      accept: () => {
        this.performToggleAvailability(menuItem, newStatus);
      },
    });
  }

  // Helper methods for display
  formatPrice(price: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(price);
  }

  getCategoryName(categoryId?: string): string {
    if (!categoryId) return '';
    const category = this.categories().find(c => c.id === categoryId);
    return category?.name || '';
  }

  getAvailabilityLabel(isAvailable: boolean): string {
    return isAvailable ? 'Có sẵn' : 'Hết hàng';
  }

  getAvailabilitySeverity(isAvailable: boolean): 'success' | 'danger' {
    return isAvailable ? 'success' : 'danger';
  }

  // Load danh sách categories
  private async loadCategories() {
    try {
      const request: PagedAndSortedResultRequestDto = {
        maxResultCount: 1000,
        sorting: 'displayOrder',
      };

      const result = await this.menuCategoryService.getList(request).toPromise();
      this.categories.set(result?.items || []);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  }

  // Load danh sách món ăn
  private loadMenuItems() {
    this.loading = true;

    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      skipCount: 0,
      sorting: 'name',
    };

    this.menuItemService
      .getList(request)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: result => {
          const menuItems = result.items || [];
          this.menuItems.set(menuItems);
        },
        error: error => {
          console.error('Error loading menu items:', error);
          this.menuItems.set([]);
        },
      });
  }

  // Thực hiện xóa một món ăn
  private performDeleteMenuItem(menuItem: MenuItemDto) {
    this.menuItemService.delete(menuItem.id).subscribe({
      next: () => {
        this.loadMenuItems();
        this.showDeleteSuccess(this.ENTITY_NAME);
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa món ăn');
      },
    });
  }

  // Thực hiện xóa nhiều món ăn
  private performDeleteSelectedMenuItems() {
    if (!this.selectedMenuItems?.length) return;

    const ids = this.selectedMenuItems.map(menuItem => menuItem.id!);

    Promise.all(ids.map(id => this.menuItemService.delete(id).toPromise()))
      .then(() => {
        this.loadMenuItems();
        this.selectedMenuItems = [];
        this.showBulkDeleteSuccess(ids.length, this.ENTITY_NAME);
      })
      .catch(error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa món ăn');
      });
  }

  // Thực hiện toggle trạng thái có sẵn
  private performToggleAvailability(menuItem: MenuItemDto, newStatus: boolean) {
    this.menuItemService.updateAvailability(menuItem.id!, newStatus).subscribe({
      next: () => {
        this.loadMenuItems();
        const statusText = newStatus ? 'có sẵn' : 'hết hàng';
        this.showSuccess(
          'Thành công',
          `Đã cập nhật trạng thái món "${menuItem.name}" thành ${statusText}`,
        );
      },
      error: error => {
        this.handleApiError(error, 'Không thể cập nhật trạng thái món ăn');
      },
    });
  }
}
