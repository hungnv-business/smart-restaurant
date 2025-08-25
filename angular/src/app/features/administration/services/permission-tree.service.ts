import { Injectable } from '@angular/core';
import { TreeNode } from 'primeng/api';
import { GetPermissionListResultDto } from '@abp/ng.permission-management/proxy';

@Injectable({
  providedIn: 'root',
})
export class PermissionTreeService {
  /**
   * Build hierarchical permission tree from ABP permissions using parentName
   */
  buildPermissionTree(availablePermissions: GetPermissionListResultDto): TreeNode[] {
    if (!availablePermissions) return [];

    // Filter out unwanted groups
    const excludedGroups = ['FeatureManagement', 'SettingManagement', 'AbpTenantManagement'];
    const filteredGroups = availablePermissions.groups.filter(
      group => !excludedGroups.includes(group.name),
    );

    return filteredGroups.map((group: any) => {
      const groupNode: TreeNode = {
        label: group.displayName || group.name,
        data: group.name,
        key: group.name,
        expanded: true,
        children: [],
      };

      // Build hierarchical tree using parentName relationships
      this.buildHierarchy(groupNode, group.permissions);

      return groupNode;
    });
  }

  /**
   * Build hierarchy using parentName relationships
   */
  private buildHierarchy(groupNode: TreeNode, permissions: any[]) {
    const permissionMap = new Map<string, TreeNode>();

    // Create all permission nodes first
    permissions.forEach(permission => {
      const node: TreeNode = {
        label: permission.displayName || permission.name,
        data: permission.name,
        key: permission.name,
        expanded: true,
        leaf: true, // Initially all are leaf nodes
        children: [],
      };
      permissionMap.set(permission.name, node);
    });

    // Build hierarchy based on parentName
    permissions.forEach(permission => {
      const currentNode = permissionMap.get(permission.name);
      if (!currentNode) return;

      if (permission.parentName === null) {
        // Root level permission - add directly to group
        if (!groupNode.children) groupNode.children = [];
        groupNode.children.push(currentNode);
      } else {
        // Child permission - add to parent
        const parentNode = permissionMap.get(permission.parentName);
        if (parentNode) {
          if (!parentNode.children) parentNode.children = [];
          parentNode.children.push(currentNode);
          parentNode.leaf = false; // Parent is not a leaf
        }
      }
    });

    // Clean up nodes that have empty children arrays
    this.cleanEmptyChildren(groupNode);
  }

  /**
   * Remove empty children arrays and set leaf property correctly
   */
  private cleanEmptyChildren(node: TreeNode) {
    if (node.children) {
      // First clean children recursively
      node.children.forEach(child => this.cleanEmptyChildren(child));

      // If children array is empty, remove it and mark as leaf
      if (node.children.length === 0) {
        delete node.children;
        node.leaf = true;
      } else {
        node.leaf = false;
      }
    } else {
      node.leaf = true;
    }
  }

  /**
   * Update partial states for parent nodes based on selected children
   */
  updateParentStates(permissionTreeNodes: TreeNode[], selectedTreeNodes: TreeNode[]): TreeNode[] {
    const updatedSelection = [...selectedTreeNodes];

    permissionTreeNodes.forEach(groupNode => {
      this.updateNodePartialState(groupNode, updatedSelection);
    });

    return updatedSelection;
  }

  /**
   * Recursively update node partial state and manage selection
   */
  private updateNodePartialState(
    node: TreeNode,
    selectedTreeNodes: TreeNode[],
  ): { selected: number; total: number } {
    if (!node.children || node.children.length === 0) {
      // Leaf node - check if it's selected
      const isSelected = selectedTreeNodes.some(selected => selected.key === node.key);
      return { selected: isSelected ? 1 : 0, total: 1 };
    }

    // Parent node - check children states
    let totalSelected = 0;
    let totalChildren = 0;

    node.children.forEach(child => {
      const childState = this.updateNodePartialState(child, selectedTreeNodes);
      totalSelected += childState.selected;
      totalChildren += childState.total;
    });

    // Set partial state based on children selection
    if (totalSelected === 0) {
      // No children selected - remove from selection if present
      const nodeIndex = selectedTreeNodes.findIndex(selected => selected.key === node.key);
      if (nodeIndex >= 0) {
        selectedTreeNodes.splice(nodeIndex, 1);
      }
      node.partialSelected = false;
    } else if (totalSelected === totalChildren) {
      // All children selected - add to selection if not present
      const isNodeSelected = selectedTreeNodes.some(selected => selected.key === node.key);
      if (!isNodeSelected) {
        selectedTreeNodes.push(node);
      }
      node.partialSelected = false;
    } else {
      // Some children selected - set partial state
      const nodeIndex = selectedTreeNodes.findIndex(selected => selected.key === node.key);
      if (nodeIndex >= 0) {
        selectedTreeNodes.splice(nodeIndex, 1);
      }
      node.partialSelected = true;
    }

    return { selected: totalSelected, total: totalChildren };
  }
}
