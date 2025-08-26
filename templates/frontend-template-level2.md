# Level 2: Business Logic UI Template

## 🔧 Khi nào sử dụng Level 2
- **Business processes có workflow**: Multi-step operations với business logic
- **Status tracking**: Theo dõi trạng thái và tiến trình
- **Phù hợp cho**: Order Management, Reservation Flow, Payment Process, Inventory...

## 🎯 UI Pattern: Stepper + Status badges + Workflow buttons
- Multi-step forms và wizards
- Status tracking với badges  
- Business rule validations
- Conditional UI elements
- Progress indicators

## Ví dụ: Order Management UI (Workflow + Multi-step)

### Main Component Template (Level 2)

```typescript
// File: angular/src/app/features/orders/order-management/order-management.component.ts
import { Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';

// PrimeNG imports for business UI
import { StepsModule } from 'primeng/steps';
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { BadgeModule } from 'primeng/badge';
import { TagModule } from 'primeng/tag';
import { TabViewModule } from 'primeng/tabview';
import { ProgressBarModule } from 'primeng/progressbar';
import { TimelineModule } from 'primeng/timeline';
import { DataViewModule } from 'primeng/dataview';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { InputNumberModule } from 'primeng/inputnumber';
import { TextareaModule } from 'primeng/textarea';
import { DividerModule } from 'primeng/divider';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ConfirmationService } from 'primeng/api';

// Application imports
import { ComponentBase } from '../../../shared/base/component-base';
import { OrderService } from '../../../proxy/orders/order.service';
import { TableService } from '../../../proxy/table-management/tables/table.service';
import { MenuItemService } from '../../../proxy/menu-management/menu-items/menu-item.service';
import {
  OrderDto,
  CreateOrderDto,
  OrderStatus,
  OrderItemDto,
  AddOrderItemDto
} from '../../../proxy/orders/dto/models';
import { TableDto } from '../../../proxy/table-management/tables/dto/models';
import { MenuItemDto } from '../../../proxy/menu-management/menu-items/dto/models';
import { takeUntil } from 'rxjs/operators';

interface OrderStep {
  label: string;
  routerLink?: string;
}

interface StatusConfig {
  severity: 'success' | 'info' | 'warning' | 'danger';
  icon: string;
  label: string;
}

@Component({
  selector: 'app-order-management',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    StepsModule,
    CardModule,
    ButtonModule,
    BadgeModule,
    TagModule,
    TabViewModule,
    ProgressBarModule,
    TimelineModule,
    DataViewModule,
    InputTextModule,
    DropdownModule,
    InputNumberModule,
    TextareaModule,
    DividerModule,
    ConfirmDialogModule,
  ],
  templateUrl: './order-management.component.html',
  providers: [ConfirmationService],
})
export class OrderManagementComponent extends ComponentBase implements OnInit {
  // Workflow configuration
  readonly steps: OrderStep[] = [
    { label: 'Chọn bàn' },
    { label: 'Chọn món' },
    { label: 'Xác nhận' },
    { label: 'Thanh toán' }
  ];

  readonly statusConfig: Record<OrderStatus, StatusConfig> = {
    [OrderStatus.Draft]: { 
      severity: 'info', 
      icon: 'pi pi-edit', 
      label: 'Nháp' 
    },
    [OrderStatus.Confirmed]: { 
      severity: 'success', 
      icon: 'pi pi-check', 
      label: 'Đã xác nhận' 
    },
    [OrderStatus.InProgress]: { 
      severity: 'warning', 
      icon: 'pi pi-clock', 
      label: 'Đang xử lý' 
    },
    [OrderStatus.Completed]: { 
      severity: 'success', 
      icon: 'pi pi-check-circle', 
      label: 'Hoàn thành' 
    },
    [OrderStatus.Cancelled]: { 
      severity: 'danger', 
      icon: 'pi pi-times', 
      label: 'Hủy' 
    }
  };

  // Signals for reactive state management
  currentOrder = signal<OrderDto | null>(null);
  orderItems = signal<OrderItemDto[]>([]);
  selectedTable = signal<TableDto | null>(null);
  availableTables = signal<TableDto[]>([]);
  menuItems = signal<MenuItemDto[]>([]);
  activeStepIndex = signal(0);
  loading = signal(false);

  // Computed values
  orderTotal = computed(() => {
    const items = this.orderItems();
    return items.reduce((total, item) => 
      total + (item.quantity * item.unitPrice), 0
    );
  });

  canProceedToNextStep = computed(() => {
    const step = this.activeStepIndex();
    switch (step) {
      case 0: return !!this.selectedTable();
      case 1: return this.orderItems().length > 0;
      case 2: return this.orderTotal() > 0;
      default: return true;
    }
  });

  orderProgress = computed(() => {
    const order = this.currentOrder();
    if (!order) return 0;
    
    switch (order.status) {
      case OrderStatus.Draft: return 25;
      case OrderStatus.Confirmed: return 50;
      case OrderStatus.InProgress: return 75;
      case OrderStatus.Completed: return 100;
      default: return 0;
    }
  });

  // Forms
  orderForm!: FormGroup;
  orderItemForm!: FormGroup;

  // Services
  private orderService = inject(OrderService);
  private tableService = inject(TableService);
  private menuItemService = inject(MenuItemService);
  private confirmationService = inject(ConfirmationService);
  private fb = inject(FormBuilder);
  private router = inject(Router);

  ngOnInit() {
    this.initializeForms();
    this.loadInitialData();
  }

  // Initialization
  private initializeForms() {
    this.orderForm = this.fb.group({
      tableId: ['', Validators.required],
      customerName: [''],
      customerPhone: [''],
      notes: ['']
    });

    this.orderItemForm = this.fb.group({
      menuItemId: ['', Validators.required],
      quantity: [1, [Validators.required, Validators.min(1)]],
      notes: ['']
    });
  }

  private loadInitialData() {
    this.loading.set(true);

    // Load available tables and menu items concurrently
    Promise.all([
      this.loadAvailableTables(),
      this.loadMenuItems()
    ]).finally(() => {
      this.loading.set(false);
    });
  }

  private async loadAvailableTables() {
    try {
      const result = await this.tableService.getAvailableTables().toPromise();
      this.availableTables.set(result || []);
    } catch (error) {
      this.handleApiError(error, 'Không thể tải danh sách bàn');
    }
  }

  private async loadMenuItems() {
    try {
      const result = await this.menuItemService.getActiveMenuItems().toPromise();
      this.menuItems.set(result || []);
    } catch (error) {
      this.handleApiError(error, 'Không thể tải danh sách món ăn');
    }
  }

  // Step navigation
  nextStep() {
    if (this.canProceedToNextStep()) {
      const currentStep = this.activeStepIndex();
      if (currentStep < this.steps.length - 1) {
        this.activeStepIndex.set(currentStep + 1);
        this.executeStepAction(currentStep + 1);
      }
    }
  }

  previousStep() {
    const currentStep = this.activeStepIndex();
    if (currentStep > 0) {
      this.activeStepIndex.set(currentStep - 1);
    }
  }

  goToStep(stepIndex: number) {
    if (stepIndex >= 0 && stepIndex < this.steps.length) {
      this.activeStepIndex.set(stepIndex);
      this.executeStepAction(stepIndex);
    }
  }

  private executeStepAction(stepIndex: number) {
    switch (stepIndex) {
      case 0:
        this.initializeTableSelection();
        break;
      case 1:
        this.initializeMenuSelection();
        break;
      case 2:
        this.prepareOrderConfirmation();
        break;
      case 3:
        this.processPayment();
        break;
    }
  }

  // Step implementations
  private initializeTableSelection() {
    // Reset table selection
    this.selectedTable.set(null);
    this.orderForm.patchValue({ tableId: '' });
  }

  onTableSelected(table: TableDto) {
    this.selectedTable.set(table);
    this.orderForm.patchValue({ tableId: table.id });
  }

  private initializeMenuSelection() {
    if (!this.currentOrder()) {
      this.createDraftOrder();
    }
  }

  private createDraftOrder() {
    const orderData: CreateOrderDto = {
      tableId: this.selectedTable()?.id!,
      customerName: this.orderForm.value.customerName,
      customerPhone: this.orderForm.value.customerPhone,
      notes: this.orderForm.value.notes
    };

    this.orderService.create(orderData)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (order) => {
          this.currentOrder.set(order);
          this.showSuccess('Thành công', 'Đã tạo đơn hàng mới');
        },
        error: (error) => {
          this.handleApiError(error, 'Không thể tạo đơn hàng');
        }
      });
  }

  addOrderItem() {
    if (this.orderItemForm.valid && this.currentOrder()) {
      const itemData: AddOrderItemDto = {
        orderId: this.currentOrder()!.id!,
        menuItemId: this.orderItemForm.value.menuItemId,
        quantity: this.orderItemForm.value.quantity,
        notes: this.orderItemForm.value.notes
      };

      this.orderService.addItem(itemData)
        .pipe(takeUntil(this.destroyed$))
        .subscribe({
          next: (orderItem) => {
            const currentItems = this.orderItems();
            this.orderItems.set([...currentItems, orderItem]);
            this.orderItemForm.reset({ quantity: 1 });
            this.showSuccess('Thành công', 'Đã thêm món vào đơn hàng');
          },
          error: (error) => {
            this.handleApiError(error, 'Không thể thêm món vào đơn hàng');
          }
        });
    }
  }

  removeOrderItem(itemId: string) {
    this.confirmationService.confirm({
      message: 'Bạn có chắc chắn muốn xóa món này khỏi đơn hàng?',
      header: 'Xác nhận',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.orderService.removeItem(itemId)
          .pipe(takeUntil(this.destroyed$))
          .subscribe({
            next: () => {
              const currentItems = this.orderItems();
              this.orderItems.set(currentItems.filter(item => item.id !== itemId));
              this.showSuccess('Thành công', 'Đã xóa món khỏi đơn hàng');
            },
            error: (error) => {
              this.handleApiError(error, 'Không thể xóa món khỏi đơn hàng');
            }
          });
      }
    });
  }

  private prepareOrderConfirmation() {
    // Load final order details for confirmation
    if (this.currentOrder()) {
      this.refreshOrderData();
    }
  }

  private refreshOrderData() {
    const orderId = this.currentOrder()?.id;
    if (orderId) {
      this.orderService.get(orderId)
        .pipe(takeUntil(this.destroyed$))
        .subscribe({
          next: (order) => {
            this.currentOrder.set(order);
            this.orderItems.set(order.orderItems || []);
          },
          error: (error) => {
            this.handleApiError(error, 'Không thể tải thông tin đơn hàng');
          }
        });
    }
  }

  confirmOrder() {
    const order = this.currentOrder();
    if (order && order.status === OrderStatus.Draft) {
      this.orderService.confirm(order.id!)
        .pipe(takeUntil(this.destroyed$))
        .subscribe({
          next: (confirmedOrder) => {
            this.currentOrder.set(confirmedOrder);
            this.nextStep();
            this.showSuccess('Thành công', 'Đã xác nhận đơn hàng');
          },
          error: (error) => {
            this.handleApiError(error, 'Không thể xác nhận đơn hàng');
          }
        });
    }
  }

  private processPayment() {
    // Navigate to payment processing
    const order = this.currentOrder();
    if (order) {
      this.router.navigate(['/orders/payment', order.id]);
    }
  }

  // Utility methods
  getStatusConfig(status: OrderStatus): StatusConfig {
    return this.statusConfig[status];
  }

  formatCurrency(amount: number): string {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(amount);
  }

  getStepClass(index: number): string {
    const current = this.activeStepIndex();
    if (index < current) return 'completed';
    if (index === current) return 'active';
    return 'pending';
  }
}
```

