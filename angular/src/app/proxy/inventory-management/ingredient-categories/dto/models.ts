import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface CreateUpdateIngredientCategoryDto {
  name: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
}

export interface IngredientCategoryDto extends FullAuditedEntityDto<string> {
  name?: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
}
