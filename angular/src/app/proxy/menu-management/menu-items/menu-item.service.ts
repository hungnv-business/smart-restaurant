import type { CreateUpdateMenuItemDto, MenuItemDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedAndSortedResultRequestDto, PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class MenuItemService {
  apiName = 'Default';
  

  create = (input: CreateUpdateMenuItemDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuItemDto>({
      method: 'POST',
      url: '/api/app/menu-item',
      body: input,
    },
    { apiName: this.apiName,...config });
  

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'DELETE',
      url: `/api/app/menu-item/${id}`,
    },
    { apiName: this.apiName,...config });
  

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuItemDto>({
      method: 'GET',
      url: `/api/app/menu-item/${id}`,
    },
    { apiName: this.apiName,...config });
  

  getList = (input: PagedAndSortedResultRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<MenuItemDto>>({
      method: 'GET',
      url: '/api/app/menu-item',
      params: { sorting: input.sorting, skipCount: input.skipCount, maxResultCount: input.maxResultCount },
    },
    { apiName: this.apiName,...config });
  

  update = (id: string, input: CreateUpdateMenuItemDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuItemDto>({
      method: 'PUT',
      url: `/api/app/menu-item/${id}`,
      body: input,
    },
    { apiName: this.apiName,...config });
  

  updateAvailability = (id: string, isAvailable: boolean, config?: Partial<Rest.Config>) =>
    this.restService.request<any, MenuItemDto>({
      method: 'PUT',
      url: `/api/app/menu-item/${id}/availability`,
      params: { isAvailable },
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
