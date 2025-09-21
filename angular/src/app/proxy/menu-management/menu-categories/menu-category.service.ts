import type { CreateUpdateMenuCategoryDto, MenuCategoryDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedAndSortedResultRequestDto, PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class MenuCategoryService {
  apiName = 'Default';

  create = (input: CreateUpdateMenuCategoryDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuCategoryDto>(
      {
        method: 'POST',
        url: '/api/app/menu-category',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: `/api/app/menu-category/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  deleteMany = (ids: string[], config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: '/api/app/menu-category/many',
        params: { ids },
      },
      { apiName: this.apiName, ...config },
    );

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuCategoryDto>(
      {
        method: 'GET',
        url: `/api/app/menu-category/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  getList = (input: PagedAndSortedResultRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<MenuCategoryDto>>(
      {
        method: 'GET',
        url: '/api/app/menu-category',
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
        url: '/api/app/menu-category/next-display-order',
      },
      { apiName: this.apiName, ...config },
    );

  update = (id: string, input: CreateUpdateMenuCategoryDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuCategoryDto>(
      {
        method: 'PUT',
        url: `/api/app/menu-category/${id}`,
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
