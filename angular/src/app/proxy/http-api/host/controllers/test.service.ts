import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';
import type { IActionResult } from '../../../microsoft/asp-net-core/mvc/models';

@Injectable({
  providedIn: 'root',
})
export class TestService {
  apiName = 'Default';

  sendTestAddItems = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IActionResult>(
      {
        method: 'POST',
        url: '/api/Test/send-test-add-items',
      },
      { apiName: this.apiName, ...config },
    );

  sendTestOrder = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IActionResult>(
      {
        method: 'POST',
        url: '/api/Test/send-test-order',
      },
      { apiName: this.apiName, ...config },
    );

  sendTestQuantityUpdate = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IActionResult>(
      {
        method: 'POST',
        url: '/api/Test/send-test-quantity-update',
      },
      { apiName: this.apiName, ...config },
    );

  sendTestRemoveItem = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IActionResult>(
      {
        method: 'POST',
        url: '/api/Test/send-test-remove-item',
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
