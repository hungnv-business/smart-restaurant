import { Routes } from '@angular/router';
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
    data: {
      title: 'Danh mục nguyên liệu',
      breadcrumb: 'Danh mục nguyên liệu',
    },
  },
  {
    path: 'ingredients',
    component: IngredientListComponent,
    data: {
      title: 'Nguyên liệu',
      breadcrumb: 'Nguyên liệu',
    },
  },
  {
    path: 'purchase-invoices',
    component: PurchaseInvoiceListComponent,
    data: {
      title: 'Hóa đơn mua',
      breadcrumb: 'Hóa đơn mua',
    },
  },
];
