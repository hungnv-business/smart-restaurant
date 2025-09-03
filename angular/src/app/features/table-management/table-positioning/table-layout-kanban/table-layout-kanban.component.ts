import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  CdkDragDrop,
  DragDropModule,
  moveItemInArray,
  transferArrayItem,
} from '@angular/cdk/drag-drop';
import { takeUntil, catchError } from 'rxjs/operators';
import { EMPTY, forkJoin } from 'rxjs';

// PrimeNG imports
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { BadgeModule } from 'primeng/badge';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialog } from 'primeng/confirmdialog';
import { ConfirmationService } from 'primeng/api';

// Application imports
import { ComponentBase } from '../../../../shared/base/component-base';
import { TableService } from '../../../../proxy/table-management/tables/table.service';
import { GlobalService } from '../../../../proxy/common/global.service';
import {
  TableDto,
  AssignTableToSectionDto,
  UpdateTableDisplayOrderDto,
} from '../../../../proxy/table-management/tables/dto/models';
import { LayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { IntLookupItemDto } from '@proxy/common/dto';
import { TableFormDialogService } from '../table-form-dialog/table-form-dialog.service';
import { TableCardComponent } from '../table-card/table-card.component';

/**
 * Component kanban board để quản lý bố trí bàn ăn theo khu vực
 * Chức năng chính:
 * - Hiển thị tất cả khu vực và bàn ăn dưới dạng kanban board
 * - Hỗ trợ drag & drop để di chuyển bàn giữa các khu vực
 * - Tạo bàn mới trực tiếp từ khu vực
 * - Cập nhật thứ tự bàn trong cùng khu vực
 * - Hiển thị trạng thái bàn (trống, đang sử dụng, đã đặt...)
 */
@Component({
  selector: 'app-table-layout-kanban',
  standalone: true,
  imports: [
    CommonModule,
    DragDropModule,
    CardModule,
    ButtonModule,
    TooltipModule,
    BadgeModule,
    ToastModule,
    ConfirmDialog,
    TableCardComponent,
  ],
  providers: [ConfirmationService],
  templateUrl: './table-layout-kanban.component.html',
  styleUrls: ['./table-layout-kanban.component.scss'],
})
export class TableLayoutKanbanComponent extends ComponentBase implements OnInit {
  /** Danh sách các khu vực bố cục nhà hàng */
  layoutSections: LayoutSectionDto[] = [];
  /** Danh sách bàn ăn theo từng khu vực (sectionId -> TableDto[]) */
  sectionTables: { [sectionId: string]: TableDto[] } = {};
  /** Các tùy chọn trạng thái bàn (trống, đang dùng, đã đặt...) */
  tableStatusOptions: IntLookupItemDto[] = [];
  /** Trạng thái đang tải dữ liệu */
  loading = false;

  /** Trạng thái hiển thị dialog tạo bàn mới */
  showCreateDialog = false;
  /** Trạng thái đang tạo bàn mới */
  creatingTable = false;
  /** ID khu vực được chọn để tạo bàn mới */
  selectedSectionId = '';

  /** Các service được inject */
  private tableService = inject(TableService);
  private tableFormDialogService = inject(TableFormDialogService);
  private globalService = inject(GlobalService);

  /**
   * Khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit(): void {
    this.loadData();
  }

  /**
   * Tải dữ liệu khu vực và bàn ăn từ API
   */
  loadData(): void {
    this.loading = true;

    forkJoin({
      sectionsWithTables: this.tableService.getAllSectionsWithTables(),
      tableStatuses: this.globalService.getTableStatuses(),
    })
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: ({ sectionsWithTables, tableStatuses }) => {
          this.loading = false;

          // Thiết lập các tùy chọn trạng thái bàn
          this.tableStatusOptions = tableStatuses || [];

          // Xóa dữ liệu hiện tại
          this.layoutSections = [];
          this.sectionTables = {};

          // Xử lý các khu vực và bàn ăn
          sectionsWithTables?.forEach(sectionData => {
            if (sectionData.id) {
              // Tạo LayoutSectionDto từ SectionWithTablesDto
              const layoutSection: LayoutSectionDto = {
                id: sectionData.id,
                sectionName: sectionData.sectionName || '',
                description: sectionData.description,
                displayOrder: sectionData.displayOrder,
                isActive: sectionData.isActive,
              };

              this.layoutSections.push(layoutSection);
              this.sectionTables[sectionData.id] = sectionData.tables || [];
            }
          });
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Có lỗi xảy ra khi tải dữ liệu');
        },
      });
  }

  /**
   * Xử lý khi ké thả bàn trong kanban board
   * @param event Event drag & drop
   */
  onTableDrop(event: CdkDragDrop<TableDto[]>): void {
    if (event.previousContainer === event.container) {
      // Sắp xếp lại thứ tự trong cùng một khu vực
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);

      const draggedTable = event.item.data as TableDto;

      this.tableService
        .updateDisplayOrder({
          tableId: draggedTable.id!,
          newPosition: event.currentIndex + 1,
        } as UpdateTableDisplayOrderDto)
        .pipe(
          takeUntil(this.destroyed$),
          catchError(error => {
            this.handleApiError(error, 'Có lỗi xảy ra khi cập nhật thứ tự bàn');
            this.loadData();
            return EMPTY;
          }),
        )
        .subscribe(() => {
          this.loadData();
        });
    } else {
      // Di chuyển giữa các khu vực khác nhau
      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex,
      );

      const draggedTable = event.item.data as TableDto;
      const targetSectionId = event.container.id;

      this.tableService
        .assignToSection(draggedTable.id!, {
          layoutSectionId: targetSectionId,
          newPosition: event.currentIndex + 1,
        } as AssignTableToSectionDto)
        .pipe(
          takeUntil(this.destroyed$),
          catchError(error => {
            this.handleApiError(error, 'Có lỗi xảy ra khi chuyển bàn sang khu vực khác');
            this.loadData();
            return EMPTY;
          }),
        )
        .subscribe(() => {
          this.loadData();
        });
    }
  }

  /**
   * Làm mới dữ liệu kanban board
   */
  refresh(): void {
    this.loadData();
  }

  /**
   * Mở dialog tạo bàn mới trong khu vực được chọn
   * @param sectionId ID của khu vực để tạo bàn
   */
  openCreateTableDialog(sectionId: string): void {
    this.selectedSectionId = sectionId;

    this.tableFormDialogService
      .openCreateTableDialog(sectionId)
      .pipe(takeUntil(this.destroyed$))
      .subscribe(success => {
        if (success) {
          this.loadData();
        }
      });
  }

  /**
   * Xử lý khi bàn ăn được cập nhật
   */
  onTableUpdated(): void {
    // Tải lại dữ liệu để lấy thông tin mới nhất
    this.loadData();
  }

  /**
   * Xử lý khi bàn ăn bị xóa
   */
  onTableDeleted(): void {
    // Tải lại dữ liệu để cập nhật danh sách
    this.loadData();
  }
}
