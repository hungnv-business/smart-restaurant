import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface CreateUpdateMenuCategoryDto {
  name: string;
  description?: string;
  displayOrder: number;
  isEnabled: boolean;
  imageUrl?: string;
}

export interface MenuCategoryDto extends FullAuditedEntityDto<string> {
  name?: string;
  description?: string;
  displayOrder: number;
  isEnabled: boolean;
  imageUrl?: string;
}