### HTML Template (Level 2)

```html
<!-- File: angular/src/app/features/orders/order-management/order-management.component.html -->
<div class="max-w-7xl mx-auto p-6">
  <div class="bg-white rounded-lg shadow-sm border">
    <!-- Header với steps -->
    <div class="p-6 border-b">
      <h2 class="text-2xl font-bold text-gray-900 mb-6">Quản lý đơn hàng</h2>
      <p-steps 
        [model]="steps" 
        [activeIndex]="activeStepIndex()"
        [readonly]="false"
        (activeIndexChange)="goToStep($event)">
      </p-steps>
    </div>

    <!-- Progress bar nếu có order -->
    @if (currentOrder()) {
      <div class="p-4 bg-gray-50 border-b">
        <p-progressBar 
          [value]="orderProgress()" 
          [showValue]="true"
          unit="%"
          class="mb-3">
        </p-progressBar>
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-gray-600">Trạng thái:</span>
          <p-tag 
            [severity]="getStatusConfig(currentOrder()!.status).severity"
            [icon]="getStatusConfig(currentOrder()!.status).icon"
            [value]="getStatusConfig(currentOrder()!.status).label">
          </p-tag>
        </div>
      </div>
    }

    <div class="p-6">
      <!-- Step 0: Chọn bàn -->
      @if (activeStepIndex() === 0) {
        <div class="space-y-8">
          <h3 class="text-lg font-semibold text-gray-900">Chọn bàn</h3>
          <form [formGroup]="orderForm">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <!-- Thông tin khách hàng -->
              <div class="space-y-6">
                <h4 class="text-base font-medium text-gray-900 border-b pb-2">Thông tin khách hàng</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="space-y-2">
                    <label for="customerName" class="block text-sm font-medium text-gray-700">Tên khách hàng</label>
                    <input 
                      pInputText 
                      id="customerName" 
                      formControlName="customerName"
                      placeholder="Nhập tên khách hàng"
                      class="w-full">
                  </div>
                  <div class="space-y-2">
                    <label for="customerPhone" class="block text-sm font-medium text-gray-700">Số điện thoại</label>
                    <input 
                      pInputText 
                      id="customerPhone" 
                      formControlName="customerPhone"
                      placeholder="Nhập số điện thoại"
                      class="w-full">
                  </div>
                </div>
                <div class="space-y-2">
                  <label for="notes" class="block text-sm font-medium text-gray-700">Ghi chú</label>
                  <textarea 
                    pInputTextarea 
                    id="notes" 
                    formControlName="notes"
                    rows="3"
                    placeholder="Ghi chú đặc biệt"
                    class="w-full">
                  </textarea>
                </div>
              </div>

              <!-- Chọn bàn -->
              <div class="space-y-6">
                <h4 class="text-base font-medium text-gray-900 border-b pb-2">Chọn bàn trống</h4>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                  @for (table of availableTables(); track table.id) {
                    <div 
                      class="relative p-4 border-2 rounded-lg cursor-pointer transition-all hover:shadow-md"
                      [class]="selectedTable()?.id === table.id ? 'border-blue-500 bg-blue-50' : 'border-gray-200 hover:border-gray-300'"
                      (click)="onTableSelected(table)">
                      <div class="text-center">
                        <div class="text-lg font-bold text-gray-900 mb-2">{{ table.tableNumber }}</div>
                        <div class="space-y-1 text-xs text-gray-600">
                          <div>{{ table.capacity }} chỗ</div>
                          <div>{{ table.section?.sectionName }}</div>
                        </div>
                      </div>
                      @if (selectedTable()?.id === table.id) {
                        <div class="absolute top-2 right-2 w-5 h-5 bg-blue-500 rounded-full flex items-center justify-center">
                          <i class="pi pi-check text-white text-xs"></i>
                        </div>
                      }
                    </div>
                  }
                </div>
              </div>
            </div>
          </form>
        </div>
      }

      <!-- Step 1: Chọn món -->
      @if (activeStepIndex() === 1) {
        <div class="step-content menu-selection">
          <div class="selection-layout">
            <!-- Menu items -->
            <div class="menu-section">
              <h3>Thực đơn</h3>
              <p-dataView [value]="menuItems()" layout="grid">
                <ng-template pTemplate="gridItem" let-item>
                  <div class="menu-item-card">
                    <img [src]="item.imageUrl || '/assets/default-food.jpg'" [alt]="item.name">
                    <h4>{{ item.name }}</h4>
                    <p>{{ item.description }}</p>
                    <div class="price">{{ formatCurrency(item.price) }}</div>
                    <button 
                      pButton 
                      label="Thêm" 
                      icon="pi pi-plus"
                      (click)="selectMenuItem(item)">
                    </button>
                  </div>
                </ng-template>
              </p-dataView>
            </div>

            <!-- Order items -->
            <div class="order-section">
              <h3>Đơn hàng hiện tại</h3>
              <div class="order-items">
                @for (item of orderItems(); track item.id) {
                  <div class="order-item">
                    <div class="item-info">
                      <span class="name">{{ item.menuItem?.name }}</span>
                      <span class="quantity">x{{ item.quantity }}</span>
                    </div>
                    <div class="item-actions">
                      <span class="price">{{ formatCurrency(item.subtotal) }}</span>
                      <button 
                        pButton 
                        icon="pi pi-trash" 
                        class="p-button-text p-button-danger"
                        (click)="removeOrderItem(item.id!)">
                      </button>
                    </div>
                  </div>
                }
              </div>
              
              <p-divider></p-divider>
              
              <div class="order-total">
                <strong>Tổng cộng: {{ formatCurrency(orderTotal()) }}</strong>
              </div>
            </div>
          </div>
        </div>
      }

      <!-- Step 2: Xác nhận -->
      @if (activeStepIndex() === 2) {
        <div class="step-content order-confirmation">
          <h3>Xác nhận đơn hàng</h3>
          
          <!-- Order summary -->
          <div class="confirmation-layout">
            <div class="order-summary">
              <h4>Thông tin đơn hàng</h4>
              <div class="summary-item">
                <span>Bàn số:</span>
                <span>{{ selectedTable()?.tableNumber }}</span>
              </div>
              <div class="summary-item">
                <span>Khách hàng:</span>
                <span>{{ orderForm.value.customerName || 'Không có' }}</span>
              </div>
              <div class="summary-item">
                <span>Số điện thoại:</span>
                <span>{{ orderForm.value.customerPhone || 'Không có' }}</span>
              </div>
            </div>

            <div class="order-details">
              <h4>Chi tiết món ăn</h4>
              <div class="order-timeline">
                @for (item of orderItems(); track item.id) {
                  <div class="timeline-item">
                    <div class="item-content">
                      <span class="item-name">{{ item.menuItem?.name }}</span>
                      <span class="item-quantity">x{{ item.quantity }}</span>
                      <span class="item-price">{{ formatCurrency(item.subtotal) }}</span>
                    </div>
                    @if (item.notes) {
                      <div class="item-notes">{{ item.notes }}</div>
                    }
                  </div>
                }
              </div>
              
              <div class="final-total">
                <h4>Tổng thanh toán: {{ formatCurrency(orderTotal()) }}</h4>
              </div>
            </div>
          </div>

          <div class="confirmation-actions">
            <button 
              pButton 
              label="Xác nhận đơn hàng" 
              icon="pi pi-check"
              class="p-button-success"
              [disabled]="orderItems().length === 0"
              (click)="confirmOrder()">
            </button>
          </div>
        </div>
      }

      <!-- Step 3: Thanh toán -->
      @if (activeStepIndex() === 3) {
        <div class="step-content payment">
          <h3>Thanh toán</h3>
          <div class="payment-info">
            <p-card>
              <div class="success-message">
                <i class="pi pi-check-circle text-success"></i>
                <h4>Đơn hàng đã được xác nhận!</h4>
                <p>Đơn hàng #{{ currentOrder()?.orderNumber }} sẽ được chuyển đến bếp xử lý.</p>
                <p>Tổng thanh toán: <strong>{{ formatCurrency(orderTotal()) }}</strong></p>
              </div>
            </p-card>
          </div>
        </div>
      }
    </div>

    <!-- Navigation buttons -->
    <div class="card-footer">
      <div class="step-navigation">
        <button 
          pButton 
          label="Quay lại" 
          icon="pi pi-chevron-left"
          class="p-button-secondary"
          [disabled]="activeStepIndex() === 0"
          (click)="previousStep()">
        </button>
        
        <div class="step-info">
          Bước {{ activeStepIndex() + 1 }} / {{ steps.length }}
        </div>
        
        <button 
          pButton 
          [label]="activeStepIndex() === steps.length - 1 ? 'Hoàn thành' : 'Tiếp theo'"
          [icon]="activeStepIndex() === steps.length - 1 ? 'pi pi-check' : 'pi pi-chevron-right'"
          iconPos="right"
          [disabled]="!canProceedToNextStep()"
          (click)="nextStep()">
        </button>
      </div>
    </div>
  </div>

  <!-- Loading overlay -->
  @if (loading()) {
    <div class="loading-overlay">
      <p-progressSpinner></p-progressSpinner>
    </div>
  }
</div>
```

