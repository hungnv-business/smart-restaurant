import { Routes } from '@angular/router';

export const TABLE_MANAGEMENT_ROUTES: Routes = [
  {
    path: 'layout-sections',
    loadComponent: () =>
      import('./layout-sections/layout-section-list/layout-section-list.component').then(
        (m) => m.LayoutSectionListComponent
      ),
    data: { breadcrumb: 'Quản lý Khu vực Bố cục' }
  },
  {
    path: 'table-positioning',
    loadComponent: () =>
      import('./table-positioning/table-layout-kanban/table-layout-kanban.component').then(
        (m) => m.TableLayoutKanbanComponent
      ),
    data: { breadcrumb: 'Quản lý Vị trí Bàn' }
  },
  {
    path: '',
    redirectTo: 'table-positioning',
    pathMatch: 'full'
  }
];