import { mapEnumToOptions } from '@abp/ng.core';

export enum OrderStatus {
  Serving = 0,
  Paid = 1,
}

export const orderStatusOptions = mapEnumToOptions(OrderStatus);
