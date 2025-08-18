# Epic 2: User Management & Role System (Quản lý Người dùng & Hệ thống Vai trò)

**Expanded Goal:** Create comprehensive user management system with role-based access control, authentication workflows, and permission management specifically designed for restaurant staff hierarchy and Vietnamese restaurant operations (Tạo hệ thống quản lý người dùng toàn diện với kiểm soát truy cập dựa trên vai trò, quy trình xác thực và quản lý quyền được thiết kế đặc biệt cho cấu trúc nhân viên nhà hàng và hoạt động nhà hàng Việt Nam).

## Story 2.1: Role-Based Access Control System (Hệ thống Kiểm soát Truy cập theo Vai trò)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to define different user roles with specific permissions (tôi muốn định nghĩa các vai trò người dùng khác nhau với quyền cụ thể),  
**so that** each staff member can access only the functions relevant to their job (để mỗi nhân viên chỉ có thể truy cập các chức năng liên quan đến công việc của họ).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Define roles: Owner, Manager, Cashier, Kitchen Staff, Waitstaff with specific permissions (Định nghĩa vai trò: Chủ sở hữu, Quản lý, Thu ngân, Nhân viên bếp, Nhân viên phục vụ với quyền cụ thể)
2. Permission matrix implementation for each role (Triển khai ma trận quyền cho mỗi vai trò)
3. Role assignment and modification interface (Giao diện phân công và sửa đổi vai trò)
4. Role-based menu and feature visibility (Hiển thị menu và tính năng dựa trên vai trò)
5. Audit trail for role changes (Đường kiểm toán cho thay đổi vai trò)

## Story 2.2: User Account Management (Quản lý Tài khoản Người dùng)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to create and manage staff accounts efficiently (tôi muốn tạo và quản lý tài khoản nhân viên một cách hiệu quả),  
**so that** all staff can access the system with appropriate credentials (để tất cả nhân viên có thể truy cập hệ thống với thông tin đăng nhập phù hợp).

**Acceptance Criteria:**
1. User creation with Vietnamese name support (Tạo người dùng với hỗ trợ tên tiếng Việt)
2. Profile management with contact information (Quản lý hồ sơ với thông tin liên lạc)
3. Password reset and security features (Đặt lại mật khẩu và tính năng bảo mật)
4. User deactivation and reactivation (Vô hiệu hóa và kích hoạt lại người dùng)
5. Bulk user operations for staff management (Thao tác hàng loạt cho quản lý nhân viên)

## Story 2.3: Authentication & Session Management (Xác thực & Quản lý Phiên)
**As a** system user (người dùng hệ thống),  
**I want** secure and convenient login experience (tôi muốn trải nghiệm đăng nhập an toàn và thuận tiện),  
**so that** I can access the system quickly during busy restaurant hours (để tôi có thể truy cập hệ thống nhanh chóng trong giờ cao điểm của nhà hàng).

**Acceptance Criteria:**
1. Touch-friendly login interface for tablets (Giao diện đăng nhập thân thiện cảm ứng cho tablet)
2. Session management with auto-logout for security (Quản lý phiên với tự động đăng xuất để bảo mật)
3. Remember device functionality for trusted devices (Chức năng nhớ thiết bị cho các thiết bị tin cậy)
4. Multi-session support for shared devices (Hỗ trợ đa phiên cho thiết bị dùng chung)
5. Failed login attempt monitoring (Giám sát các lần đăng nhập không thành công)

---