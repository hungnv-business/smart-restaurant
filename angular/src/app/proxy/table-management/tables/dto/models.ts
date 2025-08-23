import type { TableStatus } from '../../../table-status.enum';
import type { FullAuditedEntityDto } from '@abp/ng.core';

export interface AssignTableToSectionDto {
  layoutSectionId: string;
  newPosition?: number;
}

export interface CreateTableDto {
  tableNumber: string;
  displayOrder: number;
  status?: TableStatus;
  isActive: boolean;
  layoutSectionId: string;
}

export interface SectionWithTablesDto {
  id?: string;
  sectionName?: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
  tables: TableDto[];
  totalTables: number;
  activeTables: number;
}

export interface TableDto extends FullAuditedEntityDto<string> {
  tableNumber?: string;
  displayOrder: number;
  status?: TableStatus;
  isActive: boolean;
  layoutSectionId?: string;
  layoutSectionName?: string;
}

export interface ToggleActiveStatusDto {
  isActive: boolean;
}

export interface UpdateTableDisplayOrderDto {
  tableId?: string;
  newPosition: number;
}

export interface UpdateTableDto {
  tableNumber: string;
  displayOrder: number;
  status?: TableStatus;
  isActive: boolean;
  layoutSectionId: string;
}
