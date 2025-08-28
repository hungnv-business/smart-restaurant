import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { MenuItemFormDialogService } from './menu-item-form-dialog.service';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';
import { MenuItemFormComponent } from '../menu-item-form/menu-item-form.component';

describe('MenuItemFormDialogService', () => {
  let service: MenuItemFormDialogService;
  let mockDialogService: jasmine.SpyObj<DialogService>;
  let mockMenuItemService: jasmine.SpyObj<MenuItemService>;
  let mockDialogRef: jasmine.SpyObj<DynamicDialogRef>;

  const mockMenuItem: MenuItemDto = {
    id: 'item1',
    name: 'Phở Bò Tái',
    description: 'Phở bò với thịt bò tái, hành lá và ngò gai',
    price: 85000,
    isAvailable: true,
    imageUrl: 'https://example.com/pho.jpg',
    categoryId: 'cat1',
    category: {
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
    creationTime: '2025-08-25T00:00:00Z',
    lastModificationTime: null,
    creatorId: null,
    lastModifierId: null,
    isDeleted: false,
    deleterId: null,
    deletionTime: null,
  };

  beforeEach(() => {
    const spyDialogService = jasmine.createSpyObj('DialogService', ['open']);
    const spyMenuItemService = jasmine.createSpyObj('MenuItemService', ['get']);
    const spyDialogRef = jasmine.createSpyObj('DynamicDialogRef', [], {
      onClose: of(true)
    });

    TestBed.configureTestingModule({
      providers: [
        MenuItemFormDialogService,
        { provide: DialogService, useValue: spyDialogService },
        { provide: MenuItemService, useValue: spyMenuItemService },
      ]
    });

    service = TestBed.inject(MenuItemFormDialogService);
    mockDialogService = TestBed.inject(DialogService) as jasmine.SpyObj<DialogService>;
    mockMenuItemService = TestBed.inject(MenuItemService) as jasmine.SpyObj<MenuItemService>;
    mockDialogRef = spyDialogRef;
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should open create dialog with correct configuration', (done) => {
    // Arrange
    mockDialogService.open.and.returnValue(mockDialogRef);

    // Act
    service.openCreateDialog().subscribe(result => {
      // Assert
      expect(result).toBeTrue();
      expect(mockDialogService.open).toHaveBeenCalledWith(
        MenuItemFormComponent,
        jasmine.objectContaining({
          header: 'Thêm món ăn',
          width: '700px',
          modal: true,
          closable: true,
          draggable: false,
          resizable: false,
          data: jasmine.objectContaining({
            title: 'Thêm món ăn',
            menuItemId: undefined,
            menuItem: undefined
          }),
          maximizable: false,
          dismissableMask: false,
          closeOnEscape: true,
          breakpoints: {
            '960px': '80vw',
            '640px': '95vw',
          }
        })
      );
      done();
    });
  });

  it('should open edit dialog and load menu item data', (done) => {
    // Arrange
    const menuItemId = 'item1';
    mockMenuItemService.get.and.returnValue(of(mockMenuItem));
    mockDialogService.open.and.returnValue(mockDialogRef);

    // Act
    service.openEditDialog(menuItemId).subscribe(result => {
      // Assert
      expect(result).toBeTrue();
      expect(mockMenuItemService.get).toHaveBeenCalledWith(menuItemId);
      expect(mockDialogService.open).toHaveBeenCalledWith(
        MenuItemFormComponent,
        jasmine.objectContaining({
          header: 'Cập nhật món ăn',
          data: jasmine.objectContaining({
            title: 'Cập nhật món ăn',
            menuItemId: menuItemId,
            menuItem: mockMenuItem
          })
        })
      );
      done();
    });
  });

  it('should handle error when loading menu item for edit', (done) => {
    // Arrange
    const menuItemId = 'item1';
    const error = { message: 'Not found' };
    mockMenuItemService.get.and.returnValue(throwError(error));

    // Act
    service.openEditDialog(menuItemId).subscribe({
      next: () => {
        fail('Should not emit success');
      },
      error: (err) => {
        // Assert
        expect(err).toBe(error);
        expect(mockMenuItemService.get).toHaveBeenCalledWith(menuItemId);
        expect(mockDialogService.open).not.toHaveBeenCalled();
        done();
      }
    });
  });

  it('should return false when dialog is closed without result', (done) => {
    // Arrange
    const mockDialogRefCancelled = jasmine.createSpyObj('DynamicDialogRef', [], {
      onClose: of(null) // User cancelled
    });
    mockDialogService.open.and.returnValue(mockDialogRefCancelled);

    // Act
    service.openCreateDialog().subscribe(result => {
      // Assert
      expect(result).toBeFalse();
      done();
    });
  });

  it('should return true when dialog is closed with success result', (done) => {
    // Arrange
    const mockDialogRefSuccess = jasmine.createSpyObj('DynamicDialogRef', [], {
      onClose: of(true) // Success
    });
    mockDialogService.open.and.returnValue(mockDialogRefSuccess);

    // Act
    service.openCreateDialog().subscribe(result => {
      // Assert
      expect(result).toBeTrue();
      done();
    });
  });

  it('should use responsive breakpoints in dialog configuration', (done) => {
    // Arrange
    mockDialogService.open.and.returnValue(mockDialogRef);

    // Act
    service.openCreateDialog().subscribe(() => {
      // Assert
      const dialogConfig = mockDialogService.open.calls.mostRecent().args[1];
      expect(dialogConfig.breakpoints).toEqual({
        '960px': '80vw',
        '640px': '95vw',
      });
      expect(dialogConfig.width).toBe('700px');
      done();
    });
  });

  it('should configure dialog as modal and non-draggable', (done) => {
    // Arrange
    mockDialogService.open.and.returnValue(mockDialogRef);

    // Act
    service.openCreateDialog().subscribe(() => {
      // Assert
      const dialogConfig = mockDialogService.open.calls.mostRecent().args[1];
      expect(dialogConfig.modal).toBeTrue();
      expect(dialogConfig.draggable).toBeFalse();
      expect(dialogConfig.resizable).toBeFalse();
      expect(dialogConfig.maximizable).toBeFalse();
      expect(dialogConfig.closable).toBeTrue();
      expect(dialogConfig.closeOnEscape).toBeTrue();
      expect(dialogConfig.dismissableMask).toBeFalse();
      done();
    });
  });

  it('should handle dialog service errors', (done) => {
    // Arrange
    const error = new Error('Dialog service error');
    const mockDialogRefError = jasmine.createSpyObj('DynamicDialogRef', [], {
      onClose: throwError(error)
    });
    mockDialogService.open.and.returnValue(mockDialogRefError);

    // Act
    service.openCreateDialog().subscribe({
      next: () => {
        fail('Should not emit success');
      },
      error: (err) => {
        // Assert
        expect(err).toBe(error);
        done();
      }
    });
  });
});