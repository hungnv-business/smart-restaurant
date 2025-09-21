import type {
  CreateLayoutSectionDto,
  LayoutSectionDto,
  UpdateLayoutSectionDto,
} from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class LayoutSectionService {
  apiName = 'Default';

  create = (input: CreateLayoutSectionDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, LayoutSectionDto>(
      {
        method: 'POST',
        url: '/api/app/layout-section',
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  delete = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, void>(
      {
        method: 'DELETE',
        url: `/api/app/layout-section/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  get = (id: string, config?: Partial<Rest.Config>) =>
    this.restService.request<any, LayoutSectionDto>(
      {
        method: 'GET',
        url: `/api/app/layout-section/${id}`,
      },
      { apiName: this.apiName, ...config },
    );

  getList = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, LayoutSectionDto[]>(
      {
        method: 'GET',
        url: '/api/app/layout-section',
      },
      { apiName: this.apiName, ...config },
    );

  getNextDisplayOrder = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, number>(
      {
        method: 'GET',
        url: '/api/app/layout-section/next-display-order',
      },
      { apiName: this.apiName, ...config },
    );

  update = (id: string, input: UpdateLayoutSectionDto, config?: Partial<Rest.Config>) =>
    this.restService.request<any, LayoutSectionDto>(
      {
        method: 'PUT',
        url: `/api/app/layout-section/${id}`,
        body: input,
      },
      { apiName: this.apiName, ...config },
    );

  updateStatus = (id: string, isActive: boolean, config?: Partial<Rest.Config>) =>
    this.restService.request<any, LayoutSectionDto>(
      {
        method: 'PUT',
        url: `/api/app/layout-section/${id}/status`,
        params: { isActive },
      },
      { apiName: this.apiName, ...config },
    );

  constructor(private restService: RestService) {}
}