## CSS Styles (Level 2 Specific)

```scss
// File: angular/src/app/features/orders/order-management/order-management.component.scss
.step-content {
  @apply min-h-96;
  
  h3 {
    @apply text-lg font-semibold text-gray-900 mb-6;
  }
  
  h4 {
    @apply text-base font-medium text-gray-900 mb-4;
  }
}

.selection-layout {
  @apply grid grid-cols-1 lg:grid-cols-3 gap-8;
  
  .menu-section {
    @apply lg:col-span-2;
    
    .menu-item-card {
      @apply bg-white border rounded-lg p-4 hover:shadow-md transition-shadow;
      
      img {
        @apply w-full h-32 object-cover rounded-md mb-3;
      }
      
      h4 {
        @apply font-medium text-gray-900 mb-2;
      }
      
      p {
        @apply text-sm text-gray-600 mb-3;
      }
      
      .price {
        @apply text-lg font-semibold text-blue-600 mb-3;
      }
    }
  }
  
  .order-section {
    @apply bg-gray-50 rounded-lg p-4;
    
    .order-items {
      @apply space-y-3 mb-4;
      
      .order-item {
        @apply flex justify-between items-center bg-white rounded p-3 shadow-sm;
        
        .item-info {
          @apply flex flex-col;
          
          .name {
            @apply font-medium text-gray-900;
          }
          
          .quantity {
            @apply text-sm text-gray-500;
          }
        }
        
        .item-actions {
          @apply flex items-center gap-3;
          
          .price {
            @apply font-semibold text-blue-600;
          }
        }
      }
    }
    
    .order-total {
      @apply text-right text-lg font-bold text-gray-900;
    }
  }
}

.confirmation-layout {
  @apply grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8;
  
  .order-summary {
    @apply bg-gray-50 rounded-lg p-6;
    
    .summary-item {
      @apply flex justify-between items-center py-2 border-b border-gray-200 last:border-b-0;
      
      span:first-child {
        @apply font-medium text-gray-700;
      }
      
      span:last-child {
        @apply text-gray-900;
      }
    }
  }
  
  .order-details {
    .order-timeline {
      @apply space-y-4 mb-6;
      
      .timeline-item {
        @apply bg-white border rounded-lg p-4;
        
        .item-content {
          @apply flex justify-between items-center;
          
          .item-name {
            @apply font-medium text-gray-900;
          }
          
          .item-quantity {
            @apply text-gray-600;
          }
          
          .item-price {
            @apply font-semibold text-blue-600;
          }
        }
        
        .item-notes {
          @apply mt-2 text-sm text-gray-500 italic;
        }
      }
    }
    
    .final-total {
      @apply text-center p-4 bg-blue-50 rounded-lg;
      
      h4 {
        @apply text-xl font-bold text-blue-900 mb-0;
      }
    }
  }
}

.confirmation-actions {
  @apply text-center;
}

.card-footer {
  @apply p-6 border-t bg-gray-50;
  
  .step-navigation {
    @apply flex justify-between items-center;
    
    .step-info {
      @apply text-sm font-medium text-gray-600;
    }
  }
}

.loading-overlay {
  @apply fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50;
}

.success-message {
  @apply text-center space-y-4;
  
  i {
    @apply text-6xl text-green-600;
  }
  
  h4 {
    @apply text-xl font-bold text-green-800 mb-0;
  }
  
  p {
    @apply text-gray-600;
  }
}

// Business Logic UI specific styles
.p-steps {
  .p-steps-item {
    &.p-highlight .p-steps-number {
      @apply bg-blue-500 text-white;
    }
    
    &.p-disabled .p-steps-number {
      @apply bg-gray-300 text-gray-500;
    }
  }
}

.p-tag {
  &.p-tag-success {
    @apply bg-green-100 text-green-800;
  }
  
  &.p-tag-warning {
    @apply bg-yellow-100 text-yellow-800;
  }
  
  &.p-tag-info {
    @apply bg-blue-100 text-blue-800;
  }
  
  &.p-tag-danger {
    @apply bg-red-100 text-red-800;
  }
}

.p-progressbar {
  .p-progressbar-value {
    @apply bg-gradient-to-r from-blue-500 to-blue-600;
  }
}
```

