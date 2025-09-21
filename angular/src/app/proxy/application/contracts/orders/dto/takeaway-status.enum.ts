import { mapEnumToOptions } from '@abp/ng.core';

export enum TakeawayStatus {
  Preparing = 0,
  Ready = 1,
  Delivered = 2,
}

export const takeawayStatusOptions = mapEnumToOptions(TakeawayStatus);
