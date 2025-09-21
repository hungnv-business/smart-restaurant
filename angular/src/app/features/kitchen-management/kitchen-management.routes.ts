import { Routes } from '@angular/router';
import { PERMISSIONS } from '../../shared/constants/permissions';

export const KITCHEN_MANAGEMENT_ROUTES: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full',
  },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./components/kitchen-dashboard/kitchen-dashboard.component').then(
        c => c.KitchenDashboardComponent,
      ),
    data: {
      title: 'Bảng Điều Khiển Bếp',
      permission: PERMISSIONS.RESTAURANT.KITCHEN.DEFAULT,
    },
  },
];
