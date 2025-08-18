# Frontend Architecture

## Component Architecture (Kiến trúc Thành phần)

### ABP CLI Generated Structure (Cấu trúc được tạo bởi ABP CLI)

**Root Level Files (File cấp gốc):**
```
angular/
├── angular.json              # Angular workspace configuration (Cấu hình workspace Angular)
├── package.json             # Dependencies and scripts (Dependencies và scripts)
├── tsconfig.json            # TypeScript configuration (Cấu hình TypeScript)
├── tsconfig.app.json        # App-specific TypeScript config (Cấu hình TypeScript riêng cho app)
├── tsconfig.spec.json       # Test TypeScript config (Cấu hình TypeScript cho test)
├── karma.conf.js            # Test runner configuration (Cấu hình test runner)
├── nginx.conf               # Production nginx configuration (Cấu hình nginx production)
├── web.config               # IIS deployment configuration (Cấu hình triển khai IIS)
├── start.ps1                # PowerShell startup script (Script khởi động PowerShell)
├── common.props             # MSBuild properties (Thuộc tính MSBuild)
├── Dockerfile               # Docker containerization (Đóng gói Docker)
├── Dockerfile.local         # Local development Docker (Docker phát triển local)
├── dynamic-env.json         # Dynamic environment configuration (Cấu hình môi trường động)
├── e2e/                     # End-to-end tests (Kiểm thử end-to-end)
├── node_modules/            # Node.js dependencies (Dependencies Node.js)
├── README.md                # Project documentation (Tài liệu dự án)
├── src/                     # Source code (Mã nguồn)
└── yarn.lock                # Yarn lock file (File lock Yarn)
```

**Actual ABP Angular Generated Structure (Cấu trúc ABP Angular được tạo thực tế):**
```
angular/ (Based on /Users/cocacola/Desktop/flutter/abp/angular)
├── package.json                 # Real ABP Angular dependencies (Dependencies ABP Angular thực tế)
│   ├── @abp/ng.components: ~9.1.1      # ABP Angular components
│   ├── @abp/ng.core: ~9.1.1           # ABP Angular core
│   ├── @abp/ng.oauth: ~9.1.1          # OAuth integration
│   ├── @abp/ng.identity: ~9.1.1       # Identity management
│   ├── @abp/ng.tenant-management: ~9.1.1  # Multi-tenancy
│   ├── @abp/ng.theme.lepton-x: ~4.1.1    # LeptonX theme (not Poseidon)
│   └── @angular/*: ~19.1.0            # Angular 19.1.0 packages
├── angular.json                 # Angular CLI configuration
├── dynamic-env.json            # ABP dynamic environment configuration
├── src/
│   ├── app/                    # Angular application source
│   │   ├── app.module.ts       # Root module with ABP imports
│   │   ├── app.component.ts    # Root component
│   │   ├── app-routing.module.ts # Routing with ABP integration
│   │   ├── route.provider.ts   # ABP route provider configuration
│   │   ├── home/              # Default home module
│   │   │   ├── home.module.ts  # Home feature module
│   │   │   ├── home.component.ts # Home component
│   │   │   └── home-routing.module.ts # Home routing
│   │   └── shared/            # Shared module
│   │       └── shared.module.ts # Shared components and services
│   ├── assets/                # Static assets
│   │   └── images/           # Asset images including ABP branding
│   │       ├── getting-started/ # ABP getting started images
│   │       ├── login/         # Login page backgrounds
│   │       └── logo/          # Application logos
│   ├── environments/          # Environment configuration
│   │   ├── environment.ts     # Development settings
│   │   └── environment.prod.ts # Production settings
│   ├── styles.scss           # Global styles with ABP theme integration
│   ├── main.ts               # Application bootstrap
│   ├── polyfills.ts          # Browser compatibility
│   └── test.ts               # Testing configuration
├── e2e/                      # End-to-end tests
│   ├── protractor.conf.js    # E2E test configuration
│   └── src/                  # E2E test sources
├── karma.conf.js             # Unit test configuration
├── tsconfig.json             # TypeScript configuration
├── tsconfig.app.json         # App-specific TypeScript config
├── tsconfig.spec.json        # Test TypeScript config
├── Dockerfile                # Docker containerization
├── nginx.conf                # Production nginx configuration
├── web.config                # IIS deployment configuration
└── yarn.lock                 # Yarn dependency lock file
```

