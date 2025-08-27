import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface UnitDto extends FullAuditedEntityDto<string> {
  name?: string;
  displayOrder: number;
  isActive: boolean;
}
