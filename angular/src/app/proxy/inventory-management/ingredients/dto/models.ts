import type { FullAuditedEntityDto, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface CreateUpdateIngredientDto {
  categoryId: string;
  name: string;
  description?: string;
  unitId: string;
  costPerUnit?: number;
  supplierInfo?: string;
  isActive: boolean;
  purchaseUnits: CreateUpdatePurchaseUnitDto[];
}

export interface CreateUpdatePurchaseUnitDto {
  id: string;
  unitId: string;
  conversionRatio: number;
  isBaseUnit: boolean;
  purchasePrice?: number;
  isActive: boolean;
}

export interface GetIngredientListRequestDto extends PagedAndSortedResultRequestDto {
  filter?: string;
  categoryId?: string;
  includeInactive: boolean;
}

export interface IngredientDto extends FullAuditedEntityDto<string> {
  categoryId?: string;
  categoryName?: string;
  name?: string;
  description?: string;
  unitId?: string;
  unitName?: string;
  costPerUnit?: number;
  supplierInfo?: string;
  currentStock: number;
  isActive: boolean;
  purchaseUnits: IngredientPurchaseUnitDto[];
  canDelete: boolean;
}

export interface IngredientPurchaseUnitDto extends FullAuditedEntityDto<string> {
  ingredientId?: string;
  unitId?: string;
  unitName?: string;
  conversionRatio: number;
  isBaseUnit: boolean;
  purchasePrice?: number;
  isActive: boolean;
}
