import { Component, OnInit, OnDestroy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Subject, takeUntil, catchError, of } from 'rxjs';

// PrimeNG Components
import { ButtonModule } from 'primeng/button';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToastModule } from 'primeng/toast';
import { SkeletonModule } from 'primeng/skeleton';

// PrimeNG Services
import { MessageService } from 'primeng/api';

// ABP Proxy Services
import { KitchenDashboardService } from '../../../../proxy/kitchen/kitchen-dashboard.service';
import { KitchenTableGroupDto, CookingStatsDto, UpdateOrderItemStatusInput } from '../../../../proxy/kitchen/dtos/models';
import { OrderItemStatus } from '../../../../proxy/orders/order-item-status.enum';

// Custom Services  
import { KitchenSignalRService, KitchenUpdateEvent } from '../../services/kitchen-signalr.service';

// Components
import { KitchenStatusColumnComponent } from './kitchen-status-column/kitchen-status-column.component';
import { StatusUpdateEvent } from './shared/order-item-card/order-item-card.component';

@Component({
  selector: 'app-kitchen-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule,
    ProgressSpinnerModule,
    ToastModule,
    SkeletonModule,
    KitchenStatusColumnComponent
  ],
  providers: [MessageService],
  templateUrl: './kitchen-dashboard.component.html',
  styleUrl: './kitchen-dashboard.component.scss'
})
export class KitchenDashboardComponent implements OnInit, OnDestroy {
  // Reactive state using Angular signals
  private readonly destroy$ = new Subject<void>();
  
  // Data signals - separated by status
  pendingTableGroups = signal<KitchenTableGroupDto[]>([]);
  preparingTableGroups = signal<KitchenTableGroupDto[]>([]);
  readyTableGroups = signal<KitchenTableGroupDto[]>([]);
  cookingStats = signal<CookingStatsDto | null>(null);
  loading = signal<boolean>(true);
  refreshing = signal<boolean>(false);
  
  
  // SignalR state
  signalRConnectionState = signal<'disconnected' | 'connecting' | 'connected'>('disconnected');
  lastUpdate = signal<Date | null>(null);

  // Enum reference for template
  OrderItemStatus = OrderItemStatus;

  constructor(
    private kitchenDashboardService: KitchenDashboardService,
    private kitchenSignalRService: KitchenSignalRService,
    private messageService: MessageService,
  ) {}

  ngOnInit(): void {
    this.loadData();
    this.setupSignalR();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
    this.kitchenSignalRService.disconnect();
  }

  /**
   * Load dữ liệu dashboard
   */
  private loadData(): void {
    this.loading.set(true);
    
    // Load both cooking orders and stats using ABP proxy
    const orders$ = this.kitchenDashboardService.getCookingOrdersGrouped();
    const stats$ = this.kitchenDashboardService.getCookingStats();

    orders$.pipe(
      takeUntil(this.destroy$),
      catchError(error => {
        this.messageService.add({
          severity: 'error',
          summary: 'Lỗi',
          detail: 'Không thể tải danh sách món ăn'
        });
        console.error('Error loading cooking orders:', error);
        return of([]);
      })
    ).subscribe(orders => {
      this.categorizeTableGroups(orders);
      this.loading.set(false);
      this.refreshing.set(false);
    });

    stats$.pipe(
      takeUntil(this.destroy$),
      catchError(error => {
        console.error('Error loading cooking stats:', error);
        return of(null);
      })
    ).subscribe(stats => {
      this.cookingStats.set(stats);
    });
  }


  /**
   * Setup SignalR real-time connection
   */
  private setupSignalR(): void {
    // Listen to connection state changes
    this.kitchenSignalRService.getConnectionState()
      .pipe(takeUntil(this.destroy$))
      .subscribe(state => {
        this.signalRConnectionState.set(state);
        console.log('SignalR connection state:', state);
      });

    // Listen to kitchen updates
    this.kitchenSignalRService.getKitchenUpdates()
      .pipe(takeUntil(this.destroy$))
      .subscribe(update => {
        if (update) {
          this.handleSignalRUpdate(update);
        }
      });

    // Establish connection
    this.kitchenSignalRService.connect()
      .catch(error => {
        console.error('Failed to connect to SignalR:', error);
        this.messageService.add({
          severity: 'warn',
          summary: 'Kết Nối Real-time',
          detail: 'Không thể kết nối real-time. Dữ liệu sẽ được cập nhật theo lịch trình.'
        });
      });
  }

  /**
   * Handle SignalR updates
   */
  private handleSignalRUpdate(update: KitchenUpdateEvent): void {
    console.log('Received SignalR update:', update);
    this.lastUpdate.set(new Date());

    switch (update.type) {
      case 'ORDER_STATUS_CHANGED':
        this.messageService.add({
          severity: 'info',
          summary: 'Cập Nhật Trạng Thái',
          detail: update.message || 'Trạng thái món ăn đã thay đổi'
        });
        // Refresh data để lấy thông tin mới nhất
        this.loadData();
        break;

      case 'NEW_ORDER_RECEIVED':
        this.messageService.add({
          severity: 'success',
          summary: 'Đơn Hàng Mới',
          detail: update.message || 'Có đơn hàng mới cần chuẩn bị'
        });
        // Refresh data để hiển thị đơn mới
        this.loadData();
        break;

      case 'ITEM_PRIORITY_UPDATED':
        // Auto refresh để cập nhật priority mới
        this.loadData();
        break;
    }
  }

  /**
   * Manual refresh
   */
  onRefresh(): void {
    if (!this.loading()) {
      this.loadData();
    }
  }

  /**
   * Handle status update từ StatusUpdateEvent
   */
  onStatusUpdate(event: StatusUpdateEvent): void {
    const { orderItemId, status: newStatus } = event;
    const updateInput: UpdateOrderItemStatusInput = {
      orderItemId,
      status: newStatus
    };

    this.kitchenDashboardService.updateOrderItemStatus(updateInput)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: () => {
          this.messageService.add({
            severity: 'success',
            summary: 'Thành Công',
            detail: 'Đã cập nhật trạng thái món thành công'
          });
          
          // Refresh data after successful update
          this.onRefresh();
        },
        error: (error) => {
          this.messageService.add({
            severity: 'error',
            summary: 'Lỗi',
            detail: 'Không thể cập nhật trạng thái món'
          });
          console.error('Error updating order item status:', error);
        }
      });
  }

  /**
   * Phân loại table groups theo trạng thái
   */
  private categorizeTableGroups(allTableGroups: KitchenTableGroupDto[]): void {
    const pending: KitchenTableGroupDto[] = [];
    const preparing: KitchenTableGroupDto[] = [];
    const ready: KitchenTableGroupDto[] = [];

    allTableGroups.forEach(group => {
      // Kiểm tra nếu group có items với trạng thái tương ứng
      const hasPending = group.orderItems.some(item => item.status === OrderItemStatus.Pending);
      const hasPreparing = group.orderItems.some(item => item.status === OrderItemStatus.Preparing);
      const hasReady = group.orderItems.some(item => item.status === OrderItemStatus.Ready);

      if (hasPending) {
        pending.push(group);
      }
      if (hasPreparing) {
        preparing.push(group);
      }
      if (hasReady) {
        ready.push(group);
      }
    });

    // Cập nhật signals
    this.pendingTableGroups.set(pending);
    this.preparingTableGroups.set(preparing);
    this.readyTableGroups.set(ready);
  }

  /**
   * Track by function for ngFor performance
   */
  trackByTableNumber(index: number, group: KitchenTableGroupDto): string {
    return group.tableNumber || index.toString();
  }

}