import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { ConfirmationService } from 'primeng/api';
import { of, throwError } from 'rxjs';
import { DragDropModule } from '@angular/cdk/drag-drop';

import { LayoutSectionListComponent } from './layout-section-list.component';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import { LayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { ComponentBase } from '../../../../shared/base/component-base';

describe('LayoutSectionListComponent', () => {
  let component: LayoutSectionListComponent;
  let fixture: ComponentFixture<LayoutSectionListComponent>;
  let mockLayoutSectionService: jasmine.SpyObj<LayoutSectionService>;
  let mockConfirmationService: jasmine.SpyObj<ConfirmationService>;

  const mockLayoutSections: LayoutSectionDto[] = [
    {
      id: '1',
      sectionName: 'Dãy 1',
      description: 'Khu vực dãy 1',
      displayOrder: 1,
      isActive: true,
      creationTime: '2024-01-01T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null
    },
    {
      id: '2',
      sectionName: 'Khu VIP',
      description: 'Khu vực VIP cao cấp',
      displayOrder: 2,
      isActive: false,
      creationTime: '2024-01-02T00:00:00Z',
      creatorId: 'user1',
      lastModificationTime: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null
    }
  ];

  beforeEach(async () => {
    const layoutSectionServiceSpy = jasmine.createSpyObj('LayoutSectionService', [
      'getList', 'delete', 'update'
    ]);
    const confirmationServiceSpy = jasmine.createSpyObj('ConfirmationService', ['confirm']);

    await TestBed.configureTestingModule({
      imports: [
        LayoutSectionListComponent,
        NoopAnimationsModule,
        DragDropModule
      ],
      providers: [
        { provide: LayoutSectionService, useValue: layoutSectionServiceSpy },
        { provide: ConfirmationService, useValue: confirmationServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(LayoutSectionListComponent);
    component = fixture.componentInstance;
    mockLayoutSectionService = TestBed.inject(LayoutSectionService) as jasmine.SpyObj<LayoutSectionService>;
    mockConfirmationService = TestBed.inject(ConfirmationService) as jasmine.SpyObj<ConfirmationService>;

    // Setup default mock returns
    mockLayoutSectionService.getList.and.returnValue(of(mockLayoutSections));
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load layout sections on init', () => {
    // Act
    fixture.detectChanges(); // This triggers ngOnInit

    // Assert
    expect(mockLayoutSectionService.getList).toHaveBeenCalled();
    expect(component.layoutSections).toEqual(mockLayoutSections);
    expect(component.loading).toBeFalse();
  });

  it('should handle loading state correctly', () => {
    // Arrange
    component.loading = false;

    // Act
    component.loadLayoutSections();

    // Assert - loading should be true during the call
    expect(component.loading).toBeTrue();
  });

  it('should handle error when loading sections fails', () => {
    // Arrange
    const errorResponse = { error: 'Network error' };
    mockLayoutSectionService.getList.and.returnValue(throwError(() => errorResponse));
    spyOn(component as any, 'handleApiError');

    // Act
    component.loadLayoutSections();

    // Assert
    expect(component.loading).toBeFalse();
    expect((component as any).handleApiError).toHaveBeenCalledWith(
      errorResponse, 
      'Không thể tải danh sách khu vực bố cục'
    );
  });

  it('should open new dialog correctly', () => {
    // Act
    component.openNew();

    // Assert
    expect(component.selectedSection).toBeNull();
    expect(component.isEditMode).toBeFalse();
    expect(component.displayDialog).toBeTrue();
  });

  it('should open edit dialog correctly', () => {
    // Arrange
    const sectionToEdit = mockLayoutSections[0];

    // Act
    component.editSection(sectionToEdit);

    // Assert
    expect(component.selectedSection).toEqual({ ...sectionToEdit });
    expect(component.isEditMode).toBeTrue();
    expect(component.displayDialog).toBeTrue();
  });

  it('should show confirmation dialog when deleting section', () => {
    // Arrange
    const sectionToDelete = mockLayoutSections[0];

    // Act
    component.deleteSection(sectionToDelete);

    // Assert
    expect(mockConfirmationService.confirm).toHaveBeenCalledWith(
      jasmine.objectContaining({
        message: `Bạn có chắc chắn muốn xóa khu vực "${sectionToDelete.sectionName}"?\n\nLưu ý: Việc xóa khu vực có thể ảnh hưởng đến các bàn ăn đã được gán vào khu vực này.`,
        header: 'Xác nhận Xóa Khu vực',
        icon: 'pi pi-exclamation-triangle'
      })
    );
  });

  it('should delete section when confirmed', () => {
    // Arrange
    const sectionToDelete = mockLayoutSections[0];
    mockLayoutSectionService.delete.and.returnValue(of(void 0));
    spyOn(component as any, 'showSuccess');

    // Setup confirmation service to auto-accept
    mockConfirmationService.confirm.and.callFake((config: any) => {
      return config.accept();
    });

    // Act
    component.deleteSection(sectionToDelete);

    // Assert
    expect(mockLayoutSectionService.delete).toHaveBeenCalledWith(sectionToDelete.id!);
    expect(component.layoutSections).not.toContain(sectionToDelete);
    expect((component as any).showSuccess).toHaveBeenCalledWith(
      'Đã xóa thành công',
      `Khu vực "${sectionToDelete.sectionName}" đã được xóa khỏi hệ thống`
    );
  });

  it('should toggle active status correctly', () => {
    // Arrange
    const section = { ...mockLayoutSections[0] };
    const originalStatus = section.isActive;
    const updatedSection = { ...section, isActive: !originalStatus };
    
    mockLayoutSectionService.update.and.returnValue(of(updatedSection));
    spyOn(component as any, 'showSuccess');

    // Act
    component.toggleActive(section);

    // Assert
    expect(mockLayoutSectionService.update).toHaveBeenCalledWith(
      section.id!,
      jasmine.objectContaining({
        sectionName: section.sectionName,
        description: section.description,
        displayOrder: section.displayOrder,
        isActive: !originalStatus
      })
    );
    expect(section.isActive).toBe(!originalStatus);
    expect((component as any).showSuccess).toHaveBeenCalled();
  });

  it('should revert status on toggle error', () => {
    // Arrange
    const section = { ...mockLayoutSections[0] };
    const originalStatus = section.isActive;
    
    mockLayoutSectionService.update.and.returnValue(throwError(() => ({ error: 'Update failed' })));
    spyOn(component as any, 'handleApiError');

    // Act
    component.toggleActive(section);

    // Assert
    expect(section.isActive).toBe(originalStatus); // Should revert
    expect((component as any).handleApiError).toHaveBeenCalledWith(
      { error: 'Update failed' },
      'Không thể thay đổi trạng thái khu vực'
    );
  });

  it('should close dialog correctly', () => {
    // Arrange
    component.displayDialog = true;
    component.selectedSection = mockLayoutSections[0];
    component.isEditMode = true;

    // Act
    component.onDialogHide();

    // Assert
    expect(component.displayDialog).toBeFalse();
    expect(component.selectedSection).toBeNull();
    expect(component.isEditMode).toBeFalse();
  });

  it('should reload sections after save', () => {
    // Arrange
    spyOn(component, 'loadLayoutSections');

    // Act
    component.onSectionSaved();

    // Assert
    expect(component.displayDialog).toBeFalse();
    expect(component.loadLayoutSections).toHaveBeenCalled();
  });

  it('should handle Vietnamese section names correctly', () => {
    // Arrange
    const vietnameseSections: LayoutSectionDto[] = [
      {
        id: '1',
        sectionName: 'Dãy 1',
        description: 'Mô tả tiếng Việt có dấu',
        displayOrder: 1,
        isActive: true,
        creationTime: '2024-01-01T00:00:00Z',
        creatorId: 'user1',
        lastModificationTime: null,
        lastModifierId: null,
        isDeleted: false,
        deleterId: null,
        deletionTime: null
      }
    ];

    mockLayoutSectionService.getList.and.returnValue(of(vietnameseSections));

    // Act
    component.loadLayoutSections();

    // Assert
    expect(component.layoutSections[0].sectionName).toBe('Dãy 1');
    expect(component.layoutSections[0].description).toBe('Mô tả tiếng Việt có dấu');
  });
});