### Poseidon Template Integration (Tích hợp Poseidon Template)

**Actual Poseidon Template Structure (Cấu trúc Poseidon Template Thực tế):**
Based on the source code at `/Volumes/Work/data/template/poseidon-ng-19.0.0`, the real Poseidon template has the following structure (Dựa trên mã nguồn tại `/Volumes/Work/data/template/poseidon-ng-19.0.0`, template Poseidon thực tế có cấu trúc như sau):

```
poseidon-ng-19.0.0/
├── package.json                    # Real dependencies (Dependencies thực tế)
├── angular.json                    # Angular workspace config
├── tailwind.config.js              # TailwindCSS configuration (Cấu hình TailwindCSS)
├── src/
│   ├── app/
│   │   ├── app.component.ts        # Root component (Component gốc)
│   │   ├── app.config.ts           # App configuration (Cấu hình app)
│   │   ├── app.routes.ts           # Route configuration (Cấu hình route)
│   │   ├── layout/                 # Layout system (Hệ thống layout)
│   │   │   ├── components/         # Layout components (Component layout)
│   │   │   │   ├── app.layout.ts   # Main layout wrapper (Wrapper layout chính)
│   │   │   │   ├── app.topbar.ts   # Top navigation bar (Thanh điều hướng trên)
│   │   │   │   ├── app.sidebar.ts  # Sidebar navigation (Điều hướng sidebar)
│   │   │   │   ├── app.menu.ts     # Menu component (Component menu)
│   │   │   │   ├── app.breadcrumb.ts # Breadcrumb navigation (Điều hướng breadcrumb)
│   │   │   │   ├── app.footer.ts   # Footer component (Component footer)
│   │   │   │   ├── app.configurator.ts # Theme configurator (Cấu hình theme)
│   │   │   │   ├── app.search.ts   # Search functionality (Chức năng tìm kiếm)
│   │   │   │   └── app.rightmenu.ts # Right side menu (Menu bên phải)
│   │   │   └── service/
│   │   │       └── layout.service.ts # Layout state management (Quản lý trạng thái layout)
│   │   ├── pages/                  # Page components (Component trang)
│   │   │   ├── dashboards/         # Dashboard variants (Biến thể dashboard)
│   │   │   │   ├── banking/        # Banking dashboard (Dashboard ngân hàng)
│   │   │   │   ├── ecommerce/      # E-commerce dashboard (Dashboard thương mại điện tử)
│   │   │   │   └── marketing/      # Marketing dashboard (Dashboard marketing)
│   │   │   ├── apps/               # Application modules (Module ứng dụng)
│   │   │   ├── auth/               # Authentication pages (Trang xác thực)
│   │   │   ├── uikit/              # UI components showcase (Trưng bày component UI)
│   │   │   └── service/            # Demo services (Dịch vụ demo)
│   │   └── types/                  # TypeScript interfaces (Interface TypeScript)
│   ├── assets/
│   │   ├── layout/                 # Layout SCSS files (File SCSS layout)
│   │   │   ├── layout.scss         # Main layout styles (Style layout chính)
│   │   │   ├── sidebar/            # Sidebar themes and variants (Theme và biến thể sidebar)
│   │   │   ├── topbar/             # Topbar themes (Theme topbar)
│   │   │   └── variables/          # CSS variables (Biến CSS)
│   │   └── demo/                   # Demo-specific styles (Style riêng cho demo)
│   ├── styles.scss                 # Global styles (Style toàn cục)
│   └── tailwind.css                # TailwindCSS utilities (Tiện ích TailwindCSS)
└── public/                         # Static assets (Tài nguyên tĩnh)
    ├── demo/                       # Demo data and images (Dữ liệu và hình ảnh demo)
    └── layout/                     # Layout assets (Tài nguyên layout)
```

