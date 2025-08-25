import { TestBed } from '@angular/core/testing';
import { TreeNode } from 'primeng/api';
import { PermissionTreeService } from './permission-tree.service';
import { GetPermissionListResultDto } from '@abp/ng.permission-management/proxy';

describe('PermissionTreeService', () => {
  let service: PermissionTreeService;

  const mockPermissionData: GetPermissionListResultDto = {
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
            allowedProviders: [],
          },
          {
            name: 'UserManagement.Users.Create',
            displayName: 'Create User',
            parentName: 'UserManagement.Users',
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'UserManagement.Users.Update',
            displayName: 'Update User',
            parentName: 'UserManagement.Users',
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'UserManagement.Users.Delete',
            displayName: 'Delete User',
            parentName: 'UserManagement.Users',
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'UserManagement.Roles',
            displayName: 'Role Management',
            parentName: null,
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'UserManagement.Roles.Create',
            displayName: 'Create Role',
            parentName: 'UserManagement.Roles',
            isGranted: false,
            allowedProviders: [],
          },
        ],
      },
      {
        name: 'FeatureManagement',
        displayName: 'Feature Management',
        permissions: [
          {
            name: 'FeatureManagement.ManageFeatures',
            displayName: 'Manage Features',
            parentName: null,
            isGranted: false,
            allowedProviders: [],
          },
        ],
      },
      {
        name: 'SettingManagement',
        displayName: 'Setting Management',
        permissions: [
          {
            name: 'SettingManagement.ManageSettings',
            displayName: 'Manage Settings',
            parentName: null,
            isGranted: false,
            allowedProviders: [],
          },
        ],
      },
      {
        name: 'Restaurant',
        displayName: 'Restaurant Management',
        permissions: [
          {
            name: 'Restaurant.MenuItems',
            displayName: 'Menu Items',
            parentName: null,
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'Restaurant.MenuItems.View',
            displayName: 'View Menu Items',
            parentName: 'Restaurant.MenuItems',
            isGranted: false,
            allowedProviders: [],
          },
          {
            name: 'Restaurant.MenuItems.Create',
            displayName: 'Create Menu Items',
            parentName: 'Restaurant.MenuItems',
            isGranted: false,
            allowedProviders: [],
          },
        ],
      },
    ],
  };

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(PermissionTreeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('buildPermissionTree', () => {
    it('should return empty array for null input', () => {
      const result = service.buildPermissionTree(null as any);
      expect(result).toEqual([]);
    });

    it('should return empty array for undefined input', () => {
      const result = service.buildPermissionTree(undefined as any);
      expect(result).toEqual([]);
    });

    it('should filter out excluded groups', () => {
      const result = service.buildPermissionTree(mockPermissionData);

      const groupNames = result.map(group => group.data);
      expect(groupNames).not.toContain('FeatureManagement');
      expect(groupNames).not.toContain('SettingManagement');
      expect(groupNames).not.toContain('AbpTenantManagement');
      expect(groupNames).toContain('UserManagement');
      expect(groupNames).toContain('Restaurant');
    });

    it('should create group nodes with correct structure', () => {
      const result = service.buildPermissionTree(mockPermissionData);

      const userManagementGroup = result.find(group => group.data === 'UserManagement');
      expect(userManagementGroup).toBeDefined();
      expect(userManagementGroup!.label).toBe('User Management');
      expect(userManagementGroup!.key).toBe('UserManagement');
      expect(userManagementGroup!.expanded).toBe(true);
      expect(userManagementGroup!.children).toBeDefined();
    });

    it('should build hierarchical structure correctly', () => {
      const result = service.buildPermissionTree(mockPermissionData);

      const userManagementGroup = result.find(group => group.data === 'UserManagement');
      expect(userManagementGroup!.children!.length).toBe(2); // Users and Roles

      const usersNode = userManagementGroup!.children!.find(
        child => child.key === 'UserManagement.Users',
      );
      expect(usersNode).toBeDefined();
      expect(usersNode!.children!.length).toBe(3); // Create, Update, Delete
      expect(usersNode!.leaf).toBe(false);

      const createUserNode = usersNode!.children!.find(
        child => child.key === 'UserManagement.Users.Create',
      );
      expect(createUserNode).toBeDefined();
      expect(createUserNode!.leaf).toBe(true);
      expect(createUserNode!.children).toBeUndefined();
    });

    it('should handle permissions with null parent as root level', () => {
      const result = service.buildPermissionTree(mockPermissionData);

      const userManagementGroup = result.find(group => group.data === 'UserManagement');
      const rootLevelPermissions = userManagementGroup!.children!.map(child => child.key);

      expect(rootLevelPermissions).toContain('UserManagement.Users');
      expect(rootLevelPermissions).toContain('UserManagement.Roles');
    });

    it('should set leaf property correctly', () => {
      const result = service.buildPermissionTree(mockPermissionData);

      const userManagementGroup = result.find(group => group.data === 'UserManagement');
      const usersNode = userManagementGroup!.children!.find(
        child => child.key === 'UserManagement.Users',
      );
      const createUserNode = usersNode!.children!.find(
        child => child.key === 'UserManagement.Users.Create',
      );

      // Parent nodes should not be leaf
      expect(usersNode!.leaf).toBe(false);

      // Child nodes should be leaf
      expect(createUserNode!.leaf).toBe(true);
    });

    it('should handle groups with single permissions', () => {
      const singlePermissionData: GetPermissionListResultDto = {
        entityDisplayName: 'Role',
        groups: [
          {
            name: 'SimpleGroup',
            displayName: 'Simple Group',
            permissions: [
              {
                name: 'SimpleGroup.SinglePermission',
                displayName: 'Single Permission',
                parentName: null,
                isGranted: false,
                allowedProviders: [],
              },
            ],
          },
        ],
      };

      const result = service.buildPermissionTree(singlePermissionData);

      expect(result.length).toBe(1);
      const group = result[0];
      expect(group.children!.length).toBe(1);
      expect(group.children![0].leaf).toBe(true);
    });

    it('should handle deep nesting correctly', () => {
      const deepNestingData: GetPermissionListResultDto = {
        entityDisplayName: 'Role',
        groups: [
          {
            name: 'DeepGroup',
            displayName: 'Deep Group',
            permissions: [
              {
                name: 'Level1',
                displayName: 'Level 1',
                parentName: null,
                isGranted: false,
                allowedProviders: [],
              },
              {
                name: 'Level2',
                displayName: 'Level 2',
                parentName: 'Level1',
                isGranted: false,
                allowedProviders: [],
              },
              {
                name: 'Level3',
                displayName: 'Level 3',
                parentName: 'Level2',
                isGranted: false,
                allowedProviders: [],
              },
            ],
          },
        ],
      };

      const result = service.buildPermissionTree(deepNestingData);

      const level1 = result[0].children![0];
      const level2 = level1.children![0];
      const level3 = level2.children![0];

      expect(level1.key).toBe('Level1');
      expect(level1.leaf).toBe(false);
      expect(level2.key).toBe('Level2');
      expect(level2.leaf).toBe(false);
      expect(level3.key).toBe('Level3');
      expect(level3.leaf).toBe(true);
    });
  });

  describe('updateParentStates', () => {
    let permissionTreeNodes: TreeNode[];

    beforeEach(() => {
      permissionTreeNodes = service.buildPermissionTree(mockPermissionData);
    });

    it('should handle empty selected nodes', () => {
      const result = service.updateParentStates(permissionTreeNodes, []);

      expect(result).toEqual([]);

      // Check that no nodes have partial state
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      expect(usersNode!.partialSelected).toBeFalsy();
    });

    it('should handle leaf node selection', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      const createNode = usersNode!.children!.find(c => c.key === 'UserManagement.Users.Create');

      const selectedNodes = [createNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      expect(usersNode!.partialSelected).toBe(true);
      expect(result).not.toContain(usersNode);
    });

    it('should select parent when all children selected', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      const createNode = usersNode!.children!.find(c => c.key === 'UserManagement.Users.Create');
      const updateNode = usersNode!.children!.find(c => c.key === 'UserManagement.Users.Update');
      const deleteNode = usersNode!.children!.find(c => c.key === 'UserManagement.Users.Delete');

      const selectedNodes = [createNode!, updateNode!, deleteNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      expect(result).toContain(usersNode);
      expect(usersNode!.partialSelected).toBeFalsy();
    });

    it('should handle mixed selection states', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      const rolesNode = userGroup!.children!.find(c => c.key === 'UserManagement.Roles');
      const createUserNode = usersNode!.children!.find(
        c => c.key === 'UserManagement.Users.Create',
      );
      const createRoleNode = rolesNode!.children!.find(
        c => c.key === 'UserManagement.Roles.Create',
      );

      const selectedNodes = [createUserNode!, createRoleNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      // Both parent nodes should be partially selected
      expect(usersNode!.partialSelected).toBe(true);
      expect(rolesNode!.partialSelected).toBe(true);

      // Neither parent should be in selected nodes
      expect(result).not.toContain(usersNode);
      expect(result).not.toContain(rolesNode);
    });

    it('should remove parent from selection when no children selected', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');

      // Start with parent selected
      const selectedNodes = [usersNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      expect(result).not.toContain(usersNode);
      expect(usersNode!.partialSelected).toBeFalsy();
    });

    it('should handle complex nested selections', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      const rolesNode = userGroup!.children!.find(c => c.key === 'UserManagement.Roles');

      // Select all users permissions but only some roles permissions
      const createUserNode = usersNode!.children!.find(
        c => c.key === 'UserManagement.Users.Create',
      );
      const updateUserNode = usersNode!.children!.find(
        c => c.key === 'UserManagement.Users.Update',
      );
      const deleteUserNode = usersNode!.children!.find(
        c => c.key === 'UserManagement.Users.Delete',
      );
      const createRoleNode = rolesNode!.children!.find(
        c => c.key === 'UserManagement.Roles.Create',
      );

      const selectedNodes = [createUserNode!, updateUserNode!, deleteUserNode!, createRoleNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      // Users node should be fully selected (all children selected)
      expect(result).toContain(usersNode);
      expect(usersNode!.partialSelected).toBeFalsy();

      // Roles node should be partially selected (some children selected)
      expect(result).not.toContain(rolesNode);
      expect(rolesNode!.partialSelected).toBe(true);
    });

    it('should maintain original selected nodes that are valid', () => {
      const userGroup = permissionTreeNodes.find(g => g.key === 'UserManagement');
      const usersNode = userGroup!.children!.find(c => c.key === 'UserManagement.Users');
      const createNode = usersNode!.children!.find(c => c.key === 'UserManagement.Users.Create');

      const selectedNodes = [createNode!];
      const result = service.updateParentStates(permissionTreeNodes, selectedNodes);

      expect(result).toContain(createNode);
    });
  });

  describe('private methods', () => {
    it('should clean empty children arrays', () => {
      // Create a test node with empty children
      const testNode: TreeNode = {
        label: 'Test',
        key: 'test',
        children: [],
        leaf: false,
      };

      // Access private method through bracket notation for testing
      (service as any).cleanEmptyChildren(testNode);

      expect(testNode.children).toBeUndefined();
      expect(testNode.leaf).toBe(true);
    });

    it('should preserve non-empty children arrays', () => {
      const childNode: TreeNode = {
        label: 'Child',
        key: 'child',
        leaf: true,
      };

      const testNode: TreeNode = {
        label: 'Test',
        key: 'test',
        children: [childNode],
        leaf: false,
      };

      (service as any).cleanEmptyChildren(testNode);

      expect(testNode.children).toBeDefined();
      expect(testNode.children!.length).toBe(1);
      expect(testNode.leaf).toBe(false);
    });

    it('should handle nodes without children property', () => {
      const testNode: TreeNode = {
        label: 'Test',
        key: 'test',
        leaf: false,
      };

      (service as any).cleanEmptyChildren(testNode);

      expect(testNode.leaf).toBe(true);
    });
  });

  describe('integration scenarios', () => {
    it('should handle complete workflow from build to update', () => {
      // Build the tree
      const treeNodes = service.buildPermissionTree(mockPermissionData);

      // Select some nodes
      const userGroup = treeNodes.find(g => g.key === 'UserManagement');
      const createUserNode = userGroup!
        .children!.find(c => c.key === 'UserManagement.Users')!
        .children!.find(c => c.key === 'UserManagement.Users.Create');

      const selectedNodes = [createUserNode!];

      // Update parent states
      const result = service.updateParentStates(treeNodes, selectedNodes);

      // Verify the complete workflow
      expect(result).toContain(createUserNode);
      expect(treeNodes).toBeDefined();
      expect(treeNodes.length).toBeGreaterThan(0);
    });

    it('should handle empty permission groups gracefully', () => {
      const emptyGroupData: GetPermissionListResultDto = {
        entityDisplayName: 'Role',
        groups: [
          {
            name: 'EmptyGroup',
            displayName: 'Empty Group',
            permissions: [],
          },
        ],
      };

      const result = service.buildPermissionTree(emptyGroupData);

      expect(result.length).toBe(1);
      expect(result[0].children!.length).toBe(0);
    });

    it('should handle orphaned permissions gracefully', () => {
      const orphanedPermissionData: GetPermissionListResultDto = {
        entityDisplayName: 'Role',
        groups: [
          {
            name: 'OrphanGroup',
            displayName: 'Orphan Group',
            permissions: [
              {
                name: 'OrphanGroup.Child',
                displayName: 'Orphaned Child',
                parentName: 'OrphanGroup.NonExistentParent', // Parent doesn't exist
                isGranted: false,
                allowedProviders: [],
              },
            ],
          },
        ],
      };

      const result = service.buildPermissionTree(orphanedPermissionData);

      // Orphaned permission should not appear in the tree
      expect(result[0].children!.length).toBe(0);
    });
  });
});
