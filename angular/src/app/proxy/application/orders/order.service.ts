import { RestService, Rest } from '@abp/ng.core';
import type { ListResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';
import type { GuidLookupItemDto } from '../../common/dto/models';
import type { ActiveTableDto, AddItemsToOrderDto, CreateOrderDto, GetMenuItemsForOrderDto, OrderDto, TableDetailDto, UpdateOrderItemQuantityDto } from '../contracts/orders/dto/models';
import type { MenuItemDto } from '../../menu-management/menu-items/dto/models';
import type { TableStatus } from '../../table-status.enum';

@Injectable({
  providedIn: 'root',
})
export class OrderService {
  apiName = 'Default';
  

  addItemsToOrder = (orderId: string, input: AddItemsToOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderDto>({
      method: 'POST',
      url: `/api/app/order/items-to-order/${orderId}`,
      body: input,
    },
    { apiName: this.apiName,...config });
  

  create = (input: CreateOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderDto>({
      method: 'POST',
      url: '/api/app/order',
      body: input,
    },
    { apiName: this.apiName,...config });
  

  getActiveMenuCategories = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<GuidLookupItemDto>>({
      method: 'GET',
      url: '/api/app/order/active-menu-categories',
    },
    { apiName: this.apiName,...config });
  

  getActiveTables = (tableNameFilter?: string, statusFilter?: enum, config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<ActiveTableDto>>({
      method: 'GET',
      url: '/api/app/order/active-tables',
      params: { tableNameFilter, statusFilter },
    },
    { apiName: this.apiName,...config });
  

  getMenuItemsForOrder = (input: GetMenuItemsForOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, ListResultDto<MenuItemDto>>({
      method: 'GET',
      url: '/api/app/order/menu-items-for-order',
      params: { nameFilter: input.nameFilter, categoryId: input.categoryId, onlyAvailable: input.onlyAvailable },
    },
    { apiName: this.apiName,...config });
  

  getTableDetails = (tableId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, TableDetailDto>({
      method: 'GET',
      url: `/api/app/order/table-details/${tableId}`,
    },
    { apiName: this.apiName,...config });
  

  removeOrderItem = (orderId: string, orderItemId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderDto>({
      method: 'DELETE',
      url: '/api/app/order/order-item',
      params: { orderId, orderItemId },
    },
    { apiName: this.apiName,...config });
  

  updateOrderItemQuantity = (orderId: string, orderItemId: string, input: UpdateOrderItemQuantityDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, OrderDto>({
      method: 'PUT',
      url: '/api/app/order/order-item-quantity',
      params: { orderId, orderItemId },
      body: input,
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
