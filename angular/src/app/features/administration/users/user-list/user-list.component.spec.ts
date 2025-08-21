import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { ConfirmationService } from 'primeng/api';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

import { UserListComponent } from './user-list.component';
import { IdentityUserService } from '@abp/ng.identity/proxy';
import { IdentityUserDto, GetIdentityUsersInput, IdentityRoleDto } from '@abp/ng.identity/proxy';
import { MessageService } from 'primeng/api';
import { PermissionService } from '@abp/ng.core';

describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let identityUserService: jasmine.SpyObj<IdentityUserService>;
  let confirmationService: jasmine.SpyObj<ConfirmationService>;
  let messageService: jasmine.SpyObj<MessageService>;
  let permissionService: jasmine.SpyObj<PermissionService>;

  const mockUsers: IdentityUserDto[] = [
    {
      id: '1',
      userName: 'admin',
      email: 'admin@test.com',
      name: 'Admin',
      surname: 'User',
      phoneNumber: '0123456789',
      isActive: true,
      emailConfirmed: true,
      phoneNumberConfirmed: false,
      lockoutEnabled: true,
      accessFailedCount: 0,
      concurrencyStamp: 'stamp1',
      creationTime: '2024-01-01T00:00:00Z',
      creatorId: null,
      lastModificationTime: null,
      lastModifierId: null,
      extraProperties: {}
    },
    {
      id: '2',
      userName: 'user1',
      email: 'user1@test.com',
      name: 'Test',
      surname: 'User',
      phoneNumber: '0987654321',
      isActive: false,
      emailConfirmed: true,
      phoneNumberConfirmed: true,
      lockoutEnabled: false,
      accessFailedCount: 2,
      concurrencyStamp: 'stamp2',
      creationTime: '2024-01-02T00:00:00Z',
      creatorId: '1',
      lastModificationTime: '2024-01-03T00:00:00Z',
      lastModifierId: '1',
      extraProperties: {}
    }
  ];

  const mockRoles: IdentityRoleDto[] = [
    {
      id: 'role1',
      name: 'Admin',
      isDefault: false,
      isStatic: true,
      isPublic: false,
      concurrencyStamp: 'role-stamp1',
      extraProperties: {}
    },
    {
      id: 'role2',
      name: 'User',
      isDefault: true,
      isStatic: false,
      isPublic: true,
      concurrencyStamp: 'role-stamp2',
      extraProperties: {}
    }
  ];

  beforeEach(async () => {
    const identityUserServiceSpy = jasmine.createSpyObj('IdentityUserService', [
      'getList',
      'getRoles',
      'delete'
    ]);
    const confirmationServiceSpy = jasmine.createSpyObj('ConfirmationService', ['confirm']);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);
    const permissionServiceSpy = jasmine.createSpyObj('PermissionService', ['getGrantedPolicy']);

    await TestBed.configureTestingModule({
      imports: [
        UserListComponent,
        NoopAnimationsModule
      ],
      providers: [
        { provide: IdentityUserService, useValue: identityUserServiceSpy },
        { provide: ConfirmationService, useValue: confirmationServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
        { provide: PermissionService, useValue: permissionServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
    identityUserService = TestBed.inject(IdentityUserService) as jasmine.SpyObj<IdentityUserService>;
    confirmationService = TestBed.inject(ConfirmationService) as jasmine.SpyObj<ConfirmationService>;
    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    permissionService = TestBed.inject(PermissionService) as jasmine.SpyObj<PermissionService>;
  });

  beforeEach(() => {
    // Setup default spy returns
    identityUserService.getList.and.returnValue(of({
      items: mockUsers,
      totalCount: mockUsers.length
    }));
    
    identityUserService.getRoles.and.returnValue(of({
      items: [mockRoles[0]]
    }));
    
    identityUserService.delete.and.returnValue(of(undefined));
    permissionService.getGrantedPolicy.and.returnValue(true);
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('Component Initialization', () => {
    it('should initialize with empty users array', () => {
      expect(component.users()).toEqual([]);
    });

    it('should load users on ngOnInit', () => {
      component.ngOnInit();
      
      expect(identityUserService.getList).toHaveBeenCalledWith({
        maxResultCount: 50
      });
      expect(component.users()).toEqual(jasmine.any(Array));
    });

    it('should set filter fields correctly', () => {
      expect(component.filterFields).toEqual(['userName', 'email', 'name', 'surname', 'phoneNumber']);
    });

    it('should set permissions constants', () => {
      expect(component.PERMISSIONS).toBeDefined();
    });
  });

  describe('User Loading', () => {
    it('should load users successfully', () => {
      component.ngOnInit();
      
      expect(identityUserService.getList).toHaveBeenCalledWith({
        maxResultCount: 50
      });
      expect(identityUserService.getRoles).toHaveBeenCalledTimes(mockUsers.length);
    });

    it('should handle user loading error', () => {
      identityUserService.getList.and.returnValue(throwError(() => new Error('API Error')));
      spyOn(console, 'error');
      
      component.ngOnInit();
      
      expect(console.error).toHaveBeenCalledWith('Error loading data:', jasmine.any(Error));
      expect(component.users()).toEqual([]);
    });

    it('should load user roles after loading users', () => {
      component.ngOnInit();
      
      expect(identityUserService.getRoles).toHaveBeenCalledWith('1');
      expect(identityUserService.getRoles).toHaveBeenCalledWith('2');
    });

    it('should handle user roles loading error', () => {
      identityUserService.getRoles.and.returnValue(throwError(() => new Error('Roles API Error')));
      spyOn(console, 'error');
      
      component.ngOnInit();
      
      expect(console.error).toHaveBeenCalledWith('Error loading user roles:', jasmine.any(Error));
    });

    it('should skip role loading when no users exist', () => {
      identityUserService.getList.and.returnValue(of({
        items: [],
        totalCount: 0
      }));
      
      component.ngOnInit();
      
      expect(identityUserService.getRoles).not.toHaveBeenCalled();
    });
  });

  describe('Dialog Operations', () => {
    it('should open create dialog', () => {
      component.openCreateDialog();
      
      expect(component.selectedUserId).toBeUndefined();
      expect(component.userDialogVisible).toBe(true);
    });

    it('should open edit dialog with user ID', () => {
      const userId = 'test-user-id';
      
      component.openEditDialog(userId);
      
      expect(component.selectedUserId).toBe(userId);
      expect(component.userDialogVisible).toBe(true);
    });

    it('should handle user saved event', () => {
      spyOn(component, 'loadUsers');
      component.userDialogVisible = true;
      
      component.onUserSaved();
      
      expect(component.loadUsers).toHaveBeenCalled();
      expect(component.userDialogVisible).toBe(false);
    });
  });

  describe('Single User Deletion', () => {
    it('should show confirmation dialog for user deletion', () => {
      const user = mockUsers[0];
      
      component.deleteUser(user);
      
      expect(confirmationService.confirm).toHaveBeenCalledWith({
        message: `Bạn có chắc chắn muốn xóa ${user.userName}?`,
        header: 'Xác nhận',
        icon: 'pi pi-exclamation-triangle',
        acceptLabel: 'Xoá',
        rejectLabel: 'Huỷ',
        accept: jasmine.any(Function)
      });
    });

    it('should delete user when confirmed', () => {
      const user = mockUsers[0];
      spyOn(component, 'showSuccess');
      spyOn(component, 'loadUsers');
      
      // Simulate confirmation accept
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      component.deleteUser(user);
      
      expect(identityUserService.delete).toHaveBeenCalledWith(user.id);
      expect(component.loadUsers).toHaveBeenCalled();
      expect(component.showSuccess).toHaveBeenCalledWith('Thành công', 'Đã xóa người dùng');
    });

    it('should handle delete user error', () => {
      const user = mockUsers[0];
      const error = new Error('Delete failed');
      identityUserService.delete.and.returnValue(throwError(() => error));
      spyOn(component, 'handleApiError');
      
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      component.deleteUser(user);
      
      expect(component.handleApiError).toHaveBeenCalledWith(error, 'Không thể xóa người dùng');
    });
  });

  describe('Bulk User Deletion', () => {
    beforeEach(() => {
      component.selectedUsers = [mockUsers[0], mockUsers[1]];
    });

    it('should show confirmation dialog for bulk deletion', () => {
      component.deleteSelectedUsers();
      
      expect(confirmationService.confirm).toHaveBeenCalledWith({
        message: 'Bạn có chắc chắn muốn xóa các người dùng đã chọn?',
        header: 'Xác nhận',
        icon: 'pi pi-exclamation-triangle',
        acceptLabel: 'Xoá',
        rejectLabel: 'Huỷ',
        accept: jasmine.any(Function)
      });
    });

    it('should not show confirmation when no users selected', () => {
      component.selectedUsers = [];
      
      component.deleteSelectedUsers();
      
      expect(confirmationService.confirm).not.toHaveBeenCalled();
    });

    it('should not show confirmation when selectedUsers is null', () => {
      component.selectedUsers = null;
      
      component.deleteSelectedUsers();
      
      expect(confirmationService.confirm).not.toHaveBeenCalled();
    });

    it('should delete selected users when confirmed', () => {
      spyOn(component, 'showSuccess');
      spyOn(component, 'loadUsers');
      
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      component.deleteSelectedUsers();
      
      expect(identityUserService.delete).toHaveBeenCalledWith('1');
      expect(identityUserService.delete).toHaveBeenCalledWith('2');
      expect(component.loadUsers).toHaveBeenCalled();
      expect(component.selectedUsers).toEqual([]);
      expect(component.showSuccess).toHaveBeenCalledWith('Thành công', 'Đã xóa 2 người dùng');
    });

    it('should handle bulk delete error', () => {
      const error = new Error('Bulk delete failed');
      identityUserService.delete.and.returnValue(throwError(() => error));
      spyOn(component, 'handleApiError');
      spyOn(component, 'loadUsers');
      
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      component.deleteSelectedUsers();
      
      expect(component.handleApiError).toHaveBeenCalledWith(error, 'Có lỗi xảy ra khi xóa người dùng');
      expect(component.loadUsers).toHaveBeenCalled();
    });
  });

  describe('Display Helpers', () => {
    it('should get user roles as string', () => {
      const userWithRoles = { ...mockUsers[0], roles: ['Admin', 'User'] };
      spyOn(component, 'getRoleLabel').and.returnValues('Quản trị viên', 'Người dùng');
      
      const result = component.getUserRoles(userWithRoles);
      
      expect(result).toBe('Quản trị viên, Người dùng');
    });

    it('should return -- for user with no roles', () => {
      const userWithoutRoles = { ...mockUsers[0], roles: [] };
      
      const result = component.getUserRoles(userWithoutRoles);
      
      expect(result).toBe('--');
    });

    it('should return -- for user with null/undefined roles', () => {
      const userWithNullRoles = { ...mockUsers[0], roles: null };
      
      const result = component.getUserRoles(userWithNullRoles);
      
      expect(result).toBe('--');
    });

    it('should get user full name', () => {
      const user = mockUsers[0];
      
      const result = component.getUserFullName(user);
      
      // Should call inherited getFullName method
      expect(result).toBeDefined();
    });

    it('should get status label in Vietnamese', () => {
      expect(component.getStatusLabel(true)).toBe('Hoạt động');
      expect(component.getStatusLabel(false)).toBe('Vô hiệu');
    });
  });

  describe('Table Operations', () => {
    it('should filter table globally', () => {
      const mockTable = jasmine.createSpyObj('Table', ['filterGlobal']);
      const mockEvent = {
        target: { value: 'search term' }
      } as any;
      
      component.onGlobalFilter(mockTable, mockEvent);
      
      expect(mockTable.filterGlobal).toHaveBeenCalledWith('search term', 'contains');
    });
  });

  describe('Component Integration', () => {
    it('should have correct template structure', () => {
      const compiled = fixture.nativeElement as HTMLElement;
      fixture.detectChanges();
      
      // Should render the component without errors
      expect(compiled).toBeTruthy();
    });

    it('should handle component lifecycle correctly', () => {
      // Component should initialize properly
      expect(component.users()).toBeDefined();
      expect(component.filterFields).toBeDefined();
    });
  });

  describe('Error Handling', () => {
    it('should handle API errors gracefully', () => {
      const error = new Error('Network error');
      identityUserService.getList.and.returnValue(throwError(() => error));
      spyOn(console, 'error');
      
      component.ngOnInit();
      
      expect(component.users()).toEqual([]);
      expect(console.error).toHaveBeenCalled();
    });

    it('should handle role loading errors without breaking user list', () => {
      identityUserService.getRoles.and.returnValue(throwError(() => new Error('Role loading failed')));
      spyOn(console, 'error');
      
      component.ngOnInit();
      
      expect(console.error).toHaveBeenCalledWith('Error loading user roles:', jasmine.any(Error));
      // Users should still be loaded even if roles fail
      expect(component.users().length).toBeGreaterThan(0);
    });
  });
});