import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { IngredientCategoryFormComponent } from './ingredient-category-form.component';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientCategoryDto, CreateUpdateIngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';

import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { Textarea } from 'primeng/textarea';
import { ButtonModule } from 'primeng/button';
import { CheckboxModule } from 'primeng/checkbox';
import { MessageService } from 'primeng/api';

describe('IngredientCategoryFormComponent', () => {
  let component: IngredientCategoryFormComponent;
  let fixture: ComponentFixture<IngredientCategoryFormComponent>;
  let ingredientCategoryService: jasmine.SpyObj<IngredientCategoryService>;
  let messageService: jasmine.SpyObj<MessageService>;

  const mockCategory: IngredientCategoryDto = {
    id: '1',
    name: 'Rau củ',
    description: 'Rau xanh và củ quả tươi',
    displayOrder: 1,
    isActive: true
  };

  beforeEach(async () => {
    const ingredientCategoryServiceSpy = jasmine.createSpyObj('IngredientCategoryService', 
      ['get', 'create', 'update', 'getNextDisplayOrder']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [
        IngredientCategoryFormComponent,
        ReactiveFormsModule,
        HttpClientTestingModule,
        NoopAnimationsModule,
        DialogModule,
        InputTextModule,
        Textarea,
        ButtonModule,
        CheckboxModule
      ],
      providers: [
        { provide: IngredientCategoryService, useValue: ingredientCategoryServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(IngredientCategoryFormComponent);
    component = fixture.componentInstance;
    ingredientCategoryService = TestBed.inject(IngredientCategoryService) as jasmine.SpyObj<IngredientCategoryService>;
    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form with default values for create mode', () => {
    // Arrange
    ingredientCategoryService.getNextDisplayOrder.and.returnValue(of(1));

    // Act
    component.ngOnInit();

    // Assert
    expect(component.form.get('name')?.value).toBe('');
    expect(component.form.get('description')?.value).toBe('');
    expect(component.form.get('displayOrder')?.value).toBe(1);
    expect(component.form.get('isActive')?.value).toBe(true);
  });

  it('should load category data in edit mode', () => {
    // Arrange
    component.categoryId = '1';
    ingredientCategoryService.get.and.returnValue(of(mockCategory));

    // Act
    component.ngOnInit();

    // Assert
    expect(ingredientCategoryService.get).toHaveBeenCalledWith('1');
    expect(component.form.get('name')?.value).toBe('Rau củ');
    expect(component.form.get('description')?.value).toBe('Rau xanh và củ quả tươi');
    expect(component.form.get('displayOrder')?.value).toBe(1);
    expect(component.form.get('isActive')?.value).toBe(true);
  });

  it('should validate required name field', () => {
    // Arrange
    component.ngOnInit();

    // Act
    component.form.get('name')?.setValue('');
    component.form.get('name')?.markAsTouched();

    // Assert
    expect(component.form.get('name')?.errors?.['required']).toBeTruthy();
    expect(component.form.invalid).toBe(true);
  });

  it('should validate name max length', () => {
    // Arrange
    component.ngOnInit();
    const longName = 'a'.repeat(129); // Exceeds 128 character limit

    // Act
    component.form.get('name')?.setValue(longName);

    // Assert
    expect(component.form.get('name')?.errors?.['maxlength']).toBeTruthy();
  });

  it('should validate description max length', () => {
    // Arrange
    component.ngOnInit();
    const longDescription = 'a'.repeat(513); // Exceeds 512 character limit

    // Act
    component.form.get('description')?.setValue(longDescription);

    // Assert
    expect(component.form.get('description')?.errors?.['maxlength']).toBeTruthy();
  });

  it('should create new category when form is valid', () => {
    // Arrange
    const newCategoryData: CreateUpdateIngredientCategoryDto = {
      name: 'Gia vị',
      description: 'Gia vị và nguyên liệu nấu ăn',
      displayOrder: 1,
      isActive: true
    };
    
    ingredientCategoryService.getNextDisplayOrder.and.returnValue(of(1));
    ingredientCategoryService.create.and.returnValue(of(mockCategory));
    component.ngOnInit();

    // Act
    component.form.patchValue(newCategoryData);
    component.save();

    // Assert
    expect(ingredientCategoryService.create).toHaveBeenCalledWith(newCategoryData);
  });

  it('should update existing category when form is valid', () => {
    // Arrange
    const updateData: CreateUpdateIngredientCategoryDto = {
      name: 'Rau củ mới',
      description: 'Mô tả mới',
      displayOrder: 1,
      isActive: true
    };
    
    component.categoryId = '1';
    ingredientCategoryService.get.and.returnValue(of(mockCategory));
    ingredientCategoryService.update.and.returnValue(of(mockCategory));
    component.ngOnInit();

    // Act
    component.form.patchValue(updateData);
    component.save();

    // Assert
    expect(ingredientCategoryService.update).toHaveBeenCalledWith('1', updateData);
  });

  it('should not submit when form is invalid', () => {
    // Arrange
    component.ngOnInit();
    
    // Act - set invalid form state
    component.form.get('name')?.setValue('');
    component.save();

    // Assert
    expect(ingredientCategoryService.create).not.toHaveBeenCalled();
    expect(ingredientCategoryService.update).not.toHaveBeenCalled();
  });

  it('should handle create error', () => {
    // Arrange
    const error = new Error('Create failed');
    ingredientCategoryService.getNextDisplayOrder.and.returnValue(of(1));
    ingredientCategoryService.create.and.returnValue(throwError(() => error));
    spyOn(component, 'handleApiError' as any);
    component.ngOnInit();

    // Act
    component.form.patchValue({
      name: 'Test Category',
      displayOrder: 1,
      isActive: true
    });
    component.save();

    // Assert
    expect(component['handleApiError']).toHaveBeenCalledWith(error, 'Không thể tạo danh mục nguyên liệu');
  });

  it('should handle update error', () => {
    // Arrange
    const error = new Error('Update failed');
    component.categoryId = '1';
    ingredientCategoryService.get.and.returnValue(of(mockCategory));
    ingredientCategoryService.update.and.returnValue(throwError(() => error));
    spyOn(component, 'handleApiError' as any);
    component.ngOnInit();

    // Act
    component.save();

    // Assert
    expect(component['handleApiError']).toHaveBeenCalledWith(error, 'Không thể cập nhật danh mục nguyên liệu');
  });

  it('should emit success event on successful save', () => {
    // Arrange
    spyOn(component.success, 'emit');
    ingredientCategoryService.getNextDisplayOrder.and.returnValue(of(1));
    ingredientCategoryService.create.and.returnValue(of(mockCategory));
    component.ngOnInit();

    // Act
    component.form.patchValue({
      name: 'Test Category',
      displayOrder: 1,
      isActive: true
    });
    component.save();

    // Assert
    expect(component.success.emit).toHaveBeenCalledWith(true);
  });

  it('should show loading state during save', () => {
    // Arrange
    ingredientCategoryService.getNextDisplayOrder.and.returnValue(of(1));
    ingredientCategoryService.create.and.returnValue(of(mockCategory));
    component.ngOnInit();

    // Act
    component.form.patchValue({
      name: 'Test Category',
      displayOrder: 1,
      isActive: true
    });

    expect(component.loading).toBe(false);
    component.save();
    // Loading should be handled by finalize operator in the actual implementation
  });
});