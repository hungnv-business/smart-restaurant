import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { IngredientCategoryListComponent } from './ingredient-category-list.component';
import { IngredientCategoryService } from '../../../../proxy/inventory-management/ingredient-categories';
import { IngredientCategoryFormDialogService } from '../services/ingredient-category-form-dialog.service';
import { IngredientCategoryDto } from '../../../../proxy/inventory-management/ingredient-categories/dto';
import { PagedResultDto } from '@abp/ng.core';

import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { ToolbarModule } from 'primeng/toolbar';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule } from 'primeng/toast';
import { MessageService, ConfirmationService } from 'primeng/api';

describe('IngredientCategoryListComponent', () => {
  let component: IngredientCategoryListComponent;
  let fixture: ComponentFixture<IngredientCategoryListComponent>;
  let ingredientCategoryService: jasmine.SpyObj<IngredientCategoryService>;
  let dialogService: jasmine.SpyObj<IngredientCategoryFormDialogService>;
  let messageService: jasmine.SpyObj<MessageService>;

  const mockCategories: IngredientCategoryDto[] = [
    {
      id: '1',
      name: 'Rau củ',
      description: 'Rau xanh và củ quả tươi',
      displayOrder: 1,
      isActive: true
    },
    {
      id: '2', 
      name: 'Thịt cá',
      description: 'Thịt, cá và hải sản',
      displayOrder: 2,
      isActive: true
    }
  ];

  const mockPagedResult: PagedResultDto<IngredientCategoryDto> = {
    items: mockCategories,
    totalCount: 2
  };

  beforeEach(async () => {
    const ingredientCategoryServiceSpy = jasmine.createSpyObj('IngredientCategoryService', 
      ['getList', 'delete']);
    const dialogServiceSpy = jasmine.createSpyObj('IngredientCategoryFormDialogService', 
      ['openCreateDialog', 'openEditDialog']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);

    await TestBed.configureTestingModule({
      imports: [
        IngredientCategoryListComponent,
        HttpClientTestingModule,
        NoopAnimationsModule,
        TableModule,
        ButtonModule,
        InputTextModule,
        ToolbarModule,
        ConfirmDialogModule,
        ToastModule
      ],
      providers: [
        { provide: IngredientCategoryService, useValue: ingredientCategoryServiceSpy },
        { provide: IngredientCategoryFormDialogService, useValue: dialogServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
        ConfirmationService
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(IngredientCategoryListComponent);
    component = fixture.componentInstance;
    ingredientCategoryService = TestBed.inject(IngredientCategoryService) as jasmine.SpyObj<IngredientCategoryService>;
    dialogService = TestBed.inject(IngredientCategoryFormDialogService) as jasmine.SpyObj<IngredientCategoryFormDialogService>;
    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load categories on init', () => {
    // Arrange
    ingredientCategoryService.getList.and.returnValue(of(mockPagedResult));

    // Act
    component.ngOnInit();

    // Assert
    expect(ingredientCategoryService.getList).toHaveBeenCalledWith({
      maxResultCount: 1000,
      skipCount: 0,
      sorting: 'displayOrder'
    });
    expect(component.categories()).toEqual(mockCategories);
    expect(component.loading).toBeFalse();
  });

  it('should handle loading error gracefully', () => {
    // Arrange
    const error = new Error('API Error');
    ingredientCategoryService.getList.and.returnValue(throwError(() => error));
    spyOn(console, 'error');

    // Act
    component.ngOnInit();

    // Assert
    expect(console.error).toHaveBeenCalledWith('Error loading ingredient categories:', error);
    expect(component.categories()).toEqual([]);
    expect(component.loading).toBeFalse();
  });

  it('should open create dialog when openFormDialog called without id', () => {
    // Arrange
    dialogService.openCreateDialog.and.returnValue(of(true));
    ingredientCategoryService.getList.and.returnValue(of(mockPagedResult));
    spyOn(component, 'loadCategories' as any);

    // Act
    component.openFormDialog();

    // Assert
    expect(dialogService.openCreateDialog).toHaveBeenCalled();
  });

  it('should open edit dialog when openFormDialog called with id', () => {
    // Arrange
    const categoryId = '1';
    dialogService.openEditDialog.and.returnValue(of(true));
    ingredientCategoryService.getList.and.returnValue(of(mockPagedResult));
    spyOn(component, 'loadCategories' as any);

    // Act
    component.openFormDialog(categoryId);

    // Assert
    expect(dialogService.openEditDialog).toHaveBeenCalledWith(categoryId);
  });

  it('should delete category when confirmed', () => {
    // Arrange
    const categoryToDelete = mockCategories[0];
    ingredientCategoryService.delete.and.returnValue(of(void 0));
    ingredientCategoryService.getList.and.returnValue(of(mockPagedResult));
    spyOn(component, 'confirmDelete' as any).and.callFake((name: string, callback: () => void) => {
      callback();
    });

    // Act
    component.deleteCategory(categoryToDelete);

    // Assert
    expect(ingredientCategoryService.delete).toHaveBeenCalledWith(categoryToDelete.id);
  });

  it('should handle delete error', () => {
    // Arrange
    const categoryToDelete = mockCategories[0];
    const error = new Error('Delete failed');
    ingredientCategoryService.delete.and.returnValue(throwError(() => error));
    spyOn(component, 'confirmDelete' as any).and.callFake((name: string, callback: () => void) => {
      callback();
    });
    spyOn(component, 'handleApiError' as any);

    // Act
    component.deleteCategory(categoryToDelete);

    // Assert
    expect(component['handleApiError']).toHaveBeenCalledWith(error, 'Không thể xóa danh mục nguyên liệu');
  });

  it('should filter data globally when onGlobalFilter called', () => {
    // Arrange
    const mockTable = jasmine.createSpyObj('Table', ['filterGlobal']);
    const mockEvent = {
      target: { value: 'Rau' }
    } as any;

    // Act
    component.onGlobalFilter(mockTable, mockEvent);

    // Assert
    expect(mockTable.filterGlobal).toHaveBeenCalledWith('Rau', 'contains');
  });

  it('should handle bulk delete when categories selected', () => {
    // Arrange
    component.selectedCategories = mockCategories;
    spyOn(component, 'confirmBulkDelete' as any).and.callFake((callback: () => void) => {
      callback();
    });
    ingredientCategoryService.delete.and.returnValue(of(void 0));
    ingredientCategoryService.getList.and.returnValue(of(mockPagedResult));

    // Act
    component.deleteSelectedCategories();

    // Assert
    expect(ingredientCategoryService.delete).toHaveBeenCalledTimes(2);
    expect(ingredientCategoryService.delete).toHaveBeenCalledWith('1');
    expect(ingredientCategoryService.delete).toHaveBeenCalledWith('2');
  });

  it('should not delete when no categories selected', () => {
    // Arrange
    component.selectedCategories = [];

    // Act
    component.deleteSelectedCategories();

    // Assert
    expect(ingredientCategoryService.delete).not.toHaveBeenCalled();
  });
});