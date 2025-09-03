import { Routes } from '@angular/router';
import { RestaurantGuard } from '../../auth/guards/restaurant.guard';
import { PERMISSIONS } from '../../shared/constants/permissions';
import { IngredientCategoryListComponent } from './ingredient-categories/ingredient-category-list/ingredient-category-list.component';
import { IngredientListComponent } from './ingredients/ingredient-list/ingredient-list.component';
import { PurchaseInvoiceListComponent } from './purchase-invoices/purchase-invoice-list/purchase-invoice-list.component';

export const INVENTORY_MANAGEMENT_ROUTES: Routes = [
  {
    path: '',
    redirectTo: 'ingredient-categories',
    pathMatch: 'full',
  },
  {
    path: 'ingredient-categories',
    component: IngredientCategoryListComponent,
    canActivate: [RestaurantGuard],
    data: {
      title: 'Danh mục nguyên liệu',
      breadcrumb: 'Danh mục nguyên liệu',
      permission: PERMISSIONS.RESTAURANT.INVENTORY.CATEGORIES.DEFAULT,
    },
  },
  {
    path: 'ingredients',
    component: IngredientListComponent,
    canActivate: [RestaurantGuard],
    data: {
      title: 'Nguyên liệu',
      breadcrumb: 'Nguyên liệu',
      permission: PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.DEFAULT,
    },
  },
  {
    path: 'purchase-invoices',
    component: PurchaseInvoiceListComponent,
    canActivate: [RestaurantGuard],
    data: {
      title: 'Hóa đơn mua',
      breadcrumb: 'Hóa đơn mua',
      permission: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.DEFAULT,
    },
  },
];
