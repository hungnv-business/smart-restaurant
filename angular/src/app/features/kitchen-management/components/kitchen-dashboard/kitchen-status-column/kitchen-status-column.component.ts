import { Component, Input, Output, EventEmitter, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BadgeModule } from 'primeng/badge';

// ABP Proxy Types
import { KitchenTableGroupDto } from '../../../../../proxy/kitchen/dtos/models';
import { OrderItemStatus } from '../../../../../proxy/orders/order-item-status.enum';

// Child components
import { ColumnHeaderComponent } from './components/column-header.component';
import { TableGroupCardComponent } from './components/table-group-card.component';
import { EmptyStateComponent } from './components/empty-state.component';

// Types
import { StatusUpdateEvent } from '../shared/order-item-card/order-item-card.component';

@Component({
  selector: 'app-kitchen-status-column',
  standalone: true,
  imports: [
    CommonModule,
    BadgeModule,
    ColumnHeaderComponent,
    TableGroupCardComponent,
    EmptyStateComponent,
  ],
  template: `
    <div class="flex flex-col h-full md:h-full min-h-[400px]">
      <app-column-header
        [title]="title"
        [icon]="icon"
        [count]="getCount()"
        [theme]="theme"
        [badgeSeverity]="badgeSeverity"
      />

      <div class="flex-1 overflow-y-auto order-items-column max-h-[500px] md:max-h-full">
        @for (tableGroup of filteredTableGroups(); track tableGroup.tableNumber) {
          <app-table-group-card
            [tableGroup]="tableGroup"
            [status]="status"
            (statusUpdate)="statusUpdate.emit($event)"
          />
        }

        @if (filteredTableGroups().length === 0) {
          <app-empty-state [message]="getEmptyMessage()" [icon]="getEmptyIcon()" />
        }
      </div>
    </div>
  `,
  host: {
    class: 'flex-1 block',
  },
  styles: [],
})
export class KitchenStatusColumnComponent {
  @Input({ required: true }) title!: string;
  @Input({ required: true }) icon!: string;
  @Input({ required: true }) status!: OrderItemStatus;
  @Input({ required: true }) tableGroups!: KitchenTableGroupDto[];
  @Input({ required: true }) theme!: 'blue' | 'orange' | 'green';
  @Input({ required: true }) badgeSeverity!: 'info' | 'warning' | 'success';
  @Output() statusUpdate = new EventEmitter<StatusUpdateEvent>();

  /**
   * Computed: Lọc table groups có chứa items với status hiện tại
   */
  filteredTableGroups = computed(() => {
    return this.tableGroups.filter(group =>
      group.orderItems.some(item => item.status === this.status),
    );
  });

  /**
   * Đếm tổng quantity theo status
   */
  getCount(): number {
    return this.tableGroups.reduce((total, group) => {
      return (
        total +
        group.orderItems
          .filter(item => item.status === this.status)
          .reduce((sum, item) => sum + item.quantity, 0)
      );
    }, 0);
  }

  /**
   * Message khi không có data
   */
  getEmptyMessage(): string {
    switch (this.status) {
      case OrderItemStatus.Pending:
        return 'Không có món mới';
      case OrderItemStatus.Preparing:
        return 'Không có món đang làm';
      case OrderItemStatus.Ready:
        return 'Không có món sẵn sàng';
      default:
        return 'Không có dữ liệu';
    }
  }

  /**
   * Icon cho empty state
   */
  getEmptyIcon(): string {
    return 'pi-check';
  }
}
