import type { EntityDto, FullAuditedEntityDto, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface MenuItemDto extends FullAuditedEntityDto<string> {
  name?: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId?: string;
  categoryName?: string;
  isQuickCook: boolean;
  requiresCooking: boolean;
  soldQuantity: number;
  isPopular: boolean;
  maximumQuantityAvailable: number;
  isOutOfStock: boolean;
  hasLimitedStock: boolean;
  ingredients: MenuItemIngredientDto[];
}

export interface MenuItemIngredientDto extends EntityDto<string> {
  ingredientId: string;
  categoryId?: string;
  requiredQuantity: number;
  displayOrder: number;
}

export interface CreateUpdateMenuItemDto {
  name: string;
  description?: string;
  price: number;
  isAvailable: boolean;
  imageUrl?: string;
  categoryId: string;
  isQuickCook: boolean;
  requiresCooking: boolean;
  ingredients: MenuItemIngredientDto[];
}

export interface GetMenuItemListRequestDto extends PagedAndSortedResultRequestDto {
  filter?: string;
  categoryId?: string;
  onlyAvailable: boolean;
}
