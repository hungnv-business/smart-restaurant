import { Routes } from '@angular/router';
import { RestaurantGuard } from '../../auth/guards/restaurant.guard';
import { PERMISSIONS } from '../../shared/constants/permissions';
import { MenuCategoryListComponent } from './menu-categories/menu-category-list/menu-category-list.component';

export const menuManagementRoutes: Routes = [
  {
    path: '',
    redirectTo: 'menu-categories',
    pathMatch: 'full',
  },
  {
    path: 'menu-categories',
    component: MenuCategoryListComponent,
    canActivate: [RestaurantGuard],
    data: {
      breadcrumb: 'Danh mục món ăn',
      permission: PERMISSIONS.RESTAURANT.MENU.CATEGORIES.DEFAULT,
    },
  },
  {
    path: 'menu-items',
    loadChildren: () => import('./menu-items/menu-items.routes').then(m => m.MENU_ITEMS_ROUTES),
    canActivate: [RestaurantGuard],
    data: {
      breadcrumb: 'Món ăn',
      permission: PERMISSIONS.RESTAURANT.MENU.ITEMS.DEFAULT,
    },
  },
];
