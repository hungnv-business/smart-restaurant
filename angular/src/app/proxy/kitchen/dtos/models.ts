import type { EntityDto } from '@abp/ng.core';
import type { OrderItemStatus } from '../../orders/order-item-status.enum';
import type { OrderType } from '../../orders/order-type.enum';

export interface CookingStatsDto {
  quickCookItemsCount: number;
  emptyTablesCount: number;
  totalCookingItems: number;
  averageWaitingTime: number;
  highPriorityItemsCount: number;
  criticalItemsCount: number;
  highestPriorityScore: number;
  longestWaitingTable?: string;
}

export interface KitchenOrderItemDto extends EntityDto<string> {
  orderId?: string;
  tableNumber?: string;
  menuItemName?: string;
  quantity: number;
  orderTime?: string;
  isQuickCook: boolean;
  requiresCooking: boolean;
  isEmptyTablePriority: boolean;
  servedDishesCount: number;
  priorityScore: number;
  status: OrderItemStatus;
  orderType: OrderType;
}

export interface KitchenTableGroupDto {
  tableNumber?: string;
  isTakeaway: boolean;
  orderType: OrderType;
  totalItems: number;
  highestPriority: number;
  orderItems: KitchenOrderItemDto[];
}

export interface UpdateOrderItemStatusInput {
  orderItemId: string;
  status: OrderItemStatus;
  notes?: string;
}