**Real Dependencies from package.json (Dependencies Thực tế từ package.json):**
```json
{
  "dependencies": {
    "@angular/animations": "^19.0.0",
    "@angular/common": "^19.0.0",
    "@angular/compiler": "^19.0.0",
    "@angular/core": "^19.0.0",
    "@angular/forms": "^19.0.0",
    "@angular/platform-browser": "^19.0.0",
    "@angular/platform-browser-dynamic": "^19.0.0",
    "@angular/router": "^19.0.0",
    "@primeng/themes": "^19.0.2",
    "chart.js": "^4.3.0",
    "chartjs-adapter-date-fns": "^3.0.0",
    "chartjs-chart-matrix": "^2.0.1",
    "primeicons": "^7.0.0",
    "primeng": "^19.0.6",
    "quill": "^2.0.3",
    "rxjs": "~7.8.0",
    "tailwindcss-primeui": "^0.5.1",
    "tslib": "^2.3.0",
    "zone.js": "~0.15.0"
  }
}
```

**Integration into ABP Smart Restaurant (Tích hợp vào ABP Smart Restaurant):**
```bash
# Copy Poseidon template structure to ABP Angular project (Sao chép cấu trúc Poseidon template vào dự án ABP Angular)
cp -r /Volumes/Work/data/template/poseidon-ng-19.0.0/src/app/layout/ angular/src/app/
cp -r /Volumes/Work/data/template/poseidon-ng-19.0.0/src/assets/layout/ angular/src/assets/
cp /Volumes/Work/data/template/poseidon-ng-19.0.0/tailwind.config.js angular/
cp /Volumes/Work/data/template/poseidon-ng-19.0.0/src/tailwind.css angular/src/

# Install Poseidon dependencies (Cài đặt dependencies Poseidon)
cd angular/
npm install @primeng/themes chart.js chartjs-adapter-date-fns chartjs-chart-matrix primeicons primeng quill tailwindcss-primeui
```

**Poseidon Layout Service Integration (Tích hợp Poseidon Layout Service):**
```typescript
// angular/src/app/layout/service/layout.service.ts (Copied from Poseidon)
import { computed, effect, Injectable, signal } from '@angular/core';
import { Subject } from 'rxjs';

export interface layoutConfig {
    preset: string;
    primary: string;
    surface: string | undefined | null;
    darkTheme: boolean;
    menuMode: string; // 'static' | 'overlay' | 'slim' | 'horizontal' | 'compact' | 'reveal' | 'drawer'
}

@Injectable({
    providedIn: 'root'
})
export class LayoutService {
    _config: layoutConfig = {
        preset: 'Aura',
        primary: 'green',           // Vietnamese restaurant green theme (Theme xanh nhà hàng Việt Nam)
        surface: null,
        darkTheme: false,
        menuMode: 'static',         // Default static layout for restaurant (Layout tĩnh mặc định cho nhà hàng)
    };

    // Restaurant-specific color palette (Bảng màu riêng cho nhà hàng)
    bodyBackgroundPalette = {
        light: {
            green: 'linear-gradient(180deg, #e0f5e1 0%, rgba(170, 239, 172, 0.06) 111.26%)',
            blue: 'linear-gradient(180deg, #e0e7f5 0%, rgba(170, 194, 239, 0.06) 111.26%)',
            orange: 'linear-gradient(180deg, #f5e9e0 0%, rgba(239, 199, 170, 0.06) 111.26%)',
        },
        dark: {
            green: '#00231B',
            blue: '#000C23',
            orange: '#231500',
        }
    };

    layoutConfig = signal<layoutConfig>(this._config);
    layoutState = signal<any>({
        staticMenuDesktopInactive: false,
        overlayMenuActive: false,
        configSidebarVisible: false,
        staticMenuMobileActive: false,
        menuHoverActive: false,
        sidebarActive: false,
        anchored: false,
        overlaySubmenuActive: false,
        rightMenuVisible: false,
        searchBarActive: false,
    });

    // Layout mode computed properties (Thuộc tính computed cho chế độ layout)
    isStatic = computed(() => this.layoutConfig().menuMode === 'static');
    isOverlay = computed(() => this.layoutConfig().menuMode === 'overlay');
    isSlim = computed(() => this.layoutConfig().menuMode === 'slim');
    isHorizontal = computed(() => this.layoutConfig().menuMode === 'horizontal');
    isDarkTheme = computed(() => this.layoutConfig().darkTheme);
    
    // Restaurant operations (Hoạt động nhà hàng)
    onMenuToggle() {
        if (this.isOverlay()) {
            this.layoutState.update((prev: any) => ({
                ...prev,
                overlayMenuActive: !this.layoutState().overlayMenuActive
            }));
        } else {
            // Handle static menu for restaurant interface (Xử lý menu tĩnh cho giao diện nhà hàng)
            this.layoutState.update((prev: any) => ({
                ...prev,
                staticMenuDesktopInactive: !this.layoutState().staticMenuDesktopInactive
            }));
        }
    }

    updateBodyBackground(color: string) {
        const root = document.documentElement;
        const colorScheme: any = this.isDarkTheme() ? 
            this.bodyBackgroundPalette.dark : 
            this.bodyBackgroundPalette.light;
        root.style.setProperty('--surface-ground', colorScheme[color]);
    }
}
```

