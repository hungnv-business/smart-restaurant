import { Routes } from '@angular/router';
import { RestaurantGuard } from '../../auth/guards/restaurant.guard';
import { PERMISSIONS } from '../../shared/constants/permissions';

export const TABLE_MANAGEMENT_ROUTES: Routes = [
  {
    path: 'layout-sections',
    loadComponent: () =>
      import('./layout-sections/layout-section-list/layout-section-list.component').then(
        m => m.LayoutSectionListComponent,
      ),
    canActivate: [RestaurantGuard],
    data: { 
      breadcrumb: 'Quản lý Khu vực Bố cục',
      permission: PERMISSIONS.RESTAURANT.TABLES.LAYOUT_SECTION.DEFAULT,
    },
  },
  {
    path: 'table-positioning',
    loadComponent: () =>
      import('./table-positioning/table-layout-kanban/table-layout-kanban.component').then(
        m => m.TableLayoutKanbanComponent,
      ),
    canActivate: [RestaurantGuard],
    data: { 
      breadcrumb: 'Quản lý Vị trí Bàn',
      permission: PERMISSIONS.RESTAURANT.TABLES.TABLE.DEFAULT,
    },
  },
  {
    path: '',
    redirectTo: 'table-positioning',
    pathMatch: 'full',
  },
];
