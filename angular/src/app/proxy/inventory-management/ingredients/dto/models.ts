import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface CreateUpdateIngredientDto {
  categoryId: string;
  name: string;
  description?: string;
  unitId: string;
  costPerUnit?: number;
  supplierInfo?: string;
  isActive: boolean;
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
  isActive: boolean;
}
