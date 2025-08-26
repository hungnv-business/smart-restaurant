# Level 3: Interactive UI Template

## 🚀 Khi nào sử dụng Level 3
- **Complex user interactions**: Tương tác phức tạp với người dùng
- **Real-time updates**: Cập nhật thời gian thực, visual editors
- **Phù hợp cho**: Table Layout Kanban, Kitchen Dashboard, Menu Builder, Real-time Reporting...

## 🎯 UI Pattern: Drag & Drop + Canvas + Real-time widgets
- CDK Drag & Drop functionality
- Real-time updates (WebSocket/SignalR)
- Visual editors và builders
- Advanced UX interactions
- Performance-optimized components

## Ví dụ: Table Layout Kanban UI (Drag & Drop + Real-time)

### Component Template (Level 3)

```typescript
// File: angular/src/app/features/table-management/table-layout-kanban/table-layout-kanban.component.ts
import { Component, OnInit, inject, signal, computed, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  CdkDragDrop,
  DragDropModule,
  moveItemInArray,
  transferArrayItem,
} from '@angular/cdk/drag-drop';
import { takeUntil, catchError, debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { EMPTY, forkJoin, Subject, fromEvent } from 'rxjs';

// PrimeNG imports for advanced UI
import { CardModule } from 'primeng/card';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { BadgeModule } from 'primeng/badge';
import { ToastModule } from 'primeng/toast';
import { ConfirmDialog } from 'primeng/confirmdialog';
import { ConfirmationService } from 'primeng/api';
import { SkeletonModule } from 'primeng/skeleton';
import { SpeedDialModule } from 'primeng/speeddial';
import { RippleModule } from 'primeng/ripple';
import { SplitterModule } from 'primeng/splitter';
import { ContextMenuModule, MenuItem as PrimeMenuItem } from 'primeng/contextmenu';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { ToggleButtonModule } from 'primeng/togglebutton';

// Application imports
import { ComponentBase } from '../../../../shared/base/component-base';
import { TableService } from '../../../../proxy/table-management/tables/table.service';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import { GlobalService } from '../../../../proxy/common/global.service';
import {
  TableDto,
  AssignTableToSectionDto,
  UpdateTableDisplayOrderDto,
  TableStatus,
} from '../../../../proxy/table-management/tables/dto/models';
import { LayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { IntLookupItemDto } from '@proxy/common/dto';
import { TableFormDialogService } from '../table-form-dialog/table-form-dialog.service';
import { TableCardComponent } from '../table-card/table-card.component';

// Real-time imports (SignalR)
import { HubConnection, HubConnectionBuilder } from '@microsoft/signalr';

interface TableStatusConfig {
  severity: 'success' | 'info' | 'warning' | 'danger';
  icon: string;
  label: string;
  color: string;
}

interface KanbanViewOptions {
  showEmptySections: boolean;
  enableDragDrop: boolean;
  showTableDetails: boolean;
  autoRefresh: boolean;
  refreshInterval: number;
}

interface TableStatusSummary {
  total: number;
  available: number;
  occupied: number;
  reserved: number;
  maintenance: number;
}

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
    SkeletonModule,
    SpeedDialModule,
    RippleModule,
    SplitterModule,
    ContextMenuModule,
    DialogModule,
    InputTextModule,
    ToggleButtonModule,
  ],
  providers: [ConfirmationService],
  templateUrl: './table-layout-kanban.component.html',
})
export class TableLayoutKanbanComponent extends ComponentBase implements OnInit {
  // Status configuration with Vietnamese labels
  readonly statusConfig: Record<TableStatus, TableStatusConfig> = {
    [TableStatus.Available]: {
      severity: 'success',
      icon: 'pi pi-check',
      label: 'Trống',
      color: '#10B981'
    },
    [TableStatus.Occupied]: {
      severity: 'warning',
      icon: 'pi pi-users',
      label: 'Có khách',
      color: '#F59E0B'
    },
    [TableStatus.Reserved]: {
      severity: 'info',
      icon: 'pi pi-bookmark',
      label: 'Đã đặt',
      color: '#3B82F6'
    },
    [TableStatus.Maintenance]: {
      severity: 'danger',
      icon: 'pi pi-wrench',
      label: 'Bảo trì',
      color: '#EF4444'
    }
  };

  // Signals for reactive state management
  layoutSections = signal<LayoutSectionDto[]>([]);
  sectionTables = signal<{ [sectionId: string]: TableDto[] }>({});
  tableStatusOptions = signal<IntLookupItemDto[]>([]);
  loading = signal(false);
  selectedTable = signal<TableDto | null>(null);
  dragInProgress = signal(false);
  viewOptions = signal<KanbanViewOptions>({
    showEmptySections: true,
    enableDragDrop: true,
    showTableDetails: true,
    autoRefresh: true,
    refreshInterval: 30000 // 30 seconds
  });

  // Real-time connection
  private hubConnection: HubConnection | null = null;
  private refreshSubject = new Subject<void>();

  // Context menu
  contextMenuItems: PrimeMenuItem[] = [];
  showQuickActions = signal(false);
  quickActionsPosition = signal({ x: 0, y: 0 });

  // Computed values
  tableSummary = computed(() => {
    const sections = this.sectionTables();
    let summary: TableStatusSummary = {
      total: 0,
      available: 0,
      occupied: 0,
      reserved: 0,
      maintenance: 0
    };

    Object.values(sections).forEach(tables => {
      tables.forEach(table => {
        summary.total++;
        switch (table.status) {
          case TableStatus.Available:
            summary.available++;
            break;
          case TableStatus.Occupied:
            summary.occupied++;
            break;
          case TableStatus.Reserved:
            summary.reserved++;
            break;
          case TableStatus.Maintenance:
            summary.maintenance++;
            break;
        }
      });
    });

    return summary;
  });

  sectionsWithTables = computed(() => {
    const sections = this.layoutSections();
    const tables = this.sectionTables();
    const options = this.viewOptions();

    return sections
      .filter(section => options.showEmptySections || (tables[section.id!] && tables[section.id!].length > 0))
      .map(section => ({
        ...section,
        tables: tables[section.id!] || [],
        tableCount: (tables[section.id!] || []).length
      }));
  });

  // Speed dial actions
  speedDialActions = [
    {
      icon: 'pi pi-refresh',
      command: () => this.refresh(),
      tooltip: 'Làm mới dữ liệu'
    },
    {
      icon: 'pi pi-plus',
      command: () => this.showCreateTableDialog(),
      tooltip: 'Thêm bàn mới'
    },
    {
      icon: 'pi pi-cog',
      command: () => this.toggleViewOptions(),
      tooltip: 'Tùy chọn hiển thị'
    },
    {
      icon: 'pi pi-chart-bar',
      command: () => this.showStatistics(),
      tooltip: 'Thống kê bàn ăn'
    }
  ];

  // Services
  private tableService = inject(TableService);
  private layoutSectionService = inject(LayoutSectionService);
  private tableFormDialogService = inject(TableFormDialogService);
  private globalService = inject(GlobalService);

  constructor() {
    super();
    this.setupContextMenu();
    this.setupAutoRefresh();
    this.setupRealTimeConnection();
  }

  ngOnInit(): void {
    this.loadData();
    this.startRealTimeConnection();
  }

  ngOnDestroy(): void {
    super.ngOnDestroy();
    this.stopRealTimeConnection();
    this.refreshSubject.complete();
  }

  // Data loading with performance optimization
  loadData(): void {
    this.loading.set(true);

    forkJoin({
      sectionsWithTables: this.tableService.getAllSectionsWithTables(),
      tableStatuses: this.globalService.getTableStatuses(),
    })
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: ({ sectionsWithTables, tableStatuses }) => {
          this.loading.set(false);

          // Set table status options
          this.tableStatusOptions.set(tableStatuses || []);

          // Process sections with tables
          this.processSectionsData(sectionsWithTables);

          // Update real-time connection with current data
          this.updateRealTimeData();
        },
        error: error => {
          this.loading.set(false);
          this.handleApiError(error, 'Có lỗi xảy ra khi tải dữ liệu');
        },
      });
  }

  private processSectionsData(sectionsData: any[]) {
    const sections: LayoutSectionDto[] = [];
    const sectionTablesMap: { [sectionId: string]: TableDto[] } = {};

    sectionsData?.forEach(sectionData => {
      if (sectionData.id) {
        // Create LayoutSectionDto
        const layoutSection: LayoutSectionDto = {
          id: sectionData.id,
          sectionName: sectionData.sectionName || '',
          description: sectionData.description,
          displayOrder: sectionData.displayOrder,
          isActive: sectionData.isActive,
        };

        sections.push(layoutSection);
        
        // Sort tables by display order and add animation flags
        const tables = (sectionData.tables || [])
          .sort((a: TableDto, b: TableDto) => (a.displayOrder || 0) - (b.displayOrder || 0))
          .map((table: TableDto) => ({
            ...table,
            isAnimating: false,
            lastUpdated: new Date()
          }));
          
        sectionTablesMap[sectionData.id] = tables;
      }
    });

    // Update signals
    this.layoutSections.set(sections.sort((a, b) => (a.displayOrder || 0) - (b.displayOrder || 0)));
    this.sectionTables.set(sectionTablesMap);
  }

  // Advanced drag & drop with animations
  onTableDrop(event: CdkDragDrop<TableDto[]>): void {
    if (!this.viewOptions().enableDragDrop) return;

    this.dragInProgress.set(true);

    // Add animation classes
    const draggedTable = event.item.data as TableDto;
    this.animateTableMovement(draggedTable);

    if (event.previousContainer === event.container) {
      // Reordering within the same section
      this.handleIntraSectionMove(event);
    } else {
      // Moving between different sections
      this.handleInterSectionMove(event);
    }

    setTimeout(() => {
      this.dragInProgress.set(false);
    }, 500);
  }

  private handleIntraSectionMove(event: CdkDragDrop<TableDto[]>): void {
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
          this.loadData(); // Rollback
          return EMPTY;
        }),
      )
      .subscribe(() => {
        this.showSuccess('Thành công', 'Đã cập nhật thứ tự bàn');
        this.notifyRealTimeUpdate('table.reordered', { 
          tableId: draggedTable.id, 
          newPosition: event.currentIndex + 1 
        });
      });
  }

  private handleInterSectionMove(event: CdkDragDrop<TableDto[]>): void {
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
          this.loadData(); // Rollback
          return EMPTY;
        }),
      )
      .subscribe(() => {
        this.showSuccess('Thành công', 'Đã chuyển bàn sang khu vực khác');
        this.notifyRealTimeUpdate('table.moved', { 
          tableId: draggedTable.id, 
          targetSectionId,
          newPosition: event.currentIndex + 1 
        });
      });
  }

  private animateTableMovement(table: TableDto): void {
    // Find and animate the table element
    const tableElement = document.querySelector(`[data-table-id="${table.id}"]`);
    if (tableElement) {
      tableElement.classList.add('table-moving');
      setTimeout(() => {
        tableElement.classList.remove('table-moving');
      }, 300);
    }
  }

  // Real-time functionality with SignalR
  private setupRealTimeConnection(): void {
    this.hubConnection = new HubConnectionBuilder()
      .withUrl('/hubs/table-status')
      .withAutomaticReconnect()
      .build();

    // Handle real-time events
    this.hubConnection.on('TableStatusChanged', (data: { tableId: string; newStatus: TableStatus }) => {
      this.updateTableStatus(data.tableId, data.newStatus);
    });

    this.hubConnection.on('TableMoved', (data: { tableId: string; sectionId: string }) => {
      this.handleRealTimeTableMove(data);
    });

    this.hubConnection.on('TableAdded', (table: TableDto) => {
      this.handleRealTimeTableAdded(table);
    });

    this.hubConnection.on('TableRemoved', (tableId: string) => {
      this.handleRealTimeTableRemoved(tableId);
    });
  }

  private async startRealTimeConnection(): Promise<void> {
    try {
      if (this.hubConnection) {
        await this.hubConnection.start();
        console.log('Real-time connection established');
      }
    } catch (error) {
      console.error('Error starting real-time connection:', error);
      // Fallback to polling if SignalR fails
      this.setupPollingFallback();
    }
  }

  private async stopRealTimeConnection(): Promise<void> {
    try {
      if (this.hubConnection) {
        await this.hubConnection.stop();
        console.log('Real-time connection stopped');
      }
    } catch (error) {
      console.error('Error stopping real-time connection:', error);
    }
  }

  private updateTableStatus(tableId: string, newStatus: TableStatus): void {
    const currentSections = this.sectionTables();
    const updatedSections = { ...currentSections };

    // Find and update the table
    Object.keys(updatedSections).forEach(sectionId => {
      const tables = updatedSections[sectionId];
      const tableIndex = tables.findIndex(t => t.id === tableId);
      if (tableIndex !== -1) {
        updatedSections[sectionId] = [
          ...tables.slice(0, tableIndex),
          { ...tables[tableIndex], status: newStatus, lastUpdated: new Date() },
          ...tables.slice(tableIndex + 1)
        ];

        // Add visual feedback
        this.animateStatusChange(tableId);
      }
    });

    this.sectionTables.set(updatedSections);
  }

  private animateStatusChange(tableId: string): void {
    const tableElement = document.querySelector(`[data-table-id="${tableId}"]`);
    if (tableElement) {
      tableElement.classList.add('status-changed');
      setTimeout(() => {
        tableElement.classList.remove('status-changed');
      }, 1000);
    }
  }

  private notifyRealTimeUpdate(event: string, data: any): void {
    if (this.hubConnection?.state === 'Connected') {
      this.hubConnection.invoke('NotifyTableUpdate', event, data).catch(console.error);
    }
  }

  // Auto-refresh functionality
  private setupAutoRefresh(): void {
    this.refreshSubject.pipe(
      debounceTime(1000),
      distinctUntilChanged(),
      takeUntil(this.destroyed$)
    ).subscribe(() => {
      if (this.viewOptions().autoRefresh) {
        this.loadData();
      }
    });

    // Start auto-refresh timer
    effect(() => {
      const options = this.viewOptions();
      if (options.autoRefresh) {
        const interval = setInterval(() => {
          this.refreshSubject.next();
        }, options.refreshInterval);

        return () => clearInterval(interval);
      }
      return () => {};
    });
  }

  private setupPollingFallback(): void {
    // Fallback to polling if SignalR is not available
    setInterval(() => {
      if (this.viewOptions().autoRefresh) {
        this.refreshSubject.next();
      }
    }, this.viewOptions().refreshInterval);
  }

  // Context menu and quick actions
  private setupContextMenu(): void {
    this.contextMenuItems = [
      {
        label: 'Chỉnh sửa bàn',
        icon: 'pi pi-pencil',
        command: () => this.editSelectedTable()
      },
      {
        label: 'Thay đổi trạng thái',
        icon: 'pi pi-refresh',
        items: [
          {
            label: 'Trống',
            icon: 'pi pi-check',
            command: () => this.changeTableStatus(TableStatus.Available)
          },
          {
            label: 'Có khách',
            icon: 'pi pi-users',
            command: () => this.changeTableStatus(TableStatus.Occupied)
          },
          {
            label: 'Đã đặt',
            icon: 'pi pi-bookmark',
            command: () => this.changeTableStatus(TableStatus.Reserved)
          },
          {
            label: 'Bảo trì',
            icon: 'pi pi-wrench',
            command: () => this.changeTableStatus(TableStatus.Maintenance)
          }
        ]
      },
      {
        separator: true
      },
      {
        label: 'Xóa bàn',
        icon: 'pi pi-trash',
        command: () => this.deleteSelectedTable()
      }
    ];
  }

  onTableContextMenu(event: MouseEvent, table: TableDto): void {
    event.preventDefault();
    this.selectedTable.set(table);
    this.showQuickActions.set(true);
    this.quickActionsPosition.set({ x: event.clientX, y: event.clientY });
  }

  private editSelectedTable(): void {
    const table = this.selectedTable();
    if (table) {
      this.openEditTableDialog(table.id!);
    }
  }

  private changeTableStatus(newStatus: TableStatus): void {
    const table = this.selectedTable();
    if (table && table.status !== newStatus) {
      this.tableService.updateStatus(table.id!, newStatus)
        .pipe(takeUntil(this.destroyed$))
        .subscribe({
          next: () => {
            this.updateTableStatus(table.id!, newStatus);
            this.showSuccess('Thành công', 'Đã cập nhật trạng thái bàn');
            this.notifyRealTimeUpdate('table.status-changed', { 
              tableId: table.id, 
              newStatus 
            });
          },
          error: (error) => {
            this.handleApiError(error, 'Không thể cập nhật trạng thái bàn');
          }
        });
    }
    this.showQuickActions.set(false);
  }

  private deleteSelectedTable(): void {
    const table = this.selectedTable();
    if (table) {
      this.confirmationService.confirm({
        message: `Bạn có chắc chắn muốn xóa bàn số ${table.tableNumber}?`,
        header: 'Xác nhận xóa',
        icon: 'pi pi-exclamation-triangle',
        acceptLabel: 'Xóa',
        rejectLabel: 'Hủy',
        accept: () => {
          this.performDeleteTable(table);
        }
      });
    }
    this.showQuickActions.set(false);
  }

  private performDeleteTable(table: TableDto): void {
    this.tableService.delete(table.id!)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: () => {
          this.loadData();
          this.showSuccess('Thành công', 'Đã xóa bàn');
          this.notifyRealTimeUpdate('table.deleted', { tableId: table.id });
        },
        error: (error) => {
          this.handleApiError(error, 'Không thể xóa bàn');
        }
      });
  }

  // Dialog operations
  openCreateTableDialog(sectionId?: string): void {
    this.tableFormDialogService
      .openCreateTableDialog(sectionId)
      .pipe(takeUntil(this.destroyed$))
      .subscribe(success => {
        if (success) {
          this.loadData();
        }
      });
  }

  openEditTableDialog(tableId: string): void {
    this.tableFormDialogService
      .openEditTableDialog(tableId)
      .pipe(takeUntil(this.destroyed$))
      .subscribe(success => {
        if (success) {
          this.loadData();
        }
      });
  }

  private showCreateTableDialog(): void {
    this.openCreateTableDialog();
  }

  // View options and utilities
  refresh(): void {
    this.loadData();
  }

  toggleViewOptions(): void {
    // Show view options dialog or toggle sidebar
    const currentOptions = this.viewOptions();
    this.viewOptions.set({
      ...currentOptions,
      showTableDetails: !currentOptions.showTableDetails
    });
  }

  private showStatistics(): void {
    // Show statistics modal or navigate to statistics page
    console.log('Table Statistics:', this.tableSummary());
  }

  // Utility methods
  getStatusConfig(status: TableStatus): TableStatusConfig {
    return this.statusConfig[status];
  }

  getTableClasses(table: TableDto): string {
    const baseClasses = ['table-card', 'draggable'];
    const statusConfig = this.getStatusConfig(table.status);
    
    baseClasses.push(`status-${table.status.toLowerCase()}`);
    
    if (this.selectedTable()?.id === table.id) {
      baseClasses.push('selected');
    }
    
    if (this.dragInProgress()) {
      baseClasses.push('drag-active');
    }
    
    return baseClasses.join(' ');
  }

  getSectionClasses(section: LayoutSectionDto): string {
    const baseClasses = ['kanban-section'];
    
    if (!section.isActive) {
      baseClasses.push('inactive');
    }
    
    return baseClasses.join(' ');
  }

  trackByTableId(index: number, table: TableDto): string {
    return table.id!;
  }

  trackBySectionId(index: number, section: LayoutSectionDto): string {
    return section.id!;
  }

  // Real-time event handlers
  private handleRealTimeTableMove(data: { tableId: string; sectionId: string }): void {
    // Refresh data to reflect the move
    this.loadData();
  }

  private handleRealTimeTableAdded(table: TableDto): void {
    // Add the new table to the appropriate section
    const currentSections = this.sectionTables();
    const sectionId = table.layoutSectionId;
    
    if (sectionId && currentSections[sectionId]) {
      const updatedSections = {
        ...currentSections,
        [sectionId]: [...currentSections[sectionId], table]
      };
      this.sectionTables.set(updatedSections);
    }
  }

  private handleRealTimeTableRemoved(tableId: string): void {
    const currentSections = this.sectionTables();
    const updatedSections = { ...currentSections };

    // Remove the table from all sections
    Object.keys(updatedSections).forEach(sectionId => {
      updatedSections[sectionId] = updatedSections[sectionId].filter(t => t.id !== tableId);
    });

    this.sectionTables.set(updatedSections);
  }

  private updateRealTimeData(): void {
    // Update the real-time connection with current table data
    if (this.hubConnection?.state === 'Connected') {
      const tableIds = Object.values(this.sectionTables())
        .flat()
        .map(table => table.id!)
        .filter(id => id);
        
      this.hubConnection.invoke('JoinTableGroups', tableIds).catch(console.error);
    }
  }
}
```

