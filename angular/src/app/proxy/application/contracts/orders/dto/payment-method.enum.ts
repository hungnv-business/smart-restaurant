import { mapEnumToOptions } from '@abp/ng.core';

export enum PaymentMethod {
  Cash = 0,
  BankTransfer = 1,
  Credit = 2,
}

export const paymentMethodOptions = mapEnumToOptions(PaymentMethod);
