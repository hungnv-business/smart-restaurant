import type {
  CookingStatsDto,
  KitchenTableGroupDto,
  UpdateOrderItemStatusInput,
} from './dtos/models';
import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class KitchenDashboardService {
  apiName = 'Default';

  getCookingOrdersGrouped = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, KitchenTableGroupDto[]>(
      {
        method: 'GET',
        url: '/api/app/kitchen-dashboard/cooking-orders-grouped',
      },
      { apiName: this.apiName, ...config },
    );

  getCookingStats = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, CookingStatsDto>(
      {
        method: 'GET',
        url: '/api/app/kitchen-dashboard/cooking-stats',
      },
      { apiName: this.apiName, ...config },
    );

  updateOrderItemStatus = (input: UpdateOrderItemStatusInput, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'PUT',
        url: '/api/app/kitchen-dashboard/order-item-status',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
