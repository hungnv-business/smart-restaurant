import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { TooltipModule } from 'primeng/tooltip';
import { Checkbox } from 'primeng/checkbox';
import { CreateUpdatePurchaseUnitDto } from '../../../../../proxy/inventory-management/ingredients/dto';
import { UnitDto } from '../../../../../proxy/common/units/dto';

@Component({
  selector: 'app-ingredient-unit-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    ButtonModule,
    TagModule,
    TooltipModule,
    Checkbox,
  ],
  templateUrl: './ingredient-unit-list.component.html',
  styleUrls: ['./ingredient-unit-list.component.scss'],
})
export class IngredientUnitListComponent {
  @Input() purchaseUnits: CreateUpdatePurchaseUnitDto[] = [];
  @Input() baseUnitName: string = '';
  @Input() units: UnitDto[] = [];
  @Input() loading: boolean = false;

  @Output() editUnit = new EventEmitter<CreateUpdatePurchaseUnitDto>();
  @Output() deleteUnit = new EventEmitter<CreateUpdatePurchaseUnitDto>();
  @Output() addUnit = new EventEmitter<void>();

  getUnitName(unitId: string): string {
    return this.units.find(u => u.id === unitId)?.name || '';
  }

  onEditClick(unit: CreateUpdatePurchaseUnitDto) {
    this.editUnit.emit(unit);
  }

  onDeleteClick(unit: CreateUpdatePurchaseUnitDto) {
    this.deleteUnit.emit(unit);
  }

  onAddClick() {
    this.addUnit.emit();
  }
}