**Restaurant Layout Component using Poseidon (Component Layout Nhà hàng sử dụng Poseidon):**
```typescript
// angular/src/app/layout/components/restaurant.layout.ts
import { Component, computed, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AppTopbar } from './app.topbar';
import { AppSidebar } from './app.sidebar';
import { LayoutService } from '../service/layout.service';
import { AppBreadcrumb } from './app.breadcrumb';
import { AppFooter } from './app.footer';

@Component({
    selector: 'app-restaurant-layout',
    standalone: true,
    imports: [CommonModule, AppTopbar, AppSidebar, RouterModule, AppBreadcrumb, AppFooter],
    template: \`
        <div class="layout-wrapper restaurant-layout" [ngClass]="containerClass()">
            <!-- Restaurant Sidebar (Sidebar nhà hàng) -->
            <div app-sidebar [menuItems]="restaurantMenuItems"></div>
            
            <!-- Main Content Area (Khu vực nội dung chính) -->
            <div class="layout-content-wrapper">
                <div class="layout-content-wrapper-inside">
                    <!-- Restaurant Topbar (Topbar nhà hàng) -->
                    <div app-topbar [title]="'Smart Restaurant Management'"></div>
                    
                    <!-- Content with Breadcrumb (Nội dung với breadcrumb) -->
                    <div class="layout-content">
                        <div app-breadcrumb></div>
                        <router-outlet></router-outlet>
                    </div>
                    
                    <!-- Footer (Footer) -->
                    <div app-footer></div>
                </div>
            </div>
            
            <!-- Layout Mask (Lớp phủ layout) -->
            <div class="layout-mask animate-fadein"></div>
        </div>
    \`,
    styleUrls: ['../../../assets/layout/layout.scss']
})
export class RestaurantLayout {
    @ViewChild(AppSidebar) appSidebar!: AppSidebar;
    @ViewChild(AppTopbar) appTopBar!: AppTopbar;

    constructor(public layoutService: LayoutService) {
        // Set restaurant-specific theme (Đặt theme riêng cho nhà hàng)
        this.layoutService.layoutConfig.update(config => ({
            ...config,
            primary: 'green',
            menuMode: 'static'
        }));
        
        // Apply Vietnamese restaurant styling (Áp dụng style nhà hàng Việt Nam)
        this.layoutService.updateBodyBackground('green');
    }

    /// <summary>Menu items cho nhà hàng Việt Nam</summary>
    restaurantMenuItems = [
        {
            label: 'Bảng điều khiển',
            icon: 'pi pi-home',
            routerLink: '/dashboard'
        },
        {
            label: 'Quản lý đơn hàng',
            icon: 'pi pi-shopping-cart',
            items: [
                {
                    label: 'Đơn hàng mới',
                    icon: 'pi pi-plus-circle',
                    routerLink: '/orders/new'
                },
                {
                    label: 'Đơn hàng đang xử lý',
                    icon: 'pi pi-clock',
                    routerLink: '/orders/processing'
                },
                {
                    label: 'Lịch sử đơn hàng',
                    icon: 'pi pi-history',
                    routerLink: '/orders/history'
                }
            ]
        },
        {
            label: 'Quản lý menu',
            icon: 'pi pi-list',
            items: [
                {
                    label: 'Danh mục món ăn',
                    icon: 'pi pi-th-large',
                    routerLink: '/menu/categories'
                },
                {
                    label: 'Món ăn',
                    icon: 'pi pi-heart',
                    routerLink: '/menu/items'
                },
                {
                    label: 'Quản lý giá',
                    icon: 'pi pi-dollar',
                    routerLink: '/menu/pricing'
                }
            ]
        },
        {
            label: 'Quản lý bàn ăn',
            icon: 'pi pi-table',
            items: [
                {
                    label: 'Sơ đồ bàn',
                    icon: 'pi pi-map',
                    routerLink: '/tables/layout'
                },
                {
                    label: 'Trạng thái bàn',
                    icon: 'pi pi-circle',
                    routerLink: '/tables/status'
                },
                {
                    label: 'Đặt bàn',
                    icon: 'pi pi-calendar',
                    routerLink: '/tables/reservations'
                }
            ]
        },
        {
            label: 'Bếp & Phục vụ',
            icon: 'pi pi-wrench',
            items: [
                {
                    label: 'Màn hình bếp',
                    icon: 'pi pi-desktop',
                    routerLink: '/kitchen/display'
                },
                {
                    label: 'Trạng thái món ăn',
                    icon: 'pi pi-check-circle',
                    routerLink: '/kitchen/orders'
                },
                {
                    label: 'Ưu tiên đơn hàng',
                    icon: 'pi pi-sort-up',
                    routerLink: '/kitchen/priority'
                }
            ]
        },
        {
            label: 'Thanh toán',
            icon: 'pi pi-credit-card',
            items: [
                {
                    label: 'Xử lý thanh toán',
                    icon: 'pi pi-money-bill',
                    routerLink: '/payments/process'
                },
                {
                    label: 'Lịch sử thanh toán',
                    icon: 'pi pi-file',
                    routerLink: '/payments/history'
                },
                {
                    label: 'Báo cáo doanh thu',
                    icon: 'pi pi-chart-line',
                    routerLink: '/payments/reports'
                }
            ]
        },
        {
            label: 'Báo cáo & Thống kê',
            icon: 'pi pi-chart-bar',
            items: [
                {
                    label: 'Doanh thu',
                    icon: 'pi pi-chart-pie',
                    routerLink: '/reports/revenue'
                },
                {
                    label: 'Món ăn bán chạy',
                    icon: 'pi pi-star',
                    routerLink: '/reports/popular-items'
                },
                {
                    label: 'Hiệu suất nhân viên',
                    icon: 'pi pi-users',
                    routerLink: '/reports/staff'
                }
            ]
        },
        {
            label: 'Cài đặt',
            icon: 'pi pi-cog',
            items: [
                {
                    label: 'Cài đặt nhà hàng',
                    icon: 'pi pi-building',
                    routerLink: '/settings/restaurant'
                },
                {
                    label: 'Quản lý nhân viên',
                    icon: 'pi pi-user-edit',
                    routerLink: '/settings/staff'
                },
                {
                    label: 'Máy in bếp',
                    icon: 'pi pi-print',
                    routerLink: '/settings/printers'
                }
            ]
        }
    ];

    containerClass = computed(() => {
        const layoutConfig = this.layoutService.layoutConfig();
        const layoutState = this.layoutService.layoutState();

        return {
            'layout-static': layoutConfig.menuMode === 'static',
            'layout-overlay': layoutConfig.menuMode === 'overlay',
            'layout-overlay-active': layoutState.overlayMenuActive,
            'layout-mobile-active': layoutState.staticMenuMobileActive,
            'layout-static-inactive': layoutState.staticMenuDesktopInactive && layoutConfig.menuMode === 'static',
            // Restaurant-specific classes (Class riêng cho nhà hàng)
            'restaurant-theme': true,
            'vietnamese-restaurant': true,
            'green-theme': layoutConfig.primary === 'green'
        };
    });
}
```

