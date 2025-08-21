# Epic 10: Table Reservation System (Đặt bàn)

**Simple Goal:** Enable phone-based table reservations with pre-ordering capability that reuses existing order management workflow from Story 6.1 for efficient and familiar operation (Kích hoạt đặt bàn qua điện thoại với khả năng đặt món trước sử dụng lại quy trình quản lý đơn hàng hiện tại từ Story 6.1 để vận hành hiệu quả và quen thuộc).

## Story 10.1: Phone Reservation Processing (Xử lý Đặt bàn qua Điện thoại)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process customer phone reservations with table assignment and pre-ordering using existing menu interface (tôi muốn xử lý đặt bàn qua điện thoại của khách hàng với phân bàn và đặt món trước sử dụng giao diện menu hiện có),  
**so that** customers can reserve tables and pre-order food using the same familiar workflow as regular orders (để khách hàng có thể đặt bàn và đặt món trước sử dụng cùng quy trình quen thuộc như gọi món thường).

**Acceptance Criteria:**
1. **Reservation Information Capture**: Form to input customer phone number, party size, arrival time, and special requests (Thu thập thông tin đặt bàn: Form nhập số điện thoại khách, số người, giờ đến và yêu cầu đặc biệt)
2. **Table Selection for Reservation**: Select appropriate table based on party size and update table status to "Reserved" with reservation details (Chọn bàn cho đặt trước: Chọn bàn phù hợp theo số người và cập nhật trạng thái bàn thành "Đã đặt" với chi tiết đặt bàn)
3. **Pre-Order Menu Integration**: Use existing Story 6.1 menu browsing and item selection interface to take pre-orders for reserved tables (Tích hợp menu đặt trước: Sử dụng giao diện duyệt menu và chọn món hiện có từ Story 6.1 để nhận đặt món trước cho bàn đã đặt)
4. **Reserved Table Management**: Display reserved tables with reservation time, customer info, and pre-ordered items in table status overview (Quản lý bàn đã đặt: Hiển thị bàn đã đặt với thời gian đặt, thông tin khách và món đã đặt trước trong tổng quan trạng thái bàn)
5. **Arrival Processing**: When customers arrive, convert "Reserved" status to "Occupied" and automatically begin kitchen preparation for pre-ordered items (Xử lý khi khách đến: Khi khách đến, chuyển trạng thái "Đã đặt" thành "Đang sử dụng" và tự động bắt đầu chuẩn bị bếp cho món đã đặt trước)
6. **Integration with Existing Workflow**: Seamless transition to existing Story 6.1 order management workflow for additional orders and service completion (Tích hợp với quy trình hiện có: Chuyển đổi mượt mà sang quy trình quản lý đơn hàng Story 6.1 hiện có cho đơn hàng bổ sung và hoàn thành phục vụ)

---