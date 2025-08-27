import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { IngredientListComponent } from './ingredient-list.component';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientFormDialogService } from '../services/ingredient-form-dialog.service';
import { IngredientDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { PagedResultDto } from '@abp/ng.core';

import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { MessageService, ConfirmationService } from 'primeng/api';

describe('IngredientListComponent', () => {
  let component: IngredientListComponent;
  let fixture: ComponentFixture<IngredientListComponent>;
  let ingredientService: jasmine.SpyObj<IngredientService>;
  let ingredientCategoryService: jasmine.SpyObj<IngredientCategoryService>;
  let dialogService: jasmine.SpyObj<IngredientFormDialogService>;

  const mockCategories: IngredientCategoryDto[] = [
    { id: '1', name: 'Rau củ', description: '', displayOrder: 1, isActive: true },
    { id: '2', name: 'Thịt cá', description: '', displayOrder: 2, isActive: true }
  ];

  const mockIngredients: IngredientDto[] = [
    {
      id: '1',
      categoryId: '1',
      name: 'Cà chua',
      description: 'Cà chua tươi',
      unit: 'kg',
      costPerUnit: 25000,
      supplierInfo: 'Chợ Bến Thành',
      isActive: true
    },
    {
      id: '2',
      categoryId: '1',
      name: 'Hành tây',
      description: 'Hành tây tươi',
      unit: 'kg',
      costPerUnit: 20000,
      supplierInfo: 'Chợ Bến Thành',
      isActive: true
    }
  ];

  const mockPagedResult: PagedResultDto<IngredientDto> = {
    items: mockIngredients,
    totalCount: 2
  };

  const mockCategoriesPagedResult: PagedResultDto<IngredientCategoryDto> = {
    items: mockCategories,
    totalCount: 2
  };

  beforeEach(async () => {
    const ingredientServiceSpy = jasmine.createSpyObj('IngredientService', 
      ['getList', 'delete']);
    const ingredientCategoryServiceSpy = jasmine.createSpyObj('IngredientCategoryService', 
      ['getList']);
    const dialogServiceSpy = jasmine.createSpyObj('IngredientFormDialogService', 
      ['openCreateDialog', 'openEditDialog']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [
        IngredientListComponent,
        NoopAnimationsModule,
        TableModule,
        ButtonModule,
        InputTextModule,
        DropdownModule
      ],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: IngredientService, useValue: ingredientServiceSpy },
        { provide: IngredientCategoryService, useValue: ingredientCategoryServiceSpy },
        { provide: IngredientFormDialogService, useValue: dialogServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
        ConfirmationService
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(IngredientListComponent);
    component = fixture.componentInstance;
    ingredientService = TestBed.inject(IngredientService) as jasmine.SpyObj<IngredientService>;
    ingredientCategoryService = TestBed.inject(IngredientCategoryService) as jasmine.SpyObj<IngredientCategoryService>;
    dialogService = TestBed.inject(IngredientFormDialogService) as jasmine.SpyObj<IngredientFormDialogService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load ingredients and categories on init', () => {
    // Arrange
    ingredientService.getList.and.returnValue(of(mockPagedResult));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));

    // Act
    component.ngOnInit();

    // Assert
    expect(ingredientService.getList).toHaveBeenCalled();
    expect(ingredientCategoryService.getList).toHaveBeenCalled();
    expect(component.ingredients()).toEqual(mockIngredients);
    expect(component.categories()).toEqual(mockCategories);
  });

  it('should filter ingredients by category when category selected', () => {
    // Arrange
    const filteredIngredients = [mockIngredients[0]];
    const filteredResult: PagedResultDto<IngredientDto> = {
      items: filteredIngredients,
      totalCount: 1
    };

    ingredientService.getList.and.returnValue(of(filteredResult));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    component.ngOnInit();

    // Act
    component.selectedCategoryId = '1';
    component.onCategoryFilter();

    // Assert
    expect(ingredientService.getList).toHaveBeenCalledWith(
      jasmine.objectContaining({
        filter: jasmine.any(String)
      })
    );
  });

  it('should clear category filter when "Tất cả" selected', () => {
    // Arrange
    ingredientService.getList.and.returnValue(of(mockPagedResult));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));
    component.ngOnInit();

    // Act
    component.selectedCategoryId = null;
    component.onCategoryFilter();

    // Assert
    expect(component.ingredients()).toEqual(mockIngredients);
  });

  it('should open create dialog when openFormDialog called without id', () => {
    // Arrange
    dialogService.openCreateDialog.and.returnValue(of(true));
    spyOn(component, 'loadIngredients' as any);

    // Act
    component.openFormDialog();

    // Assert
    expect(dialogService.openCreateDialog).toHaveBeenCalled();
  });

  it('should open edit dialog when openFormDialog called with id', () => {
    // Arrange
    const ingredientId = '1';
    dialogService.openEditDialog.and.returnValue(of(true));
    spyOn(component, 'loadIngredients' as any);

    // Act
    component.openFormDialog(ingredientId);

    // Assert
    expect(dialogService.openEditDialog).toHaveBeenCalledWith(ingredientId);
  });

  it('should delete ingredient when confirmed', () => {
    // Arrange
    const ingredientToDelete = mockIngredients[0];
    ingredientService.delete.and.returnValue(of(void 0));
    ingredientService.getList.and.returnValue(of(mockPagedResult));
    spyOn(component, 'confirmDelete' as any).and.callFake((_: string, callback: () => void) => {
      callback();
    });

    // Act
    component.deleteIngredient(ingredientToDelete);

    // Assert
    expect(ingredientService.delete).toHaveBeenCalledWith(ingredientToDelete.id);
  });

  it('should handle delete error gracefully', () => {
    // Arrange
    const ingredientToDelete = mockIngredients[0];
    const error = new Error('Delete failed');
    ingredientService.delete.and.returnValue(throwError(() => error));
    spyOn(component, 'confirmDelete' as any).and.callFake((_: string, callback: () => void) => {
      callback();
    });
    spyOn(component, 'handleApiError' as any);

    // Act
    component.deleteIngredient(ingredientToDelete);

    // Assert
    expect(component['handleApiError']).toHaveBeenCalledWith(error, 'Không thể xóa nguyên liệu');
  });

  it('should format currency correctly', () => {
    // Act & Assert
    expect(component.formatCurrency(25000)).toBe('25.000 ₫');
    expect(component.formatCurrency(null)).toBe('Chưa có giá');
    expect(component.formatCurrency(undefined)).toBe('Chưa có giá');
  });

  it('should handle loading state correctly', () => {
    // Arrange
    ingredientService.getList.and.returnValue(of(mockPagedResult));
    ingredientCategoryService.getList.and.returnValue(of(mockCategoriesPagedResult));

    // Act
    expect(component.loading).toBe(false);
    component.ngOnInit();
    
    // Assert - loading state should be managed by finalize operator
    expect(component.loading).toBe(false);
  });

  it('should handle bulk delete when ingredients selected', () => {
    // Arrange
    component.selectedIngredients = mockIngredients;
    spyOn(component, 'confirmBulkDelete' as any).and.callFake((callback: () => void) => {
      callback();
    });
    ingredientService.delete.and.returnValue(of(void 0));
    ingredientService.getList.and.returnValue(of(mockPagedResult));

    // Act
    component.deleteSelectedIngredients();

    // Assert
    expect(ingredientService.delete).toHaveBeenCalledTimes(2);
    expect(ingredientService.delete).toHaveBeenCalledWith('1');
    expect(ingredientService.delete).toHaveBeenCalledWith('2');
  });

  it('should get category name by id correctly', () => {
    // Arrange
    component.categories.set(mockCategories);

    // Act & Assert
    expect(component.getCategoryName('1')).toBe('Rau củ');
    expect(component.getCategoryName('2')).toBe('Thịt cá');
    expect(component.getCategoryName('999')).toBe('N/A');
  });
});