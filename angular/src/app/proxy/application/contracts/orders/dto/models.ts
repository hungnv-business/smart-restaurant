import type { EntityDto, FullAuditedEntityDto } from '@abp/ng.core';
import type { TableStatus } from '../../../../table-status.enum';
import type { OrderType } from '../../../../orders/order-type.enum';
import type { OrderStatus } from '../../../../orders/order-status.enum';
import type { OrderItemStatus } from '../../../../orders/order-item-status.enum';
import type { PaymentMethod } from './payment-method.enum';

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

export interface IngredientAvailabilityResultDto {
  isAvailable: boolean;
  missingIngredients: MissingIngredientDto[];
  totalItemsCount: number;
  unavailableItemsCount: number;
  summaryMessage?: string;
  unavailableMenuItems: string[];
}

export interface MissingIngredientDto {
  menuItemId?: string;
  menuItemName?: string;
  ingredientId?: string;
  ingredientName?: string;
  requiredQuantity: number;
  currentStock: number;
  unit?: string;
  shortageAmount: number;
  displayMessage?: string;
}

export interface OrderForPaymentDto {
  id?: string;
  orderNumber?: string;
  orderType?: OrderType;
  status?: OrderStatus;
  totalAmount: number;
  notes?: string;
  creationTime?: string;
  tableInfo?: string;
  orderItems: OrderItemDto[];
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

export interface PaymentRequestDto {
  orderId?: string;
  paymentMethod?: PaymentMethod;
  customerMoney?: number;
  notes?: string;
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
  hasMissingIngredients: boolean;
  missingIngredients: MissingIngredientDto[];
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

export interface VerifyIngredientsRequestDto {
  items: CreateOrderItemDto[];
}
