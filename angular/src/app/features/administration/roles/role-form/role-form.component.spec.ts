import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { of, throwError } from 'rxjs';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

import { RoleFormComponent } from './role-form.component';
import { IdentityRoleService, IdentityRoleDto } from '@abp/ng.identity/proxy';
import { PermissionsService, GetPermissionListResultDto, UpdatePermissionsDto } from '@abp/ng.permission-management/proxy';
import { PermissionTreeService } from '../../services/permission-tree.service';
import { MessageService } from 'primeng/api';
import { PermissionService } from '@abp/ng.core';
import { TreeNode } from 'primeng/api';

describe('RoleFormComponent', () => {
  let component: RoleFormComponent;
  let fixture: ComponentFixture<RoleFormComponent>;
  let identityRoleService: jasmine.SpyObj<IdentityRoleService>;
  let permissionsService: jasmine.SpyObj<PermissionsService>;
  let permissionTreeService: jasmine.SpyObj<PermissionTreeService>;
  let messageService: jasmine.SpyObj<MessageService>;
  let permissionService: jasmine.SpyObj<PermissionService>;

  const mockRole: IdentityRoleDto = {
    id: 'role-id',
    name: 'TestRole',
    isDefault: false,
    isPublic: true,
    isStatic: false,
    concurrencyStamp: 'stamp',
    extraProperties: {}
  };

  const mockPermissionList: GetPermissionListResultDto = {
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
          },
          {
            name: 'UserManagement.Users.Update',
            displayName: 'Update User',
            parentName: 'UserManagement.Users',
            isGranted: false,
            allowedProviders: []
          }
        ]
      }
    ]
  };

  const mockPermissionTree: TreeNode[] = [
    {
      label: 'User Management',
      key: 'UserManagement',
      expanded: true,
      children: [
        {
          label: 'User Management',
          key: 'UserManagement.Users',
          expanded: true,
          children: [
            {
              label: 'Create User',
              key: 'UserManagement.Users.Create',
              leaf: true
            },
            {
              label: 'Update User',
              key: 'UserManagement.Users.Update',
              leaf: true
            }
          ]
        }
      ]
    }
  ];

  beforeEach(async () => {
    const identityRoleServiceSpy = jasmine.createSpyObj('IdentityRoleService', [
      'get',
      'create',
      'update'
    ]);
    const permissionsServiceSpy = jasmine.createSpyObj('PermissionsService', [
      'get',
      'update'
    ]);
    const permissionTreeServiceSpy = jasmine.createSpyObj('PermissionTreeService', [
      'buildPermissionTree',
      'updateParentStates'
    ]);
    const messageServiceSpy = jasmine.createSpyObj('MessageService', ['add']);
    const permissionServiceSpy = jasmine.createSpyObj('PermissionService', ['getGrantedPolicy']);

    await TestBed.configureTestingModule({
      imports: [
        RoleFormComponent,
        ReactiveFormsModule,
        NoopAnimationsModule
      ],
      providers: [
        FormBuilder,
        { provide: IdentityRoleService, useValue: identityRoleServiceSpy },
        { provide: PermissionsService, useValue: permissionsServiceSpy },
        { provide: PermissionTreeService, useValue: permissionTreeServiceSpy },
        { provide: MessageService, useValue: messageServiceSpy },
        { provide: PermissionService, useValue: permissionServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(RoleFormComponent);
    component = fixture.componentInstance;
    identityRoleService = TestBed.inject(IdentityRoleService) as jasmine.SpyObj<IdentityRoleService>;
    permissionsService = TestBed.inject(PermissionsService) as jasmine.SpyObj<PermissionsService>;
    permissionTreeService = TestBed.inject(PermissionTreeService) as jasmine.SpyObj<PermissionTreeService>;
    messageService = TestBed.inject(MessageService) as jasmine.SpyObj<MessageService>;
    permissionService = TestBed.inject(PermissionService) as jasmine.SpyObj<PermissionService>;
  });

  beforeEach(() => {
    // Setup default spy returns
    permissionsService.get.and.returnValue(of(mockPermissionList));
    permissionTreeService.buildPermissionTree.and.returnValue(mockPermissionTree);
    permissionTreeService.updateParentStates.and.returnValue([]);
    identityRoleService.get.and.returnValue(of(mockRole));
    identityRoleService.create.and.returnValue(of(mockRole));
    identityRoleService.update.and.returnValue(of(mockRole));
    permissionsService.update.and.returnValue(of(undefined));
    permissionService.getGrantedPolicy.and.returnValue(true);
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('Component Initialization', () => {
    it('should initialize form with default values', () => {
      expect(component.roleForm).toBeDefined();
      expect(component.roleForm.get('name')?.value).toBe('');
      expect(component.roleForm.get('isDefault')?.value).toBe(false);
      expect(component.roleForm.get('isPublic')?.value).toBe(false);
    });

    it('should set isEditMode to false by default', () => {
      expect(component.isEditMode).toBe(false);
    });

    it('should initialize empty permission arrays', () => {
      expect(component.permissionTreeNodes).toEqual([]);
      expect(component.selectedTreeNodes).toEqual([]);
      expect(component.availablePermissions).toBeNull();
    });

    it('should call loadPermissions on ngOnInit', () => {
      spyOn(component, 'loadPermissions');
      
      component.ngOnInit();
      
      expect(component.loadPermissions).toHaveBeenCalled();
    });
  });

  describe('Create Mode', () => {
    beforeEach(() => {
      component.roleId = undefined;
      component.ngOnInit();
    });

    it('should set isEditMode to false', () => {
      expect(component.isEditMode).toBe(false);
    });

    it('should enable name field', () => {
      expect(component.roleForm.get('name')?.enabled).toBe(true);
    });

    it('should initialize form in create mode', () => {
      component.ngOnInit();
      
      expect(component.isEditMode).toBe(false);
      expect(component.roleForm.get('name')?.enabled).toBe(true);
    });
  });

  describe('Edit Mode', () => {
    beforeEach(() => {
      component.roleId = 'role-id';
      spyOn(component, 'loadRole');
    });

    it('should set isEditMode to true', () => {
      component.ngOnInit();
      
      expect(component.isEditMode).toBe(true);
      expect(component.loadRole).toHaveBeenCalledWith('role-id');
    });

    it('should load role when roleId changes', () => {
      component.visible = true;
      component.roleId = 'new-role-id';
      
      component.ngOnChanges();
      
      expect(component.isEditMode).toBe(true);
      expect(component.loadRole).toHaveBeenCalledWith('new-role-id');
    });

    it('should reset form when switching to create mode', () => {
      component.visible = true;
      component.roleId = undefined;
      
      component.ngOnChanges();
      
      expect(component.isEditMode).toBe(false);
    });
  });

  describe('Permission Loading', () => {
    it('should load available permissions successfully', async () => {
      await component.loadPermissions();
      
      expect(permissionsService.get).toHaveBeenCalledWith('R', '');
      expect(component.availablePermissions).toEqual(mockPermissionList);
      expect(permissionTreeService.buildPermissionTree).toHaveBeenCalledWith(mockPermissionList);
      expect(component.permissionTreeNodes).toEqual(mockPermissionTree);
    });

    it('should handle permission loading error', async () => {
      permissionsService.get.and.returnValue(throwError(() => new Error('Permission loading failed')));
      spyOn(console, 'error');
      
      await component.loadPermissions();
      
      expect(console.error).toHaveBeenCalledWith('Error loading permissions:', jasmine.any(Error));
    });

    it('should not build tree when no permissions available', async () => {
      permissionsService.get.and.returnValue(of(null as any));
      
      await component.loadPermissions();
      
      expect(permissionTreeService.buildPermissionTree).not.toHaveBeenCalled();
    });
  });

  describe('Role Loading', () => {
    it('should load role successfully', async () => {
      spyOn(component, 'loadRolePermissions').and.returnValue(Promise.resolve());
      
      await component.loadRole('role-id');
      
      expect(identityRoleService.get).toHaveBeenCalledWith('role-id');
      expect(component.roleForm.get('name')?.value).toBe(mockRole.name);
      expect(component.roleForm.get('isDefault')?.value).toBe(mockRole.isDefault);
      expect(component.roleForm.get('isPublic')?.value).toBe(mockRole.isPublic);
      expect(component.loadRolePermissions).toHaveBeenCalledWith(mockRole.name);
    });

    it('should disable name field in edit mode', async () => {
      component.isEditMode = true;
      spyOn(component, 'loadRolePermissions').and.returnValue(Promise.resolve());
      
      await component.loadRole('role-id');
      
      expect(component.roleForm.get('name')?.disabled).toBe(true);
    });

    it('should handle role loading error', async () => {
      const error = new Error('Role loading failed');
      identityRoleService.get.and.returnValue(throwError(() => error));
      spyOn(console, 'error');
      
      await component.loadRole('role-id');
      
      expect(component.loading).toBe(false);
    });
  });

  describe('Role Permission Loading', () => {
    beforeEach(() => {
      component.permissionTreeNodes = mockPermissionTree;
      component.availablePermissions = mockPermissionList;
    });

    it('should load role permissions successfully', async () => {
      const rolePermissions = {
        ...mockPermissionList,
        groups: [
          {
            ...mockPermissionList.groups[0],
            permissions: [
              { ...mockPermissionList.groups[0].permissions[0], isGranted: true },
              { ...mockPermissionList.groups[0].permissions[1], isGranted: false },
              { ...mockPermissionList.groups[0].permissions[2], isGranted: true }
            ]
          }
        ]
      };
      
      permissionsService.get.and.returnValue(of(rolePermissions));
      
      await component.loadRolePermissions('TestRole');
      
      expect(permissionsService.get).toHaveBeenCalledWith('R', 'TestRole');
      expect(permissionTreeService.updateParentStates).toHaveBeenCalled();
    });

    it('should handle role permission loading error', async () => {
      permissionsService.get.and.returnValue(throwError(() => new Error('Permission loading failed')));
      spyOn(console, 'error');
      
      await component.loadRolePermissions('TestRole');
      
      expect(console.error).toHaveBeenCalledWith('Error loading role permissions:', jasmine.any(Error));
    });

    it('should correctly identify granted permissions', async () => {
      const rolePermissions = {
        ...mockPermissionList,
        groups: [
          {
            ...mockPermissionList.groups[0],
            permissions: [
              { ...mockPermissionList.groups[0].permissions[0], isGranted: true },
              { ...mockPermissionList.groups[0].permissions[1], isGranted: true },
              { ...mockPermissionList.groups[0].permissions[2], isGranted: false }
            ]
          }
        ]
      };
      
      permissionsService.get.and.returnValue(of(rolePermissions));
      await component.loadRolePermissions('TestRole');
      
      // Should process granted permissions correctly
      expect(permissionTreeService.updateParentStates).toHaveBeenCalled();
    });
  });

  describe('Form Submission', () => {
    beforeEach(() => {
      component.roleForm.patchValue({
        name: 'TestRole',
        isDefault: false,
        isPublic: true
      });
      spyOn(component, 'validateForm').and.returnValue(true);
    });

    it('should not submit if form is invalid', async () => {
      // Make form invalid
      component.roleForm.patchValue({ name: '' });
      
      await component.onSubmit();
      
      expect(identityRoleService.create).not.toHaveBeenCalled();
      expect(identityRoleService.update).not.toHaveBeenCalled();
    });

    it('should create role in create mode', async () => {
      component.isEditMode = false;
      
      await component.onSubmit();
      
      expect(identityRoleService.create).toHaveBeenCalled();
    });

    it('should update role in edit mode', async () => {
      component.isEditMode = true;
      component.roleId = 'role-id';
      
      await component.onSubmit();
      
      expect(identityRoleService.update).toHaveBeenCalled();
    });
  });

  describe('Role Creation and Update', () => {
    it('should handle successful role creation', async () => {
      component.isEditMode = false;
      spyOn(component.roleSaved, 'emit');
      
      await component.onSubmit();
      
      expect(identityRoleService.create).toHaveBeenCalled();
      expect(permissionsService.update).toHaveBeenCalled();
      expect(component.roleSaved.emit).toHaveBeenCalled();
    });

    it('should handle successful role update', async () => {
      component.isEditMode = true;
      component.roleId = 'role-id';
      spyOn(component.roleSaved, 'emit');
      
      await component.onSubmit();
      
      expect(identityRoleService.update).toHaveBeenCalled();
      expect(permissionsService.update).toHaveBeenCalled();
      expect(component.roleSaved.emit).toHaveBeenCalled();
    });

    it('should handle creation errors', async () => {
      const error = new Error('Creation failed');
      identityRoleService.create.and.returnValue(throwError(() => error));
      spyOn(console, 'error');
      
      await component.onSubmit();
      
      expect(component.loading).toBe(false);
    });
  });

  describe('Permission Management', () => {
    beforeEach(() => {
      component.availablePermissions = mockPermissionList;
      component.selectedTreeNodes = [
        { key: 'UserManagement.Users', label: 'User Management' },
        { key: 'UserManagement.Users.Create', label: 'Create User' }
      ];
    });

    it('should update role permissions successfully', async () => {
      await component.updateRolePermissions('TestRole');
      
      expect(permissionsService.update).toHaveBeenCalledWith('R', 'TestRole', {
        permissions: jasmine.any(Array)
      });
    });

    it('should correctly map selected permissions', async () => {
      await component.updateRolePermissions('TestRole');
      
      const updateCall = permissionsService.update.calls.mostRecent();
      const updateDto = updateCall.args[2];
      
      expect(updateDto.permissions).toBeDefined();
      expect(Array.isArray(updateDto.permissions)).toBe(true);
    });

    it('should handle permission update error', async () => {
      const error = new Error('Permission update failed');
      permissionsService.update.and.returnValue(throwError(() => error));
      
      try {
        await component.updateRolePermissions('TestRole');
        fail('Should have thrown error');
      } catch (e) {
        expect(e).toEqual(error);
      }
    });

    it('should skip update when no permissions available', async () => {
      component.availablePermissions = null;
      
      await component.updateRolePermissions('TestRole');
      
      expect(permissionsService.update).not.toHaveBeenCalled();
    });
  });

  describe('Dialog Management', () => {
    it('should hide dialog and emit change', () => {
      spyOn(component.visibleChange, 'emit');
      component.visible = true;
      
      component.hideDialog();
      
      expect(component.visible).toBe(false);
      expect(component.visibleChange.emit).toHaveBeenCalledWith(false);
    });

    it('should cancel and hide dialog', () => {
      spyOn(component, 'hideDialog');
      
      component.cancel();
      
      expect(component.hideDialog).toHaveBeenCalled();
    });
  });

  describe('Component Integration', () => {
    it('should handle component lifecycle correctly', () => {
      expect(component).toBeTruthy();
      expect(component.roleForm).toBeDefined();
      expect(component.permissionTreeNodes).toBeDefined();
    });

    it('should manage loading state properly', () => {
      expect(component.loading).toBe(false);
      
      // Loading should be managed during async operations
      expect(typeof component.loading).toBe('boolean');
    });

    it('should handle permission tree nodes', () => {
      expect(Array.isArray(component.permissionTreeNodes)).toBe(true);
      expect(Array.isArray(component.selectedTreeNodes)).toBe(true);
    });
  });
});