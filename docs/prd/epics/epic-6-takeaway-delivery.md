# Epic 6: Takeaway & Delivery Orders (Gọi đồ mang về)

**Simplified Goal:** Enable simple takeaway order processing workflow: customer arrives → staff takes order → prints kitchen bill → confirms completion → processes payment. Orders display on kitchen screen with takeaway marking to differentiate from dine-in orders (Kích hoạt quy trình xử lý đơn mang về đơn giản: khách tới quán → nhân viên gọi món → in bill bếp → xác nhận hoàn thành → xử lý thanh toán. Đơn hàng hiển thị trên màn hình bếp với đánh dấu mang về để phân biệt với đơn ăn tại quán).

## Story 6.1: Takeaway Order Processing Workflow (Quy trình Xử lý Đơn hàng Mang về)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process takeaway orders with a simple workflow without table assignment (tôi muốn xử lý đơn hàng mang về với quy trình đơn giản không cần phân bàn),  
**so that** customers can quickly order food for takeaway (để khách hàng có thể nhanh chóng gọi món mang về).

**Acceptance Criteria:**
1. **Takeaway Order Creation**: Direct menu access without table selection for takeaway orders (Tạo đơn mang về: Truy cập menu trực tiếp không cần chọn bàn cho đơn mang về)
2. **Menu Browsing & Item Selection**: Same menu interface as dine-in with quantity and notes functionality (Duyệt menu và chọn món: Giao diện menu giống như ăn tại quán với chức năng số lượng và ghi chú)
3. **Kitchen Integration with Takeaway Marking**: Orders print to kitchen with clear "TAKEAWAY" marking and display on Story 5.2 kitchen screen (Tích hợp bếp với đánh dấu mang về: Đơn hàng in ra bếp với dấu hiệu "MANG VỀ" rõ ràng và hiển thị trên màn hình bếp Story 5.2)
4. **Order Status Tracking**: Real-time status updates (Confirmed, Preparing, Ready for Pickup) (Theo dõi trạng thái đơn: Cập nhật trạng thái thời gian thực - Đã xác nhận, Đang chuẩn bị, Sẵn sàng lấy)
5. **Payment Processing Integration**: Direct integration with Epic 8 payment processing (Tích hợp xử lý thanh toán: Tích hợp trực tiếp với xử lý thanh toán Epic 8)

---