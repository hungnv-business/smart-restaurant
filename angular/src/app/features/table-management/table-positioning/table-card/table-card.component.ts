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

@Component({
  selector: 'app-table-card',
  standalone: true,
  imports: [CommonModule, CdkDrag, CardModule, ButtonModule, TooltipModule, BadgeModule],
  templateUrl: './table-card.component.html',
  styleUrls: ['./table-card.component.scss'],
})
export class TableCardComponent extends ComponentBase {
  @Input() table!: TableDto;
  @Input() tableStatusOptions: IntLookupItemDto[] = [];
  @Output() tableUpdated = new EventEmitter<void>();
  @Output() tableDeleted = new EventEmitter<void>();

  // Expose TableStatus enum to template
  readonly tableStatus = TableStatus;

  private tableService = inject(TableService);
  private tableFormDialogService = inject(TableFormDialogService);

  constructor() {
    super();
  }

  getStatusText(status: TableStatus): string {
    const statusOption = this.tableStatusOptions.find(option => option.id === status);
    return statusOption?.displayName || 'Unknown';
  }

  getStatusSeverity(status: TableStatus): 'success' | 'info' | 'warning' | 'danger' {
    switch (status) {
      case TableStatus.Available:
        return 'success';
      case TableStatus.Occupied:
        return 'danger';
      case TableStatus.Reserved:
        return 'warning';
      case TableStatus.Cleaning:
        return 'info';
      default:
        return 'info';
    }
  }

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
        const message = isActive ? 'Đã hiển thị bàn' : 'Đã ẩn bàn';
        this.showSuccess('Thành công', message);
        this.tableUpdated.emit();
      });
  }

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
        this.showSuccess('Thành công', 'Xóa bàn thành công');
        this.tableDeleted.emit();
      });
  }
}
