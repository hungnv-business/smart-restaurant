import { Component, Input, Output, EventEmitter, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CdkDrag } from '@angular/cdk/drag-drop';
import { takeUntil, catchError } from 'rxjs/operators';
import { EMPTY } from 'rxjs';

// PrimeNG imports
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { BadgeModule } from 'primeng/badge';

// Application imports
import { ComponentBase } from '../../../../shared/base/component-base';
import { TableService } from '../../../../proxy/table-management/tables/table.service';
import {
  TableDto,
  ToggleActiveStatusDto,
} from '../../../../proxy/table-management/tables/dto/models';
import { TableStatus } from '../../../../proxy/table-status.enum';
import { TableFormDialogService } from '../table-form-dialog/table-form-dialog.service';
import { IntLookupItemDto } from '@proxy/common/dto';

/**
 * Component hiển thị thông tin một bàn ăn dưới dạng card
 * Chức năng chính:
 * - Hiển thị thông tin bàn (số bàn, số chỗ ngồi, trạng thái)
 * - Hỗ trợ drag & drop để di chuyển bàn giữa các khu vực
 * - Chỉnh sửa thông tin bàn qua dialog
 * - Bật/tắt trạng thái hiển thị bàn
 * - Xóa bàn với xác nhận
 * - Hiển thị màu sắc trạng thái (xanh=trống, đỏ=đang dùng, vàng=đã đặt)
 */
@Component({
  selector: 'app-table-card',
  standalone: true,
  imports: [CommonModule, CdkDrag, CardModule, ButtonModule, TooltipModule, BadgeModule],
  templateUrl: './table-card.component.html',
  styleUrls: ['./table-card.component.scss'],
})
export class TableCardComponent extends ComponentBase {
  /** Thông tin bàn ăn được hiển thị */
  @Input() table!: TableDto;
  /** Danh sách các tùy chọn trạng thái bàn */
  @Input() tableStatusOptions: IntLookupItemDto[] = [];
  /** Event phát ra khi bàn được cập nhật */
  @Output() tableUpdated = new EventEmitter<void>();
  /** Event phát ra khi bàn bị xóa */
  @Output() tableDeleted = new EventEmitter<void>();

  /** Expose TableStatus enum cho template sử dụng */
  readonly tableStatus = TableStatus;

  /** Các service được inject */
  private tableService = inject(TableService);
  private tableFormDialogService = inject(TableFormDialogService);

  /**
   * Khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Lấy tên hiển thị của trạng thái bàn bằng tiếng Việt
   * @param status Trạng thái bàn
   * @returns Tên trạng thái tiếng Việt
   */
  getStatusText(status: TableStatus): string {
    const statusOption = this.tableStatusOptions.find(option => option.id === status);
    return statusOption?.displayName || 'Unknown';
  }

  /**
   * Lấy mức độ độ nghiêm trọng của trạng thái (dùng cho màu sắc badge)
   * @param status Trạng thái bàn
   * @returns Mức độ nghiêm trọng cho style
   */
  getStatusSeverity(status: TableStatus): 'success' | 'info' | 'warning' | 'danger' {
    switch (status) {
      case TableStatus.Available: // Bàn trống - màu xanh
        return 'success';
      case TableStatus.Occupied: // Bàn đang dùng - màu đỏ
        return 'danger';
      case TableStatus.Reserved: // Bàn đã đặt - màu vàng
        return 'warning';
      default:
        return 'info';
    }
  }

  /**
   * Xử lý khi click nút chỉnh sửa bàn
   */
  onEditClick(): void {
    this.tableFormDialogService
      .openEditTableDialog(this.table.id)
      .pipe(takeUntil(this.destroyed$))
      .subscribe(success => {
        if (success) {
          this.tableUpdated.emit();
        }
      });
  }

  /**
   * Xử lý khi click nút bật/tắt trạng thái hiển thị bàn
   */
  onToggleActiveClick(): void {
    const newStatus = !this.table.isActive;
    const message = newStatus
      ? `Bạn có muốn hiển thị bàn "${this.table.tableNumber}"?`
      : `Bạn có muốn ẩn bàn "${this.table.tableNumber}"?`;

    this.confirmationService.confirm({
      message: message,
      header: 'Xác nhận thay đổi',
      icon: 'pi pi-question-circle',
      acceptLabel: newStatus ? 'Hiển thị' : 'Ẩn',
      rejectLabel: 'Hủy',
      accept: () => {
        this.toggleActiveStatus(newStatus);
      },
    });
  }

  /**
   * Xử lý khi click nút xóa bàn
   */
  onDeleteClick(): void {
    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa bàn "${this.table.tableNumber}"?`,
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Xóa',
      rejectLabel: 'Hủy',
      accept: () => {
        this.deleteTable(this.table.id!);
      },
    });
  }

  /**
   * Chuyển đổi trạng thái hiển thị của bàn
   * @param isActive Trạng thái mới (true = hiển thị, false = ẩn)
   */
  toggleActiveStatus(isActive: boolean): void {
    const input: ToggleActiveStatusDto = { isActive };

    this.tableService
      .toggleActiveStatus(this.table.id!, input)
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          this.handleApiError(error, 'Có lỗi xảy ra khi thay đổi trạng thái bàn');
          return EMPTY;
        }),
      )
      .subscribe(() => {
        // Hiển thị thông báo thành công và phát event cập nhật
        const message = isActive ? 'Đã hiển thị bàn' : 'Đã ẩn bàn';
        this.showSuccess('Thành công', message);
        this.tableUpdated.emit();
      });
  }

  /**
   * Xóa bàn ăn khỏi hệ thống
   * @param tableId ID của bàn cần xóa
   */
  deleteTable(tableId: string): void {
    this.tableService
      .delete(tableId)
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          this.handleApiError(error, 'Có lỗi xảy ra khi xóa bàn');
          return EMPTY;
        }),
      )
      .subscribe(() => {
        // Hiển thị thông báo và phát event xóa thành công
        this.showSuccess('Thành công', 'Xóa bàn thành công');
        this.tableDeleted.emit();
      });
  }
}
