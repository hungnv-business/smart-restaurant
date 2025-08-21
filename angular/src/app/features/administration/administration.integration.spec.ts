import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { Location } from '@angular/common';
import { Component } from '@angular/core';
import { of, throwError } from 'rxjs';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { RouterTestingModule } from '@angular/router/testing';

import { UserListComponent } from './users/user-list/user-list.component';
import { RoleFormComponent } from './roles/role-form/role-form.component';
import { PermissionTreeService } from './services/permission-tree.service';
import { IdentityUserService, IdentityRoleService } from '@abp/ng.identity/proxy';
import { PermissionsService } from '@abp/ng.permission-management/proxy';
import { MessageService, ConfirmationService } from 'primeng/api';
import { PermissionService } from '@abp/ng.core';

// Mock components for routing tests
@Component({
  template: '<div>Users Page</div>'
})
class MockUsersComponent { }

@Component({
  template: '<div>Roles Page</div>'
})
class MockRolesComponent { }

describe('Administration Module Integration Tests', () => {
  let userListComponent: UserListComponent;
  let userListFixture: ComponentFixture<UserListComponent>;
  let roleFormComponent: RoleFormComponent;
  let roleFormFixture: ComponentFixture<RoleFormComponent>;
  let router: Router;
  let location: Location;
  
  let identityUserService: jasmine.SpyObj<IdentityUserService>;
  let identityRoleService: jasmine.SpyObj<IdentityRoleService>;
  let permissionsService: jasmine.SpyObj<PermissionsService>;
  let permissionTreeService: PermissionTreeService;
  let messageService: jasmine.SpyObj<MessageService>;
  let confirmationService: jasmine.SpyObj<ConfirmationService>;
  let permissionService: jasmine.SpyObj<PermissionService>;

  const mockUsers = [
    {
      id: '1',
      userName: 'admin',
      email: 'admin@test.com',
      name: 'Admin',
      surname: 'User',
      isActive: true,
      phoneNumber: '0123456789',
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
      isActive: false,
      phoneNumber: '0987654321',
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

  const mockRoles = [
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

  const mockPermissions = {
    entityDisplayName: 'Role',
    groups: [
      {
        name: 'UserManagement',
        displayName: 'User Management',
        permissions: [
          {
            name: 'UserManagement.Users',
            displayName: 'User Management',
            parentName: null,
            isGranted: false,
            allowedProviders: []
          },
          {
            name: 'UserManagement.Users.Create',
            displayName: 'Create User',
            parentName: 'UserManagement.Users',
            isGranted: false,
            allowedProviders: []
          }
        ]
      }
    ]
  };

  beforeEach(async () => {
    const identityUserServiceSpy = jasmine.createSpyObj('IdentityUserService', [
      'getList', 'getRoles', 'create', 'update', 'delete'
    ]);
    const identityRoleServiceSpy = jasmine.createSpyObj('IdentityRoleService', [
      'getList', 'get', 'create', 'update', 'delete'
    ]);
    const permissionsServiceSpy = jasmine.createSpyObj('PermissionsService', [
      'get', 'update'
    ]);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);
    const confirmationServiceSpy = jasmine.createSpyObj('ConfirmationService', ['confirm']);
    const permissionServiceSpy = jasmine.createSpyObj('PermissionService', [
      'getGrantedPolicy'
    ]);

    await TestBed.configureTestingModule({
      imports: [
        UserListComponent,
        RoleFormComponent,
        NoopAnimationsModule,
        RouterTestingModule.withRoutes([
          { path: 'users', component: MockUsersComponent },
          { path: 'roles', component: MockRolesComponent }
        ])
      ],
      declarations: [MockUsersComponent, MockRolesComponent],
      providers: [
        PermissionTreeService,
        { provide: IdentityUserService, useValue: identityUserServiceSpy },
        { provide: IdentityRoleService, useValue: identityRoleServiceSpy },
        { provide: PermissionsService, useValue: permissionsServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
        { provide: ConfirmationService, useValue: confirmationServiceSpy },
        { provide: PermissionService, useValue: permissionServiceSpy }
      ]
    }).compileComponents();

    router = TestBed.inject(Router);
    location = TestBed.inject(Location);
    identityUserService = TestBed.inject(IdentityUserService) as jasmine.SpyObj<IdentityUserService>;
    identityRoleService = TestBed.inject(IdentityRoleService) as jasmine.SpyObj<IdentityRoleService>;
    permissionsService = TestBed.inject(PermissionsService) as jasmine.SpyObj<PermissionsService>;
    permissionTreeService = TestBed.inject(PermissionTreeService);
    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    confirmationService = TestBed.inject(ConfirmationService) as jasmine.SpyObj<ConfirmationService>;
    permissionService = TestBed.inject(PermissionService) as jasmine.SpyObj<PermissionService>;

    // Setup default spy returns
    setupDefaultSpyReturns();
  });

  function setupDefaultSpyReturns() {
    identityUserService.getList.and.returnValue(of({
      items: mockUsers,
      totalCount: mockUsers.length
    }));
    
    identityUserService.getRoles.and.returnValue(of({
      items: [mockRoles[0]]
    }));
    
    identityUserService.create.and.returnValue(of(mockUsers[0]));
    identityUserService.update.and.returnValue(of(mockUsers[0]));
    identityUserService.delete.and.returnValue(of(undefined));
    
    identityRoleService.getList.and.returnValue(of({
      items: mockRoles,
      totalCount: mockRoles.length
    }));
    
    identityRoleService.get.and.returnValue(of(mockRoles[0]));
    identityRoleService.create.and.returnValue(of(mockRoles[0]));
    identityRoleService.update.and.returnValue(of(mockRoles[0]));
    identityRoleService.delete.and.returnValue(of(undefined));
    
    permissionsService.get.and.returnValue(of(mockPermissions));
    permissionsService.update.and.returnValue(of(undefined));
    
    permissionService.getGrantedPolicy.and.returnValue(true);
  }

  function createUserListComponent() {
    userListFixture = TestBed.createComponent(UserListComponent);
    userListComponent = userListFixture.componentInstance;
    userListFixture.detectChanges();
  }

  function createRoleFormComponent() {
    roleFormFixture = TestBed.createComponent(RoleFormComponent);
    roleFormComponent = roleFormFixture.componentInstance;
    roleFormComponent.visible = true;
    roleFormFixture.detectChanges();
  }

  describe('User Management Workflow', () => {
    beforeEach(() => {
      createUserListComponent();
    });

    it('should load users and their roles on initialization', async () => {
      expect(identityUserService.getList).toHaveBeenCalledWith({
        maxResultCount: 50
      });
      expect(identityUserService.getRoles).toHaveBeenCalledTimes(mockUsers.length);
      expect(userListComponent.users().length).toBe(mockUsers.length);
    });

    it('should handle user creation workflow', async () => {
      // Open create dialog
      userListComponent.openCreateDialog();
      
      expect(userListComponent.userDialogVisible).toBe(true);
      expect(userListComponent.selectedUserId).toBeUndefined();
      
      // Simulate user saved
      userListComponent.onUserSaved();
      
      expect(userListComponent.userDialogVisible).toBe(false);
      expect(identityUserService.getList).toHaveBeenCalledTimes(2); // Initial load + reload after save
    });

    it('should handle user editing workflow', async () => {
      const userId = 'test-user-id';
      
      // Open edit dialog
      userListComponent.openEditDialog(userId);
      
      expect(userListComponent.userDialogVisible).toBe(true);
      expect(userListComponent.selectedUserId).toBe(userId);
      
      // Simulate user saved
      userListComponent.onUserSaved();
      
      expect(userListComponent.userDialogVisible).toBe(false);
      expect(identityUserService.getList).toHaveBeenCalledTimes(2);
    });

    it('should handle single user deletion workflow', async () => {
      const user = mockUsers[0];
      
      // Setup confirmation to accept deletion
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      userListComponent.deleteUser(user);
      
      expect(confirmationService.confirm).toHaveBeenCalled();
      expect(identityUserService.delete).toHaveBeenCalledWith(user.id);
      expect(identityUserService.getList).toHaveBeenCalledTimes(2); // Initial + reload after delete
    });

    it('should handle bulk user deletion workflow', async () => {
      userListComponent.selectedUsers = [mockUsers[0], mockUsers[1]];
      
      confirmationService.confirm.and.callFake((options: any) => {
        options.accept();
      });
      
      userListComponent.deleteSelectedUsers();
      
      expect(confirmationService.confirm).toHaveBeenCalled();
      expect(identityUserService.delete).toHaveBeenCalledTimes(2);
      expect(userListComponent.selectedUsers).toEqual([]);
      expect(identityUserService.getList).toHaveBeenCalledTimes(2);
    });

    it('should handle API errors gracefully during user operations', async () => {
      const error = new Error('API Error');
      identityUserService.getList.and.returnValue(throwError(() => error));
      spyOn(console, 'error');
      
      userListComponent.ngOnInit();
      
      expect(console.error).toHaveBeenCalledWith('Error loading data:', error);
      expect(userListComponent.users()).toEqual([]);
    });
  });

  describe('Role Management Workflow', () => {
    beforeEach(() => {
      createRoleFormComponent();
    });

    it('should load permissions on initialization', async () => {
      expect(permissionsService.get).toHaveBeenCalledWith('R', '');
      expect(roleFormComponent.availablePermissions).toEqual(mockPermissions);
    });

    it('should handle role creation workflow', async () => {
      // Setup form for creation
      roleFormComponent.roleForm.patchValue({
        name: 'NewRole',
        isDefault: false,
        isPublic: true
      });
      
      spyOn(roleFormComponent, 'showSuccess');
      spyOn(roleFormComponent, 'hideDialog');
      spyOn(roleFormComponent.roleSaved, 'emit');
      
      await roleFormComponent.onSubmit();
      
      expect(identityRoleService.create).toHaveBeenCalledWith({
        name: 'NewRole',
        isDefault: false,
        isPublic: true
      });
      expect(permissionsService.update).toHaveBeenCalled();
      expect(roleFormComponent.showSuccess).toHaveBeenCalledWith('Thành công', 'Đã tạo vai trò mới');
      expect(roleFormComponent.hideDialog).toHaveBeenCalled();
      expect(roleFormComponent.roleSaved.emit).toHaveBeenCalled();
    });

    it('should handle role editing workflow', async () => {
      // Setup for edit mode
      roleFormComponent.roleId = 'role-id';
      roleFormComponent.isEditMode = true;
      
      roleFormComponent.roleForm.patchValue({
        name: 'UpdatedRole',
        isDefault: true,
        isPublic: false
      });
      
      spyOn(roleFormComponent, 'showSuccess');
      spyOn(roleFormComponent, 'hideDialog');
      spyOn(roleFormComponent.roleSaved, 'emit');
      
      await roleFormComponent.onSubmit();
      
      expect(identityRoleService.update).toHaveBeenCalledWith('role-id', {
        name: 'UpdatedRole',
        isDefault: true,
        isPublic: false,
        concurrencyStamp: null
      });
      expect(permissionsService.update).toHaveBeenCalled();
      expect(roleFormComponent.showSuccess).toHaveBeenCalledWith('Thành công', 'Đã cập nhật vai trò');
      expect(roleFormComponent.hideDialog).toHaveBeenCalled();
      expect(roleFormComponent.roleSaved.emit).toHaveBeenCalled();
    });

    it('should handle permission tree building and selection', async () => {
      const treeNodes = permissionTreeService.buildPermissionTree(mockPermissions);
      
      expect(treeNodes).toBeDefined();
      expect(treeNodes.length).toBeGreaterThan(0);
      
      // Test permission selection
      const selectedNodes = [treeNodes[0]];
      const updatedSelection = permissionTreeService.updateParentStates(treeNodes, selectedNodes);
      
      expect(updatedSelection).toBeDefined();
    });

    it('should handle role loading with permissions', async () => {
      const roleName = 'TestRole';
      
      await roleFormComponent.loadRole('role-id');
      
      expect(identityRoleService.get).toHaveBeenCalledWith('role-id');
      expect(permissionsService.get).toHaveBeenCalledWith('R', roleName);
    });

    it('should handle API errors during role operations', async () => {
      const error = new Error('Role API Error');
      identityRoleService.get.and.returnValue(throwError(() => error));
      spyOn(roleFormComponent, 'handleApiError');
      
      await roleFormComponent.loadRole('role-id');
      
      expect(roleFormComponent.handleApiError).toHaveBeenCalledWith(error, 'Không thể tải thông tin vai trò');
    });
  });

  describe('Component Integration', () => {
    it('should integrate UserList and RoleForm components', async () => {
      createUserListComponent();
      createRoleFormComponent();
      
      // Both components should be created without errors
      expect(userListComponent).toBeTruthy();
      expect(roleFormComponent).toBeTruthy();
      
      // Both should load their respective data
      expect(identityUserService.getList).toHaveBeenCalled();
      expect(permissionsService.get).toHaveBeenCalled();
    });

    it('should handle form validation in role component', async () => {
      createRoleFormComponent();
      
      // Submit empty form
      roleFormComponent.roleForm.patchValue({
        name: '', // Required field empty
        isDefault: false,
        isPublic: false
      });
      
      spyOn(roleFormComponent, 'validateForm').and.callThrough();
      spyOn(roleFormComponent, 'showWarning');
      
      await roleFormComponent.onSubmit();
      
      expect(roleFormComponent.validateForm).toHaveBeenCalled();
      expect(roleFormComponent.showWarning).toHaveBeenCalled();
      expect(identityRoleService.create).not.toHaveBeenCalled();
    });

    it('should handle user role assignment display', () => {
      createUserListComponent();
      
      const userWithRoles = {
        ...mockUsers[0],
        roles: ['Admin', 'User']
      };
      
      spyOn(userListComponent, 'getRoleLabel').and.returnValues('Quản trị viên', 'Người dùng');
      
      const result = userListComponent.getUserRoles(userWithRoles);
      
      expect(result).toBe('Quản trị viên, Người dùng');
    });
  });

  describe('Error Handling Integration', () => {
    it('should handle cascading failures gracefully', async () => {
      createUserListComponent();
      
      // Simulate user loading success but role loading failure
      identityUserService.getRoles.and.returnValue(throwError(() => new Error('Role loading failed')));
      spyOn(console, 'error');
      
      userListComponent.ngOnInit();
      
      // Users should still be loaded
      expect(userListComponent.users().length).toBeGreaterThan(0);
      // Error should be logged
      expect(console.error).toHaveBeenCalledWith('Error loading user roles:', jasmine.any(Error));
    });

    it('should handle permission loading failure in role form', async () => {
      permissionsService.get.and.returnValue(throwError(() => new Error('Permission loading failed')));
      spyOn(console, 'error');
      
      createRoleFormComponent();
      
      expect(console.error).toHaveBeenCalledWith('Error loading permissions:', jasmine.any(Error));
      expect(roleFormComponent.availablePermissions).toBeNull();
    });
  });

  describe('Navigation Integration', () => {
    it('should support routing to administration pages', async () => {
      await router.navigate(['/users']);
      expect(location.path()).toBe('/users');
      
      await router.navigate(['/roles']);
      expect(location.path()).toBe('/roles');
    });
  });

  describe('Service Dependencies', () => {
    it('should properly inject all required services', () => {
      createUserListComponent();
      createRoleFormComponent();
      
      // Verify that all services are properly injected and functional
      expect(identityUserService).toBeTruthy();
      expect(identityRoleService).toBeTruthy();
      expect(permissionsService).toBeTruthy();
      expect(permissionTreeService).toBeTruthy();
      expect(messageService).toBeTruthy();
      expect(confirmationService).toBeTruthy();
      expect(permissionService).toBeTruthy();
    });

    it('should handle PermissionTreeService integration', () => {
      const treeService = TestBed.inject(PermissionTreeService);
      
      expect(treeService).toBeTruthy();
      
      // Test tree building with mock data
      const result = treeService.buildPermissionTree(mockPermissions);
      expect(result).toBeDefined();
      expect(result.length).toBe(1); // One group
    });
  });

  describe('Complete Administration Workflow', () => {
    it('should support complete user management cycle', async () => {
      createUserListComponent();
      
      // 1. Load users
      expect(userListComponent.users().length).toBe(2);
      
      // 2. Create new user
      userListComponent.openCreateDialog();
      expect(userListComponent.userDialogVisible).toBe(true);
      
      // 3. Edit existing user
      userListComponent.openEditDialog('user-id');
      expect(userListComponent.selectedUserId).toBe('user-id');
      
      // 4. Delete user
      confirmationService.confirm.and.callFake((options: any) => options.accept());
      userListComponent.deleteUser(mockUsers[0]);
      expect(identityUserService.delete).toHaveBeenCalledWith(mockUsers[0].id);
    });

    it('should support complete role management cycle', async () => {
      createRoleFormComponent();
      
      // 1. Load permissions
      expect(roleFormComponent.availablePermissions).toEqual(mockPermissions);
      
      // 2. Create role with permissions
      roleFormComponent.roleForm.patchValue({
        name: 'TestRole',
        isDefault: false,
        isPublic: true
      });
      
      await roleFormComponent.onSubmit();
      
      expect(identityRoleService.create).toHaveBeenCalled();
      expect(permissionsService.update).toHaveBeenCalled();
    });
  });
});