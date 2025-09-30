import { Component, OnInit, OnDestroy, signal, Injector } from '@angular/core';
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
import {
  KitchenTableGroupDto,
  CookingStatsDto,
  UpdateOrderItemStatusInput,
} from '../../../../proxy/kitchen/dtos/models';
import { OrderItemStatus } from '../../../../proxy/orders/order-item-status.enum';

// Custom Services
import { KitchenSignalRService, KitchenUpdateEvent } from '../../services/kitchen-signalr.service';
import { NotificationSoundService } from '../../services/notification-sound.service';

// Components
import { KitchenStatusColumnComponent } from './kitchen-status-column/kitchen-status-column.component';
import { StatusUpdateEvent } from './shared/order-item-card/order-item-card.component';
import { ComponentBase } from '@/shared/base/component-base';

@Component({
  selector: 'app-kitchen-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule,
    ProgressSpinnerModule,
    ToastModule,
    SkeletonModule,
    KitchenStatusColumnComponent,
  ],
  providers: [MessageService],
  templateUrl: './kitchen-dashboard.component.html',
  styleUrl: './kitchen-dashboard.component.scss',
})
export class KitchenDashboardComponent extends ComponentBase implements OnInit, OnDestroy {
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
    private notificationSoundService: NotificationSoundService,
  ) {
    super();
  }

  ngOnInit(): void {
    this.loadData();
    this.setupSignalR();
    this.initializeNotificationSound();
  }

  ngOnDestroy(): void {
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

    orders$
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          this.handleApiError(error);
          console.error('Error loading cooking orders:', error);
          return of([]);
        }),
      )
      .subscribe(orders => {
        this.categorizeTableGroups(orders);
        this.loading.set(false);
        this.refreshing.set(false);
      });

    stats$
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          console.error('Error loading cooking stats:', error);
          return of(null);
        }),
      )
      .subscribe(stats => {
        this.cookingStats.set(stats);
      });
  }

  /**
   * Setup SignalR real-time connection
   */
  private setupSignalR(): void {
    // Listen to connection state changes
    this.kitchenSignalRService
      .getConnectionState()
      .pipe(takeUntil(this.destroyed$))
      .subscribe(state => {
        this.signalRConnectionState.set(state);
      });

    // Listen to kitchen updates
    this.kitchenSignalRService
      .getKitchenUpdates()
      .pipe(takeUntil(this.destroyed$))
      .subscribe(update => {
        if (update) {
          this.handleSignalRUpdate(update);
        }
      });

    // Establish connection
    this.kitchenSignalRService.connect().catch(error => {
      this.messageService.add({
        severity: 'warn',
        summary: 'Kết Nối Real-time',
        detail: 'Không thể kết nối real-time. Dữ liệu sẽ được cập nhật theo lịch trình.',
      });
    });
  }

  /**
   * Khởi tạo notification sound service
   */
  private async initializeNotificationSound(): Promise<void> {
    try {
      await this.notificationSoundService.initialize();
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Handle SignalR updates từ mobile
   */
  private async handleSignalRUpdate(update: KitchenUpdateEvent): Promise<void> {
    this.lastUpdate.set(new Date());

    switch (update.type) {
      case 'NEW_ORDER_RECEIVED':
        // Phát âm thanh và đọc message
        const newOrderMessage = update.message || 'Có đơn hàng mới cần chuẩn bị';
        await this.notificationSoundService.playNotification('newOrder', newOrderMessage);

        // Hiển thị thông báo đơn hàng mới
        this.messageService.add({
          severity: 'success',
          summary: 'Đơn Hàng Mới Từ Mobile',
          detail: newOrderMessage,
          life: 5000,
        });

        // Delay để đảm bảo database đã được commit
        setTimeout(() => {
          this.loadData();
        }, 1000);
        break;

      case 'ORDER_ITEM_QUANTITY_UPDATED':
        // Phát âm thanh và đọc message với thông tin chi tiết
        const updateMessage =
          update.message ||
          `${update.tableName || 'Mang về'} đã cập nhật ${update.menuItemName} thành ${update.newQuantity} món`;
        await this.notificationSoundService.playNotification('newOrder', updateMessage);

        // Hiển thị thông báo cập nhật số lượng
        this.messageService.add({
          severity: 'info',
          summary: 'Cập Nhật Số Lượng',
          detail: updateMessage,
          life: 4000,
        });

        // Delay để đảm bảo database đã được commit
        setTimeout(() => {
          this.loadData();
        }, 1000);
        break;

      case 'ORDER_ITEMS_ADDED':
        // Phát âm thanh và đọc message với thông tin chi tiết
        const addMessage =
          update.message || `${update.tableName || 'Mang về'} đã thêm ${update.addedItemsDetail}`;
        await this.notificationSoundService.playNotification('newOrder', addMessage);

        // Hiển thị thông báo thêm món
        this.messageService.add({
          severity: 'success',
          summary: 'Thêm Món Mới',
          detail: addMessage,
          life: 5000,
        });

        // Delay để đảm bảo database đã được commit
        setTimeout(() => {
          this.loadData();
        }, 1000);
        break;

      case 'ORDER_ITEM_REMOVED':
        // Phát âm thanh và đọc message với số lượng chi tiết
        const removeMessage =
          update.message ||
          `${update.tableName || 'Mang về'} đã xóa ${update.quantity} món ${update.menuItemName}`;
        await this.notificationSoundService.playNotification('newOrder', removeMessage);

        // Hiển thị thông báo xóa món
        this.messageService.add({
          severity: 'warn',
          summary: 'Xóa Món',
          detail: removeMessage,
          life: 4000,
        });

        // Delay để đảm bảo database đã được commit
        setTimeout(() => {
          this.loadData();
        }, 1000);
        break;

      case 'ORDER_ITEM_SERVED':
        // Phát âm thanh và đọc message
        const servedMessage = update.message || `Đơn ${update.orderNumber} đã được phục vụ`;
        await this.notificationSoundService.playNotification('newOrder', servedMessage);

        // Hiển thị thông báo đã phục vụ
        this.messageService.add({
          severity: 'success',
          summary: 'Món Đã Phục Vụ',
          detail: servedMessage,
          life: 3000,
        });

        // Delay để đảm bảo database đã được commit
        setTimeout(() => {
          this.loadData();
        }, 1000);
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
      status: newStatus,
    };

    this.kitchenDashboardService
      .updateOrderItemStatus(updateInput)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: () => {
          this.messageService.add({
            severity: 'success',
            summary: 'Thành Công',
            detail: 'Đã cập nhật trạng thái món thành công',
          });

          // Refresh data after successful update
          this.onRefresh();
        },
        error: error => {
          this.handleApiError(error);
        },
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

  /**
   * Bật/tắt âm thanh thông báo
   */
  toggleNotificationSound(): void {
    const currentConfig = this.notificationSoundService.getConfig();
    this.notificationSoundService.setEnabled(!currentConfig.enabled);

    const status = !currentConfig.enabled ? 'bật' : 'tắt';
    this.messageService.add({
      severity: 'info',
      summary: 'Cài Đặt Âm Thanh',
      detail: `Đã ${status} âm thanh thông báo`,
      life: 2000,
    });
  }

  /**
   * Test âm thanh
   */
  async testNotificationSound(): Promise<void> {
    try {
      await this.notificationSoundService.testSound('newOrder');
      this.messageService.add({
        severity: 'info',
        summary: 'Test Âm Thanh',
        detail: 'Đã phát âm thanh test',
        life: 2000,
      });
    } catch (error) {
      this.messageService.add({
        severity: 'warn',
        summary: 'Lỗi Âm Thanh',
        detail: 'Không thể phát âm thanh',
        life: 3000,
      });
    }
  }

  /**
   * Kiểm tra trạng thái âm thanh
   */
  isSoundEnabled(): boolean {
    return this.notificationSoundService.getConfig().enabled;
  }

  /**
   * Bật/tắt text-to-speech
   */
  toggleSpeech(): void {
    const currentConfig = this.notificationSoundService.getConfig();
    this.notificationSoundService.setSpeechEnabled(!currentConfig.speechEnabled);

    const status = !currentConfig.speechEnabled ? 'bật' : 'tắt';
    this.messageService.add({
      severity: 'info',
      summary: 'Cài Đặt Giọng Đọc',
      detail: `Đã ${status} giọng đọc thông báo`,
      life: 2000,
    });
  }

  /**
   * Test giọng đọc
   */
  async testSpeech(): Promise<void> {
    try {
      await this.notificationSoundService.testSpeech();
      this.messageService.add({
        severity: 'info',
        summary: 'Test Giọng Đọc',
        detail: 'Đã test giọng đọc tiếng Việt',
        life: 2000,
      });
    } catch (error) {
      this.messageService.add({
        severity: 'warn',
        summary: 'Lỗi Giọng Đọc',
        detail: 'Không thể test giọng đọc',
        life: 3000,
      });
    }
  }

  /**
   * Kiểm tra trạng thái speech
   */
  isSpeechEnabled(): boolean {
    return this.notificationSoundService.getConfig().speechEnabled;
  }

  /**
   * Kiểm tra hỗ trợ speech
   */
  isSpeechSupported(): boolean {
    return this.notificationSoundService.isSpeechSupported();
  }

  /**
   * Dừng tất cả âm thanh và speech
   */
  stopAllSounds(): void {
    this.notificationSoundService.stopAll();
    this.messageService.add({
      severity: 'info',
      summary: 'Dừng Âm Thanh',
      detail: 'Đã dừng tất cả âm thanh và giọng đọc',
      life: 2000,
    });
  }
}
