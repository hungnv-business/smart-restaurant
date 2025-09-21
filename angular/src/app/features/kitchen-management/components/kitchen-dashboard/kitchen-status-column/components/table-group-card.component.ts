import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

// ABP Proxy Types
import {
  KitchenTableGroupDto,
  KitchenOrderItemDto,
} from '../../../../../../proxy/kitchen/dtos/models';
import { OrderItemStatus } from '../../../../../../proxy/orders/order-item-status.enum';
import { OrderType } from '../../../../../../proxy/orders/order-type.enum';

// Local components
import {
  OrderItemCardComponent,
  StatusUpdateEvent,
} from '../../shared/order-item-card/order-item-card.component';

@Component({
  selector: 'app-table-group-card',
  standalone: true,
  imports: [CommonModule, OrderItemCardComponent],
  template: `
    <div class="card mb-2 p-4">
      <!-- Table Header -->
      <div class="flex justify-content-between align-items-center pb-3 border-bottom-1 border-200">
        <div class="flex align-items-center gap-3">
          <div
            class="min-w-[70px] text-center text-white px-4 py-2 border-round font-bold text-base"
            [ngClass]="getOrderTypeColorClass()"
          >
            {{ tableGroup.tableNumber }}
          </div>
        </div>
      </div>

      <!-- Order Items List -->
      <div [ngClass]="status === 0 ? 'order-items-grid' : 'order-items-list'">
        @for (item of getFilteredItems(); track item.id) {
          <app-order-item-card [orderItem]="item" (statusUpdate)="statusUpdate.emit($event)">
          </app-order-item-card>
        }
      </div>
    </div>
  `,
  styles: [
    `
      .order-items-grid {
        display: grid;
        gap: 0.75rem;
        grid-template-columns: 1fr;
      }

      @media (min-width: 768px) {
        .order-items-grid {
          grid-template-columns: 1fr 1fr;
        }
      }

      .order-items-list {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
    `,
  ],
})
export class TableGroupCardComponent {
  @Input({ required: true }) tableGroup!: KitchenTableGroupDto;
  @Input({ required: true }) status!: OrderItemStatus;
  @Output() statusUpdate = new EventEmitter<StatusUpdateEvent>();

  /**
   * Lấy số lượng món theo status
   */
  getItemCount(): number {
    return this.getFilteredItems().length;
  }

  /**
   * Lấy danh sách món đã filter theo status
   */
  getFilteredItems(): KitchenOrderItemDto[] {
    return this.tableGroup.orderItems.filter(item => item.status === this.status);
  }

  /**
   * Lấy CSS class cho màu sắc theo orderType
   * OrderType.DineIn (0) = màu xanh dương (ăn tại quán)
   * OrderType.Takeaway (1) = màu cam (mang về)
   * OrderType.Delivery (2) = màu đỏ (giao hàng)
   */
  getOrderTypeColorClass(): string {
    switch (this.tableGroup.orderType) {
      case OrderType.DineIn:
        return 'bg-blue-500'; // Xanh dương - ăn tại quán
      case OrderType.Takeaway:
        return 'bg-purple-500'; // Tím - mang về
      case OrderType.Delivery:
        return 'bg-red-500'; // Đỏ - giao hàng
      default:
        return 'bg-gray-500'; // Xám - không xác định
    }
  }
}
