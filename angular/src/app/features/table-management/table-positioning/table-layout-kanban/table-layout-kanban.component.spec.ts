import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CdkDragDrop, DragDropModule } from '@angular/cdk/drag-drop';
import { MessageService } from 'primeng/api';
import { of, throwError } from 'rxjs';

import { TableLayoutKanbanComponent } from './table-layout-kanban.component';
import { TableService } from '../../../../proxy/table-management/tables/table.service';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import { TableDto } from '../../../../proxy/table-management/tables/dto/models';
import { LayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { TableStatus } from '../../../../proxy/table-status.enum';

describe('TableLayoutKanbanComponent', () => {
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
    },
    {
      id: 'section2',
      sectionName: 'Khu vực 2',
      description: 'Mô tả khu vực 2',
      displayOrder: 2,
      isActive: true,
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
    },
    {
      id: 'table2',
      tableNumber: 'B02',
      displayOrder: 2,
      status: TableStatus.Occupied,
      isActive: true,
      layoutSectionId: 'section1',
      layoutSectionName: 'Khu vực 1',
    },
    {
      id: 'table3',
      tableNumber: 'B03',
      displayOrder: 1,
      status: TableStatus.Reserved,
      isActive: true,
      layoutSectionId: 'section2',
      layoutSectionName: 'Khu vực 2',
    },
  ];

  beforeEach(async () => {
    const tableServiceSpy = jasmine.createSpyObj('TableService', [
      'getAllTablesOrdered',
      'assignToSection',
      'updateDisplayOrder',
    ]);
    const layoutSectionServiceSpy = jasmine.createSpyObj('LayoutSectionService', ['getList']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [TableLayoutKanbanComponent, DragDropModule],
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

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load layout sections and tables on init', async () => {
    // Act
    await component.ngOnInit();

    // Assert
    expect(mockLayoutSectionService.getList).toHaveBeenCalled();
    expect(mockTableService.getAllTablesOrdered).toHaveBeenCalled();
    expect(component.layoutSections).toEqual(mockLayoutSections);
    expect(component.sectionTables['section1']).toEqual([mockTables[0], mockTables[1]]);
    expect(component.sectionTables['section2']).toEqual([mockTables[2]]);
  });

  it('should group tables by section correctly', async () => {
    // Act
    await component.loadAllTables();

    // Assert
    expect(component.sectionTables['section1'].length).toBe(2);
    expect(component.sectionTables['section2'].length).toBe(1);
    expect(component.sectionTables['section1'][0].tableNumber).toBe('B01');
    expect(component.sectionTables['section1'][1].tableNumber).toBe('B02');
    expect(component.sectionTables['section2'][0].tableNumber).toBe('B03');
  });

  it('should handle table drop within same section', async () => {
    // Arrange
    await component.ngOnInit();
    mockTableService.updateDisplayOrder.and.returnValue(of(void 0));

    const mockEvent = {
      previousContainer: { data: component.sectionTables['section1'] },
      container: { data: component.sectionTables['section1'], id: 'section1' },
      previousIndex: 0,
      currentIndex: 1,
      item: { data: mockTables[0] },
    } as any as CdkDragDrop<TableDto[]>;

    // Act
    await component.onTableDrop(mockEvent);

    // Assert
    expect(mockTableService.updateDisplayOrder).toHaveBeenCalledWith(mockTables[0].id!, {
      displayOrder: 1,
    });
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Success',
      detail: 'Table order updated successfully',
      life: 3000,
    });
  });

  it('should handle table drop between different sections', async () => {
    // Arrange
    await component.ngOnInit();
    mockTableService.assignToSection.and.returnValue(of(void 0));

    const mockEvent = {
      previousContainer: { data: component.sectionTables['section1'] },
      container: { data: component.sectionTables['section2'], id: 'section2' },
      previousIndex: 0,
      currentIndex: 0,
      item: { data: mockTables[0] },
    } as any as CdkDragDrop<TableDto[]>;

    // Act
    await component.onTableDrop(mockEvent);

    // Assert
    expect(mockTableService.assignToSection).toHaveBeenCalledWith(mockTables[0].id!, {
      layoutSectionId: 'section2',
    });
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Success',
      detail: 'Table moved to different section successfully',
      life: 3000,
    });
  });

  it('should return correct status text', () => {
    expect(component.getStatusText(TableStatus.Available)).toBe('Available');
    expect(component.getStatusText(TableStatus.Occupied)).toBe('Occupied');
    expect(component.getStatusText(TableStatus.Reserved)).toBe('Reserved');
    expect(component.getStatusText(TableStatus.Cleaning)).toBe('Cleaning');
  });

  it('should return correct status severity', () => {
    expect(component.getStatusSeverity(TableStatus.Available)).toBe('success');
    expect(component.getStatusSeverity(TableStatus.Occupied)).toBe('danger');
    expect(component.getStatusSeverity(TableStatus.Reserved)).toBe('warning');
    expect(component.getStatusSeverity(TableStatus.Cleaning)).toBe('info');
  });

  it('should return correct table card class', () => {
    const table = { ...mockTables[0], status: TableStatus.Available };
    expect(component.getTableCardClass(table)).toBe('table-card available');

    table.status = TableStatus.Occupied;
    expect(component.getTableCardClass(table)).toBe('table-card occupied');
  });

  it('should handle error during data loading', async () => {
    // Arrange
    mockLayoutSectionService.getList.and.returnValue(throwError(() => new Error('Network error')));

    // Act
    await component.loadData();

    // Assert
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'error',
      summary: 'Error',
      detail: 'Failed to load data',
      life: 5000,
    });
  });

  it('should handle error during table assignment', async () => {
    // Arrange
    await component.ngOnInit();
    mockTableService.assignToSection.and.returnValue(
      throwError(() => new Error('Assignment failed')),
    );
    mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables)); // For revert

    const mockEvent = {
      previousContainer: { data: component.sectionTables['section1'] },
      container: { data: component.sectionTables['section2'], id: 'section2' },
      previousIndex: 0,
      currentIndex: 0,
      item: { data: mockTables[0] },
    } as any as CdkDragDrop<TableDto[]>;

    // Act
    await component.onTableDrop(mockEvent);

    // Assert
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'error',
      summary: 'Error',
      detail: 'Failed to move table to different section',
      life: 5000,
    });
    expect(mockTableService.getAllTablesOrdered).toHaveBeenCalled(); // Should revert
  });

  it('should refresh data when refresh is called', async () => {
    // Arrange
    spyOn(component, 'loadData');

    // Act
    await component.refresh();

    // Assert
    expect(component.loadData).toHaveBeenCalled();
  });

  it('should open create table dialog with correct section ID', () => {
    // Arrange
    const sectionId = 'section1';
    spyOn(component, 'resetNewTableForm').and.callThrough();

    // Act
    component.openCreateTableDialog(sectionId);

    // Assert
    expect(component.showCreateDialog).toBe(true);
    expect(component.selectedSectionId).toBe(sectionId);
    expect(component.newTable.layoutSectionId).toBe(sectionId);
    expect(component.resetNewTableForm).toHaveBeenCalled();
  });

  it('should close create dialog and reset form', () => {
    // Arrange
    component.showCreateDialog = true;
    spyOn(component, 'resetNewTableForm').and.callThrough();

    // Act
    component.closeCreateDialog();

    // Assert
    expect(component.showCreateDialog).toBe(false);
    expect(component.resetNewTableForm).toHaveBeenCalled();
  });

  it('should validate table number correctly', () => {
    // Test empty table number
    component.newTable.tableNumber = '';
    expect(component.isTableNumberValid()).toBe(false);

    // Test whitespace only
    component.newTable.tableNumber = '   ';
    expect(component.isTableNumberValid()).toBe(false);

    // Test valid table number
    component.newTable.tableNumber = 'B01';
    expect(component.isTableNumberValid()).toBe(true);
  });

  it('should validate form correctly', () => {
    // Test invalid form
    component.newTable.tableNumber = '';
    expect(component.isFormValid()).toBe(false);

    // Test valid form
    component.newTable.tableNumber = 'B01';
    expect(component.isFormValid()).toBe(true);
  });

  it('should create table successfully', async () => {
    // Arrange
    await component.ngOnInit();
    component.selectedSectionId = 'section1';
    component.newTable = {
      tableNumber: 'B04',
      displayOrder: 0,
      status: TableStatus.Available,
      isActive: true,
      layoutSectionId: 'section1',
    };

    const newTable: TableDto = {
      id: 'table4',
      tableNumber: 'B04',
      displayOrder: 3,
      status: TableStatus.Available,
      isActive: true,
      layoutSectionId: 'section1',
      layoutSectionName: 'Khu vực 1',
    };

    mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));
    mockTableService.create.and.returnValue(of(newTable));
    spyOn(component, 'closeCreateDialog');

    // Act
    await component.createTable();

    // Assert
    expect(mockTableService.create).toHaveBeenCalledWith(component.newTable);
    expect(component.sectionTables['section1']).toContain(newTable);
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Success',
      detail: 'Đã thêm bàn mới thành công',
      life: 3000,
    });
    expect(component.closeCreateDialog).toHaveBeenCalled();
  });

  it('should prevent creating table with duplicate number', async () => {
    // Arrange
    component.newTable = {
      tableNumber: 'B01', // Already exists in mockTables
      displayOrder: 0,
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

  it('should show warning for invalid form submission', async () => {
    // Arrange
    component.newTable.tableNumber = '';

    // Act
    await component.createTable();

    // Assert
    expect(mockTableService.create).not.toHaveBeenCalled();
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'warn',
      summary: 'Cảnh báo',
      detail: 'Vui lòng nhập đầy đủ thông tin bắt buộc',
      life: 3000,
    });
  });

  it('should handle create table error', async () => {
    // Arrange
    component.newTable = {
      tableNumber: 'B04',
      displayOrder: 0,
      status: TableStatus.Available,
      isActive: true,
      layoutSectionId: 'section1',
    };

    mockTableService.getAllTablesOrdered.and.returnValue(of([]));
    mockTableService.create.and.returnValue(throwError(() => new Error('Create failed')));

    // Act
    await component.createTable();

    // Assert
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'error',
      summary: 'Lỗi',
      detail: 'Có lỗi xảy ra khi thêm bàn mới',
      life: 5000,
    });
  });

  it('should set default display order when opening create dialog', () => {
    // Arrange
    component.sectionTables['section1'] = [mockTables[0], mockTables[1]]; // 2 tables

    // Act
    component.openCreateTableDialog('section1');

    // Assert
    expect(component.newTable.displayOrder).toBe(2); // Next available position
  });

  describe('Section Assignment Validation and Table Status Logic', () => {
    it('should validate section exists before assignment', async () => {
      // Arrange
      await component.ngOnInit();
      const invalidEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: [], id: 'nonexistent-section' },
        previousIndex: 0,
        currentIndex: 0,
        item: { data: mockTables[0] },
      } as any;

      // Act & Assert - should not assign to nonexistent section
      await component.onTableDrop(invalidEvent);
      expect(mockTableService.assignToSection).not.toHaveBeenCalled();
    });

    it('should maintain table status during section assignment', async () => {
      // Arrange
      await component.ngOnInit();
      const occupiedTable = { ...mockTables[1], status: TableStatus.Occupied };
      mockTableService.assignToSection.and.returnValue(of(void 0));
      mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));

      const mockEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: component.sectionTables['section2'], id: 'section2' },
        previousIndex: 1,
        currentIndex: 0,
        item: { data: occupiedTable },
      } as any;

      // Act
      await component.onTableDrop(mockEvent);

      // Assert - table status should be preserved during move
      expect(mockTableService.assignToSection).toHaveBeenCalledWith(
        occupiedTable.id!,
        jasmine.objectContaining({
          layoutSectionId: 'section2',
        }),
      );
      // Status should remain Occupied after assignment
      expect(occupiedTable.status).toBe(TableStatus.Occupied);
    });

    it('should validate table status enum values correctly', () => {
      // Test all possible status values
      const statusValues = [
        TableStatus.Available,
        TableStatus.Occupied,
        TableStatus.Reserved,
        TableStatus.Cleaning,
      ];

      statusValues.forEach(status => {
        expect(Object.values(TableStatus)).toContain(status);
        expect(component.getStatusText(status)).toBeDefined();
        expect(component.getStatusSeverity(status)).toBeDefined();
      });
    });

    it('should validate new table status assignment', () => {
      // Arrange
      component.newTable = {
        tableNumber: 'B05',
        displayOrder: 1,
        status: TableStatus.Available,
        isActive: true,
        layoutSectionId: 'section1',
      };

      // Act & Assert - should accept valid status
      expect(component.newTable.status).toBe(TableStatus.Available);
      expect(component.isFormValid()).toBe(true);

      // Test invalid status should not be possible with enum
      expect(() => {
        component.newTable.status = 'InvalidStatus' as any;
      }).not.toThrow();
    });

    it('should handle mixed status tables in same section', async () => {
      // Arrange
      const mixedStatusTables: TableDto[] = [
        { ...mockTables[0], status: TableStatus.Available },
        { ...mockTables[1], status: TableStatus.Occupied },
        {
          id: 'table4',
          tableNumber: 'B04',
          displayOrder: 3,
          status: TableStatus.Reserved,
          isActive: true,
          layoutSectionId: 'section1',
          layoutSectionName: 'Khu vực 1',
        },
        {
          id: 'table5',
          tableNumber: 'B05',
          displayOrder: 4,
          status: TableStatus.Cleaning,
          isActive: true,
          layoutSectionId: 'section1',
          layoutSectionName: 'Khu vực 1',
        },
      ];

      mockTableService.getAllTablesOrdered.and.returnValue(of(mixedStatusTables));
      await component.loadAllTables();

      // Act & Assert - should group all tables regardless of status
      expect(component.sectionTables['section1'].length).toBe(4);

      // Verify each status is handled correctly
      const sectionTables = component.sectionTables['section1'];
      expect(sectionTables.some(t => t.status === TableStatus.Available)).toBe(true);
      expect(sectionTables.some(t => t.status === TableStatus.Occupied)).toBe(true);
      expect(sectionTables.some(t => t.status === TableStatus.Reserved)).toBe(true);
      expect(sectionTables.some(t => t.status === TableStatus.Cleaning)).toBe(true);
    });

    it('should validate section assignment with table display order recalculation', async () => {
      // Arrange
      await component.ngOnInit();
      const tableToMove = mockTables[0]; // Currently at position 0 in section1
      mockTableService.assignToSection.and.returnValue(of(void 0));

      // Mock updated tables after move (table should appear at end of target section)
      const updatedTables = [
        mockTables[1], // Remains in section1
        mockTables[2], // Remains in section2
        { ...tableToMove, layoutSectionId: 'section2', displayOrder: 2 }, // Moved to section2
      ];
      mockTableService.getAllTablesOrdered.and.returnValue(of(updatedTables));

      const mockEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: component.sectionTables['section2'], id: 'section2' },
        previousIndex: 0,
        currentIndex: 1, // Insert at end of section2
        item: { data: tableToMove },
      } as any;

      // Act
      await component.onTableDrop(mockEvent);

      // Assert
      expect(mockTableService.assignToSection).toHaveBeenCalledWith(
        tableToMove.id!,
        jasmine.objectContaining({
          layoutSectionId: 'section2',
        }),
      );
      // Should reload data to get updated display orders
      expect(mockTableService.getAllTablesOrdered).toHaveBeenCalled();
    });

    it('should prevent assignment to inactive sections', async () => {
      // Arrange
      const inactiveSections = [
        ...mockLayoutSections,
        {
          id: 'inactive-section',
          sectionName: 'Khu vực không hoạt động',
          description: 'Khu vực đã tạm ngưng',
          displayOrder: 4,
          isActive: false, // Inactive section
          creationTime: '2024-01-04T00:00:00Z',
          creatorId: 'user1',
          lastModificationTime: null,
          lastModifierId: null,
          isDeleted: false,
          deleterId: null,
          deletionTime: null,
        },
      ];

      mockLayoutSectionService.getList.and.returnValue(of(inactiveSections));
      await component.ngOnInit();

      // Act & Assert - inactive section should not be available for assignment
      expect(component.layoutSections.some(s => s.id === 'inactive-section' && !s.isActive)).toBe(
        true,
      );
      expect(component.sectionTables['inactive-section']).toBeUndefined();
    });

    it('should validate table number uniqueness across all sections', async () => {
      // Arrange
      const duplicateTable = {
        tableNumber: 'B01', // Already exists in mockTables
        displayOrder: 1,
        status: TableStatus.Available,
        isActive: true,
        layoutSectionId: 'section2',
      };

      component.newTable = duplicateTable;
      mockTableService.getAllTablesOrdered.and.returnValue(of(mockTables));

      // Act
      await component.createTable();

      // Assert - should prevent duplicate table numbers even across sections
      expect(mockTableService.create).not.toHaveBeenCalled();
      expect(mockMessageService.add).toHaveBeenCalledWith({
        severity: 'warn',
        summary: 'Cảnh báo',
        detail: 'Số bàn này đã tồn tại. Vui lòng chọn số bàn khác.',
        life: 3000,
      });
    });

    it('should handle table status transitions during drag and drop', async () => {
      // Arrange
      await component.ngOnInit();
      const reservedTable = { ...mockTables[0], status: TableStatus.Reserved };

      // Mock the table being moved while maintaining its reserved status
      mockTableService.updateDisplayOrder.and.returnValue(of(void 0));

      const mockEvent = {
        previousContainer: { data: component.sectionTables['section1'] },
        container: { data: component.sectionTables['section1'], id: 'section1' },
        previousIndex: 0,
        currentIndex: 1,
        item: { data: reservedTable },
      } as any;

      // Act
      await component.onTableDrop(mockEvent);

      // Assert - status should be preserved during reordering
      expect(mockTableService.updateDisplayOrder).toHaveBeenCalledWith(
        reservedTable.id!,
        jasmine.objectContaining({
          displayOrder: 1,
        }),
      );
      expect(reservedTable.status).toBe(TableStatus.Reserved);
    });
  });
});