### HTML Template (Level 3)

```html
<!-- File: angular/src/app/features/table-management/table-layout-kanban/table-layout-kanban.component.html -->
<div class="table-layout-kanban">
  <!-- Header with stats and controls -->
  <div class="kanban-header">
    <div class="header-content">
      <h1>Sơ đồ bàn ăn</h1>
      
      <!-- Statistics summary -->
      <div class="stats-summary">
        <div class="stat-card total">
          <div class="stat-value">{{ tableSummary().total }}</div>
          <div class="stat-label">Tổng bàn</div>
        </div>
        <div class="stat-card available">
          <div class="stat-value">{{ tableSummary().available }}</div>
          <div class="stat-label">Trống</div>
        </div>
        <div class="stat-card occupied">
          <div class="stat-value">{{ tableSummary().occupied }}</div>
          <div class="stat-label">Có khách</div>
        </div>
        <div class="stat-card reserved">
          <div class="stat-value">{{ tableSummary().reserved }}</div>
          <div class="stat-label">Đã đặt</div>
        </div>
        <div class="stat-card maintenance">
          <div class="stat-value">{{ tableSummary().maintenance }}</div>
          <div class="stat-label">Bảo trì</div>
        </div>
      </div>

      <!-- View controls -->
      <div class="header-controls">
        <p-toggleButton 
          [(ngModel)]="viewOptions().showEmptySections"
          onLabel="Hiện khu trống" 
          offLabel="Ẩn khu trống"
          onIcon="pi pi-eye" 
          offIcon="pi pi-eye-slash"
          (onChange)="updateViewOption('showEmptySections', $event.checked)">
        </p-toggleButton>
        
        <p-toggleButton 
          [(ngModel)]="viewOptions().enableDragDrop"
          onLabel="Kéo thả ON" 
          offLabel="Kéo thả OFF"
          onIcon="pi pi-arrows-alt" 
          offIcon="pi pi-lock"
          (onChange)="updateViewOption('enableDragDrop', $event.checked)">
        </p-toggleButton>
        
        <button 
          pButton 
          icon="pi pi-refresh" 
          label="Làm mới"
          class="p-button-secondary"
          (click)="refresh()"
          [loading]="loading()">
        </button>
      </div>
    </div>
  </div>

  <!-- Loading skeleton -->
  @if (loading()) {
    <div class="loading-skeleton">
      @for (i of [1,2,3]; track i) {
        <div class="skeleton-section">
          <p-skeleton height="2rem" width="200px" class="mb-3"></p-skeleton>
          <div class="skeleton-tables">
            @for (j of [1,2,3,4]; track j) {
              <p-skeleton height="120px" width="100px"></p-skeleton>
            }
          </div>
        </div>
      }
    </div>
  }

  <!-- Kanban board -->
  @if (!loading()) {
    <div class="kanban-board" [class.drag-disabled]="!viewOptions().enableDragDrop">
      <!-- Sections with drag & drop -->
      @for (section of sectionsWithTables(); track trackBySectionId($index, section)) {
        <div 
          class="kanban-section-container"
          [class]="getSectionClasses(section)"
          [attr.data-section-id]="section.id">
          
          <!-- Section header -->
          <div class="section-header">
            <div class="section-title">
              <h3>{{ section.sectionName }}</h3>
              @if (section.description) {
                <p class="section-description">{{ section.description }}</p>
              }
              <div class="section-stats">
                <p-badge [value]="section.tableCount" severity="info"></p-badge>
                <span class="stats-text">{{ section.tableCount }} bàn</span>
              </div>
            </div>
            
            <!-- Section actions -->
            <div class="section-actions">
              <button 
                pButton 
                icon="pi pi-plus" 
                class="p-button-text p-button-sm"
                pTooltip="Thêm bàn vào khu vực này"
                (click)="openCreateTableDialog(section.id)">
              </button>
              
              <button 
                pButton 
                icon="pi pi-cog" 
                class="p-button-text p-button-sm"
                pTooltip="Cấu hình khu vực"
                (click)="editSection(section.id)">
              </button>
            </div>
          </div>

          <!-- Drag & Drop container -->
          <div 
            class="section-content"
            cdkDropList
            [id]="section.id!"
            [cdkDropListData]="section.tables"
            [cdkDropListDisabled]="!viewOptions().enableDragDrop"
            (cdkDropListDropped)="onTableDrop($event)">
            
            <!-- Table cards with drag handles -->
            @for (table of section.tables; track trackByTableId($index, table)) {
              <div 
                class="table-wrapper"
                cdkDrag
                [cdkDragData]="table"
                [cdkDragDisabled]="!viewOptions().enableDragDrop"
                [attr.data-table-id]="table.id"
                (contextmenu)="onTableContextMenu($event, table)">
                
                <!-- Drag preview -->
                <div class="drag-preview" *cdkDragPreview>
                  <div class="table-preview">
                    <div class="table-number">{{ table.tableNumber }}</div>
                    <div class="table-status">{{ getStatusConfig(table.status).label }}</div>
                  </div>
                </div>

                <!-- Drag placeholder -->
                <div class="drag-placeholder" *cdkDragPlaceholder></div>

                <!-- Table card component -->
                <app-table-card
                  [table]="table"
                  [statusConfig]="getStatusConfig(table.status)"
                  [showDetails]="viewOptions().showTableDetails"
                  [isSelected]="selectedTable()?.id === table.id"
                  [isDragActive]="dragInProgress()"
                  (click)="onTableClick(table)"
                  (statusChange)="onTableStatusChange(table, $event)"
                  (edit)="openEditTableDialog(table.id!)"
                  (delete)="onTableDelete(table)">
                </app-table-card>

                <!-- Drag handle -->
                @if (viewOptions().enableDragDrop) {
                  <div class="drag-handle" cdkDragHandle>
                    <i class="pi pi-bars" pTooltip="Kéo để di chuyển"></i>
                  </div>
                }
              </div>
            }

            <!-- Empty section placeholder -->
            @if (section.tables.length === 0) {
              <div class="empty-section">
                <div class="empty-content">
                  <i class="pi pi-inbox empty-icon"></i>
                  <p>Chưa có bàn nào trong khu vực này</p>
                  <button 
                    pButton 
                    label="Thêm bàn đầu tiên" 
                    icon="pi pi-plus"
                    class="p-button-sm"
                    (click)="openCreateTableDialog(section.id)">
                  </button>
                </div>
              </div>
            }
          </div>
        </div>
      }
    </div>
  }

  <!-- Speed dial for quick actions -->
  <p-speedDial 
    [model]="speedDialActions" 
    direction="up" 
    [transitionDelay]="80"
    buttonClassName="p-button-help"
    [style]="{ position: 'fixed', right: '2rem', bottom: '2rem' }">
  </p-speedDial>

  <!-- Context menu for table actions -->
  <p-contextMenu [model]="contextMenuItems" #contextMenu></p-contextMenu>

  <!-- Quick actions popup -->
  @if (showQuickActions()) {
    <div 
      class="quick-actions-popup"
      [style.left.px]="quickActionsPosition().x"
      [style.top.px]="quickActionsPosition().y"
      (clickOutside)="showQuickActions.set(false)">
      
      <div class="quick-actions-header">
        <span>Bàn {{ selectedTable()?.tableNumber }}</span>
        <button 
          pButton 
          icon="pi pi-times" 
          class="p-button-text p-button-sm"
          (click)="showQuickActions.set(false)">
        </button>
      </div>
      
      <div class="quick-actions-content">
        <!-- Status change buttons -->
        <div class="status-actions">
          @for (status of Object.values(TableStatus); track status) {
            @if (status !== selectedTable()?.status) {
              <button 
                pButton 
                [label]="getStatusConfig(status).label"
                [icon]="getStatusConfig(status).icon"
                [severity]="getStatusConfig(status).severity"
                class="p-button-sm p-button-outlined status-btn"
                (click)="changeTableStatus(status)">
              </button>
            }
          }
        </div>

        <p-divider></p-divider>

        <!-- Action buttons -->
        <div class="action-buttons">
          <button 
            pButton 
            label="Chỉnh sửa" 
            icon="pi pi-pencil"
            class="p-button-sm p-button-text"
            (click)="editSelectedTable()">
          </button>
          
          <button 
            pButton 
            label="Xóa" 
            icon="pi pi-trash"
            class="p-button-sm p-button-text p-button-danger"
            (click)="deleteSelectedTable()">
          </button>
        </div>
      </div>
    </div>
  }

  <!-- Real-time connection status -->
  <div class="connection-status" [class]="getConnectionStatusClass()">
    @if (hubConnection?.state === 'Connected') {
      <i class="pi pi-circle-on text-success"></i>
      <span>Kết nối thời gian thực</span>
    } @else {
      <i class="pi pi-circle-off text-warning"></i>
      <span>Không có kết nối thời gian thực</span>
    }
  </div>

  <!-- View options sidebar -->
  @if (showViewOptions()) {
    <div class="view-options-sidebar">
      <div class="sidebar-header">
        <h3>Tùy chọn hiển thị</h3>
        <button 
          pButton 
          icon="pi pi-times" 
          class="p-button-text"
          (click)="showViewOptions.set(false)">
        </button>
      </div>
      
      <div class="sidebar-content">
        <!-- Display options -->
        <div class="option-group">
          <h4>Hiển thị</h4>
          <div class="form-field">
            <p-checkbox 
              [(ngModel)]="viewOptions().showEmptySections"
              binary="true"
              label="Hiển thị khu vực trống"
              (onChange)="updateViewOptions()">
            </p-checkbox>
          </div>
          
          <div class="form-field">
            <p-checkbox 
              [(ngModel)]="viewOptions().showTableDetails"
              binary="true"
              label="Hiển thị chi tiết bàn"
              (onChange)="updateViewOptions()">
            </p-checkbox>
          </div>
        </div>

        <!-- Interaction options -->
        <div class="option-group">
          <h4>Tương tác</h4>
          <div class="form-field">
            <p-checkbox 
              [(ngModel)]="viewOptions().enableDragDrop"
              binary="true"
              label="Cho phép kéo thả"
              (onChange)="updateViewOptions()">
            </p-checkbox>
          </div>
        </div>

        <!-- Auto refresh options -->
        <div class="option-group">
          <h4>Tự động làm mới</h4>
          <div class="form-field">
            <p-checkbox 
              [(ngModel)]="viewOptions().autoRefresh"
              binary="true"
              label="Tự động làm mới dữ liệu"
              (onChange)="updateViewOptions()">
            </p-checkbox>
          </div>
          
          @if (viewOptions().autoRefresh) {
            <div class="form-field">
              <label>Chu kỳ làm mới (giây)</label>
              <p-inputNumber
                [(ngModel)]="viewOptions().refreshInterval"
                [min]="5"
                [max]="300"
                suffix=" giây"
                (onInput)="updateViewOptions()">
              </p-inputNumber>
            </div>
          }
        </div>
      </div>
    </div>
  }
</div>
```

