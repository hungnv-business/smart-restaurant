import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';
import { ConfirmationService, MessageService } from 'primeng/api';
import { MenuItemListComponent } from './menu-item-list.component';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuCategoryService } from '../../../../proxy/menu-management/menu-categories';
import { MenuItemFormDialogService } from '../services/menu-item-form-dialog.service';
import { MenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';
import { MenuCategoryDto } from '../../../../proxy/menu-management/menu-categories/dto';

describe('MenuItemListComponent', () => {
  let component: MenuItemListComponent;
  let fixture: ComponentFixture<MenuItemListComponent>;
  let mockMenuItemService: jasmine.SpyObj<MenuItemService>;
  let mockMenuCategoryService: jasmine.SpyObj<MenuCategoryService>;
  let mockDialogService: jasmine.SpyObj<MenuItemFormDialogService>;
  let mockMessageService: jasmine.SpyObj<MessageService>;
  let mockConfirmationService: jasmine.SpyObj<ConfirmationService>;

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

  const mockMenuItems: MenuItemDto[] = [
    {
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
    },
    {
      id: 'item2',
      name: 'Phở Gà',
      description: 'Phở gà truyền thống',
      price: 75000,
      isAvailable: false,
      imageUrl: null,
      categoryId: 'cat1',
      category: mockCategories[0],
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
    const spyMenuItemService = jasmine.createSpyObj('MenuItemService', [
      'getList',
      'delete',
      'updateAvailability',
    ]);
    const spyMenuCategoryService = jasmine.createSpyObj('MenuCategoryService', [
      'getList',
    ]);
    const spyDialogService = jasmine.createSpyObj('MenuItemFormDialogService', [
      'openCreateDialog',
      'openEditDialog',
    ]);
    const spyMessageService = jasmine.createSpyObj('MessageService', ['add']);
    const spyConfirmationService = jasmine.createSpyObj('ConfirmationService', ['confirm']);

    await TestBed.configureTestingModule({
      imports: [MenuItemListComponent, NoopAnimationsModule],
      providers: [
        { provide: MenuItemService, useValue: spyMenuItemService },
        { provide: MenuCategoryService, useValue: spyMenuCategoryService },
        { provide: MenuItemFormDialogService, useValue: spyDialogService },
        { provide: MessageService, useValue: spyMessageService },
        { provide: ConfirmationService, useValue: spyConfirmationService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(MenuItemListComponent);
    component = fixture.componentInstance;

    mockMenuItemService = TestBed.inject(MenuItemService) as jasmine.SpyObj<MenuItemService>;
    mockMenuCategoryService = TestBed.inject(MenuCategoryService) as jasmine.SpyObj<MenuCategoryService>;
    mockDialogService = TestBed.inject(MenuItemFormDialogService) as jasmine.SpyObj<MenuItemFormDialogService>;
    mockMessageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    mockConfirmationService = TestBed.inject(ConfirmationService) as jasmine.SpyObj<ConfirmationService>;
  });

  it('should create', () => {
    mockMenuItemService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));

    expect(component).toBeTruthy();
  });

  it('should load menu items on init', async () => {
    // Arrange
    mockMenuItemService.getList.and.returnValue(
      of({
        items: mockMenuItems,
        totalCount: mockMenuItems.length,
      }),
    );
    mockMenuCategoryService.getList.and.returnValue(
      of({
        items: mockCategories,
        totalCount: mockCategories.length,
      }),
    );

    // Act
    fixture.detectChanges();
    await fixture.whenStable();

    // Assert
    expect(mockMenuItemService.getList).toHaveBeenCalled();
    expect(mockMenuCategoryService.getList).toHaveBeenCalled();
    expect(component.menuItems).toEqual(mockMenuItems);
    expect(component.totalRecords).toBe(mockMenuItems.length);
    expect(component.loading).toBeFalse();
  });

  it('should handle loading error', async () => {
    // Arrange
    mockMenuItemService.getList.and.returnValue(throwError({ message: 'Network error' }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));

    // Act
    fixture.detectChanges();
    await fixture.whenStable();

    // Assert
    expect(component.loading).toBeFalse();
    expect(component.menuItems).toEqual([]);
  });

  it('should open create dialog', () => {
    // Arrange
    mockMenuItemService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
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
    mockMenuItemService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockDialogService.openEditDialog.and.returnValue(of(true));
    const itemId = 'item1';

    fixture.detectChanges();

    // Act
    component.openEditDialog(itemId);

    // Assert
    expect(mockDialogService.openEditDialog).toHaveBeenCalledWith(itemId);
  });

  it('should toggle availability status', async () => {
    // Arrange
    const menuItem = mockMenuItems[0];
    mockMenuItemService.getList.and.returnValue(of({ items: [menuItem], totalCount: 1 }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockMenuItemService.updateAvailability.and.returnValue(of(undefined));
    mockConfirmationService.confirm.and.callFake((config: any) => {
      config.accept();
    });

    fixture.detectChanges();

    // Act
    component.toggleAvailability(menuItem);
    await fixture.whenStable();

    // Assert
    expect(mockConfirmationService.confirm).toHaveBeenCalled();
    expect(mockMenuItemService.updateAvailability).toHaveBeenCalledWith(menuItem.id, !menuItem.isAvailable);
  });

  it('should confirm delete operation', () => {
    // Arrange
    const menuItem = mockMenuItems[0];
    mockMenuItemService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));

    fixture.detectChanges();

    // Act
    component.confirmDelete(menuItem);

    // Assert
    expect(mockConfirmationService.confirm).toHaveBeenCalledWith({
      message: `Bạn có chắc chắn muốn xóa món "${menuItem.name}"?`,
      header: 'Xác nhận xóa',
      icon: 'pi pi-exclamation-triangle',
      accept: jasmine.any(Function),
    });
  });

  it('should delete menu item when confirmed', async () => {
    // Arrange
    const menuItem = mockMenuItems[0];
    mockMenuItemService.getList.and.returnValue(of({ items: [menuItem], totalCount: 1 }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: [], totalCount: 0 }));
    mockMenuItemService.delete.and.returnValue(of(undefined));

    fixture.detectChanges();

    // Act
    await component['deleteMenuItem'](menuItem.id);

    // Assert
    expect(mockMenuItemService.delete).toHaveBeenCalledWith(menuItem.id);
    expect(mockMessageService.add).toHaveBeenCalledWith({
      severity: 'success',
      summary: 'Thành công',
      detail: 'Đã xóa món ăn',
    });
  });

  it('should filter by category', async () => {
    // Arrange
    const categoryId = 'cat1';
    mockMenuItemService.getList.and.returnValue(of({ items: mockMenuItems, totalCount: mockMenuItems.length }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: mockCategories.length }));

    fixture.detectChanges();

    // Act
    component.onCategoryFilter(categoryId);
    await fixture.whenStable();

    // Assert
    expect(component.selectedCategoryId).toBe(categoryId);
    expect(mockMenuItemService.getList).toHaveBeenCalledTimes(2); // Initial load + filter
  });

  it('should search menu items', async () => {
    // Arrange
    const searchTerm = 'Phở';
    mockMenuItemService.getList.and.returnValue(of({ items: mockMenuItems, totalCount: mockMenuItems.length }));
    mockMenuCategoryService.getList.and.returnValue(of({ items: mockCategories, totalCount: mockCategories.length }));

    fixture.detectChanges();

    // Act
    component.onGlobalFilter(searchTerm);
    await fixture.whenStable();

    // Assert
    expect(component.globalFilter).toBe(searchTerm);
    expect(mockMenuItemService.getList).toHaveBeenCalledTimes(2); // Initial load + search
  });

  it('should refresh data after successful dialog operations', async () => {
    // Arrange
    mockMenuItemService.getList.and.returnValue(
      of({ items: mockMenuItems, totalCount: mockMenuItems.length }),
    );
    mockMenuCategoryService.getList.and.returnValue(
      of({ items: mockCategories, totalCount: mockCategories.length }),
    );
    mockDialogService.openCreateDialog.and.returnValue(of(true));

    fixture.detectChanges();

    // Reset call count after initial load
    mockMenuItemService.getList.calls.reset();

    // Act
    component.openCreateDialog();
    await fixture.whenStable();

    // Assert - should reload data after successful dialog
    expect(mockMenuItemService.getList).toHaveBeenCalledTimes(1);
  });
});