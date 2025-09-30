import { Component, Input, Output, EventEmitter, OnInit, OnDestroy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { interval, Subject, takeUntil } from 'rxjs';

// PrimeNG Components
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { BadgeModule } from 'primeng/badge';
import { TooltipModule } from 'primeng/tooltip';

// ABP Proxy Types
import { KitchenOrderItemDto } from '../../../../../../proxy/kitchen/dtos/models';
import { OrderItemStatus } from '../../../../../../proxy/orders/order-item-status.enum';

export interface StatusUpdateEvent {
  orderItemId: string;
  status: OrderItemStatus;
}

@Component({
  selector: 'app-order-item-card',
  standalone: true,
  imports: [
    CommonModule,
    CardModule,
    ButtonModule,
    TagModule,
    BadgeModule,
    TooltipModule,
  ],
  templateUrl: './order-item-card.component.html',
  styleUrl: './order-item-card.component.scss',
})
export class OrderItemCardComponent implements OnInit, OnDestroy {
  @Input({ required: true }) orderItem!: KitchenOrderItemDto;
  @Output() statusUpdate = new EventEmitter<StatusUpdateEvent>();

  // Enum reference for template
  OrderItemStatus = OrderItemStatus;

  // Real-time waiting time
  private destroy$ = new Subject<void>();
  currentWaitingTime = signal<string>('0:00');

  constructor() {}

  ngOnInit(): void {
    this.updateWaitingTime();
    this.startWaitingTimeTimer();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private startWaitingTimeTimer(): void {
    interval(1000) // Cập nhật mỗi giây
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => {
        this.updateWaitingTime();
      });
  }

  private updateWaitingTime(): void {
    if (!this.orderItem.orderTime) {
      this.currentWaitingTime.set('0:00');
      return;
    }

    const orderTime = new Date(this.orderItem.orderTime);
    const now = new Date();
    const diffMs = now.getTime() - orderTime.getTime();

    if (diffMs <= 0) {
      this.currentWaitingTime.set('0:00');
      return;
    }

    const totalSeconds = Math.floor(diffMs / 1000);
    const totalMinutes = Math.floor(totalSeconds / 60);

    // Luôn hiển thị mm:ss format
    const minutes = totalMinutes;
    const seconds = totalSeconds % 60;
    const timeStr = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

    this.currentWaitingTime.set(timeStr);
  }

  /**
   * Bắt đầu nấu món (Pending → Preparing)
   */
  startPreparation(): void {
    if (this.canTransitionTo(OrderItemStatus.Preparing)) {
      this.updateStatus(OrderItemStatus.Preparing);
    }
  }

  /**
   * Hoàn thành món (Preparing → Ready)
   */
  markAsReady(): void {
    if (this.canTransitionTo(OrderItemStatus.Ready)) {
      this.updateStatus(OrderItemStatus.Ready);
    }
  }

  /**
   * Lùi về trạng thái Đơn Mới (Preparing → Pending)
   */
  revertToPending(): void {
    if (this.canRevertTo(OrderItemStatus.Pending)) {
      this.updateStatus(OrderItemStatus.Pending);
    }
  }

  /**
   * Lùi về trạng thái Đang Làm (Ready → Preparing)
   */
  revertToPreparing(): void {
    if (this.canRevertTo(OrderItemStatus.Preparing)) {
      this.updateStatus(OrderItemStatus.Preparing);
    }
  }

  /**
   * Cập nhật trạng thái
   */
  private updateStatus(newStatus: OrderItemStatus): void {
    this.statusUpdate.emit({
      orderItemId: this.orderItem.id!,
      status: newStatus,
    });
  }

  /**
   * Kiểm tra có thể chuyển đổi trạng thái không
   */
  canTransitionTo(newStatus: OrderItemStatus): boolean {
    const currentStatus = this.orderItem.status || OrderItemStatus.Pending;
    switch (currentStatus) {
      case OrderItemStatus.Pending:
        return newStatus === OrderItemStatus.Preparing;
      case OrderItemStatus.Preparing:
        return newStatus === OrderItemStatus.Ready;
      case OrderItemStatus.Ready:
        // Kitchen không thể chuyển sang Served - chỉ waitstaff mới được
        return false;
      case OrderItemStatus.Served:
      case OrderItemStatus.Canceled:
        return false;
      default:
        return false;
    }
  }

  /**
   * Kiểm tra có thể lùi về trạng thái trước không
   */
  canRevertTo(revertStatus: OrderItemStatus): boolean {
    const currentStatus = this.orderItem.status || OrderItemStatus.Pending;
    switch (currentStatus) {
      case OrderItemStatus.Preparing:
        return revertStatus === OrderItemStatus.Pending;
      case OrderItemStatus.Ready:
        return revertStatus === OrderItemStatus.Preparing;
      case OrderItemStatus.Pending:
      case OrderItemStatus.Served:
      case OrderItemStatus.Canceled:
        return false;
      default:
        return false;
    }
  }

  /**
   * Lấy severity cho status tag
   */
  getStatusSeverity(
    status: OrderItemStatus,
  ): 'secondary' | 'info' | 'success' | 'warn' | 'danger' {
    switch (status) {
      case OrderItemStatus.Pending:
        return 'info'; // Xanh dương cho Đơn Mới
      case OrderItemStatus.Preparing:
        return 'warn'; // Cam cho Đang Làm
      case OrderItemStatus.Ready:
        return 'success'; // Xanh lá cho Sẵn Sàng
      case OrderItemStatus.Served:
        return 'success';
      case OrderItemStatus.Canceled:
        return 'danger';
      default:
        return 'secondary';
    }
  }

  /**
   * Lấy icon cho trạng thái
   */
  getStatusIcon(status: OrderItemStatus): string {
    switch (status) {
      case OrderItemStatus.Pending:
        return 'pi pi-clock';
      case OrderItemStatus.Preparing:
        return 'pi pi-cog';
      case OrderItemStatus.Ready:
        return 'pi pi-check-circle';
      case OrderItemStatus.Served:
        return 'pi pi-verified';
      case OrderItemStatus.Canceled:
        return 'pi pi-times-circle';
      default:
        return 'pi pi-question';
    }
  }

  /**
   * Lấy CSS class cho priority
   */
  getPriorityClass(): string {
    const score = this.orderItem.priorityScore;
    if (score >= 150) return 'priority-critical';
    if (score >= 100) return 'priority-high';
    if (score >= 50) return 'priority-medium';
    return 'priority-normal';
  }

  /**
   * Format thời gian chờ
   */
  getFormattedWaitingTime(): string {
    const minutes = this.getCurrentWaitingMinutes();
    if (minutes < 60) {
      return `${minutes} phút`;
    } else {
      const hours = Math.floor(minutes / 60);
      const remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}p` : `${hours}h`;
    }
  }

  /**
   * Lấy severity cho waiting time badge
   */
  getWaitingTimeSeverity(): 'secondary' | 'info' | 'success' | 'warning' | 'danger' {
    const minutes = this.getCurrentWaitingMinutes();
    if (minutes >= 45) return 'danger';
    if (minutes >= 30) return 'warning';
    if (minutes >= 15) return 'info';
    return 'secondary';
  }

  /**
   * Lấy CSS class cho hiển thị thời gian (màu đỏ nếu quá lâu)
   */
  getTimeDisplayClass(): string {
    const waitingMinutes = this.getCurrentWaitingMinutes();
    if (waitingMinutes >= 30) {
      return 'text-red-600 font-bold';
    } else if (waitingMinutes >= 20) {
      return 'text-orange-600 font-medium';
    }
    return 'text-600';
  }

  /**
   * Tính thời gian chờ hiện tại (real-time)
   */
  getCurrentWaitingMinutes(): number {
    if (!this.orderItem.orderTime) return 0;
    const orderTime = new Date(this.orderItem.orderTime);
    const now = new Date();
    return Math.floor((now.getTime() - orderTime.getTime()) / (1000 * 60));
  }
}
