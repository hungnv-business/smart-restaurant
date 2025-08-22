import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { LayoutSectionFormComponent } from './layout-section-form.component';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import { LayoutSectionDto, CreateLayoutSectionDto, UpdateLayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';

describe('LayoutSectionFormComponent', () => {
  let component: LayoutSectionFormComponent;
  let fixture: ComponentFixture<LayoutSectionFormComponent>;
  let mockLayoutSectionService: jasmine.SpyObj<LayoutSectionService>;

  const mockSection: LayoutSectionDto = {
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
  };

  beforeEach(async () => {
    const layoutSectionServiceSpy = jasmine.createSpyObj('LayoutSectionService', [
      'create', 'update', 'getNextDisplayOrder'
    ]);

    await TestBed.configureTestingModule({
      imports: [
        LayoutSectionFormComponent,
        ReactiveFormsModule,
        NoopAnimationsModule,
        ValidationErrorComponent,
        FormFooterActionsComponent
      ],
      providers: [
        { provide: LayoutSectionService, useValue: layoutSectionServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(LayoutSectionFormComponent);
    component = fixture.componentInstance;
    mockLayoutSectionService = TestBed.inject(LayoutSectionService) as jasmine.SpyObj<LayoutSectionService>;

    // Setup default mock returns
    mockLayoutSectionService.getNextDisplayOrder.and.returnValue(of(1));
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form with default values for new section', () => {
    // Act
    fixture.detectChanges(); // This triggers ngOnInit

    // Assert
    expect(component.sectionForm).toBeDefined();
    expect(component.sectionForm.get('sectionName')?.value).toBe('');
    expect(component.sectionForm.get('description')?.value).toBe('');
    expect(component.sectionForm.get('displayOrder')?.value).toBe(1);
    expect(component.sectionForm.get('isActive')?.value).toBe(true);
    expect(mockLayoutSectionService.getNextDisplayOrder).toHaveBeenCalled();
  });

  it('should populate form when editing existing section', () => {
    // Arrange
    component.section = mockSection;
    component.isEditMode = true;

    // Act
    fixture.detectChanges();

    // Assert
    expect(component.sectionForm.get('sectionName')?.value).toBe('Dãy 1');
    expect(component.sectionForm.get('description')?.value).toBe('Khu vực dãy 1');
    expect(component.sectionForm.get('displayOrder')?.value).toBe(1);
    expect(component.sectionForm.get('isActive')?.value).toBe(true);
  });

  it('should validate required section name', () => {
    // Arrange
    fixture.detectChanges();
    const sectionNameControl = component.sectionForm.get('sectionName');

    // Act
    sectionNameControl?.setValue('');
    sectionNameControl?.markAsTouched();

    // Assert
    expect(sectionNameControl?.invalid).toBe(true);
    expect(sectionNameControl?.errors?.['required']).toBeTruthy();
  });

  it('should validate section name max length', () => {
    // Arrange
    fixture.detectChanges();
    const sectionNameControl = component.sectionForm.get('sectionName');
    const longName = 'x'.repeat(129); // Exceeds 128 characters

    // Act
    sectionNameControl?.setValue(longName);

    // Assert
    expect(sectionNameControl?.invalid).toBe(true);
    expect(sectionNameControl?.errors?.['maxlength']).toBeTruthy();
  });

  it('should validate description max length', () => {
    // Arrange
    fixture.detectChanges();
    const descriptionControl = component.sectionForm.get('description');
    const longDescription = 'x'.repeat(513); // Exceeds 512 characters

    // Act
    descriptionControl?.setValue(longDescription);

    // Assert
    expect(descriptionControl?.invalid).toBe(true);
    expect(descriptionControl?.errors?.['maxlength']).toBeTruthy();
  });

  it('should validate display order range', () => {
    // Arrange
    fixture.detectChanges();
    const displayOrderControl = component.sectionForm.get('displayOrder');

    // Test minimum value
    displayOrderControl?.setValue(0);
    expect(displayOrderControl?.invalid).toBe(true);
    expect(displayOrderControl?.errors?.['min']).toBeTruthy();

    // Test maximum value
    displayOrderControl?.setValue(1000);
    expect(displayOrderControl?.invalid).toBe(true);
    expect(displayOrderControl?.errors?.['max']).toBeTruthy();

    // Test valid value
    displayOrderControl?.setValue(5);
    expect(displayOrderControl?.valid).toBe(true);
  });

  it('should create new section when form is submitted in create mode', () => {
    // Arrange
    const createDto: CreateLayoutSectionDto = {
      sectionName: 'Khu VIP',
      description: 'Khu vực VIP cao cấp',
      displayOrder: 2,
      isActive: true
    };
    
    const createdSection: LayoutSectionDto = { ...mockSection, ...createDto, id: '2' };
    mockLayoutSectionService.create.and.returnValue(of(createdSection));
    spyOn(component as any, 'showSuccess');
    spyOn(component.saved, 'emit');

    fixture.detectChanges();
    
    // Set form values
    component.sectionForm.patchValue(createDto);

    // Act
    component.onSubmit();

    // Assert
    expect(mockLayoutSectionService.create).toHaveBeenCalledWith(jasmine.objectContaining({
      sectionName: 'Khu VIP',
      description: 'Khu vực VIP cao cấp',
      displayOrder: 2,
      isActive: true
    }));
    expect((component as any).showSuccess).toHaveBeenCalledWith(
      'Tạo mới thành công',
      'Khu vực "Khu VIP" đã được tạo thành công'
    );
    expect(component.saved.emit).toHaveBeenCalled();
    expect(component.loading).toBe(false);
  });

  it('should update section when form is submitted in edit mode', () => {
    // Arrange
    const updateDto: UpdateLayoutSectionDto = {
      sectionName: 'Dãy 1 - Cập nhật',
      description: 'Mô tả mới',
      displayOrder: 3,
      isActive: false
    };
    
    const updatedSection: LayoutSectionDto = { ...mockSection, ...updateDto };
    mockLayoutSectionService.update.and.returnValue(of(updatedSection));
    spyOn(component as any, 'showSuccess');
    spyOn(component.saved, 'emit');

    component.section = mockSection;
    component.isEditMode = true;
    fixture.detectChanges();
    
    // Set form values
    component.sectionForm.patchValue(updateDto);

    // Act
    component.onSubmit();

    // Assert
    expect(mockLayoutSectionService.update).toHaveBeenCalledWith(
      mockSection.id!,
      jasmine.objectContaining({
        sectionName: 'Dãy 1 - Cập nhật',
        description: 'Mô tả mới',
        displayOrder: 3,
        isActive: false
      })
    );
    expect((component as any).showSuccess).toHaveBeenCalledWith(
      'Cập nhật thành công',
      'Thông tin khu vực "Dãy 1 - Cập nhật" đã được cập nhật'
    );
    expect(component.saved.emit).toHaveBeenCalled();
  });

  it('should handle create error', () => {
    // Arrange
    const errorResponse = { error: 'Create failed' };
    mockLayoutSectionService.create.and.returnValue(throwError(() => errorResponse));
    spyOn(component as any, 'handleApiError');

    fixture.detectChanges();
    component.sectionForm.patchValue({
      sectionName: 'Test Section',
      displayOrder: 1,
      isActive: true
    });

    // Act
    component.onSubmit();

    // Assert
    expect((component as any).handleApiError).toHaveBeenCalledWith(
      errorResponse,
      'Không thể tạo khu vực mới'
    );
    expect(component.loading).toBe(false);
  });

  it('should handle update error', () => {
    // Arrange
    const errorResponse = { error: 'Update failed' };
    mockLayoutSectionService.update.and.returnValue(throwError(() => errorResponse));
    spyOn(component as any, 'handleApiError');

    component.section = mockSection;
    component.isEditMode = true;
    fixture.detectChanges();
    
    component.sectionForm.patchValue({
      sectionName: 'Updated Section',
      displayOrder: 2,
      isActive: false
    });

    // Act
    component.onSubmit();

    // Assert
    expect((component as any).handleApiError).toHaveBeenCalledWith(
      errorResponse,
      'Không thể cập nhật thông tin khu vực'
    );
    expect(component.loading).toBe(false);
  });

  it('should not submit when form is invalid', () => {
    // Arrange
    fixture.detectChanges();
    spyOn(component as any, 'validateForm').and.returnValue(false);

    // Act
    component.onSubmit();

    // Assert
    expect(mockLayoutSectionService.create).not.toHaveBeenCalled();
    expect(mockLayoutSectionService.update).not.toHaveBeenCalled();
  });

  it('should emit cancelled when cancel is clicked', () => {
    // Arrange
    spyOn(component.cancelled, 'emit');

    // Act
    component.onCancel();

    // Assert
    expect(component.cancelled.emit).toHaveBeenCalled();
  });

  it('should apply section name suggestion when clicked', () => {
    // Arrange
    fixture.detectChanges();
    const suggestion = 'Khu VIP';

    // Act
    component.onSectionNameSuggestionClick(suggestion);

    // Assert
    expect(component.sectionForm.get('sectionName')?.value).toBe(suggestion);
    expect(component.sectionForm.get('sectionName')?.touched).toBe(true);
  });

  it('should have Vietnamese restaurant section suggestions', () => {
    // Assert
    expect(component.sectionNameSuggestions).toContain('Dãy 1');
    expect(component.sectionNameSuggestions).toContain('Khu VIP');
    expect(component.sectionNameSuggestions).toContain('Sân vườn');
    expect(component.sectionNameSuggestions).toContain('Phòng riêng');
    expect(component.sectionNameSuggestions.length).toBeGreaterThan(10);
  });

  it('should handle null description correctly', () => {
    // Arrange
    const createDto = {
      sectionName: 'Test Section',
      description: '',
      displayOrder: 1,
      isActive: true
    };
    
    mockLayoutSectionService.create.and.returnValue(of({ ...mockSection, ...createDto }));
    fixture.detectChanges();
    
    component.sectionForm.patchValue(createDto);

    // Act
    component.onSubmit();

    // Assert
    expect(mockLayoutSectionService.create).toHaveBeenCalledWith(jasmine.objectContaining({
      sectionName: 'Test Section',
      description: undefined, // Empty string should be converted to undefined
      displayOrder: 1,
      isActive: true
    }));
  });

  it('should trim whitespace from input values', () => {
    // Arrange
    const createDto = {
      sectionName: '  Dãy 1  ',
      description: '  Mô tả có khoảng trắng  ',
      displayOrder: 1,
      isActive: true
    };
    
    mockLayoutSectionService.create.and.returnValue(of(mockSection));
    fixture.detectChanges();
    
    component.sectionForm.patchValue(createDto);

    // Act
    component.onSubmit();

    // Assert
    expect(mockLayoutSectionService.create).toHaveBeenCalledWith(jasmine.objectContaining({
      sectionName: 'Dãy 1',
      description: 'Mô tả có khoảng trắng',
      displayOrder: 1,
      isActive: true
    }));
  });
});