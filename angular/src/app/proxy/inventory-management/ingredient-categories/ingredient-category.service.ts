import type { CreateUpdateIngredientCategoryDto, IngredientCategoryDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedAndSortedResultRequestDto, PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class IngredientCategoryService {
  apiName = 'Default';

  create = (input: CreateUpdateIngredientCategoryDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientCategoryDto>(
      {
        method: 'POST',
        url: '/api/app/ingredient-category',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: `/api/app/ingredient-category/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  deleteMany = (ids: string[], config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: '/api/app/ingredient-category/many',
        params: { ids },
      },
      { apiName: this.apiName, ...config },
    );

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientCategoryDto>(
      {
        method: 'GET',
        url: `/api/app/ingredient-category/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  getList = (input: PagedAndSortedResultRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<IngredientCategoryDto>>(
      {
        method: 'GET',
        url: '/api/app/ingredient-category',
        params: {
          sorting: input.sorting,
          skipCount: input.skipCount,
          maxResultCount: input.maxResultCount,
        },
      },
      { apiName: this.apiName, ...config },
    );

  getNextDisplayOrder = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, number>(
      {
        method: 'GET',
        url: '/api/app/ingredient-category/next-display-order',
      },
      { apiName: this.apiName, ...config },
    );

  update = (id: string, input: CreateUpdateIngredientCategoryDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientCategoryDto>(
      {
        method: 'PUT',
        url: `/api/app/ingredient-category/${id}`,
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