### ABP Feature Module Organization (Tổ chức Module Tính năng ABP)

**Feature-Based Structure (Cấu trúc Dựa trên Tính năng):**
```
angular/src/app/
├── app.component.ts             # Root component (Component gốc)
├── app.module.ts               # Root module (Module gốc)
├── app-routing.module.ts       # Root routing (Routing gốc)
├── route.provider.ts           # ABP route provider (Provider route ABP)
├── proxy/                      # ABP generated proxies (Proxy được tạo bởi ABP)
│   ├── orders/                # Order service proxies
│   │   ├── order.service.ts   # Auto-generated order service
│   │   ├── models.ts          # Order DTOs and interfaces
│   │   └── index.ts           # Barrel exports
│   ├── menu-items/            # Menu item service proxies
│   ├── tables/                # Table service proxies
│   ├── payments/              # Payment service proxies
│   └── volo/                  # ABP framework services
└── restaurant-features/        # Custom restaurant modules (Module nhà hàng tùy chỉnh)
    ├── dashboard/             # Dashboard module
    │   ├── dashboard.module.ts
    │   ├── dashboard-routing.module.ts
    │   ├── dashboard.component.ts
    │   ├── dashboard.component.html
    │   └── dashboard.component.scss
    ├── order-management/       # Order management module
    │   ├── order-management.module.ts
    │   ├── order-management-routing.module.ts
    │   ├── components/
    │   │   ├── order-list/
    │   │   ├── order-create/
    │   │   ├── order-detail/
    │   │   └── kitchen-display/
    │   └── services/
    │       └── order-state.service.ts
    ├── menu-management/        # Menu management module
    │   ├── menu-management.module.ts
    │   ├── menu-management-routing.module.ts
    │   ├── components/
    │   │   ├── menu-category-list/
    │   │   ├── menu-item-list/
    │   │   ├── menu-item-form/
    │   │   └── menu-availability/
    │   └── services/
    └── table-management/       # Table management module
        ├── table-management.module.ts
        ├── table-management-routing.module.ts
        ├── components/
        │   ├── table-layout/
        │   ├── table-status/
        │   ├── reservation-form/
        │   └── table-assignment/
        └── services/
```

