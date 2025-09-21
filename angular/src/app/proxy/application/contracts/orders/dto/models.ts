import type { OrderType } from '../../../../orders/order-type.enum';
import type { EntityDto, FullAuditedEntityDto } from '@abp/ng.core';
import type { TableStatus } from '../../../../table-status.enum';
import type { TakeawayStatus } from './takeaway-status.enum';
import type { OrderStatus } from '../../../../orders/order-status.enum';
import type { OrderItemStatus } from '../../../../orders/order-item-status.enum';
import type { PaymentMethod } from './payment-method.enum';

export interface AddItemsToOrderDto {
  items: CreateOrderItemDto[];
  additionalNotes?: string;
}

export interface CreateOrderDto {
  tableId?: string;
  orderType: OrderType;
  notes?: string;
  customerName?: string;
  customerPhone?: string;
  orderItems: CreateOrderItemDto[];
}

export interface CreateOrderItemDto {
  menuItemId: string;
  menuItemName: string;
  quantity: number;
  unitPrice: number;
  notes?: string;
}

export interface DineInTableDto extends EntityDto<string> {
  tableNumber?: string;
  displayOrder: number;
  status: TableStatus;
  statusDisplay?: string;
  layoutSectionId?: string;
  layoutSectionName?: string;
  hasActiveOrders: boolean;
  currentOrderId?: string;
  pendingItemsDisplay?: string;
  readyItemsCountDisplay?: string;
  orderCreatedTime?: string;
}

export interface GetDineInTablesDto {
  tableNameFilter?: string;
  statusFilter?: TableStatus;
}

export interface GetMenuItemsForOrderDto {
  nameFilter?: string;
  categoryId?: string;
  onlyAvailable?: boolean;
}

export interface GetTakeawayOrdersDto {
  statusFilter?: TakeawayStatus;
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

export interface OrderDetailsDto extends EntityDto<string> {
  orderNumber?: string;
  orderType: OrderType;
  status: OrderStatus;
  statusDisplay?: string;
  totalAmount: number;
  notes?: string;
  createdTime?: string;
  customerName?: string;
  customerPhone?: string;
  paymentTime?: string;
  tableNumber?: string;
  layoutSectionName?: string;
  orderSummary: OrderSummaryDto;
  orderItems: OrderItemDetailDto[];
}

export interface OrderForPaymentDto {
  id?: string;
  orderNumber?: string;
  orderType: OrderType;
  status: OrderStatus;
  totalAmount: number;
  notes?: string;
  creationTime?: string;
  tableInfo?: string;
  orderItems: OrderItemDto[];
}

export interface OrderItemDetailDto extends EntityDto<string> {
  menuItemName?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  status: OrderItemStatus;
  specialRequest?: string;
  canEdit: boolean;
  canDelete: boolean;
  hasMissingIngredients: boolean;
  missingIngredients: MissingIngredientDto[];
  requiresCooking: boolean;
}

export interface OrderItemDto extends FullAuditedEntityDto<string> {
  orderId?: string;
  menuItemId?: string;
  menuItemName?: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  notes?: string;
  status: OrderItemStatus;
  statusDisplay?: string;
  preparationStartTime?: string;
  preparationCompleteTime?: string;
  preparationDurationMinutes?: number;
}

export interface OrderSummaryDto {
  totalItemsCount: number;
  pendingServeCount: number;
  totalAmount: number;
}

export interface PaymentRequestDto {
  orderId?: string;
  paymentMethod: PaymentMethod;
  customerMoney?: number;
  notes?: string;
}

export interface TakeawayOrderDto extends EntityDto<string> {
  orderNumber?: string;
  customerName?: string;
  customerPhone?: string;
  status: TakeawayStatus;
  statusDisplay?: string;
  totalAmount: number;
  notes?: string;
  createdTime?: string;
  paymentTime?: string;
  itemNames: string[];
  itemCount: number;
  formattedTotal?: string;
  formattedOrderTime?: string;
  formattedPaymentTime?: string;
}

export interface UpdateOrderItemQuantityDto {
  newQuantity: number;
  notes?: string;
}

export interface VerifyIngredientsRequestDto {
  items: CreateOrderItemDto[];
}
