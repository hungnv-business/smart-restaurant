import { Routes } from '@angular/router';
import { RestaurantLayoutComponent } from './layout/components/restaurant.layout';

export const appRoutes: Routes = [
  {
    path: '',
    component: RestaurantLayoutComponent,
    children: [
      {
        path: '',
        pathMatch: 'full',
        loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes),
      },
      {
        path: 'restaurant',
        children: [
          {
            path: 'dashboard',
            loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes), // Temporary - will be replaced with actual dashboard
          }
        ]
      }
    ]
  },
  {
    path: 'account',
    loadChildren: () => import('@abp/ng.account').then(m => m.createRoutes()),
  },
  {
    path: 'identity',
    loadChildren: () => import('@abp/ng.identity').then(m => m.createRoutes()),
  },
  {
    path: 'tenant-management',
    loadChildren: () =>
      import('@abp/ng.tenant-management').then(m => m.createRoutes()),
  },
  {
    path: 'setting-management',
    loadChildren: () =>
      import('@abp/ng.setting-management').then(m => m.createRoutes()),
  },
];
