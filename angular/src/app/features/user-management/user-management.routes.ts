import { Routes } from '@angular/router';

export const USER_MANAGEMENT_ROUTES: Routes = [
  {
    path: '',
    redirectTo: 'users',
    pathMatch: 'full',
  },
  {
    path: 'users',
    loadComponent: () =>
      import('./components/user-list/user-list.component').then(c => c.UserListComponent),
    data: {
      breadcrumb: 'Người dùng',
    },
  },
  {
    path: 'roles',
    loadComponent: () =>
      import('./components/role-list/role-list.component').then(c => c.RoleListComponent),
    data: {
      breadcrumb: 'Vai trò',
    },
  },
];
