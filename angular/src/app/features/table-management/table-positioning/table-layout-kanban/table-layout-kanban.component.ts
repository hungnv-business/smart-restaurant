import { Component, OnInit } from '@angular/core';
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
import {
  TableFormDialogService,
  TableFormDialogData,
} from '../table-form-dialog/table-form-dialog.service';
import { TableCardComponent } from '../table-card/table-card.component';

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
    TableCardComponent,
  ],
  providers: [],
  templateUrl: './table-layout-kanban.component.html',
  styleUrls: ['./table-layout-kanban.component.scss'],
})
export class TableLayoutKanbanComponent extends ComponentBase implements OnInit {
  layoutSections: LayoutSectionDto[] = [];
  sectionTables: { [sectionId: string]: TableDto[] } = {};
  tableStatusOptions: IntLookupItemDto[] = [];
  loading = false;

  showCreateDialog = false;
  creatingTable = false;
  selectedSectionId = '';

  constructor(
    private tableService: TableService,
    private tableFormDialogService: TableFormDialogService,
    private globalService: GlobalService
  ) {
    super();
  }

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.loading = true;

    forkJoin({
      sectionsWithTables: this.tableService.getAllSectionsWithTables(),
      tableStatuses: this.globalService.getTableStatuses()
    }).pipe(
      takeUntil(this.destroyed$)
    ).subscribe({
      next: ({ sectionsWithTables, tableStatuses }) => {
        this.loading = false;

        // Set table status options
        this.tableStatusOptions = tableStatuses || [];

        // Clear current data
        this.layoutSections = [];
        this.sectionTables = {};

        // Process sections with tables
        sectionsWithTables?.forEach(sectionData => {
          if (sectionData.id) {
            // Create LayoutSectionDto from SectionWithTablesDto
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
      error: (error) => {
        this.loading = false;
        this.handleApiError(error, 'Có lỗi xảy ra khi tải dữ liệu');
      }
    });
  }

  onTableDrop(event: CdkDragDrop<TableDto[]>): void {
    if (event.previousContainer === event.container) {
      // Reordering within the same section
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
          })
        )
        .subscribe(() => {
          this.loadData();
        });
    } else {
      // Moving between different sections
      transferArrayItem(
        event.previousContainer.data,
        event.container.data,
        event.previousIndex,
        event.currentIndex
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
          })
        )
        .subscribe(() => {
          this.loadData();
        });
    }
  }

  refresh(): void {
    this.loadData();
  }

  // Dialog Methods using DialogService
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

  onTableUpdated(): void {
    // Reload data to get updated information
    this.loadData();
  }

  onTableDeleted(): void {
    // Reload data to refresh the list
    this.loadData();
  }
}