#### Order Processing Component (Component Xử lý Đơn hàng)

```typescript
// angular/src/app/restaurant-features/order-management/components/order-create/order-create.component.ts
import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Subject, takeUntil } from 'rxjs';
import { MessageService, ConfirmationService } from 'primeng/api';

// ABP auto-generated services (Dịch vụ tự động tạo bởi ABP)
import { OrderService, CreateOrderDto, OrderDto } from '../../../../proxy/orders';
import { MenuItemService, MenuItemDto } from '../../../../proxy/menu-items';
import { TableService, TableDto } from '../../../../proxy/tables';

@Component({
  selector: 'app-order-create',
  templateUrl: './order-create.component.html',
  styleUrls: ['./order-create.component.scss'],
  providers: [MessageService, ConfirmationService]
})
export class OrderCreateComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  // ABP service injection (Injection dịch vụ ABP)
  private orderService = inject(OrderService);
  private menuItemService = inject(MenuItemService);
  private tableService = inject(TableService);
  private messageService = inject(MessageService);
  private confirmationService = inject(ConfirmationService);

  // Component state (Trạng thái component)
  selectedTable: TableDto | null = null;
  availableTables: TableDto[] = [];
  menuItems: MenuItemDto[] = [];
  orderItems: any[] = [];
  loading = false;

  ngOnInit(): void {
    this.loadTables();
    this.loadMenuItems();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  /// <summary>Tải danh sách bàn trống</summary>
  private loadTables(): void {
    this.tableService.getAvailable()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (tables) => {
          this.availableTables = tables;
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error',
            summary: 'Lỗi',
            detail: 'Không thể tải danh sách bàn'
          });
        }
      });
  }

  /// <summary>Thêm món vào đơn hàng</summary>
  addMenuItem(menuItem: MenuItemDto, quantity: number): void {
    const existingItem = this.orderItems.find(item => item.menuItemId === menuItem.id);
    
    if (existingItem) {
      existingItem.quantity += quantity;
      existingItem.subtotal = existingItem.quantity * existingItem.price;
    } else {
      this.orderItems.push({
        menuItemId: menuItem.id,
        menuItemName: menuItem.name,
        quantity: quantity,
        price: menuItem.price,
        subtotal: quantity * menuItem.price,
        notes: ''
      });
    }
  }

  /// <summary>Tính tổng tiền đơn hàng</summary>
  get totalAmount(): number {
    return this.orderItems.reduce((total, item) => total + item.subtotal, 0);
  }
}
```

