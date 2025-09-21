import type { GuidLookupItemDto, IntLookupItemDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class GlobalService {
  apiName = 'Default';

  getIngredientCategoriesLookup = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>(
      {
        method: 'GET',
        url: '/api/app/global/ingredient-categories-lookup',
      },
      { apiName: this.apiName, ...config },
    );

  getIngredientsByCategoryLookup = (categoryId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>(
      {
        method: 'GET',
        url: `/api/app/global/ingredients-by-category-lookup/${categoryId}`,
      },
      { apiName: this.apiName, ...config },
    );

  getMenuCategoriesLookup = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>(
      {
        method: 'GET',
        url: '/api/app/global/menu-categories-lookup',
      },
      { apiName: this.apiName, ...config },
    );

  getTableStatusLookup = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IntLookupItemDto[]>(
      {
        method: 'GET',
        url: '/api/app/global/table-status-lookup',
      },
      { apiName: this.apiName, ...config },
    );

  getUnitsLookup = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, GuidLookupItemDto[]>(
      {
        method: 'GET',
        url: '/api/app/global/units-lookup',
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
