import { Routes } from '@angular/router';
import { RestaurantLayoutComponent } from './layout/components/restaurant.layout';
import { RestaurantGuard } from './auth/guards/restaurant.guard';
import { PERMISSIONS } from './shared/constants/permissions';

export const appRoutes: Routes = [
  {
    path: '',
    component: RestaurantLayoutComponent,
    canActivate: [RestaurantGuard],
    canActivateChild: [RestaurantGuard],
    children: [
      {
        path: '',
        children: [
          {
            path: 'dashboard',
            loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes), // Temporary - will be replaced with actual dashboard
          },
          {
            path: 'administration',
            canMatch: [RestaurantGuard],
            loadChildren: () =>
              import('./features/administration/administration.routes').then(
                m => m.ADMINISTRATION_ROUTES,
              ),
            data: {
              breadcrumb: 'Quản trị hệ thống',
            },
          },
          {
            path: 'table-management',
            loadChildren: () =>
              import('./features/table-management/table-management.routes').then(
                m => m.TABLE_MANAGEMENT_ROUTES,
              ),
            data: {
              breadcrumb: 'Quản lý Bàn',
              permission: PERMISSIONS.RESTAURANT.TABLES.DEFAULT,
            },
          },
          // Future restaurant features - will be implemented in later stories
          {
            path: 'orders',
            redirectTo: 'dashboard', // Placeholder - will be implemented in story for orders
            data: { permission: PERMISSIONS.RESTAURANT.ORDERS },
          },
          {
            path: 'menu-management',
            loadChildren: () =>
              import('./features/menu-management/menu-management.routes').then(
                m => m.menuManagementRoutes,
              ),
            data: {
              breadcrumb: 'Quản lý Menu',
              permission: PERMISSIONS.RESTAURANT.MENU.DEFAULT,
            },
          },
          {
            path: 'inventory-management',
            loadChildren: () =>
              import('./features/inventory-management/inventory-management.routes').then(
                m => m.INVENTORY_MANAGEMENT_ROUTES,
              ),
            data: {
              breadcrumb: 'Quản lý Kho',
              permission: PERMISSIONS.RESTAURANT.INVENTORY.DEFAULT,
            },
          },
          {
            path: 'kitchen-management',
            loadChildren: () =>
              import('./features/kitchen-management/kitchen-management.routes').then(
                m => m.KITCHEN_MANAGEMENT_ROUTES,
              ),
            data: {
              breadcrumb: 'Quản lý Bếp',
              permission: PERMISSIONS.RESTAURANT.KITCHEN.DEFAULT,
            },
          },
          {
            path: 'reports',
            redirectTo: 'dashboard', // Placeholder - will be implemented in story for reports
            data: { permission: PERMISSIONS.RESTAURANT.REPORTS.DEFAULT },
          },
          {
            path: '',
            redirectTo: 'dashboard',
            pathMatch: 'full',
          },
        ],
      },
    ],
  },
  {
    path: 'auth',
    loadChildren: () => import('./auth/auth.routes').then(m => m.AUTH_ROUTES),
  },
  {
    path: 'error',
    loadChildren: () => import('./error/error.routes').then(m => m.ERROR_ROUTES),
  },
  {
    path: '**',
    redirectTo: '/error/404',
    pathMatch: 'full',
  },
];