## State Management Architecture (Kiến trúc Quản lý Trạng thái)

### State Structure (Cấu trúc Trạng thái)

```typescript
// NgRx State Structure
interface AppState {
  auth: AuthState;
  orders: OrderState;
  menu: MenuState;
  tables: TableState;
  payments: PaymentState;
  ui: UIState;
}

interface OrderState {
  orders: Order[];
  selectedOrder: Order | null;
  currentTableOrders: Order[];
  loading: boolean;
  error: string | null;
}

// Actions
export const OrderActions = createActionGroup({
  source: 'Order',
  events: {
    'Load Orders': emptyProps(),
    'Load Orders Success': props<{ orders: Order[] }>(),
    'Load Orders Failure': props<{ error: string }>(),
    'Create Order': props<{ order: CreateOrderDto }>(),
    'Update Order Status': props<{ orderId: string; status: OrderStatus }>(),
    'Real Time Order Update': props<{ order: Order }>()
  }
});
```

### State Management Patterns (Các Mẫu Quản lý Trạng thái)

- **Feature State Modules:** Each restaurant feature (orders, menu, tables) has dedicated state slice
- **Entity State Management:** Use @ngrx/entity for normalized data storage and efficient updates
- **Real-time State Sync:** SignalR events automatically dispatch NgRx actions for state updates
- **Optimistic Updates:** UI updates immediately, rollback on server error
- **Caching Strategy:** Store menu data and table configurations in state for offline capability

## Routing Architecture (Kiến trúc Định tuyến)

### Route Organization (Tổ chức Định tuyến)

```
/dashboard                  # Main restaurant dashboard
├── /tables                # Table management view
├── /orders                # Order processing
│   ├── /new              # Create new order
│   ├── /:id              # Order details
│   └── /:id/payment      # Payment processing
├── /menu                  # Menu management
│   ├── /categories       # Category management
│   └── /items            # Item management
├── /kitchen               # Kitchen display
├── /reservations          # Reservation management
├── /reports               # Analytics and reporting
├── /staff                 # Staff management
│   └── /leaves           # Leave management
└── /settings              # System settings
```

### Protected Route Pattern (Mẫu Định tuyến Được bảo vệ)