### SCSS Styles (Level 3)

```scss
// File: angular/src/app/features/table-management/table-layout-kanban/table-layout-kanban.component.scss
.table-layout-kanban {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: #f8fafc;
  position: relative;

  .kanban-header {
    background: white;
    border-bottom: 1px solid #e2e8f0;
    padding: 1.5rem 2rem;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

    .header-content {
      display: flex;
      justify-content: space-between;
      align-items: center;
      max-width: 1400px;
      margin: 0 auto;

      h1 {
        margin: 0;
        color: #1e293b;
        font-size: 1.875rem;
        font-weight: 700;
      }

      .stats-summary {
        display: flex;
        gap: 1rem;

        .stat-card {
          background: white;
          border-radius: 0.5rem;
          padding: 1rem 1.5rem;
          text-align: center;
          border: 2px solid transparent;
          transition: all 0.2s;
          min-width: 80px;

          .stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
          }

          .stat-label {
            font-size: 0.875rem;
            color: #64748b;
          }

          &.total {
            border-color: #e2e8f0;
            .stat-value { color: #475569; }
          }

          &.available {
            border-color: #10b981;
            .stat-value { color: #10b981; }
          }

          &.occupied {
            border-color: #f59e0b;
            .stat-value { color: #f59e0b; }
          }

          &.reserved {
            border-color: #3b82f6;
            .stat-value { color: #3b82f6; }
          }

          &.maintenance {
            border-color: #ef4444;
            .stat-value { color: #ef4444; }
          }
        }
      }

      .header-controls {
        display: flex;
        align-items: center;
        gap: 1rem;
      }
    }
  }

  .loading-skeleton {
    padding: 2rem;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;

    .skeleton-section {
      .skeleton-tables {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
        gap: 1rem;
        margin-top: 1rem;
      }
    }
  }

  .kanban-board {
    flex: 1;
    overflow-x: auto;
    overflow-y: hidden;
    padding: 2rem;

    display: flex;
    gap: 2rem;
    min-height: calc(100vh - 200px);

    &.drag-disabled {
      .table-wrapper {
        cursor: default;
        
        .drag-handle {
          display: none;
        }
      }
    }

    .kanban-section-container {
      min-width: 300px;
      max-width: 400px;
      background: white;
      border-radius: 0.75rem;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      display: flex;
      flex-direction: column;
      transition: all 0.3s ease;

      &.inactive {
        opacity: 0.6;
        .section-header h3::after {
          content: " (Không hoạt động)";
          color: #ef4444;
          font-size: 0.875rem;
        }
      }

      .section-header {
        padding: 1.5rem;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;

        .section-title {
          flex: 1;

          h3 {
            margin: 0 0 0.5rem 0;
            color: #1e293b;
            font-size: 1.25rem;
            font-weight: 600;
          }

          .section-description {
            margin: 0 0 0.75rem 0;
            color: #64748b;
            font-size: 0.875rem;
          }

          .section-stats {
            display: flex;
            align-items: center;
            gap: 0.5rem;

            .stats-text {
              color: #64748b;
              font-size: 0.875rem;
            }
          }
        }

        .section-actions {
          display: flex;
          gap: 0.5rem;
        }
      }

      .section-content {
        flex: 1;
        padding: 1rem;
        min-height: 200px;
        display: flex;
        flex-direction: column;
        gap: 1rem;

        // CDK Drag & Drop styles
        &.cdk-drop-list-dragging {
          transition: transform 250ms cubic-bezier(0, 0, 0.2, 1);
        }

        .table-wrapper {
          position: relative;
          transition: all 0.2s ease;

          &.cdk-drag-preview {
            box-sizing: border-box;
            border-radius: 0.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            transform: rotate(2deg);
          }

          &.cdk-drag-animating {
            transition: transform 300ms cubic-bezier(0, 0, 0.2, 1);
          }

          &:not(.cdk-drag-disabled) {
            cursor: grab;

            &:hover {
              transform: translateY(-2px);
              box-shadow: 0 8px 12px -2px rgba(0, 0, 0, 0.15);

              .drag-handle {
                opacity: 1;
              }
            }

            &:active {
              cursor: grabbing;
            }
          }

          .drag-handle {
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            border-radius: 0.25rem;
            padding: 0.25rem;
            opacity: 0;
            transition: opacity 0.2s;
            z-index: 10;

            i {
              font-size: 0.875rem;
            }
          }

          .drag-placeholder {
            background: #e2e8f0;
            border: 2px dashed #cbd5e1;
            border-radius: 0.5rem;
            min-height: 120px;
            margin: 0.5rem 0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #64748b;
            font-size: 0.875rem;

            &::before {
              content: "Thả bàn vào đây";
            }
          }
        }

        .empty-section {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 200px;

          .empty-content {
            text-align: center;
            color: #64748b;

            .empty-icon {
              font-size: 3rem;
              margin-bottom: 1rem;
              color: #cbd5e1;
            }

            p {
              margin-bottom: 1.5rem;
              font-size: 0.875rem;
            }
          }
        }
      }
    }
  }

  // Quick actions popup
  .quick-actions-popup {
    position: fixed;
    background: white;
    border-radius: 0.5rem;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    border: 1px solid #e2e8f0;
    z-index: 1000;
    min-width: 250px;
    max-width: 300px;

    .quick-actions-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem;
      border-bottom: 1px solid #e2e8f0;
      font-weight: 600;
      color: #1e293b;
    }

    .quick-actions-content {
      padding: 1rem;

      .status-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
        margin-bottom: 1rem;

        .status-btn {
          flex: 1;
          min-width: 110px;
        }
      }

      .action-buttons {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;

        button {
          justify-content: flex-start;
        }
      }
    }
  }

  // Connection status indicator
  .connection-status {
    position: fixed;
    bottom: 1rem;
    left: 1rem;
    background: white;
    padding: 0.5rem 1rem;
    border-radius: 1.5rem;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.875rem;
    z-index: 100;

    &.connected {
      border-left: 4px solid #10b981;
    }

    &.disconnected {
      border-left: 4px solid #f59e0b;
    }
  }

  // View options sidebar
  .view-options-sidebar {
    position: fixed;
    right: 0;
    top: 0;
    height: 100vh;
    width: 350px;
    background: white;
    box-shadow: -4px 0 6px -1px rgba(0, 0, 0, 0.1);
    z-index: 1000;
    transform: translateX(100%);
    transition: transform 0.3s ease;

    &.open {
      transform: translateX(0);
    }

    .sidebar-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1.5rem;
      border-bottom: 1px solid #e2e8f0;

      h3 {
        margin: 0;
        color: #1e293b;
      }
    }

    .sidebar-content {
      padding: 1.5rem;
      overflow-y: auto;
      height: calc(100vh - 80px);

      .option-group {
        margin-bottom: 2rem;

        h4 {
          margin: 0 0 1rem 0;
          color: #374151;
          font-size: 1rem;
          font-weight: 600;
        }

        .form-field {
          margin-bottom: 1rem;

          label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-size: 0.875rem;
            font-weight: 500;
          }
        }
      }
    }
  }

  // Animations
  @keyframes tableMoving {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
  }

  @keyframes statusChanged {
    0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.7); }
    50% { transform: scale(1.1); box-shadow: 0 0 0 10px rgba(59, 130, 246, 0); }
    100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
  }

  .table-moving {
    animation: tableMoving 0.3s ease-in-out;
  }

  .status-changed {
    animation: statusChanged 1s ease-in-out;
  }

  // Responsive design
  @media (max-width: 768px) {
    .kanban-header {
      padding: 1rem;

      .header-content {
        flex-direction: column;
        gap: 1rem;
        align-items: stretch;

        .stats-summary {
          overflow-x: auto;
          padding-bottom: 0.5rem;
        }

        .header-controls {
          justify-content: center;
        }
      }
    }

    .kanban-board {
      padding: 1rem;
      gap: 1rem;

      .kanban-section-container {
        min-width: 280px;
      }
    }

    .view-options-sidebar {
      width: 100vw;
    }
  }
}
```

