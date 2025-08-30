import type { FullAuditedEntityDto, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface CreateUpdatePurchaseInvoiceDto {
  invoiceNumber: string;
  invoiceDateId: number;
  notes?: string;
  items: CreateUpdatePurchaseInvoiceItemDto[];
}

export interface CreateUpdatePurchaseInvoiceItemDto {
  ingredientId: string;
  quantity: number;
  unitId?: string;
  unitName: string;
  unitPrice?: number;
  totalPrice?: number;
  supplierInfo?: string;
  notes?: string;
}

export interface GetPurchaseInvoiceListDto extends PagedAndSortedResultRequestDto {
  filter?: string;
  fromDateId?: number;
  toDateId?: number;
}

export interface IngredientLookupDto {
  id?: string;
  name?: string;
  unitId?: string;
  unitName?: string;
  costPerUnit: number;
  supplierInfo?: string;
}

export interface PurchaseInvoiceDto extends FullAuditedEntityDto<string> {
  invoiceNumber?: string;
  invoiceDate?: string;
  invoiceDateId: number;
  totalAmount: number;
  notes?: string;
  canDelete: boolean;
  canEdit: boolean;
  items: PurchaseInvoiceItemDto[];
}

export interface PurchaseInvoiceItemDto extends FullAuditedEntityDto<string> {
  purchaseInvoiceId?: string;
  ingredientId?: string;
  quantity: number;
  unitId?: string;
  unitName?: string;
  unitPrice?: number;
  totalPrice: number;
  supplierInfo?: string;
  notes?: string;
  categoryId?: string;
}
