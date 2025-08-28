import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MessageService } from 'primeng/api';
import { of, throwError } from 'rxjs';
import { MenuItemFormComponent } from './menu-item-form.component';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuItemDto, CreateUpdateMenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';

describe('MenuItemFormComponent', () => {
  let component: MenuItemFormComponent;
  let fixture: ComponentFixture<MenuItemFormComponent>;
  let mockMenuItemService: jasmine.SpyObj<MenuItemService>;
  let mockMenuCategoryService: jasmine.SpyObj<MenuCategoryService>;
  let mockDialogRef: jasmine.SpyObj<DynamicDialogRef>;
  let mockDialogConfig: DynamicDialogConfig;
  let mockMessageService: jasmine.SpyObj<MessageService>;

  const mockCategories: MenuCategoryDto[] = [
    {
      id: 'cat1',
      name: 'Món Phở',
      description: 'Các loại phở truyền thống',
      displayOrder: 1,
      isEnabled: true,
      imageUrl: null,
      imageMetadata: null,
      creationTime: '2025-08-25T00:00:00Z',
      lastModificationTime: null,
      creatorId: null,
      lastModifierId: null,
      isDeleted: false,
      deleterId: null,
      deletionTime: null,
    },
  ];

  const mockMenuItem: MenuItemDto = {
    id: 'item1',
    name: 'Phở Bò Tái',
    description: 'Phở bò với thịt bò tái, hành lá và ngò gai',
    price: 85000,
    isAvailable: true,
    imageUrl: 'https://example.com/pho.jpg',
    categoryId: 'cat1',
    category: mockCategories[0],
    creationTime: '2025-08-25T00:00:00Z',
    lastModificationTime: null,
    creatorId: null,
    lastModifierId: null,
    isDeleted: false,
    deleterId: null,
    deletionTime: null,
  };

  beforeEach(async () => {
    const spyMenuItemService = jasmine.createSpyObj('MenuItemService', [
      'get',
      'create',
      'update',
    ]);
    const spyMenuCategoryService = jasmine.createSpyObj('MenuCategoryService', [
      'getList',
    ]);
    const spyDialogRef = jasmine.createSpyObj('DynamicDialogRef', ['close']);
    const spyMessageService = jasmine.createSpyObj('MessageService', ['add']);

    mockDialogConfig = {
      data: null
    };

    await TestBed.configureTestingModule({
      imports: [ReactiveFormsModule, NoopAnimationsModule, MenuItemFormComponent],
      providers: [
        FormBuilder,
        { provide: DynamicDialogRef, useValue: spyDialogRef },
        { provide: DynamicDialogConfig, useValue: mockDialogConfig },
        { provide: MenuItemService, useValue: spyMenuItemService },
        { provide: MenuCategoryService, useValue: spyMenuCategoryService },
        { provide: MessageService, useValue: spyMessageService },
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(MenuItemFormComponent);
    component = fixture.componentInstance;

    mockMenuItemService = TestBed.inject(MenuItemService) as jasmine.SpyObj<MenuItemService>;
    mockMenuCategoryService = TestBed.inject(MenuCategoryService) as jasmine.SpyObj<MenuCategoryService>;
    mockDialogRef = TestBed.inject(DynamicDialogRef) as jasmine.SpyObj<DynamicDialogRef>;
    mockMessageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
  });

  it('should create', () => {
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    fixture.detectChanges();

    expect(component).toBeTruthy();
  });

  it('should load categories on init', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));

    // Act
    fixture.detectChanges();
    await fixture.whenStable();

    // Assert
    expect(mockMenuCategoryService.getList).toHaveBeenCalled();
    expect(component.categories).toEqual(mockCategories);
  });

  it('should initialize form in create mode', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));

    // Act
    fixture.detectChanges();

    // Assert
    expect(component.isEditMode).toBeFalse();
    expect(component.form.get('name')?.value).toBe('');
    expect(component.form.get('price')?.value).toBeNull();
    expect(component.form.get('isAvailable')?.value).toBe(true);
  });

  it('should load menu item data in edit mode', async () => {
    // Arrange
    mockDialogConfig.data = { id: 'item1' };
    mockMenuItemService.get.and.returnValue(of(mockMenuItem));
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));

    // Act
    fixture.detectChanges();
    await fixture.whenStable();

    // Assert
    expect(component.isEditMode).toBeTrue();
    expect(mockMenuItemService.get).toHaveBeenCalledWith('item1');
    expect(component.form.get('name')?.value).toBe('Phở Bò Tái');
    expect(component.form.get('price')?.value).toBe(85000);
    expect(component.form.get('categoryId')?.value).toBe('cat1');
  });

  it('should validate required fields', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    fixture.detectChanges();

    // Act
    component.form.get('name')?.setValue('');
    component.form.get('price')?.setValue(null);
    component.form.get('categoryId')?.setValue('');

    // Assert
    expect(component.form.get('name')?.hasError('required')).toBeTrue();
    expect(component.form.get('price')?.hasError('required')).toBeTrue();
    expect(component.form.get('categoryId')?.hasError('required')).toBeTrue();
    expect(component.form.valid).toBeFalse();
  });

  it('should validate price is positive', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    fixture.detectChanges();

    // Act
    component.form.get('price')?.setValue(-1000);

    // Assert
    expect(component.form.get('price')?.hasError('min')).toBeTrue();
    expect(component.form.valid).toBeFalse();
  });

  it('should create new menu item', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    mockMenuItemService.create.and.returnValue(of(mockMenuItem));
    fixture.detectChanges();

    const formData: CreateUpdateMenuItemDto = {
      name: 'Phở Gà',
      description: 'Phở gà truyền thống',
      price: 75000,
      isAvailable: true,
      categoryId: 'cat1',
      imageUrl: null
    };

    component.form.patchValue(formData);

    // Act
    component.onSave();
    await fixture.whenStable();

    // Assert
    expect(mockMenuItemService.create).toHaveBeenCalledWith(formData);
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã tạo món ăn mới'
    });
    expect(mockDialogRef.close).toHaveBeenCalledWith(true);
  });

  it('should update existing menu item', async () => {
    // Arrange
    mockDialogConfig.data = { id: 'item1' };
    mockMenuItemService.get.and.returnValue(of(mockMenuItem));
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    mockMenuItemService.update.and.returnValue(of(mockMenuItem));
    
    fixture.detectChanges();
    await fixture.whenStable();

    const formData: CreateUpdateMenuItemDto = {
      name: 'Phở Bò Tái Cập Nhật',
      description: 'Mô tả cập nhật',
      price: 90000,
      isAvailable: false,
      categoryId: 'cat1',
      imageUrl: 'https://example.com/updated.jpg'
    };

    component.form.patchValue(formData);

    // Act
    component.onSave();
    await fixture.whenStable();

    // Assert
    expect(mockMenuItemService.update).toHaveBeenCalledWith('item1', formData);
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã cập nhật món ăn'
    });
    expect(mockDialogRef.close).toHaveBeenCalledWith(true);
  });

  it('should handle save error', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    mockMenuItemService.create.and.returnValue(throwError({ message: 'Server error' }));
    fixture.detectChanges();

    component.form.patchValue({
      name: 'Test Item',
      price: 50000,
      categoryId: 'cat1',
      isAvailable: true
    });

    // Act
    component.onSave();
    await fixture.whenStable();

    // Assert
    expect(component.loading).toBeFalse();
    expect(mockDialogRef.close).not.toHaveBeenCalled();
  });

  it('should cancel and close dialog', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    fixture.detectChanges();

    // Act
    component.onCancel();

    // Assert
    expect(mockDialogRef.close).toHaveBeenCalledWith(false);
  });

  it('should not save when form is invalid', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    fixture.detectChanges();

    // Keep form invalid (empty required fields)

    // Act
    component.onSave();

    // Assert
    expect(mockMenuItemService.create).not.toHaveBeenCalled();
    expect(mockMenuItemService.update).not.toHaveBeenCalled();
    expect(component.form.valid).toBeFalse();
  });

  it('should show loading state during save', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: 1 }));
    mockMenuItemService.create.and.returnValue(of(mockMenuItem).pipe(
      // Simulate delay to check loading state
    ));
    fixture.detectChanges();

    component.form.patchValue({
      name: 'Test Item',
      price: 50000,
      categoryId: 'cat1',
      isAvailable: true
    });

    // Act
    component.onSave();

    // Assert
    expect(component.loading).toBeTrue();
  });
});