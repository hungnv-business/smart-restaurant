import type { EntityDto, FullAuditedEntityDto, PagedAndSortedResultRequestDto } from '@abp/ng.core';
import type { IngredientPurchaseUnitDto } from '../../ingredients/dto/models';

export interface CreateUpdatePurchaseInvoiceDto {
  invoiceNumber: string;
  invoiceDateId: number;
  notes?: string;
  items: CreateUpdatePurchaseInvoiceItemDto[];
}

export interface CreateUpdatePurchaseInvoiceItemDto extends EntityDto<string> {
  ingredientId: string;
  quantity: number;
  purchaseUnitId: string;
  unitPrice?: number;
  totalPrice?: number;
  supplierInfo?: string;
  notes?: string;
  displayOrder: number;
}

export interface GetPurchaseInvoiceListDto extends PagedAndSortedResultRequestDto {
  filter?: string;
  fromDateId?: number;
  toDateId?: number;
}

export interface IngredientForPurchaseDto {
  id?: string;
  name?: string;
  costPerUnit?: number;
  supplierInfo?: string;
  purchaseUnits: IngredientPurchaseUnitDto[];
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
  purchaseUnitId?: string;
  unitPrice?: number;
  totalPrice: number;
  supplierInfo?: string;
  notes?: string;
  categoryId?: string;
  displayOrder: number;
}
