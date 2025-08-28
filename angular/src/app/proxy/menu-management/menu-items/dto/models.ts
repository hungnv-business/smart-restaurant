import type { FullAuditedEntityDto } from '@abp/ng.core';
import type { MenuCategoryDto } from '../../menu-categories/dto/models';

export interface CreateUpdateMenuItemDto {
  name: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId: string;
}

export interface MenuItemDto extends FullAuditedEntityDto<string> {
  name?: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId?: string;
  category: MenuCategoryDto;
}
