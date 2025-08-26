import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';
import { ConfirmationService, MessageService } from 'primeng/api';
import { MenuCategoryListComponent } from './menu-category-list.component';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuCategoryFormDialogService } from '../services/menu-category-form-dialog.service';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';

describe('MenuCategoryListComponent', () => {
  let component: MenuCategoryListComponent;
  let fixture: ComponentFixture<MenuCategoryListComponent>;
  let mockMenuCategoryService: jasmine.SpyObj<MenuCategoryService>;
  let mockDialogService: jasmine.SpyObj<MenuCategoryFormDialogService>;
  let mockMessageService: jasmine.SpyObj<MessageService>;
  let mockConfirmationService: jasmine.SpyObj<ConfirmationService>;

  const mockCategories: MenuCategoryDto[] = [
    {
      id: '1',
      name: 'Món khai vị',
      description: 'Các món khai vị truyền thống',
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
    {
      id: '2',
      name: 'Món chính',
      description: 'Các món chính phong phú',
      displayOrder: 2,
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

  beforeEach(async () => {
    const spyMenuCategoryService = jasmine.createSpyObj('MenuCategoryService', [
      'getList',
      'delete',
    ]);
    const spyDialogService = jasmine.createSpyObj('MenuCategoryFormDialogService', [
      'openCreateDialog',
      'openEditDialog',
    ]);
    const spyMessageService = jasmine.createSpyObj('MessageService', ['add']);
    const spyConfirmationService = jasmine.createSpyObj('ConfirmationService', ['confirm']);

    await TestBed.configureTestingModule({
      imports: [MenuCategoryListComponent, NoopAnimationsModule],
      providers: [
        { provide: MenuCategoryService, useValue: spyMenuCategoryService },
        { provide: MenuCategoryFormDialogService, useValue: spyDialogService },
        { provide: MessageService, useValue: spyMessageService },
        { provide: ConfirmationService, useValue: spyConfirmationService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(MenuCategoryListComponent);
    component = fixture.componentInstance;

    mockMenuCategoryService = TestBed.inject(
      MenuCategoryService,
    ) as jasmine.SpyObj<MenuCategoryService>;
    mockDialogService = TestBed.inject(
      MenuCategoryFormDialogService,
    ) as jasmine.SpyObj<MenuCategoryFormDialogService>;
    mockMessageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    mockConfirmationService = TestBed.inject(
      ConfirmationService,
    ) as jasmine.SpyObj<ConfirmationService>;
  });

  it('should create', () => {
    mockMenuCategoryService.getList.and.returnValue(
      of({
        items: [],
        totalCount: 0,
      }),
    );

    expect(component).toBeTruthy();
  });

  it('should load menu categories on init', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(
      of({
        items: mockCategories,
        totalCount: mockCategories.length,
      }),
    );

    // Act
    fixture.detectChanges(); // Triggers ngOnInit
    await fixture.whenStable();

    // Assert
    expect(mockMenuCategoryService.getList).toHaveBeenCalledWith({
      maxResultCount: 1000,
      skipCount: 0,
      sorting: 'displayOrder',
    });
    expect(component.menuCategories).toEqual(mockCategories);
    expect(component.totalRecords).toBe(mockCategories.length);
    expect(component.loading).toBeFalse();
  });

  it('should handle loading error', async () => {
    // Arrange
    const errorMessage = 'Network error';
    mockMenuCategoryService.getList.and.returnValue(throwError({ message: errorMessage }));

    // Act
    fixture.detectChanges();
    await fixture.whenStable();

    // Assert
    expect(component.loading).toBeFalse();
    expect(component.menuCategories).toEqual([]);
  });

  it('should open create dialog', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockDialogService.openCreateDialog.and.returnValue(of(true));

    fixture.detectChanges();

    // Act
    component.openCreateDialog();

    // Assert
    expect(mockDialogService.openCreateDialog).toHaveBeenCalled();
  });

  it('should open edit dialog', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockDialogService.openEditDialog.and.returnValue(of(true));
    const categoryId = '123';

    fixture.detectChanges();

    // Act
    component.openEditDialog(categoryId);

    // Assert
    expect(mockDialogService.openEditDialog).toHaveBeenCalledWith(categoryId);
  });

  it('should show success message after create dialog closes with success', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockDialogService.openCreateDialog.and.returnValue(of(true));

    fixture.detectChanges();

    // Act
    component.openCreateDialog();
    await fixture.whenStable();

    // Assert
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã tạo danh mục mới',
    });
  });

  it('should confirm delete operation', () => {
    // Arrange
    const category = mockCategories[0];
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));

    fixture.detectChanges();

    // Act
    component.confirmDelete(category);

    // Assert
    expect(mockConfirmationService.confirm).toHaveBeenCalledWith({
      message: `Bạn có chắc chắn muốn xóa danh mục "${category.name}"?`,
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: jasmine.any(Function),
    });
  });

  it('should delete category when confirmed', async () => {
    // Arrange
    const category = mockCategories[0];
    mockMenuCategoryService.getList.and.returnValue(of({ items: [category], totalCount: 1 }));
    mockMenuCategoryService.delete.and.returnValue(of(undefined));

    fixture.detectChanges();

    // Act
    await component['deleteCategory'](category.id);

    // Assert
    expect(mockMenuCategoryService.delete).toHaveBeenCalledWith(category.id);
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã xóa danh mục',
    });
  });

  it('should refresh data after successful dialog operations', async () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(
      of({ items: mockCategories, totalCount: mockCategories.length }),
    );
    mockDialogService.openCreateDialog.and.returnValue(of(true));

    fixture.detectChanges();

    // Reset call count after initial load
    mockMenuCategoryService.getList.calls.reset();

    // Act
    component.openCreateDialog();
    await fixture.whenStable();

    // Assert - should reload data after successful dialog
    expect(mockMenuCategoryService.getList).toHaveBeenCalledTimes(1);
  });

  it('should display correct data in template', () => {
    // Arrange
    mockMenuCategoryService.getList.and.returnValue(
      of({
        items: [mockCategories[0]],
        totalCount: 1,
      }),
    );

    // Act
    fixture.detectChanges();

    // Assert
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.textContent).toContain('Món khai vị');
    expect(compiled.textContent).toContain('Các món khai vị truyền thống');
  });
});
