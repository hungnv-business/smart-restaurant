import type { AssignTableToSectionDto, CreateTableDto, SectionWithTablesDto, TableDto, ToggleActiveStatusDto, UpdateTableDisplayOrderDto, UpdateTableDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import type { PagedAndSortedResultRequestDto, PagedResultDto } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class TableService {
  apiName = 'Default';
  

  assignToSection = (id: string, input: AssignTableToSectionDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'POST',
      url: `/api/app/table/${id}/assign-to-section`,
      body: input,
    },
    { apiName: this.apiName,...config });
  

  create = (input: CreateTableDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, TableDto>({
      method: 'POST',
      url: '/api/app/table',
      body: input,
    },
    { apiName: this.apiName,...config });
  

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'DELETE',
      url: `/api/app/table/${id}`,
    },
    { apiName: this.apiName,...config });
  

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, TableDto>({
      method: 'GET',
      url: `/api/app/table/${id}`,
    },
    { apiName: this.apiName,...config });
  

  getAllSectionsWithTables = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, SectionWithTablesDto[]>({
      method: 'GET',
      url: '/api/app/table/sections-with-tables',
    },
    { apiName: this.apiName,...config });
  

  getList = (input: PagedAndSortedResultRequestDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, PagedResultDto<TableDto>>({
      method: 'GET',
      url: '/api/app/table',
      params: { sorting: input.sorting, skipCount: input.skipCount, maxResultCount: input.maxResultCount },
    },
    { apiName: this.apiName,...config });
  

  getNextDisplayOrder = (layoutSectionId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, number>({
      method: 'GET',
      url: `/api/app/table/next-display-order/${layoutSectionId}`,
    },
    { apiName: this.apiName,...config });
  

  getTablesBySection = (layoutSectionId: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, TableDto[]>({
      method: 'GET',
      url: `/api/app/table/tables-by-section/${layoutSectionId}`,
    },
    { apiName: this.apiName,...config });
  

  toggleActiveStatus = (id: string, input: ToggleActiveStatusDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'POST',
      url: `/api/app/table/${id}/toggle-active-status`,
      body: input,
    },
    { apiName: this.apiName,...config });
  

  update = (id: string, input: UpdateTableDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, TableDto>({
      method: 'PUT',
      url: `/api/app/table/${id}`,
      body: input,
    },
    { apiName: this.apiName,...config });
  

  updateDisplayOrder = (input: UpdateTableDisplayOrderDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>({
      method: 'PUT',
      url: '/api/app/table/display-order',
      body: input,
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
