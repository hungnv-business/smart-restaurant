import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { DragDropModule, CdkDragDrop } from '@angular/cdk/drag-drop';
import { MessageService } from 'primeng/api';
import { of, throwError } from 'rxjs';

import { TableLayoutKanbanComponent } from './table-layout-kanban/table-layout-kanban.component';
import { TableService } from '../../../proxy/table-management/tables/table.service';
import { LayoutSectionService } from '../../../proxy/table-management/layout-sections/layout-section.service';
import {
  TableDto,
  CreateTableDto,
  UpdateTableDto,
  AssignTableToSectionDto,
} from '../../../proxy/table-management/tables/dto/models';
import { LayoutSectionDto } from '../../../proxy/table-management/layout-sections/dto/models';
import { TableStatus } from '../../../proxy/table-status.enum';

describe('Table Positioning Integration Tests', () => {
  let component: TableLayoutKanbanComponent;
  let fixture: ComponentFixture<TableLayoutKanbanComponent>;
  let mockTableService: jasmine.SpyObj<TableService>;
  let mockLayoutSectionService: jasmine.SpyObj<LayoutSectionService>;
  let mockMessageService: jasmine.SpyObj<MessageService>;

  const mockLayoutSections: LayoutSectionDto[] = [
    {
      id: 'section1',
      sectionName: 'Khu vực 1',
      description: 'Mô tả khu vực 1',
      displayOrder: 1,
      isActive: true,
      creationTime: '2024-01-01T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
    {
      id: 'section2',
      sectionName: 'Khu vực 2',
      description: 'Mô tả khu vực 2',
      displayOrder: 2,
      isActive: true,
      creationTime: '2024-01-02T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
    {
      id: 'section3',
      sectionName: 'Khu VIP',
      description: 'Khu vực VIP cao cấp',
      displayOrder: 3,
      isActive: true,
      creationTime: '2024-01-03T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
  ];

  const mockTables: TableDto[] = [
    {
      id: 'table1',
      tableNumber: 'B01',
      displayOrder: 1,
      status: TableStatus.Available,
      isActive: true,
      layoutSectionId: 'section1',
      layoutSectionName: 'Khu vực 1',
      creationTime: '2024-01-01T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
    {
      id: 'table2',
      tableNumber: 'B02',
      displayOrder: 2,
      status: TableStatus.Occupied,
      isActive: true,
      layoutSectionId: 'section1',
      layoutSectionName: 'Khu vực 1',
      creationTime: '2024-01-01T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
    {
      id: 'table3',
      tableNumber: 'V01',
      displayOrder: 1,
      status: TableStatus.Reserved,
      isActive: true,
      layoutSectionId: 'section3',
      layoutSectionName: 'Khu VIP',
      creationTime: '2024-01-03T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
  ];

  beforeEach(async () => {
    const tableServiceSpy = jasmine.createSpyObj('TableService', [
      'getAllTablesOrdered',
      'assignToSection',
      'updateDisplayOrder',
      'create',
      'update',
      'delete',
    ]);
    const layoutSectionServiceSpy = jasmine.createSpyObj('LayoutSectionService', ['getList']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [TableLayoutKanbanComponent, DragDropModule, NoopAnimationsModule],
      providers: [
        { provide: TableService, useValue: tableServiceSpy },
        { provide: LayoutSectionService, useValue: layoutSectionServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(TableLayoutKanbanComponent);
    component = fixture.componentInstance;
    mockTableService = TestBed.inject(TableService) as jasmine.SpyObj<TableService>;
    mockLayoutSectionService = TestBed.inject(
      LayoutSectionService,
    ) as jasmine.SpyObj<LayoutSectionService>;
    mockMessageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;

    // Setup default service mocks
    mockLayoutSectionService.getList.and.returnValue(of(mockLayoutSections));
    mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));
  });

  describe('ABP Service Integration - Table Section Assignment', () => {
    it('should successfully assign table to different section through ABP service', async () => {
      // Arrange
      await component.ngOnInit();
      const sourceTable = mockTables[0]; // B01 from section1
      const targetSectionId = 'section2';

      mockTableService.assignToSection.and.returnValue(of(void 0));
      mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));

      const mockDragEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: component.sectionTables['section2'], id: targetSectionId },
        previousIndex: 0,
        currentIndex: 0,
        item: { data: sourceTable },
      } as any as CdkDragDrop<TableDto[]>;

      // Act
      await component.onTableDrop(mockDragEvent);

      // Assert - Verify ABP service was called with correct parameters
      expect(mockTableService.assignToSection).toHaveBeenCalledWith(
        sourceTable.id!,
        jasmine.objectContaining({
          layoutSectionId: targetSectionId,
        } as AssignTableToSectionDto),
      );
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'success',
        summary: 'Success',
        detail: 'Table moved to different section successfully',
        life: 3000,
      });
    });

    it('should handle ABP service assignment validation errors', async () => {
      // Arrange
      await component.ngOnInit();
      const sourceTable = mockTables[0];
      const targetSectionId = 'invalid-section';

      const validationError = new Error('Validation failed: Section does not exist');
      mockTableService.assignToSection.and.returnValue(throwError(() => validationError));
      mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));

      const mockDragEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: [], id: targetSectionId },
        previousIndex: 0,
        currentIndex: 0,
        item: { data: sourceTable },
      } as any as CdkDragDrop<TableDto[]>;

      // Act
      await component.onTableDrop(mockDragEvent);

      // Assert
      expect(mockTableService.assignToSection).toHaveBeenCalledWith(
        sourceTable.id!,
        jasmine.objectContaining({
          layoutSectionId: targetSectionId,
        }),
      );
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'error',
        summary: 'Error',
        detail: 'Failed to move table to different section',
        life: 5000,
      });
      // Should revert changes by reloading data
      expect(mockTableService.getAllTablesOrdered).toHaveBeenCalled();
    });

    it('should successfully update table display order within same section', async () => {
      // Arrange
      await component.ngOnInit();
      const tableToMove = mockTables[0];
      const newDisplayOrder = 2;

      mockTableService.updateDisplayOrder.and.returnValue(of(void 0));

      const mockDragEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: component.sectionTables['section1'], id: 'section1' },
        previousIndex: 0,
        currentIndex: 1,
        item: { data: tableToMove },
      } as any as CdkDragDrop<TableDto[]>;

      // Act
      await component.onTableDrop(mockDragEvent);

      // Assert
      expect(mockTableService.updateDisplayOrder).toHaveBeenCalledWith(
        tableToMove.id!,
        jasmine.objectContaining({
          displayOrder: newDisplayOrder,
        } as UpdateTableDto),
      );
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'success',
        summary: 'Success',
        detail: 'Table order updated successfully',
        life: 3000,
      });
    });
  });

  describe('Table Creation Integration with ABP Services', () => {
    it('should create new table through ABP service with Vietnamese validation', async () => {
      // Arrange
      await component.ngOnInit();
      component.selectedSectionId = 'section1';

      const newTableData: CreateTableDto = {
        tableNumber: 'B03',
        displayOrder: 3,
        status: TableStatus.Available,
        isActive: true,
        layoutSectionId: 'section1',
      };

      const createdTable: TableDto = {
        id: 'table4',
        ...newTableData,
        layoutSectionName: 'Khu vực 1',
        creationTime: '2024-01-04T00:00:00Z',
        creatorId: 'user1',
        lastModificationTime: null,
        lastModifierId: null,
        isDeleted: false,
        deleterId: null,
        deletionTime: null,
      };

      component.newTable = newTableData;
      mockTableService.getAllTablesOrdered.and.returnValue(of([])); // No existing tables for duplicate check
      mockTableService.create.and.returnValue(of(createdTable));
      mockTableService.getAllTablesOrdered.and.returnValue(of([...mockTables, createdTable]));

      // Act
      await component.createTable();

      // Assert
      expect(mockTableService.create).toHaveBeenCalledWith(newTableData);
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'success',
        summary: 'Success',
        detail: 'Đã thêm bàn mới thành công',
        life: 3000,
      });
      expect(component.showCreateDialog).toBe(false);
    });

    it('should validate Vietnamese table numbers correctly', async () => {
      // Arrange
      await component.ngOnInit();
      component.selectedSectionId = 'section3';

      const vietnameseTableNumbers = ['VIP01', 'V01', 'Bàn-01', 'Phòng-A1'];

      for (const tableNumber of vietnameseTableNumbers) {
        // Setup new table data
        component.newTable = {
          tableNumber,
          displayOrder: 1,
          status: TableStatus.Available,
          isActive: true,
          layoutSectionId: 'section3',
        };

        const createdTable: TableDto = {
          id: `table-${tableNumber}`,
          ...component.newTable,
          layoutSectionName: 'Khu VIP',
          creationTime: '2024-01-04T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        };

        mockTableService.getAllTablesOrdered.and.returnValue(of([])); // No duplicates
        mockTableService.create.and.returnValue(of(createdTable));

        // Act
        await component.createTable();

        // Assert
        expect(mockTableService.create).toHaveBeenCalledWith(
          jasmine.objectContaining({
            tableNumber: tableNumber,
          }),
        );
        expect(component.isTableNumberValid()).toBe(true);
      }
    });

    it('should prevent creation of duplicate table numbers', async () => {
      // Arrange
      await component.ngOnInit();
      component.selectedSectionId = 'section1';
      component.newTable = {
        tableNumber: 'B01', // Already exists in mockTables
        displayOrder: 3,
        status: TableStatus.Available,
        isActive: true,
        layoutSectionId: 'section1',
      };

      mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));

      // Act
      await component.createTable();

      // Assert
      expect(mockTableService.create).not.toHaveBeenCalled();
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'warn',
        summary: 'Cảnh báo',
        detail: 'Số bàn này đã tồn tại. Vui lòng chọn số bàn khác.',
        life: 3000,
      });
    });
  });

  describe('Table Status Management Integration', () => {
    it('should validate table status transitions correctly', () => {
      // Test status display and severity mappings
      expect(component.getStatusText(TableStatus.Available)).toBe('Available');
      expect(component.getStatusText(TableStatus.Occupied)).toBe('Occupied');
      expect(component.getStatusText(TableStatus.Reserved)).toBe('Reserved');
      expect(component.getStatusText(TableStatus.Cleaning)).toBe('Cleaning');

      expect(component.getStatusSeverity(TableStatus.Available)).toBe('success');
      expect(component.getStatusSeverity(TableStatus.Occupied)).toBe('danger');
      expect(component.getStatusSeverity(TableStatus.Reserved)).toBe('warning');
      expect(component.getStatusSeverity(TableStatus.Cleaning)).toBe('info');
    });

    it('should apply correct CSS classes based on table status', () => {
      const testTable = { ...mockTables[0] };

      testTable.status = TableStatus.Available;
      expect(component.getTableCardClass(testTable)).toBe('table-card available');

      testTable.status = TableStatus.Occupied;
      expect(component.getTableCardClass(testTable)).toBe('table-card occupied');

      testTable.status = TableStatus.Reserved;
      expect(component.getTableCardClass(testTable)).toBe('table-card reserved');

      testTable.status = TableStatus.Cleaning;
      expect(component.getTableCardClass(testTable)).toBe('table-card cleaning');
    });
  });

  describe('Data Loading and Error Handling Integration', () => {
    it('should handle ABP service loading errors gracefully', async () => {
      // Test layout section service error
      mockLayoutSectionService.getList.and.returnValue(
        throwError(() => new Error('Network error')),
      );

      await component.loadData();

      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'error',
        summary: 'Error',
        detail: 'Failed to load data',
        life: 5000,
      });

      // Test table service error
      mockLayoutSectionService.getList.and.returnValue(of(mockLayoutSections));
      mockTableService.getAllTablesOrdered.and.returnValue(
        throwError(() => new Error('Database error')),
      );

      await component.loadData();

      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'error',
        summary: 'Error',
        detail: 'Failed to load data',
        life: 5000,
      });
    });

    it('should properly reload data after successful operations', async () => {
      // Arrange
      await component.ngOnInit();
      expect(mockTableService.getAllTablesOrdered).toHaveBeenCalledTimes(1);

      // Act - Refresh data
      await component.refresh();

      // Assert
      expect(mockLayoutSectionService.getList).toHaveBeenCalledTimes(2);
      expect(mockTableService.getAllTablesOrdered).toHaveBeenCalledTimes(2);
    });
  });

  describe('Vietnamese Restaurant Workflow Integration', () => {
    it('should handle Vietnamese section names and table numbers correctly', async () => {
      // Arrange - Vietnamese layout sections
      const vietnameseSections: LayoutSectionDto[] = [
        {
          id: 'section-vip',
          sectionName: 'Phòng VIP',
          description: 'Khu vực VIP dành cho khách hàng đặc biệt',
          displayOrder: 1,
          isActive: true,
          creationTime: '2024-01-01T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        },
        {
          id: 'section-garden',
          sectionName: 'Sân vườn',
          description: 'Khu vực ngoài trời thoáng mát',
          displayOrder: 2,
          isActive: true,
          creationTime: '2024-01-02T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        },
      ];

      const vietnameseTables: TableDto[] = [
        {
          id: 'table-vip1',
          tableNumber: 'VIP-01',
          displayOrder: 1,
          status: TableStatus.Available,
          isActive: true,
          layoutSectionId: 'section-vip',
          layoutSectionName: 'Phòng VIP',
          creationTime: '2024-01-01T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        },
        {
          id: 'table-garden1',
          tableNumber: 'SV-01',
          displayOrder: 1,
          status: TableStatus.Available,
          isActive: true,
          layoutSectionId: 'section-garden',
          layoutSectionName: 'Sân vườn',
          creationTime: '2024-01-02T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        },
      ];

      mockLayoutSectionService.getList.and.returnValue(of(vietnameseSections));
      mockTableService.getAllTablesOrdered.and.returnValue(of(vietnameseTables));

      // Act
      await component.ngOnInit();

      // Assert
      expect(component.layoutSections).toEqual(vietnameseSections);
      expect(component.sectionTables['section-vip']).toEqual([vietnameseTables[0]]);
      expect(component.sectionTables['section-garden']).toEqual([vietnameseTables[1]]);

      // Test Vietnamese table assignment
      mockTableService.assignToSection.and.returnValue(of(void 0));
      const mockDragEvent = {
        previousContainer: { data: component.sectionTables['section-vip'] },
        container: { data: component.sectionTables['section-garden'], id: 'section-garden' },
        previousIndex: 0,
        currentIndex: 0,
        item: { data: vietnameseTables[0] },
      } as any as CdkDragDrop<TableDto[]>;

      await component.onTableDrop(mockDragEvent);

      expect(mockTableService.assignToSection).toHaveBeenCalledWith(
        'table-vip1',
        jasmine.objectContaining({
          layoutSectionId: 'section-garden',
        }),
      );
    });
  });
});
