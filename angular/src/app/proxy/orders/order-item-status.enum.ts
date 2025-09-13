import { mapEnumToOptions } from '@abp/ng.core';

export enum OrderItemStatus {
  Pending = 0,
  Preparing = 1,
  Ready = 2,
  Served = 3,
  Canceled = 4,
}

export const orderItemStatusOptions = mapEnumToOptions(OrderItemStatus);
