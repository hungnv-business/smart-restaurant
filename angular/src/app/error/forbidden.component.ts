import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';

// PrimeNG
import { ButtonModule } from 'primeng/button';

// ABP
import { AuthService, ConfigStateService } from '@abp/ng.core';

@Component({
  selector: 'app-forbidden',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule
  ],
  template: `
    <div class="min-h-screen bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center p-6">
      <div class="w-full max-w-md">
        <div class="bg-white dark:bg-surface-800 rounded-3xl shadow-2xl overflow-hidden">
          <!-- Header -->
          <div class="bg-gradient-to-r from-blue-500 to-purple-600 text-white text-center py-8">
            <div class="mb-4">
              <img src="/layout/images/logo-white.svg" alt="SmartRestaurant" class="h-16 mx-auto">
            </div>
            <h1 class="text-2xl font-light">Smart Restaurant</h1>
          </div>

          <!-- Body -->
          <div class="p-8 text-center">
            <!-- 403 Error Icon -->
            <div class="mb-6">
              <i class="pi pi-lock text-red-500 text-6xl"></i>
            </div>

            <!-- Error Title -->
            <h2 class="text-red-500 text-2xl font-medium mb-6">Không có quyền truy cập</h2>

            <!-- Error Message -->
            <div class="mb-8">
              <p class="text-surface-700 dark:text-surface-300 text-lg mb-6 leading-relaxed">
                Bạn không có quyền sử dụng tính năng này.
              </p>
              
              @if (currentUserRole) {
                <div class="bg-surface-100 dark:bg-surface-700 rounded-xl p-6 mb-6 text-left">
                  <div class="flex justify-between items-center">
                    <strong class="text-surface-600 dark:text-surface-400">Vai trò hiện tại:</strong>
                    <span class="text-blue-600 dark:text-blue-400 font-medium">{{ getVietnameseRoleName(currentUserRole) }}</span>
                  </div>
                </div>
              }

              <div class="flex items-center justify-center gap-2 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 text-yellow-800 dark:text-yellow-200">
                <i class="pi pi-info-circle"></i>
                <span>Vui lòng liên hệ quản trị viên để được cấp quyền truy cập.</span>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex flex-col gap-3 mb-8">
              <button 
                pButton 
                type="button" 
                label="Quay lại" 
                icon="pi pi-arrow-left"
                class="w-full"
                severity="secondary"
                (click)="goBack()">
              </button>
              
              <button 
                pButton 
                type="button" 
                label="Trang chủ" 
                icon="pi pi-home"
                class="w-full"
                (click)="goHome()">
              </button>
              
              <button 
                pButton 
                type="button" 
                label="Đăng xuất" 
                icon="pi pi-sign-out"
                class="w-full"
                severity="contrast"
                outlined
                (click)="logout()">
              </button>
            </div>
          </div>

          <!-- Footer -->
          <div class="border-t border-surface-200 dark:border-surface-700 text-center p-4">
            <small class="text-surface-500 dark:text-surface-400 flex items-center justify-center gap-2">
              <i class="pi pi-clock"></i>
              {{ currentTime | date:'HH:mm:ss - dd/MM/yyyy' }}
            </small>
          </div>
        </div>
      </div>
    </div>
  `
})
export class ForbiddenComponent implements OnInit, OnDestroy {
  permissionName: string | null = null;
  returnUrl: string | null = null;
  currentUserRole: string | null = null;
  currentTime = new Date();

  private timeInterval: number | null = null;

  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private authService = inject(AuthService);
  private configState = inject(ConfigStateService);
  
  constructor() {}

  ngOnInit() {
    // Get query parameters
    this.route.queryParams.subscribe(params => {
      this.permissionName = params['permission'];
      this.returnUrl = params['returnUrl'];
    });

    // Get current user role
    this.loadCurrentUserRole();

    // Update time every second
    this.timeInterval = window.setInterval(() => {
      this.currentTime = new Date();
    }, 1000) as number;
  }

  ngOnDestroy() {
    if (this.timeInterval) {
      window.clearInterval(this.timeInterval);
    }
  }

  private loadCurrentUserRole() {
    const currentUser = this.configState.getOne('currentUser');
    if (currentUser?.roles?.length > 0) {
      // Get the first/primary role
      this.currentUserRole = currentUser.roles[0];
    }
  }

  getVietnamesePermissionName(permission: string): string {
    const permissionMap: { [key: string]: string } = {
      'SmartRestaurant.Settings': 'Quản lý cài đặt',
      'SmartRestaurant.Users': 'Quản lý người dùng',
      'SmartRestaurant.Dashboard': 'Xem dashboard',
      'SmartRestaurant.Reports': 'Xem báo cáo',
      'SmartRestaurant.Admin': 'Quản trị hệ thống'
    };
    return permissionMap[permission] || permission;
  }

  getVietnameseRoleName(roleName: string): string {
    const roleMap: { [key: string]: string } = {
      'admin': 'Quản trị viên',
      'manager': 'Quản lý',
      'user': 'Người dùng',
      'guest': 'Khách'
    };
    return roleMap[roleName.toLowerCase()] || roleName;
  }

  goBack() {
    if (this.returnUrl) {
      this.router.navigateByUrl(this.returnUrl);
    } else {
      window.history.back();
    }
  }

  goHome() {
    this.router.navigate(['/']);
  }

  logout() {
    this.authService.logout().subscribe(() => {
      this.router.navigate(['/auth/login']);
    });
  }
}