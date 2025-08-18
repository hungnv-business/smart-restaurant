# Epic 6: Order Processing & Kitchen Coordination (Order)

**Expanded Goal:** Enable complete end-to-end order workflow from table selection through real-time kitchen coordination, implementing the complete waitstaff workflow: view table status → select customer table → browse menu → order items → confirm order → print to kitchen → serve customers → confirm completion (Kích hoạt quy trình đơn hàng đầu cuối hoàn chỉnh từ chọn bàn đến phối hợp bếp thời gian thực, triển khai quy trình nhân viên phục vụ hoàn chỉnh: xem trạng thái bàn → chọn bàn khách → duyệt menu → gọi món → xác nhận đơn → in cho bếp → phục vụ khách → xác nhận hoàn thành).

## Story 6.1: Waitstaff Order Management Workflow (Quy trình Gọi món của Nhân viên Phục vụ)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to complete the entire order process from table selection through order confirmation and kitchen coordination (tôi muốn hoàn thành toàn bộ quy trình gọi món từ chọn bàn đến xác nhận đơn hàng và phối hợp với bếp),  
**so that** I can efficiently serve customers through a seamless workflow: view table status → select customer table → browse menu → order items → confirm order → coordinate with kitchen → serve customers → confirm completion (để tôi có thể phục vụ khách hàng hiệu quả thông qua quy trình mượt mà: xem trạng thái bàn → chọn bàn khách → duyệt menu → gọi món → xác nhận đơn → phối hợp bếp → phục vụ khách → xác nhận hoàn thành).

**Acceptance Criteria:**
1. **Table Status & Selection**: Real-time table status display (Available, Occupied, Reserved, Cleaning) with color-coded indicators and touch-friendly selection interface (Quản lý trạng thái bàn: Hiển thị trạng thái thời gian thực với text và chỉ báo mã màu và giao diện chọn bàn thân thiện cảm ứng)
2. **Menu Browsing & Search**: Mobile-responsive menu display with Vietnamese text search, autocomplete, category filtering, and real-time availability status (Duyệt menu và tìm kiếm: Hiển thị menu responsive với tìm kiếm tiếng Việt, tự động hoàn thành, lọc danh mục và trạng thái có sẵn thời gian thực)
3. **Item Selection & Customization**: Item selection with quantity adjustment, individual or general notes, and order summary display with table information (Chọn món và tùy chỉnh: Chọn món với điều chỉnh số lượng, ghi chú riêng hoặc chung, và hiển thị tóm tắt đơn hàng với thông tin bàn)
4. **Order Confirmation & Kitchen Integration**: Order confirmation with automatic printing to appropriate kitchen stations and real-time status tracking (Confirmed, Preparing, Ready, Served) (Xác nhận đơn hàng và tích hợp bếp: Xác nhận đơn với in tự động cho trạm bếp phù hợp và theo dõi trạng thái thời gian thực)
5. **Manual Print Functionality**: Manual print button to select specific dishes and reprint kitchen bills for orders as needed (Chức năng in thủ công: Nút in thủ công để chọn các món cụ thể và in lại bill bếp cho đơn hàng khi cần thiết)
6. **Service Completion Workflow**: Service completion confirmation interface with integration to table status updates and order history tracking (Quy trình hoàn thành phục vụ: Giao diện xác nhận hoàn thành phục vụ với tích hợp cập nhật trạng thái bàn và theo dõi lịch sử đơn hàng)
7. **Payment Button Integration**: Payment processing button placed alongside print and service action buttons for seamless payment workflow integration with Epic 8 (Tích hợp nút thanh toán: Nút xử lý thanh toán đặt cạnh các nút in và thao tác phục vụ để tích hợp quy trình thanh toán mượt mà với Epic 8)

## Story 6.2: Kitchen Priority Management Dashboard (Bảng điều khiển Quản lý Ưu tiên Bếp)
**As a** kitchen staff (nhân viên bếp),  
**I want** to see all tables with pending orders prioritized by order time and dish preparation speed (tôi muốn xem tất cả các bàn có đơn hàng chưa phục vụ được ưu tiên theo thời gian gọi món và tốc độ chế biến),  
**so that** I can optimize cooking sequence to serve quick dishes first while maintaining order priority (để tôi có thể tối ưu thứ tự nấu ăn, phục vụ món nhanh trước trong khi vẫn duy trì ưu tiên đơn hàng).

**Acceptance Criteria:**
1. Table-based order display showing all pending orders sorted by order time (Hiển thị đơn hàng theo bàn cho tất cả đơn chưa phục vụ, sắp xếp theo thời gian gọi)
2. Quick-cook dish indicators (vegetables, tofu, light dishes) with visual priority markers (Đánh dấu món nấu nhanh - rau, đậu phụ, món nhẹ - với chỉ báo ưu tiên trực quan)
3. Cooking time estimates for each dish with color-coded urgency levels (Ước tính thời gian nấu cho từng món với mức độ khẩn cấp mã màu)
4. Smart preparation suggestions balancing FIFO order priority with quick-serve opportunities (Gợi ý chuẩn bị thông minh cân bằng ưu tiên đơn hàng đến trước với cơ hội phục vụ nhanh)
5. Real-time updates when dishes are completed and served to tables (Cập nhật thời gian thực khi món được hoàn thành và phục vụ cho bàn)

---