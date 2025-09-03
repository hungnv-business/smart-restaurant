import type { CreateUpdateIngredientDto, GetIngredientListRequestDto, IngredientDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class IngredientService {
  apiName = 'Default';
  

  create = (input: CreateUpdateIngredientDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientDto>({
      method: 'POST',
      url: '/api/app/ingredient',
      body: input,
    },
    { apiName: this.apiName,...config });
  

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'DELETE',
      url: `/api/app/ingredient/${id}`,
    },
    { apiName: this.apiName,...config });
  

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientDto>({
      method: 'GET',
      url: `/api/app/ingredient/${id}`,
    },
    { apiName: this.apiName,...config });
  

  getList = (input: GetIngredientListRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<IngredientDto>>({
      method: 'GET',
      url: '/api/app/ingredient',
      params: { filter: input.filter, categoryId: input.categoryId, includeInactive: input.includeInactive, sorting: input.sorting, skipCount: input.skipCount, maxResultCount: input.maxResultCount },
    },
    { apiName: this.apiName,...config });
  

  update = (id: string, input: CreateUpdateIngredientDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, IngredientDto>({
      method: 'PUT',
      url: `/api/app/ingredient/${id}`,
      body: input,
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
