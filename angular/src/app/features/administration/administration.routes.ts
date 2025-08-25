import { Routes } from '@angular/router';
import { PERMISSIONS } from '../../shared/constants/permissions';

export const ADMINISTRATION_ROUTES: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./users/users.routes').then(m => m.USERS_ROUTES),
    data: {
      breadcrumb: 'Quản lý người dùng',
      permission: PERMISSIONS.USERS.DEFAULT,
    },
  },
  {
    path: 'roles',
    loadChildren: () => import('./roles/roles.routes').then(m => m.ROLES_ROUTES),
    data: {
      breadcrumb: 'Quản lý vai trò',
      permission: PERMISSIONS.ROLES.DEFAULT,
    },
  },
  {
    path: '',
    redirectTo: 'users',
    pathMatch: 'full',
  },
];
