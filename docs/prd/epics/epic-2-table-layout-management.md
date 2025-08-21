# Epic 2: Table Layout Management (Quản lý Bố cục Bàn)

**Expanded Goal:** Design and implement hierarchical table layout management system with layout sections (rows/areas) and table positioning within sections, supporting drag-and-drop table arrangement, status tracking, and integration with reservation and order systems for efficient restaurant floor management (Thiết kế và triển khai hệ thống quản lý bố cục bàn phân cấp với các khu vực bố cục (dãy/khu) và định vị bàn trong khu vực, hỗ trợ sắp xếp bàn kéo-thả, theo dõi trạng thái và tích hợp với hệ thống đặt bàn và đặt món để quản lý sàn nhà hàng hiệu quả).

## Story 2.1: Layout Section Management (Quản lý Khu vực Bố cục)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to create and manage layout sections like "Dãy 1", "Dãy 2", "Khu VIP" (tôi muốn tạo và quản lý các khu vực bố cục như "Dãy 1", "Dãy 2", "Khu VIP"),  
**so that** I can organize tables into logical sections within the restaurant (để tôi có thể tổ chức bàn thành các khu vực hợp lý trong nhà hàng).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. CRUD operations for layout sections with Vietnamese names (Thao tác CRUD cho khu vực bố cục với tên tiếng Việt)
2. Section ordering and display management (Quản lý thứ tự và hiển thị khu vực)
3. Section status control (active/inactive) (Điều khiển trạng thái khu vực - hoạt động/không hoạt động)

## Story 2.2: Table Positioning within Layout Sections (Quản lý Vị trí Bàn trong Khu vực)
**As a** restaurant staff (nhân viên nhà hàng),  
**I want** to position tables within layout sections using drag-and-drop functionality (tôi muốn định vị bàn trong các khu vực bố cục bằng chức năng kéo-thả),  
**so that** I can arrange tables efficiently and update their positions as needed (để tôi có thể sắp xếp bàn hiệu quả và cập nhật vị trí khi cần thiết).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Table belongs to one layout section (Bàn thuộc về một khu vực bố cục)
2. Drag-and-drop positioning using @angular/cdk/drag-drop (Định vị kéo-thả sử dụng @angular/cdk/drag-drop)
3. Position persistence and visual feedback during drag operations (Lưu trữ vị trí và phản hồi trực quan trong quá trình kéo)
4. Table status management within sections (Quản lý trạng thái bàn trong khu vực)

---