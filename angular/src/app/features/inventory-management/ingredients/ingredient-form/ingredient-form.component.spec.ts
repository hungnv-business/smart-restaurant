import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { IngredientFormComponent } from './ingredient-form.component';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { GlobalService } from '../../../../proxy/common';
import { IngredientDto, CreateUpdateIngredientDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { UnitDto } from '../../../../proxy/common/units/dto';
import { PagedResultDto } from '@abp/ng.core';

import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { CheckboxModule } from 'primeng/checkbox';
import { MessageService } from 'primeng/api';

describe('IngredientFormComponent', () => {
  let component: IngredientFormComponent;
  let fixture: ComponentFixture<IngredientFormComponent>;
  let ingredientService: jasmine.SpyObj<IngredientService>;
  let ingredientCategoryService: jasmine.SpyObj<IngredientCategoryService>;
  let globalService: jasmine.SpyObj<GlobalService>;

  const mockCategories: IngredientCategoryDto[] = [
    { id: '1', name: 'Rau củ', description: '', displayOrder: 1, isActive: true },
    { id: '2', name: 'Thịt cá', description: '', displayOrder: 2, isActive: true }
  ];

  const mockUnits: UnitDto[] = [
    { id: '1', name: 'kg', displayOrder: 1, isActive: true },
    { id: '2', name: 'gram', displayOrder: 2, isActive: true },
    { id: '3', name: 'lít', displayOrder: 3, isActive: true }
  ];

  const mockIngredient: IngredientDto = {
    id: '1',
    categoryId: '1',
    name: 'Cà chua',
    description: 'Cà chua tươi',
    unit: 'kg',
    costPerUnit: 25000,
    supplierInfo: 'Chợ Bến Thành',
    isActive: true
  };

  const mockCategoriesPagedResult: PagedResultDto<IngredientCategoryDto> = {
    items: mockCategories,
    totalCount: 2
  };


  beforeEach(async () => {
    const ingredientServiceSpy = jasmine.createSpyObj('IngredientService', 
      ['get', 'create', 'update']);
    const ingredientCategoryServiceSpy = jasmine.createSpyObj('IngredientCategoryService', 
      ['getList']);
    const globalServiceSpy = jasmine.createSpyObj('GlobalService', 
      ['getUnits']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [
        IngredientFormComponent,
        ReactiveFormsModule,
        NoopAnimationsModule,
        DialogModule,
        InputTextModule,
        InputNumber,
        DropdownModule,
        ButtonModule,
        CheckboxModule
      ],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: IngredientService, useValue: ingredientServiceSpy },
        { provide: IngredientCategoryService, useValue: ingredientCategoryServiceSpy },
        { provide: GlobalService, useValue: globalServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(IngredientFormComponent);
    component = fixture.componentInstance;
    ingredientService = TestBed.inject(IngredientService) as jasmine.SpyObj<IngredientService>;
    ingredientCategoryService = TestBed.inject(IngredientCategoryService) as jasmine.SpyObj<IngredientCategoryService>;
    globalService = TestBed.inject(GlobalService) as jasmine.SpyObj<GlobalService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should initialize form with default values for create mode', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));

    // Act
    component.ngOnInit();

    // Assert
    expect(component.form.get('name')?.value).toBe('');
    expect(component.form.get('description')?.value).toBe('');
    expect(component.form.get('categoryId')?.value).toBe('');
    expect(component.form.get('unitId')?.value).toBe('');
    expect(component.form.get('costPerUnit')?.value).toBeNull();
    expect(component.form.get('supplierInfo')?.value).toBe('');
    expect(component.form.get('isActive')?.value).toBe(true);
  });

  it('should load ingredient data in edit mode', () => {
    // Arrange
    component.ingredientId = '1';
    ingredientService.get.and.returnValue(of(mockIngredient));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));

    // Act
    component.ngOnInit();

    // Assert
    expect(ingredientService.get).toHaveBeenCalledWith('1');
    expect(component.form.get('name')?.value).toBe('Cà chua');
    expect(component.form.get('description')?.value).toBe('Cà chua tươi');
    expect(component.form.get('categoryId')?.value).toBe('1');
    expect(component.form.get('costPerUnit')?.value).toBe(25000);
    expect(component.form.get('supplierInfo')?.value).toBe('Chợ Bến Thành');
  });

  it('should validate required fields', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    component.ngOnInit();

    // Act - Test name required
    component.form.get('name')?.setValue('');
    component.form.get('name')?.markAsTouched();

    // Assert
    expect(component.form.get('name')?.errors?.['required']).toBeTruthy();

    // Act - Test categoryId required  
    component.form.get('categoryId')?.setValue('');
    component.form.get('categoryId')?.markAsTouched();

    // Assert
    expect(component.form.get('categoryId')?.errors?.['required']).toBeTruthy();

    // Act - Test unitId required
    component.form.get('unitId')?.setValue('');
    component.form.get('unitId')?.markAsTouched();

    // Assert
    expect(component.form.get('unitId')?.errors?.['required']).toBeTruthy();
    expect(component.form.invalid).toBe(true);
  });

  it('should validate name max length', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    component.ngOnInit();
    const longName = 'a'.repeat(129); // Exceeds 128 character limit

    // Act
    component.form.get('name')?.setValue(longName);

    // Assert
    expect(component.form.get('name')?.errors?.['maxlength']).toBeTruthy();
  });

  it('should validate cost per unit minimum value', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    component.ngOnInit();

    // Act
    component.form.get('costPerUnit')?.setValue(-100);

    // Assert
    expect(component.form.get('costPerUnit')?.errors?.['min']).toBeTruthy();
  });

  it('should create new ingredient when form is valid', () => {
    // Arrange
    const newIngredientData: CreateUpdateIngredientDto = {
      categoryId: '1',
      name: 'Hành tây',
      description: 'Hành tây tươi',
      unitId: '1',
      costPerUnit: 20000,
      supplierInfo: 'Chợ Bến Thành',
      isActive: true
    };
    
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    ingredientService.create.and.returnValue(of(mockIngredient));
    component.ngOnInit();

    // Act
    component.form.patchValue(newIngredientData);
    component.save();

    // Assert
    expect(ingredientService.create).toHaveBeenCalledWith(newIngredientData);
  });

  it('should update existing ingredient when form is valid', () => {
    // Arrange
    const updateData: CreateUpdateIngredientDto = {
      categoryId: '1',
      name: 'Cà chua mới',
      description: 'Mô tả mới',
      unitId: '1',
      costPerUnit: 30000,
      supplierInfo: 'Nhà cung cấp mới',
      isActive: true
    };
    
    component.ingredientId = '1';
    ingredientService.get.and.returnValue(of(mockIngredient));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    ingredientService.update.and.returnValue(of(mockIngredient));
    component.ngOnInit();

    // Act
    component.form.patchValue(updateData);
    component.save();

    // Assert
    expect(ingredientService.update).toHaveBeenCalledWith('1', updateData);
  });

  it('should not submit when form is invalid', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    component.ngOnInit();
    
    // Act - set invalid form state
    component.form.get('name')?.setValue('');
    component.save();

    // Assert
    expect(ingredientService.create).not.toHaveBeenCalled();
    expect(ingredientService.update).not.toHaveBeenCalled();
  });

  it('should handle create error', () => {
    // Arrange
    const error = new Error('Create failed');
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    ingredientService.create.and.returnValue(throwError(() => error));
    spyOn(component, 'handleApiError' as any);
    component.ngOnInit();

    // Act
    component.form.patchValue({
      categoryId: '1',
      name: 'Test Ingredient',
      unitId: '1',
      isActive: true
    });
    component.save();

    // Assert
    expect(component['handleApiError']).toHaveBeenCalledWith(error, 'Không thể tạo nguyên liệu');
  });

  it('should load categories and units dropdown data', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));

    // Act
    component.ngOnInit();

    // Assert
    expect(ingredientCategoryService.getList).toHaveBeenCalledWith({ maxResultCount: 1000, skipCount: 0 });
    expect(globalService.getUnits).toHaveBeenCalled();
    expect(component.categories).toEqual(mockCategories);
    expect(component.units).toEqual(mockUnits);
  });

  it('should emit success event on successful save', () => {
    // Arrange
    spyOn(component.success, 'emit');
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    ingredientService.create.and.returnValue(of(mockIngredient));
    component.ngOnInit();

    // Act
    component.form.patchValue({
      categoryId: '1',
      name: 'Test Ingredient',
      unitId: '1',
      isActive: true
    });
    component.save();

    // Assert
    expect(component.success.emit).toHaveBeenCalledWith(true);
  });

  it('should allow null cost per unit', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    globalService.getUnits.and.returnValue(of(mockUnits));
    component.ngOnInit();

    // Act
    component.form.patchValue({
      categoryId: '1',
      name: 'Test Ingredient',
      unitId: '1',
      costPerUnit: null,
      isActive: true
    });

    // Assert
    expect(component.form.get('costPerUnit')?.value).toBeNull();
    expect(component.form.valid).toBe(true);
  });
});