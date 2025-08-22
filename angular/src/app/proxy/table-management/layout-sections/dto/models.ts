import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface CreateLayoutSectionDto {
  sectionName: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
}

export interface LayoutSectionDto extends FullAuditedEntityDto<string> {
  sectionName?: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
}

export interface UpdateLayoutSectionDto {
  sectionName: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
}
