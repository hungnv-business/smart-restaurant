import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AppMenuitem } from './app.menuitem';
import { PERMISSIONS } from '../../shared/constants/permissions';
import { ComponentBase } from '../../shared/base/component-base';

@Component({
  selector: '[app-menu]',
  standalone: true,
  imports: [CommonModule, AppMenuitem, RouterModule],
  template: `
    <ul class="layout-menu">
      <ng-container *ngFor="let item of model; let i = index">
        <li
          app-menuitem
          *ngIf="!item.separator && item.visible !== false"
          [item]="item"
          [index]="i"
          [root]="true"
        ></li>
        <li *ngIf="item.separator" class="menu-separator"></li>
      </ng-container>
    </ul>
  `,
})
export class AppMenu extends ComponentBase implements OnInit {
  model: any[] = [];

  constructor() {
    super();
  }

  ngOnInit() {
    this.buildMenu();
  }

  private buildMenu() {
    this.model = [
      {
        label: 'Trang chủ',
        icon: 'pi pi-home',
        routerLink: ['/'],
        visible: true,
      },
      { separator: true },

      // Dashboard
      {
        label: 'Bảng điều khiển',
        icon: 'pi pi-fw pi-chart-bar',
        routerLink: ['/dashboard'],
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.DASHBOARD),
      },

      // Orders Management
      {
        label: 'Quản lý đơn hàng',
        icon: 'pi pi-fw pi-shopping-cart',
        routerLink: ['/orders'],
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.ORDERS),
      },

      // Menu Management
      {
        label: 'Quản lý thực đơn',
        icon: 'pi pi-fw pi-book',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.MENU.DEFAULT),
        items: [
          {
            label: 'Danh mục món ăn',
            icon: 'pi pi-fw pi-tags',
            routerLink: ['/menu-management/menu-categories'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.MENU.CATEGORIES.DEFAULT),
          },
          {
            label: 'Món ăn',
            icon: 'pi pi-fw pi-star',
            routerLink: ['/menu-management/menu-items'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.MENU.ITEMS.DEFAULT),
          },
        ],
      },

      // Table Management
      {
        label: 'Quản lý bàn ăn',
        icon: 'pi pi-fw pi-th-large',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.TABLES.DEFAULT),
        items: [
          {
            label: 'Khu vực bố cục',
            icon: 'pi pi-fw pi-sitemap',
            routerLink: ['/table-management/layout-sections'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.TABLES.LAYOUT_SECTION.DEFAULT),
          },
          {
            label: 'Quản lý bàn',
            icon: 'pi pi-fw pi-table',
            routerLink: ['/table-management/table-positioning'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.TABLES.TABLE.DEFAULT),
          },
        ],
      },

      // Inventory Management
      {
        label: 'Quản lý kho',
        icon: 'pi pi-fw pi-box',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.INVENTORY.DEFAULT),
        items: [
          {
            label: 'Danh mục nguyên liệu',
            icon: 'pi pi-fw pi-tags',
            routerLink: ['/inventory-management/ingredient-categories'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.INVENTORY.CATEGORIES.DEFAULT),
          },
          {
            label: 'Nguyên liệu',
            icon: 'pi pi-fw pi-shopping-bag',
            routerLink: ['/inventory-management/ingredients'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.INVENTORY.INGREDIENTS.DEFAULT),
          },
        ],
      },

      // Kitchen & Service
      {
        label: 'Bếp & Phục vụ',
        icon: 'pi pi-fw pi-wrench',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.KITCHEN.DEFAULT),
        items: [
          {
            label: 'Bếp & Phục vụ',
            icon: 'pi pi-fw pi-cog',
            routerLink: ['/kitchen'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.KITCHEN.DEFAULT),
          },
          {
            label: 'Cập nhật trạng thái món',
            icon: 'pi pi-fw pi-refresh',
            routerLink: ['/kitchen/status'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.KITCHEN.UPDATE_STATUS),
          },
        ],
      },

      // Payments
      {
        label: 'Thanh toán',
        icon: 'pi pi-fw pi-credit-card',
        routerLink: ['/payments'],
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.PAYMENTS),
      },

      // Reports
      {
        label: 'Báo cáo & Thống kê',
        icon: 'pi pi-fw pi-chart-bar',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS.DEFAULT),
        items: [
          {
            label: 'Báo cáo doanh thu',
            icon: 'pi pi-fw pi-chart-line',
            routerLink: ['/reports/revenue'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS.REVENUE),
          },
          {
            label: 'Món ăn bán chạy',
            icon: 'pi pi-fw pi-star-fill',
            routerLink: ['/reports/popular'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS.POPULAR),
          },
          {
            label: 'Hiệu suất nhân viên',
            icon: 'pi pi-fw pi-users',
            routerLink: ['/reports/staff'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS.STAFF),
          },
        ],
      },

      { separator: true },

      // User Management
      {
        label: 'Quản lý Nhân viên',
        icon: 'pi pi-fw pi-users',
        visible: this.hasAnyPermission([PERMISSIONS.USERS.DEFAULT, PERMISSIONS.ROLES.DEFAULT]),
        items: [
          {
            label: 'Người dùng',
            icon: 'pi pi-fw pi-users',
            routerLink: ['/administration/users'],
            visible: this.hasPermission(PERMISSIONS.USERS.DEFAULT),
          },
          {
            label: 'Vai trò',
            icon: 'pi pi-fw pi-shield',
            routerLink: ['/administration/roles'],
            visible: this.hasPermission(PERMISSIONS.ROLES.DEFAULT),
          },
        ],
      },

      // Settings
      {
        label: 'Cài đặt',
        icon: 'pi pi-fw pi-cog',
        visible: this.hasPermission(PERMISSIONS.RESTAURANT.SETTINGS.DEFAULT),
        items: [
          {
            label: 'Máy in bếp',
            icon: 'pi pi-fw pi-print',
            routerLink: ['/settings/printers'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.SETTINGS.PRINTERS),
          },
          {
            label: 'Cài đặt chung',
            icon: 'pi pi-fw pi-cog',
            routerLink: ['/settings'],
            visible: this.hasPermission(PERMISSIONS.RESTAURANT.SETTINGS.DEFAULT),
          },
        ],
      },
    ];
  }
}
