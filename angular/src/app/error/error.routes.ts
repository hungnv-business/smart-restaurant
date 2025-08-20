import { Routes } from '@angular/router';

export const ERROR_ROUTES: Routes = [
  {
    path: '403',
    loadComponent: () => import('./components/forbidden.component').then(c => c.ForbiddenComponent)
  },
  {
    path: '404',
    loadComponent: () => import('./components/notfound.component').then(c => c.NotfoundComponent)
  },
  {
    path: '',
    redirectTo: '404',
    pathMatch: 'full'
  }
];