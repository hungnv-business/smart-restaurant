import type { CreateUpdatePurchaseInvoiceDto, GetPurchaseInvoiceListDto, IngredientForPurchaseDto, PurchaseInvoiceDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class PurchaseInvoiceService {
  apiName = 'Default';
  

  create = (input: CreateUpdatePurchaseInvoiceDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PurchaseInvoiceDto>({
      method: 'POST',
      url: '/api/app/purchase-invoice',
      body: input,
    },
    { apiName: this.apiName,...config });
  

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'DELETE',
      url: `/api/app/purchase-invoice/${id}`,
    },
    { apiName: this.apiName,...config });
  

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PurchaseInvoiceDto>({
      method: 'GET',
      url: `/api/app/purchase-invoice/${id}`,
    },
    { apiName: this.apiName,...config });
  

  getIngredientForPurchase = (ingredientId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientForPurchaseDto>({
      method: 'GET',
      url: `/api/app/purchase-invoice/ingredient-for-purchase/${ingredientId}`,
    },
    { apiName: this.apiName,...config });
  

  getList = (input: GetPurchaseInvoiceListDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<PurchaseInvoiceDto>>({
      method: 'GET',
      url: '/api/app/purchase-invoice',
      params: { filter: input.filter, fromDateId: input.fromDateId, toDateId: input.toDateId, sorting: input.sorting, skipCount: input.skipCount, maxResultCount: input.maxResultCount },
    },
    { apiName: this.apiName,...config });
  

  update = (id: string, input: CreateUpdatePurchaseInvoiceDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PurchaseInvoiceDto>({
      method: 'PUT',
      url: `/api/app/purchase-invoice/${id}`,
      body: input,
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
