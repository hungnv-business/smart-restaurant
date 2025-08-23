import { mapEnumToOptions } from '@abp/ng.core';

export enum TableStatus {
  Available = 0,
  Occupied = 1,
  Reserved = 2,
  Cleaning = 3,
}

export const tableStatusOptions = mapEnumToOptions(TableStatus);
