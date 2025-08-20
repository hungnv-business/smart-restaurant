import {Component, OnInit} from '@angular/core';
import {CommonModule} from '@angular/common';
import {RouterModule} from '@angular/router';
import {AppMenuitem} from './app.menuitem';
import { PermissionService } from '@abp/ng.core';
import { PERMISSIONS } from '../../shared/constants/permissions';

@Component({
    selector: '[app-menu]',
    standalone: true,
    imports: [CommonModule, AppMenuitem, RouterModule],
    template: `
        <ul class="layout-menu">
            <ng-container *ngFor="let item of model; let i = index">
                <li app-menuitem *ngIf="!item.separator" [item]="item" [index]="i" [root]="true"></li>
                <li *ngIf="item.separator" class="menu-separator"></li>
            </ng-container>
        </ul>
    `
})
export class AppMenu implements OnInit {
    model: any[] = [];

    constructor(private permissionService: PermissionService) {}

    ngOnInit() {
        this.buildMenu();
    }

    private buildMenu() {
        this.model = [
            {
                label: 'Trang chủ',
                icon: 'pi pi-home',
                routerLink: ['/']
            },
            {separator: true}
        ];

        // Only show User Management if user has permission
        if (this.permissionService.getGrantedPolicy(PERMISSIONS.USERS.DEFAULT)) {
            this.model.push({
                label: 'Quản lý Nhân viên',
                icon: 'pi pi-fw pi-users',
                items: [
                    {
                        label: 'Danh sách Nhân viên',
                        icon: 'pi pi-fw pi-list',
                        routerLink: ['/user-management']
                    },
                    {
                        label: 'ABP Identity (Admin)',
                        icon: 'pi pi-fw pi-cog',
                        routerLink: ['/identity']
                    }
                ]
            });
        }
    }
}
