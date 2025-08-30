import type { GuidLookupItemDto, IntLookupItemDto } from './dto/models';
import type { UnitDto } from './units/dto/models';
import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class GlobalService {
  apiName = 'Default';
  

  getCategories = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>({
      method: 'GET',
      url: '/api/app/global/categories',
    },
    { apiName: this.apiName,...config });
  

  getIngredientsByCategory = (categoryId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>({
      method: 'GET',
      url: `/api/app/global/ingredients-by-category/${categoryId}`,
    },
    { apiName: this.apiName,...config });
  

  getTableStatuses = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IntLookupItemDto[]>({
      method: 'GET',
      url: '/api/app/global/table-statuses',
    },
    { apiName: this.apiName,...config });
  

  getUnits = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, UnitDto[]>({
      method: 'GET',
      url: '/api/app/global/units',
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
