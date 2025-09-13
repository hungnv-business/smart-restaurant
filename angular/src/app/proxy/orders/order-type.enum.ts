import { mapEnumToOptions } from '@abp/ng.core';

export enum OrderType {
  DineIn = 0,
  Takeaway = 1,
  Delivery = 2,
}

export const orderTypeOptions = mapEnumToOptions(OrderType);
