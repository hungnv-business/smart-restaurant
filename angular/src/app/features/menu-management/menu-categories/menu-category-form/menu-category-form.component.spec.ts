import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MenuCategoryFormComponent, MenuCategoryFormData } from './menu-category-form.component';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import {
  MenuCategoryDto,
  CreateUpdateMenuCategoryDto,
} from '../../../../proxy/menu-management/menu-categories/dto';

describe('MenuCategoryFormComponent', () => {
  let component: MenuCategoryFormComponent;
  let fixture: ComponentFixture<MenuCategoryFormComponent>;
  let mockMenuCategoryService: jasmine.SpyObj<MenuCategoryService>;
  let mockDialogRef: jasmine.SpyObj<DynamicDialogRef>;
  let mockDialogConfig: DynamicDialogConfig<MenuCategoryFormData>;

  const mockCategory: MenuCategoryDto = {
    id: '1',
    name: 'Món khai vị',
    description: 'Các món khai vị truyền thống',
    displayOrder: 1,
    isEnabled: true,
    imageUrl: 'https://example.com/image.jpg',
    imageMetadata: '{"alt": "Category image"}',
    creationTime: '2025-08-25T00:00:00Z',
    lastModificationTime: null,
    creatorId: null,
    lastModifierId: null,
    isDeleted: false,
    deleterId: null,
    deletionTime: null,
  };

  beforeEach(async () => {
    const spyMenuCategoryService = jasmine.createSpyObj('MenuCategoryService', [
      'create',
      'update',
    ]);
    const spyDialogRef = jasmine.createSpyObj('DynamicDialogRef', ['close']);

    mockDialogConfig = {
      data: {
        isEdit: false,
      },
    };

    await TestBed.configureTestingModule({
      imports: [MenuCategoryFormComponent, ReactiveFormsModule, NoopAnimationsModule],
      providers: [
        { provide: MenuCategoryService, useValue: spyMenuCategoryService },
        { provide: DynamicDialogRef, useValue: spyDialogRef },
        { provide: DynamicDialogConfig, useValue: mockDialogConfig },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(MenuCategoryFormComponent);
    component = fixture.componentInstance;

    mockMenuCategoryService = TestBed.inject(
      MenuCategoryService,
    ) as jasmine.SpyObj<MenuCategoryService>;
    mockDialogRef = TestBed.inject(DynamicDialogRef) as jasmine.SpyObj<DynamicDialogRef>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form for create mode', () => {
    // Act
    fixture.detectChanges();

    // Assert
    expect(component.isEdit).toBeFalse();
    expect(component.form.get('name')?.value).toBe('');
    expect(component.form.get('displayOrder')?.value).toBe(0);
    expect(component.form.get('isEnabled')?.value).toBe(true);
  });

  it('should initialize form for edit mode', () => {
    // Arrange
    mockDialogConfig.data = {
      isEdit: true,
      category: mockCategory,
    };

    // Act
    component.ngOnInit();
    fixture.detectChanges();

    // Assert
    expect(component.isEdit).toBeTrue();
    expect(component.form.get('name')?.value).toBe(mockCategory.name);
    expect(component.form.get('description')?.value).toBe(mockCategory.description);
    expect(component.form.get('displayOrder')?.value).toBe(mockCategory.displayOrder);
    expect(component.form.get('isEnabled')?.value).toBe(mockCategory.isEnabled);
  });

  it('should validate required fields', () => {
    // Act
    fixture.detectChanges();

    // Assert
    const nameControl = component.form.get('name');
    expect(nameControl?.valid).toBeFalse();
    expect(nameControl?.hasError('required')).toBeTrue();

    // Make name valid
    nameControl?.setValue('Test Category');
    expect(nameControl?.valid).toBeTrue();
  });

  it('should validate field lengths', () => {
    // Arrange
    fixture.detectChanges();
    const nameControl = component.form.get('name');
    const descriptionControl = component.form.get('description');

    // Act & Assert - Name too long
    nameControl?.setValue('a'.repeat(129)); // Max is 128
    expect(nameControl?.hasError('maxlength')).toBeTrue();

    // Act & Assert - Description too long
    descriptionControl?.setValue('a'.repeat(513)); // Max is 512
    expect(descriptionControl?.hasError('maxlength')).toBeTrue();
  });

  it('should create menu category on form submission', async () => {
    // Arrange
    const createDto: CreateUpdateMenuCategoryDto = {
      name: 'New Category',
      description: 'New description',
      displayOrder: 3,
      isEnabled: true,
      imageUrl: '',
      imageMetadata: '',
    };

    mockMenuCategoryService.create.and.returnValue(of(mockCategory));

    fixture.detectChanges();

    // Set form values
    component.form.patchValue(createDto);

    // Act
    await component.onSubmit();

    // Assert
    expect(mockMenuCategoryService.create).toHaveBeenCalledWith(createDto);
    expect(mockDialogRef.close).toHaveBeenCalledWith(true);
  });

  it('should update menu category on form submission in edit mode', async () => {
    // Arrange
    mockDialogConfig.data = {
      isEdit: true,
      category: mockCategory,
    };

    const updateDto: CreateUpdateMenuCategoryDto = {
      name: 'Updated Category',
      description: 'Updated description',
      displayOrder: 2,
      isEnabled: false,
      imageUrl: 'https://example.com/new-image.jpg',
      imageMetadata: '{"alt": "New image"}',
    };

    mockMenuCategoryService.update.and.returnValue(of(mockCategory));

    component.ngOnInit();
    fixture.detectChanges();

    // Set form values
    component.form.patchValue(updateDto);

    // Act
    await component.onSubmit();

    // Assert
    expect(mockMenuCategoryService.update).toHaveBeenCalledWith(mockCategory.id, updateDto);
    expect(mockDialogRef.close).toHaveBeenCalledWith(true);
  });

  it('should not submit invalid form', async () => {
    // Arrange
    fixture.detectChanges();
    // Leave form invalid (empty required name)

    // Act
    await component.onSubmit();

    // Assert
    expect(mockMenuCategoryService.create).not.toHaveBeenCalled();
    expect(mockDialogRef.close).not.toHaveBeenCalled();
  });

  it('should handle API errors during submission', async () => {
    // Arrange
    const error = { message: 'API Error' };
    mockMenuCategoryService.create.and.returnValue(throwError(error));

    fixture.detectChanges();

    // Set valid form values
    component.form.patchValue({
      name: 'Valid Category',
      displayOrder: 1,
      isEnabled: true,
    });

    // Act
    await component.onSubmit();

    // Assert
    expect(component.loading).toBeFalse();
    expect(mockDialogRef.close).not.toHaveBeenCalled();
  });

  it('should close dialog on cancel', () => {
    // Arrange
    fixture.detectChanges();

    // Act
    component.onCancel();

    // Assert
    expect(mockDialogRef.close).toHaveBeenCalledWith(false);
  });

  it('should show loading state during submission', async () => {
    // Arrange
    mockMenuCategoryService.create.and.returnValue(of(mockCategory).pipe());
    fixture.detectChanges();

    component.form.patchValue({
      name: 'Valid Category',
      displayOrder: 1,
      isEnabled: true,
    });

    // Act
    const submitPromise = component.onSubmit();

    // Assert loading state
    expect(component.loading).toBeTrue();

    await submitPromise;
    expect(component.loading).toBeFalse();
  });

  it('should display form validation errors', () => {
    // Arrange
    fixture.detectChanges();

    // Make form touched to show validation errors
    component.form.markAllAsTouched();
    fixture.detectChanges();

    // Assert
    expect(component.isFieldInvalidForm('name')).toBeTrue();

    const compiled = fixture.nativeElement as HTMLElement;
    const errorElements = compiled.querySelectorAll('.p-error');
    expect(errorElements.length).toBeGreaterThan(0);
  });
});