## Key Features của Level 2

### 1. Multi-step Workflow với PrimeNG Steps
- **p-steps component**: Hiển thị progress của workflow
- **Step navigation**: Cho phép di chuyển giữa các bước
- **Conditional rendering**: Hiển thị nội dung theo step hiện tại

### 2. State Management với Angular Signals
- **Reactive state**: Sử dụng signals cho reactive programming
- **Computed values**: Tự động tính toán derived state
- **Signal effects**: Tự động phản ứng với thay đổi state

### 3. Business Logic Integration
- **Form validation**: Validation rules cho từng step
- **Business rules**: Logic kiểm tra có thể tiến tới step tiếp theo
- **Status tracking**: Theo dõi và hiển thị trạng thái quy trình

### 4. Advanced UI Components
- **Progress bars**: Hiển thị tiến độ xử lý
- **Status badges**: Tags hiển thị trạng thái với màu sắc
- **Data views**: Hiển thị danh sách với layout linh hoạt
- **Timeline components**: Hiển thị lịch sử và timeline

### 5. Enhanced User Experience
- **Loading states**: Hiển thị loading khi xử lý
- **Confirmation dialogs**: Xác nhận hành động quan trọng  
- **Success/error messaging**: Feedback rõ ràng cho người dùng
- **Responsive design**: Hoạt động tốt trên mọi thiết bị

## Best Practices cho Level 2

1. **Workflow Design**: Thiết kế workflow rõ ràng, dễ hiểu
2. **State Management**: Sử dụng signals và computed values hiệu quả
3. **Form Handling**: Quản lý forms phức tạp với validation
4. **Error Handling**: Xử lý lỗi và thông báo người dùng
5. **Performance**: Lazy loading và optimization cho UI phức tạp
6. **Accessibility**: Đảm bảo keyboard navigation và screen readers
7. **Testing**: Unit test cho business logic và integration test cho workflow