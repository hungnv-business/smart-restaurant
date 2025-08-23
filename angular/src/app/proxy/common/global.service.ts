import type { IntLookupItemDto } from './dto/models';
import { RestService, Rest } from '@abp/ng.core';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class GlobalService {
  apiName = 'Default';
  

  getTableStatuses = (config?: Partial<Rest.Config>) =>
    this.restService.request<any, IntLookupItemDto[]>({
      method: 'GET',
      url: '/api/app/global/table-statuses',
    },
    { apiName: this.apiName,...config });

  constructor(private restService: RestService) {}
}
