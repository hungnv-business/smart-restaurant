import { Injectable } from '@angular/core';
import { TreeNode } from 'primeng/api';
import { GetPermissionListResultDto } from '@abp/ng.permission-management/proxy';

/**
 * Service quản lý cây phân quyền trong hệ thống nhà hàng
 * Chức năng chính:
 * - Xây dựng cây phân quyền phân cấp từ ABP permissions
 * - Cập nhật trạng thái partial selection cho các node cha
 * - Quản lý mối quan hệ cha-con giữa các quyền
 * 
 * Sử dụng: Hiển thị danh sách quyền dạng tree cho phép gán quyền cho vai trò
 */
@Injectable({
  providedIn: 'root',
})
export class PermissionTreeService {
  /**
   * Xây dựng cây phân quyền phân cấp từ danh sách quyền ABP
   * @param availablePermissions Danh sách quyền từ ABP framework
   * @returns Mảng TreeNode đại diện cho cây phân quyền
   */
  buildPermissionTree(availablePermissions: GetPermissionListResultDto): TreeNode[] {
    if (!availablePermissions) return [];

    // Loại bỏ các nhóm quyền không cần thiết cho hệ thống nhà hàng
    const excludedGroups = ['FeatureManagement', 'SettingManagement', 'AbpTenantManagement'];
    const filteredGroups = availablePermissions.groups.filter(
      group => !excludedGroups.includes(group.name),
    );

    return filteredGroups.map((group: any) => {
      // Tạo node gốc cho nhóm quyền (VD: "Quản lý bàn", "Quản lý menu")
      const groupNode: TreeNode = {
        label: group.displayName || group.name,
        data: group.name,
        key: group.name,
        expanded: true,
        children: [],
      };

      // Xây dựng cây phân cấp sử dụng mối quan hệ parentName
      this.buildHierarchy(groupNode, group.permissions);

      return groupNode;
    });
  }

  /**
   * Xây dựng cây phân cấp sử dụng mối quan hệ parentName
   * @param groupNode Node gốc của nhóm quyền
   * @param permissions Danh sách các quyền trong nhóm
   */
  private buildHierarchy(groupNode: TreeNode, permissions: any[]) {
    const permissionMap = new Map<string, TreeNode>();

    // Tạo tất cả các node quyền trước
    permissions.forEach(permission => {
      const node: TreeNode = {
        label: permission.displayName || permission.name,
        data: permission.name,
        key: permission.name,
        expanded: true,
        leaf: true, // Ban đầu tất cả đều là node lá
        children: [],
      };
      permissionMap.set(permission.name, node);
    });

    // Xây dựng cây phân cấp dựa trên parentName
    permissions.forEach(permission => {
      const currentNode = permissionMap.get(permission.name);
      if (!currentNode) return;

      if (permission.parentName === null) {
        // Quyền cấp gốc - thêm trực tiếp vào nhóm
        if (!groupNode.children) groupNode.children = [];
        groupNode.children.push(currentNode);
      } else {
        // Quyền con - thêm vào node cha
        const parentNode = permissionMap.get(permission.parentName);
        if (parentNode) {
          if (!parentNode.children) parentNode.children = [];
          parentNode.children.push(currentNode);
          parentNode.leaf = false; // Node cha không phải là node lá
        }
      }
    });

    // Dọn dẹp các node có mảng children rỗng
    this.cleanEmptyChildren(groupNode);
  }

  /**
   * Loại bỏ mảng children rỗng và thiết lập thuộc tính leaf chính xác
   * @param node Node cần được dọn dẹp
   */
  private cleanEmptyChildren(node: TreeNode) {
    if (node.children) {
      // Đầu tiên dọn dẹp children một cách đệ quy
      node.children.forEach(child => this.cleanEmptyChildren(child));

      // Nếu mảng children rỗng, xóa nó và đánh dấu là node lá
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
   * Cập nhật trạng thái partial selection cho các node cha dựa trên node con được chọn
   * @param permissionTreeNodes Danh sách node gốc của cây quyền
   * @param selectedTreeNodes Danh sách node đã được chọn
   * @returns Danh sách node đã được chọn sau khi cập nhật
   */
  updateParentStates(permissionTreeNodes: TreeNode[], selectedTreeNodes: TreeNode[]): TreeNode[] {
    const updatedSelection = [...selectedTreeNodes];

    permissionTreeNodes.forEach(groupNode => {
      this.updateNodePartialState(groupNode, updatedSelection);
    });

    return updatedSelection;
  }

  /**
   * Cập nhật trạng thái partial selection của node một cách đệ quy
   * @param node Node cần cập nhật trạng thái
   * @param selectedTreeNodes Danh sách node đã được chọn
   * @returns Số lượng node được chọn và tổng số node
   */
  private updateNodePartialState(
    node: TreeNode,
    selectedTreeNodes: TreeNode[],
  ): { selected: number; total: number } {
    if (!node.children || node.children.length === 0) {
      // Node lá - kiểm tra xem có được chọn không
      const isSelected = selectedTreeNodes.some(selected => selected.key === node.key);
      return { selected: isSelected ? 1 : 0, total: 1 };
    }

    // Node cha - kiểm tra trạng thái của các node con
    let totalSelected = 0;
    let totalChildren = 0;

    node.children.forEach(child => {
      const childState = this.updateNodePartialState(child, selectedTreeNodes);
      totalSelected += childState.selected;
      totalChildren += childState.total;
    });

    // Thiết lập trạng thái partial dựa trên việc chọn node con
    if (totalSelected === 0) {
      // Không có node con nào được chọn - loại bỏ khỏi danh sách chọn nếu có
      const nodeIndex = selectedTreeNodes.findIndex(selected => selected.key === node.key);
      if (nodeIndex >= 0) {
        selectedTreeNodes.splice(nodeIndex, 1);
      }
      node.partialSelected = false;
    } else if (totalSelected === totalChildren) {
      // Tất cả node con được chọn - thêm vào danh sách chọn nếu chưa có
      const isNodeSelected = selectedTreeNodes.some(selected => selected.key === node.key);
      if (!isNodeSelected) {
        selectedTreeNodes.push(node);
      }
      node.partialSelected = false;
    } else {
      // Một số node con được chọn - thiết lập trạng thái partial
      const nodeIndex = selectedTreeNodes.findIndex(selected => selected.key === node.key);
      if (nodeIndex >= 0) {
        selectedTreeNodes.splice(nodeIndex, 1);
      }
      node.partialSelected = true;
    }

    return { selected: totalSelected, total: totalChildren };
  }
}
