import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { ConfirmationService } from 'primeng/api';
import { of } from 'rxjs';
import { DragDropModule } from '@angular/cdk/drag-drop';

import { LayoutSectionListComponent } from './layout-section-list/layout-section-list.component';
import { LayoutSectionFormComponent } from './layout-section-form/layout-section-form.component';
import { LayoutSectionService } from '../../../proxy/table-management/layout-sections/layout-section.service';
import {
  LayoutSectionDto,
  CreateLayoutSectionDto,
  UpdateLayoutSectionDto,
} from '../../../proxy/table-management/layout-sections/dto/models';

describe('Layout Section Management Integration', () => {
  let listComponent: LayoutSectionListComponent;
  let formComponent: LayoutSectionFormComponent;
  let listFixture: ComponentFixture<LayoutSectionListComponent>;
  let formFixture: ComponentFixture<LayoutSectionFormComponent>;
  let mockLayoutSectionService: jasmine.SpyObj<LayoutSectionService>;
  let mockConfirmationService: jasmine.SpyObj<ConfirmationService>;

  const mockLayoutSections: LayoutSectionDto[] = [
    {
      id: '1',
      sectionName: 'Dãy 1',
      description: 'Khu vực dãy đầu tiên',
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
      id: '2',
      sectionName: 'Khu VIP',
      description: 'Khu vực VIP cao cấp',
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

  beforeEach(async () => {
    const layoutSectionServiceSpy = jasmine.createSpyObj('LayoutSectionService', [
      'getList',
      'create',
      'update',
      'delete',
      'getNextDisplayOrder',
    ]);
    const confirmationServiceSpy = jasmine.createSpyObj('ConfirmationService', ['confirm']);

    await TestBed.configureTestingModule({
      imports: [
        LayoutSectionListComponent,
        LayoutSectionFormComponent,
        NoopAnimationsModule,
        DragDropModule,
      ],
      providers: [
        { provide: LayoutSectionService, useValue: layoutSectionServiceSpy },
        { provide: ConfirmationService, useValue: confirmationServiceSpy },
      ],
    }).compileComponents();

    mockLayoutSectionService = TestBed.inject(
      LayoutSectionService,
    ) as jasmine.SpyObj<LayoutSectionService>;
    mockConfirmationService = TestBed.inject(
      ConfirmationService,
    ) as jasmine.SpyObj<ConfirmationService>;

    // Setup default mock returns
    mockLayoutSectionService.getList.and.returnValue(of(mockLayoutSections));
    mockLayoutSectionService.getNextDisplayOrder.and.returnValue(of(3));

    // Create components
    listFixture = TestBed.createComponent(LayoutSectionListComponent);
    listComponent = listFixture.componentInstance;

    formFixture = TestBed.createComponent(LayoutSectionFormComponent);
    formComponent = formFixture.componentInstance;
  });

  describe('Full CRUD Workflow Integration', () => {
    it('should complete full create workflow', async () => {
      // Arrange - Setup list component
      listFixture.detectChanges();
      expect(listComponent.layoutSections.length).toBe(2);

      // Simulate opening new dialog
      listComponent.openNew();
      expect(listComponent.displayDialog).toBe(true);
      expect(listComponent.sectionId).toBe(false);

      // Setup form component for new section
      formComponent.section = listComponent.selectedSection;
      formComponent.sectionId = listComponent.sectionId;
      formFixture.detectChanges();

      // Arrange - Mock create operation
      const newSection: LayoutSectionDto = {
        id: '3',
        sectionName: 'Sân vườn',
        description: 'Khu vực ngoài trời',
        displayOrder: 3,
        isActive: true,
        creationTime: '2024-01-03T00:00:00Z',
        creatorId: 'user1',
        lastModificationTime: null,
        lastModifierId: null,
        isDeleted: false,
        deleterId: null,
        deletionTime: null,
      };

      mockLayoutSectionService.create.and.returnValue(of(newSection));
      mockLayoutSectionService.getList.and.returnValue(of([...mockLayoutSections, newSection]));

      // Act - Fill and submit form
      formComponent.sectionForm.patchValue({
        sectionName: 'Sân vườn',
        description: 'Khu vực ngoài trời',
        displayOrder: 3,
        isActive: true,
      });

      spyOn(formComponent.saved, 'emit').and.callThrough();
      formComponent.onSubmit();

      // Assert
      expect(mockLayoutSectionService.create).toHaveBeenCalledWith(
        jasmine.objectContaining({
          sectionName: 'Sân vườn',
          description: 'Khu vực ngoài trời',
          displayOrder: 3,
          isActive: true,
        }),
      );
      expect(formComponent.saved.emit).toHaveBeenCalled();

      // Simulate saving completed
      listComponent.onSectionSaved();
      expect(listComponent.displayDialog).toBe(false);
      expect(mockLayoutSectionService.getList).toHaveBeenCalled();
    });

    it('should complete full edit workflow', async () => {
      // Arrange - Setup list component
      listFixture.detectChanges();
      const sectionToEdit = mockLayoutSections[0];

      // Simulate opening edit dialog
      listComponent.editSection(sectionToEdit);
      expect(listComponent.displayDialog).toBe(true);
      expect(listComponent.sectionId).toBe(true);
      expect(listComponent.selectedSection).toEqual({ ...sectionToEdit });

      // Setup form component for editing
      formComponent.section = listComponent.selectedSection;
      formComponent.sectionId = listComponent.sectionId;
      formFixture.detectChanges();

      // Verify form is populated with existing data
      expect(formComponent.sectionForm.get('sectionName')?.value).toBe('Dãy 1');
      expect(formComponent.sectionForm.get('description')?.value).toBe('Khu vực dãy đầu tiên');

      // Arrange - Mock update operation
      const updatedSection: LayoutSectionDto = {
        ...sectionToEdit,
        sectionName: 'Dãy 1 - Cập nhật',
        description: 'Khu vực dãy đầu tiên - đã cập nhật',
      };

      mockLayoutSectionService.update.and.returnValue(of(updatedSection));

      // Act - Modify and submit form
      formComponent.sectionForm.patchValue({
        sectionName: 'Dãy 1 - Cập nhật',
        description: 'Khu vực dãy đầu tiên - đã cập nhật',
      });

      spyOn(formComponent.saved, 'emit').and.callThrough();
      formComponent.onSubmit();

      // Assert
      expect(mockLayoutSectionService.update).toHaveBeenCalledWith(
        sectionToEdit.id!,
        jasmine.objectContaining({
          sectionName: 'Dãy 1 - Cập nhật',
          description: 'Khu vực dãy đầu tiên - đã cập nhật',
        }),
      );
      expect(formComponent.saved.emit).toHaveBeenCalled();
    });

    it('should complete full delete workflow', async () => {
      // Arrange - Setup list component
      listFixture.detectChanges();
      const sectionToDelete = mockLayoutSections[0];

      mockLayoutSectionService.delete.and.returnValue(of(void 0));
      mockConfirmationService.confirm.and.callFake((config: any) => {
        // Simulate user confirming the deletion
        if (config.accept) {
          config.accept();
        }
        return mockConfirmationService;
      });

      // Act - Delete section
      listComponent.deleteSection(sectionToDelete);

      // Assert
      expect(mockConfirmationService.confirm).toHaveBeenCalledWith(
        jasmine.objectContaining({
          message: jasmine.stringMatching(
            new RegExp(`Bạn có chắc chắn muốn xóa khu vực "${sectionToDelete.sectionName}"`),
          ),
          header: 'Xác nhận Xóa Khu vực',
        }),
      );
      expect(mockLayoutSectionService.delete).toHaveBeenCalledWith(sectionToDelete.id!);
      expect(listComponent.layoutSections).not.toContain(sectionToDelete);
    });
  });

  describe('Vietnamese Text Validation Integration', () => {
    it('should handle Vietnamese section names correctly throughout workflow', async () => {
      const vietnameseSectionData = {
        sectionName: 'Khu Vực Tiếng Việt',
        description: 'Mô tả có dấu tiếng Việt: àáâãèéêìíòóôõùúýđ',
        displayOrder: 1,
        isActive: true,
      };

      // Setup form component
      formFixture.detectChanges();

      // Test form validation with Vietnamese text
      formComponent.sectionForm.patchValue(vietnameseSectionData);
      expect(formComponent.sectionForm.valid).toBe(true);

      // Mock successful creation with Vietnamese text
      const vietnameseSection: LayoutSectionDto = {
        id: '4',
        ...vietnameseSectionData,
        creationTime: '2024-01-04T00:00:00Z',
        creatorId: 'user1',
        lastModificationTime: null,
        lastModifierId: null,
        isDeleted: false,
        deleterId: null,
        deletionTime: null,
      };

      mockLayoutSectionService.create.and.returnValue(of(vietnameseSection));

      // Act
      formComponent.onSubmit();

      // Assert
      expect(mockLayoutSectionService.create).toHaveBeenCalledWith(
        jasmine.objectContaining({
          sectionName: 'Khu Vực Tiếng Việt',
          description: 'Mô tả có dấu tiếng Việt: àáâãèéêìíòóôõùúýđ',
        }),
      );
    });

    it('should validate Vietnamese suggestion patterns', () => {
      formFixture.detectChanges();

      // Test common Vietnamese restaurant section names
      const vietnameseSuggestions = [
        'Dãy 1',
        'Dãy 2',
        'Khu VIP',
        'Phòng riêng',
        'Sân vườn',
        'Tầng 1',
        'Khu gia đình',
        'Quầy bar',
      ];

      vietnameseSuggestions.forEach(suggestion => {
        expect(formComponent.sectionNameSuggestions).toContain(suggestion);

        // Test applying suggestion
        formComponent.onSectionNameSuggestionClick(suggestion);
        expect(formComponent.sectionForm.get('sectionName')?.value).toBe(suggestion);
        expect(formComponent.sectionForm.get('sectionName')?.valid).toBe(true);
      });
    });
  });

  describe('Section Ordering Integration', () => {
    it('should maintain correct display order throughout operations', async () => {
      // Setup list component
      listFixture.detectChanges();

      // Test that sections are displayed in correct order
      expect(listComponent.layoutSections[0].displayOrder).toBe(1);
      expect(listComponent.layoutSections[1].displayOrder).toBe(2);

      // Test getNextDisplayOrder integration
      formFixture.detectChanges();
      expect(mockLayoutSectionService.getNextDisplayOrder).toHaveBeenCalled();
      expect(formComponent.sectionForm.get('displayOrder')?.value).toBe(3);

      // Test drag and drop reordering
      const mockDragEvent = {
        previousIndex: 0,
        currentIndex: 1,
        item: {} as any,
        container: {} as any,
        previousContainer: {} as any,
        isPointerOverContainer: true,
        distance: { x: 0, y: 0 },
        dropPoint: { x: 0, y: 0 },
        event: {} as any,
      };

      mockLayoutSectionService.update.and.returnValue(of(mockLayoutSections[0]));
      listComponent.onSectionDrop(mockDragEvent);

      // Verify that sections were reordered and update calls were made
      expect(mockLayoutSectionService.update).toHaveBeenCalled();
    });
  });

  describe('Form State Management Integration', () => {
    it('should properly manage form state during dialog open/close', () => {
      // Initial state
      listFixture.detectChanges();
      expect(listComponent.displayDialog).toBe(false);
      expect(listComponent.selectedSection).toBeNull();

      // Open new dialog
      listComponent.openNew();
      expect(listComponent.displayDialog).toBe(true);
      expect(listComponent.selectedSection).toBeNull();
      expect(listComponent.sectionId).toBe(false);

      // Close dialog
      listComponent.onDialogHide();
      expect(listComponent.displayDialog).toBe(false);
      expect(listComponent.selectedSection).toBeNull();
      expect(listComponent.sectionId).toBe(false);

      // Open edit dialog
      const sectionToEdit = mockLayoutSections[0];
      listComponent.editSection(sectionToEdit);
      expect(listComponent.displayDialog).toBe(true);
      expect(listComponent.selectedSection).toEqual({ ...sectionToEdit });
      expect(listComponent.sectionId).toBe(true);
    });

    it('should handle form cancellation properly', () => {
      formFixture.detectChanges();
      spyOn(formComponent.cancelled, 'emit');

      formComponent.onCancel();

      expect(formComponent.cancelled.emit).toHaveBeenCalled();
    });
  });
});
