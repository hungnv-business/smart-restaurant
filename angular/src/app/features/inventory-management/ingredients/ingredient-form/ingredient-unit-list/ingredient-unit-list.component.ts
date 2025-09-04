import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { TooltipModule } from 'primeng/tooltip';
import { Checkbox } from 'primeng/checkbox';
import { CreateUpdatePurchaseUnitDto } from '../../../../../proxy/inventory-management/ingredients/dto';
import { GuidLookupItemDto } from '@proxy/common/dto';

/**
 * Component hiển thị danh sách các đơn vị mua hàng của nguyên liệu
 * 
 * Chức năng chính:
 * - Hiển thị bảng các đơn vị mua hàng với thông tin chi tiết
 * - Hiển thị tỷ lệ quy đổi so với đơn vị cơ bản (VD: 1 thùng = 24 chai)
 * - Hiển thị giá mua cho từng đơn vị
 * - Đánh dấu đơn vị cơ sở (base unit) với tag đặc biệt
 * - Các action: thêm mới, chỉnh sửa, xóa đơn vị
 * - Responsive table với sorting và filtering
 * 
 * @example
 * // Sử dụng trong ingredient form:
 * <app-ingredient-unit-list
 *   [purchaseUnits]="purchaseUnits"
 *   [units]="units"
 *   (addUnit)="onAddUnit()"
 *   (editUnit)="onEditUnit($event)"
 *   (deleteUnit)="onDeleteUnit($event)">
 * </app-ingredient-unit-list>
 */
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
  /** Danh sách các đơn vị mua hàng của nguyên liệu */
  @Input() purchaseUnits: CreateUpdatePurchaseUnitDto[] = [];
  /** Tên đơn vị cơ bản để hiển thị trong tooltip */
  @Input() baseUnitName: string = '';
  /** Danh sách tất cả đơn vị đo lường từ hệ thống */
  @Input() units: GuidLookupItemDto[] = [];
  /** Trạng thái loading khi thực hiện thao tác */
  @Input() loading: boolean = false;

  /** Event khi click chỉnh sửa đơn vị */
  @Output() editUnit = new EventEmitter<CreateUpdatePurchaseUnitDto>();
  /** Event khi click xóa đơn vị */
  @Output() deleteUnit = new EventEmitter<CreateUpdatePurchaseUnitDto>();
  /** Event khi click thêm đơn vị mới */
  @Output() addUnit = new EventEmitter<void>();

  /**
   * Lấy tên đơn vị đo lường theo ID
   * @param unitId - ID của đơn vị đo lường
   * @returns Tên đơn vị hoặc chuỗi rỗng nếu không tìm thấy
   */
  getUnitName(unitId: string): string {
    return this.units.find(u => u.id === unitId)?.displayName || '';
  }

  /**
   * Xử lý event click chỉnh sửa đơn vị
   * Emit event để parent component xử lý
   * @param unit - Đơn vị mua hàng cần chỉnh sửa
   */
  onEditClick(unit: CreateUpdatePurchaseUnitDto) {
    this.editUnit.emit(unit);
  }

  /**
   * Xử lý event click xóa đơn vị
   * Emit event để parent component xử lý
   * @param unit - Đơn vị mua hàng cần xóa
   */
  onDeleteClick(unit: CreateUpdatePurchaseUnitDto) {
    this.deleteUnit.emit(unit);
  }

  /**
   * Xử lý event click thêm đơn vị mới
   * Emit event để parent component mở dialog thêm đơn vị
   */
  onAddClick() {
    this.addUnit.emit();
  }
}