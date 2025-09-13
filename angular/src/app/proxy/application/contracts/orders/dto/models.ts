import type { EntityDto, FullAuditedEntityDto } from '@abp/ng.core';
import type { TableStatus } from '../../../../table-status.enum';
import type { OrderType } from '../../../../orders/order-type.enum';
import type { OrderStatus } from '../../../../orders/order-status.enum';
import type { OrderItemStatus } from '../../../../orders/order-item-status.enum';

export interface ActiveTableDto extends EntityDto<string> {
  tableNumber?: string;
  displayOrder: number;
  status?: TableStatus;
  statusDisplay?: string;
  layoutSectionId?: string;
  layoutSectionName?: string;
  hasActiveOrders: boolean;
  orderStatusDisplay?: string;
  pendingItemsCount: number;
}

export interface AddItemsToOrderDto {
  items: CreateOrderItemDto[];
  additionalNotes?: string;
}

export interface CreateOrderDto {
  tableId?: string;
  orderType: OrderType;
  notes?: string;
  orderItems: CreateOrderItemDto[];
}

export interface CreateOrderItemDto {
  menuItemId: string;
  menuItemName: string;
  quantity: number;
  unitPrice: number;
  notes?: string;
}

export interface GetMenuItemsForOrderDto {
  nameFilter?: string;
  categoryId?: string;
  onlyAvailable?: boolean;
}

export interface OrderDto extends FullAuditedEntityDto<string> {
  orderNumber?: string;
  tableId?: string;
  tableName?: string;
  orderType?: OrderType;
  status?: OrderStatus;
  statusDisplay?: string;
  totalAmount: number;
  notes?: string;
  confirmedTime?: string;
  preparingTime?: string;
  readyTime?: string;
  servedTime?: string;
  paidTime?: string;
  orderItems: OrderItemDto[];
  itemCount: number;
  elapsedMinutes: number;
}

export interface OrderItemDto extends FullAuditedEntityDto<string> {
  orderId?: string;
  menuItemId?: string;
  menuItemName?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  notes?: string;
  status?: OrderItemStatus;
  statusDisplay?: string;
  preparationStartTime?: string;
  preparationCompleteTime?: string;
  preparationDurationMinutes?: number;
}

export interface TableDetailDto extends EntityDto<string> {
  tableNumber?: string;
  layoutSectionName?: string;
  status?: TableStatus;
  statusDisplay?: string;
  orderId?: string;
  orderSummary: TableOrderSummaryDto;
  orderItems: TableOrderItemDto[];
}

export interface TableOrderItemDto {
  id?: string;
  menuItemName?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  status?: OrderItemStatus;
  canEdit: boolean;
  canDelete: boolean;
  specialRequest?: string;
}

export interface TableOrderSummaryDto {
  totalItemsCount: number;
  pendingServeCount: number;
  totalAmount: number;
}

export interface UpdateOrderItemQuantityDto {
  newQuantity: number;
  notes?: string;
}