```typescript
// ABP Permission-based Route Guard
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { PermissionService } from '@abp/ng.core';

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private permissionService: PermissionService,
    private router: Router
  ) {}

  async canActivate(route: ActivatedRouteSnapshot): Promise<boolean> {
    const requiredPermission = route.data['permission'];
    
    if (!requiredPermission) {
      return true;
    }

    const hasPermission = await this.permissionService
      .getGrantedPolicy(requiredPermission);

    if (!hasPermission) {
      this.router.navigate(['/access-denied']);
      return false;
    }

    return true;
  }
}
```

## Frontend Services Layer (Lớp Dịch vụ Frontend)

### ABP Auto-Generated Service Proxies (Service Proxy Tự động tạo bởi ABP)

**Step 1: Generate Proxies (Bước 1: Tạo Proxy)**
```bash
# From angular/ directory (Từ thư mục angular/)
abp generate-proxy -t ng -u https://localhost:44391

# Or using npm script (Hoặc sử dụng npm script)
npm run generate-proxy
```

**Step 2: Auto-Generated Service (Bước 2: Service Tự động tạo)**
```typescript
// Auto-generated by ABP CLI in src/app/proxy/orders/order.service.ts
// (Tự động tạo bởi ABP CLI)
import { Injectable } from '@angular/core';
import { RestService } from '@abp/ng.core';
import { Observable } from 'rxjs';
import type { GetOrdersInput, OrderDto, CreateOrderDto, UpdateOrderStatusDto } from './models';

@Injectable({
  providedIn: 'root',
})
export class OrderService {
  apiName = 'Default';

  constructor(private restService: RestService) {}

  create = (input: CreateOrderDto): Observable<OrderDto> =>
    this.restService.request<any, OrderDto>({
      method: 'POST',
      url: '/api/app/orders',
      body: input,
    }, { apiName: this.apiName });

  getList = (input: GetOrdersInput): Observable<PagedResultDto<OrderDto>> =>
    this.restService.request<any, PagedResultDto<OrderDto>>({
      method: 'GET',
      url: '/api/app/orders',
      params: { ...input },
    }, { apiName: this.apiName });
}
```

### Service Example (Ví dụ Dịch vụ)

```typescript
// SignalR Service for Real-time Updates
import { Injectable } from '@angular/core';
import { HubConnection, HubConnectionBuilder } from '@microsoft/signalr';
import { BehaviorSubject, Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { OrderActions } from '@store/orders/order.actions';

@Injectable({
  providedIn: 'root'
})
export class SignalRService {
  private hubConnection: HubConnection;
  private connectionState$ = new BehaviorSubject<boolean>(false);

  // Observable streams for real-time events
  public orderStatusChanged$ = new BehaviorSubject<{orderId: string, status: string}>(null);
  public newOrderReceived$ = new BehaviorSubject<Order>(null);
  public tableStatusChanged$ = new BehaviorSubject<{tableId: string, status: string}>(null);

  constructor(private store: Store) {
    this.initializeConnection();
  }

  private initializeConnection(): void {
    this.hubConnection = new HubConnectionBuilder()
      .withUrl('/signalr/kitchen')
      .withAutomaticReconnect()
      .build();

    this.setupEventHandlers();
    this.startConnection();
  }

  private setupEventHandlers(): void {
    // Kitchen Hub Events
    this.hubConnection.on('OrderStatusChanged', (orderId: string, status: string) => {
      this.orderStatusChanged$.next({ orderId, status });
      this.store.dispatch(OrderActions.realTimeOrderUpdate({ 
        orderId, 
        status: status as OrderStatus 
      }));
    });

    this.hubConnection.on('NewOrderReceived', (order: Order) => {
      this.newOrderReceived$.next(order);
      this.store.dispatch(OrderActions.realTimeOrderUpdate({ order }));
    });
  }

  // Send updates to server
  async updateOrderStatus(orderId: string, status: string): Promise<void> {
    if (this.hubConnection.state === 'Connected') {
      await this.hubConnection.invoke('UpdateOrderStatus', orderId, status);
    }
  }
}
```