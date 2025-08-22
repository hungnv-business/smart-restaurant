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
    path: '',
    redirectTo: 'layout-sections',
    pathMatch: 'full'
  }
];