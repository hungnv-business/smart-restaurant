# Requirements (Yêu cầu)

## Functional Requirements (Yêu cầu Chức năng)

**FR1:** The system shall provide two-level menu management allowing category-level enable/disable and individual dish-level control for seasonal variations (Hệ thống sẽ cung cấp quản lý menu hai cấp cho phép bật/tắt cấp danh mục và điều khiển cấp món riêng lẻ cho biến thể theo mùa)

**FR2:** The system shall support Vietnamese payment processing with three methods: cash, debt/credit, and QR code bank transfer with mandatory staff confirmation (Hệ thống sẽ hỗ trợ xử lý thanh toán Việt Nam với ba phương thức: tiền mặt, nợ/tín dụng, và chuyển khoản ngân hàng QR với xác nhận nhân viên bắt buộc)

**FR3:** The system shall process orders with real-time updates via SignalR to kitchen stations categorized by type (hotpot, grilled, drinking stations) (Hệ thống sẽ xử lý đơn hàng với cập nhật thời gian thực qua SignalR đến các trạm bếp được phân loại theo loại - trạm lẩu, nướng, nhậu)

**FR4:** The system shall automatically deduct inventory based on ingredient mapping when orders are confirmed (Hệ thống sẽ tự động trừ kho dựa trên mapping nguyên liệu khi đơn hàng được xác nhận)

**FR5:** The system shall provide role-based access control with distinct permissions for owner, manager, cashier, kitchen staff, and waitstaff (Hệ thống sẽ cung cấp kiểm soát truy cập dựa trên vai trò với quyền riêng biệt cho chủ sở hữu, quản lý, thu ngân, nhân viên bếp, và nhân viên phục vụ)

**FR6:** The system shall support Vietnamese-only interface including currency (VND), timezone (Asia/Ho_Chi_Minh), and Vietnamese text search capabilities (Hệ thống sẽ hỗ trợ giao diện chỉ tiếng Việt bao gồm tiền tệ (VND), múi giờ (Asia/Ho_Chi_Minh), và khả năng tìm kiếm văn bản tiếng Việt)

**FR7:** The system shall operate in offline mode during internet outages with data synchronization when connectivity returns (Hệ thống sẽ hoạt động ở chế độ offline trong thời gian mất kết nối internet với đồng bộ hóa dữ liệu khi kết nối trở lại)

**FR8:** The system shall generate daily, weekly, and monthly revenue reports with category-specific analytics for business decision making (Hệ thống sẽ tạo báo cáo doanh thu hàng ngày, hàng tuần, và hàng tháng với phân tích đặc thù danh mục cho việc ra quyết định kinh doanh)

## Non-Functional Requirements (Yêu cầu Phi chức năng)

**NFR1:** The system shall achieve 99.5% uptime during operating hours (11:30-21:00) with maximum 2-second response time for order processing (Hệ thống sẽ đạt 99.5% thời gian hoạt động trong giờ kinh doanh với thời gian phản hồi tối đa 2 giây cho xử lý đơn hàng)

**NFR2:** The system shall support minimum 30 concurrent orders during peak hours (17:00-21:00) without performance degradation (Hệ thống sẽ hỗ trợ tối thiểu 30 đơn hàng đồng thời trong giờ cao điểm mà không giảm hiệu suất)

**NFR3:** The system shall implement responsive mobile-first design optimized for tablet operations with touch-friendly interfaces (Hệ thống sẽ triển khai thiết kế responsive ưu tiên mobile được tối ưu cho hoạt động tablet với giao diện thân thiện cảm ứng)

**NFR4:** The system shall ensure data backup and recovery with maximum 1-hour Recovery Time Objective (RTO) and 15-minute Recovery Point Objective (RPO) (Hệ thống sẽ đảm bảo sao lưu và khôi phục dữ liệu với Mục tiêu Thời gian Khôi phục tối đa 1 giờ và Mục tiêu Điểm Khôi phục 15 phút)

**NFR5:** The system shall maintain 70% automated test coverage with integration testing for critical business workflows (Hệ thống sẽ duy trì 70% độ bao phủ kiểm thử tự động với kiểm thử tích hợp cho quy trình kinh doanh quan trọng)

**NFR6:** The system shall implement security measures including data encryption at rest and in transit, secure authentication, and audit logging (Hệ thống sẽ triển khai các biện pháp bảo mật bao gồm mã hóa dữ liệu khi nghỉ và khi truyền, xác thực an toàn, và ghi log kiểm toán)

---
