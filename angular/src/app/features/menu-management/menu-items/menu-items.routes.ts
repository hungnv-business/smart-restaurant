import { Routes } from '@angular/router';
import { MenuItemListComponent } from './menu-item-list/menu-item-list.component';

export const MENU_ITEMS_ROUTES: Routes = [
  {
    path: '',
    component: MenuItemListComponent,
    data: {
      title: 'Món ăn',
      breadcrumb: 'Món ăn',
    },
  },
];
