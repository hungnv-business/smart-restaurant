import type { EntityDto, FullAuditedEntityDto, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface MenuItemDto extends FullAuditedEntityDto<string> {
  name?: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId?: string;
  categoryName?: string;
  soldQuantity: number;
  isPopular: boolean;
}

export interface CreateUpdateMenuItemDto {
  name: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId: string;
  ingredients: MenuItemIngredientDto[];
}

export interface GetMenuItemListRequestDto extends PagedAndSortedResultRequestDto {
  filter?: string;
  categoryId?: string;
  onlyAvailable: boolean;
}

export interface MenuItemIngredientDto extends EntityDto<string> {
  ingredientId: string;
  requiredQuantity: number;
  displayOrder: number;
}
