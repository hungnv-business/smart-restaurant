import { RestService, Rest } from '@abp/ng.core';
import type { ListResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';
import type { GuidLookupItemDto } from '../../common/dto/models';
import type {
  AddItemsToOrderDto,
  CreateOrderDto,
  DineInTableDto,
  GetDineInTablesDto,
  GetMenuItemsForOrderDto,
  GetTakeawayOrdersDto,
  IngredientAvailabilityResultDto,
  OrderDetailsDto,
  OrderForPaymentDto,
  PaymentRequestDto,
  TakeawayOrderDto,
  UpdateOrderItemQuantityDto,
  VerifyIngredientsRequestDto,
} from '../contracts/orders/dto/models';
import type { TakeawayStatus } from '../contracts/orders/dto/takeaway-status.enum';
import type { MenuItemDto } from '../../menu-management/menu-items/dto/models';

@Injectable({
  providedIn: 'root',
})
export class OrderService {
  apiName = 'Default';

  addItemsToOrder = (orderId: string, input: AddItemsToOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'POST',
        url: `/api/app/order/items-to-order/${orderId}`,
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  create = (input: CreateOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'POST',
        url: '/api/app/order',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  getActiveMenuCategories = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<GuidLookupItemDto>>(
      {
        method: 'GET',
        url: '/api/app/order/active-menu-categories',
      },
      { apiName: this.apiName, ...config },
    );

  getDineInTables = (input: GetDineInTablesDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<DineInTableDto>>(
      {
        method: 'GET',
        url: '/api/app/order/dine-in-tables',
        params: { tableNameFilter: input.tableNameFilter, statusFilter: input.statusFilter },
      },
      { apiName: this.apiName, ...config },
    );

  getMenuItemsForOrder = (input: GetMenuItemsForOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<MenuItemDto>>(
      {
        method: 'GET',
        url: '/api/app/order/menu-items-for-order',
        params: {
          nameFilter: input.nameFilter,
          categoryId: input.categoryId,
          onlyAvailable: input.onlyAvailable,
        },
      },
      { apiName: this.apiName, ...config },
    );

  getOrderDetails = (orderId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderDetailsDto>(
      {
        method: 'GET',
        url: `/api/app/order/order-details/${orderId}`,
      },
      { apiName: this.apiName, ...config },
    );

  getOrderForPayment = (orderId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderForPaymentDto>(
      {
        method: 'GET',
        url: `/api/app/order/order-for-payment/${orderId}`,
      },
      { apiName: this.apiName, ...config },
    );

  getTakeawayOrders = (input: GetTakeawayOrdersDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<TakeawayOrderDto>>(
      {
        method: 'GET',
        url: '/api/app/order/takeaway-orders',
        params: { statusFilter: input.statusFilter },
      },
      { apiName: this.apiName, ...config },
    );

  markOrderItemServed = (orderItemId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'POST',
        url: `/api/app/order/mark-order-item-served/${orderItemId}`,
      },
      { apiName: this.apiName, ...config },
    );

  processPayment = (input: PaymentRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'POST',
        url: '/api/app/order/process-payment',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  removeOrderItem = (orderId: string, orderItemId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: '/api/app/order/order-item',
        params: { orderId, orderItemId },
      },
      { apiName: this.apiName, ...config },
    );

  updateOrderItemQuantity = (
    orderId: string,
    orderItemId: string,
    input: UpdateOrderItemQuantityDto,
    config?: Partial<Rest.Config>,
  ) =>
    this.restService.request<any, void>(
      {
        method: 'PUT',
        url: '/api/app/order/order-item-quantity',
        params: { orderId, orderItemId },
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  updateTakeawayOrderStatus = (
    orderId: string,
    status: TakeawayStatus,
    config?: Partial<Rest.Config>,
  ) =>
    this.restService.request<any, void>(
      {
        method: 'PUT',
        url: `/api/app/order/takeaway-order-status/${orderId}`,
        params: { status },
      },
      { apiName: this.apiName, ...config },
    );

  verifyIngredientsAvailability = (
    input: VerifyIngredientsRequestDto,
    config?: Partial<Rest.Config>,
  ) =>
    this.restService.request<any, IngredientAvailabilityResultDto>(
      {
        method: 'POST',
        url: '/api/app/order/verify-ingredients-availability',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