## Key Features của Level 3

### 1. Advanced Drag & Drop với Angular CDK
- **cdkDrag và cdkDrop**: Drag & drop functionality nâng cao
- **Custom drag preview**: Preview tùy chỉnh khi kéo
- **Drop zones**: Vùng thả linh hoạt với visual feedback
- **Animation feedback**: Hiệu ứng mượt mà khi di chuyển

### 2. Real-time Updates với SignalR
- **Hub connection**: Kết nối real-time với backend
- **Live data sync**: Đồng bộ dữ liệu thời gian thực
- **Connection fallback**: Fallback về polling nếu SignalR fails
- **Real-time events**: Xử lý events từ server

### 3. Performance Optimization
- **Angular Signals**: State management hiệu suất cao
- **Computed values**: Reactive computations
- **Virtual scrolling**: Tối ưu cho danh sách lớn
- **Change detection**: OnPush strategies

### 4. Advanced UI Components
- **Speed Dial**: Quick actions floating button
- **Context Menu**: Right-click menu với actions
- **Skeleton Loading**: Loading states đẹp mắt
- **Dynamic tooltips**: Tooltips thông minh

### 5. Interactive Features
- **Multi-select**: Chọn nhiều items cùng lúc
- **Keyboard shortcuts**: Hỗ trợ phím tắt
- **Touch gestures**: Hỗ trợ mobile gestures
- **Visual feedback**: Animations và transitions

### 6. Customizable Views
- **View options**: Tùy chỉnh hiển thị
- **Filter và sort**: Lọc và sắp xếp dữ liệu
- **Layout switching**: Chuyển đổi layout
- **Responsive design**: Tối ưu cho mọi màn hình

## Best Practices cho Level 3

1. **Performance**: Sử dụng OnPush change detection và immutable data
2. **Memory Management**: Proper cleanup của subscriptions và listeners
3. **Error Handling**: Robust error handling cho real-time connections
4. **Accessibility**: ARIA labels và keyboard navigation
5. **Testing**: Unit tests và integration tests cho complex interactions
6. **Code Organization**: Modular components và services
7. **TypeScript**: Strong typing cho complex data structures