import {Component, OnInit} from '@angular/core';
import {CommonModule} from '@angular/common';
import {RouterModule} from '@angular/router';
import {AppMenuitem} from './app.menuitem';
import { PERMISSIONS } from '../../shared/constants/permissions';
import { ComponentBase } from '../../shared/base/component-base';

@Component({
    selector: '[app-menu]',
    standalone: true,
    imports: [CommonModule, AppMenuitem, RouterModule],
    template: `
        <ul class="layout-menu">
            <ng-container *ngFor="let item of model; let i = index">
                <li app-menuitem *ngIf="!item.separator && item.visible !== false" [item]="item" [index]="i" [root]="true"></li>
                <li *ngIf="item.separator" class="menu-separator"></li>
            </ng-container>
        </ul>
    `
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
                visible: true
            },
            {separator: true},
            
            // Dashboard
            {
                label: 'Bảng điều khiển',
                icon: 'pi pi-fw pi-chart-bar',
                routerLink: ['/dashboard'],
                visible: this.hasPermission(PERMISSIONS.RESTAURANT.ORDERS_VIEW)
            },

            // Orders Management
            {
                label: 'Quản lý đơn hàng',
                icon: 'pi pi-fw pi-shopping-cart',
                routerLink: ['/orders'],
                visible: this.hasPermission(PERMISSIONS.RESTAURANT.ORDERS_VIEW)
            },

            // Menu Management
            {
                label: 'Quản lý thực đơn',
                icon: 'pi pi-fw pi-book',
                visible: this.hasAnyPermission([PERMISSIONS.RESTAURANT.MENU_VIEW, PERMISSIONS.RESTAURANT.MENU_CREATE, PERMISSIONS.RESTAURANT.MENU_UPDATE]),
                items: [
                    {
                        label: 'Danh mục món ăn',
                        icon: 'pi pi-fw pi-tags',
                        routerLink: ['/menu/categories'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.MENU_VIEW)
                    },
                    {
                        label: 'Món ăn',
                        icon: 'pi pi-fw pi-star',
                        routerLink: ['/menu/items'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.MENU_VIEW)
                    }
                ]
            },

            // Tables Management  
            {
                label: 'Quản lý bàn ăn',
                icon: 'pi pi-fw pi-table',
                routerLink: ['/tables'],
                visible: this.hasPermission(PERMISSIONS.RESTAURANT.ORDERS_VIEW)
            },

            // Kitchen & Service
            {
                label: 'Bếp & Phục vụ',
                icon: 'pi pi-fw pi-wrench',
                visible: this.hasAnyPermission([PERMISSIONS.RESTAURANT.KITCHEN_VIEW, PERMISSIONS.RESTAURANT.KITCHEN_MANAGE]),
                items: [
                    {
                        label: 'Bếp & Phục vụ',
                        icon: 'pi pi-fw pi-cog',
                        routerLink: ['/kitchen'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.KITCHEN_VIEW)
                    },
                    {
                        label: 'Cập nhật trạng thái món',
                        icon: 'pi pi-fw pi-refresh',
                        routerLink: ['/kitchen/status'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.KITCHEN_MANAGE)
                    }
                ]
            },

            // Payments
            {
                label: 'Thanh toán',
                icon: 'pi pi-fw pi-credit-card',
                routerLink: ['/payments'],
                visible: this.hasPermission(PERMISSIONS.RESTAURANT.ORDERS_VIEW)
            },

            // Reports
            {
                label: 'Báo cáo & Thống kê',
                icon: 'pi pi-fw pi-chart-bar',
                visible: this.hasAnyPermission([PERMISSIONS.RESTAURANT.REPORTS_VIEW, PERMISSIONS.RESTAURANT.REPORTS_EXPORT]),
                items: [
                    {
                        label: 'Báo cáo doanh thu',
                        icon: 'pi pi-fw pi-chart-line',
                        routerLink: ['/reports/revenue'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS_VIEW)
                    },
                    {
                        label: 'Món ăn bán chạy',
                        icon: 'pi pi-fw pi-star-fill',
                        routerLink: ['/reports/popular'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS_VIEW)
                    },
                    {
                        label: 'Hiệu suất nhân viên',
                        icon: 'pi pi-fw pi-users',
                        routerLink: ['/reports/staff'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.REPORTS_VIEW)
                    }
                ]
            },

            {separator: true},

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
                        visible: this.hasPermission(PERMISSIONS.USERS.DEFAULT)
                    },
                    {
                        label: 'Vai trò',
                        icon: 'pi pi-fw pi-shield',
                        routerLink: ['/administration/roles'],
                        visible: this.hasPermission(PERMISSIONS.ROLES.DEFAULT)
                    }
                ]
            },

            // Settings
            {
                label: 'Cài đặt',
                icon: 'pi pi-fw pi-cog',
                visible: this.hasAnyPermission([PERMISSIONS.RESTAURANT.SETTINGS_VIEW, PERMISSIONS.RESTAURANT.SETTINGS_MANAGE]),
                items: [
                    {
                        label: 'Máy in bếp',
                        icon: 'pi pi-fw pi-print',
                        routerLink: ['/settings/printers'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.SETTINGS_MANAGE)
                    },
                    {
                        label: 'Cài đặt chung',
                        icon: 'pi pi-fw pi-cog',
                        routerLink: ['/settings'],
                        visible: this.hasPermission(PERMISSIONS.RESTAURANT.SETTINGS_VIEW)
                    }
                ]
            }
        ];
    }
}
