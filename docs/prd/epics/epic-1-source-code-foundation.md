# Epic 1: Source Code Foundation & Infrastructure (Tạo Source Code & Hạ tầng Cốt lõi)

**Expanded Goal:** Establish complete project foundation including ABP Framework setup, development environment configuration, basic authentication, core infrastructure, and initial deployment pipeline to enable all subsequent development work (Thiết lập nền tảng dự án hoàn chỉnh bao gồm thiết lập ABP Framework, cấu hình môi trường phát triển, xác thực cơ bản, hạ tầng cốt lõi và pipeline triển khai ban đầu để cho phép tất cả công việc phát triển tiếp theo).

## Story 1.1: Project Structure & Development Environment Setup (Thiết lập Cấu trúc Dự án & Môi trường Phát triển)
**As a** developer (lập trình viên),  
**I want** to establish ABP Framework project structure with proper configuration (tôi muốn thiết lập cấu trúc dự án ABP Framework với cấu hình phù hợp),  
**so that** development can proceed efficiently with all necessary tools (để quá trình phát triển có thể tiếp diễn hiệu quả với đầy đủ các công cụ cần thiết).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. ABP Framework solution created with .NET 8 and Angular 19 templates (Tạo giải pháp ABP Framework với mẫu .NET 8 và Angular 19)
2. PostgreSQL database connection configured with Vietnamese collation (Cấu hình kết nối cơ sở dữ liệu PostgreSQL với sắp xếp tiếng Việt)
3. Docker containerization setup completed with docker-compose (Hoàn thành thiết lập đóng gói Docker với docker-compose)
4. Development environment documented in CLAUDE.md (Tài liệu hóa môi trường phát triển trong CLAUDE.md)
5. Initial CI/CD pipeline configured with basic build and test stages (Cấu hình pipeline CI/CD ban đầu với các giai đoạn build và test cơ bản)

## Story 1.2: Angular Poseidon Theme Integration (Tích hợp Theme Poseidon vào Angular)
**As a** restaurant staff member (nhân viên nhà hàng),  
**I want** to use a professional and intuitive web interface optimized for restaurant operations (tôi muốn sử dụng giao diện web chuyên nghiệp và trực quan được tối ưu cho hoạt động nhà hàng),  
**so that** I can complete tasks quickly and efficiently during busy periods (để tôi có thể hoàn thành nhiệm vụ nhanh chóng và hiệu quả trong thời gian bận rộn).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Poseidon theme installed and configured with PrimeNG components in Angular project (Theme Poseidon được cài đặt và cấu hình với các component PrimeNG trong dự án Angular)
2. Vietnamese restaurant color palette customization (warm reds, golds, browns) applied to theme (Tùy chỉnh bảng màu nhà hàng Việt Nam - đỏ ấm, vàng, nâu - được áp dụng cho theme)
3. Touch-friendly responsive design implemented for tablet-first usage (Thiết kế responsive thân thiện cảm ứng được triển khai ưu tiên sử dụng tablet)
4. Typography configuration supporting Vietnamese characters with proper font rendering (Cấu hình typography hỗ trợ ký tự tiếng Việt với render font phù hợp)
5. PrimeNG component library integrated with custom Vietnamese restaurant aesthetics (Thư viện component PrimeNG được tích hợp với thẩm mỹ nhà hàng Việt Nam tùy chỉnh)
6. Layout structure established for main restaurant workflows (dashboard, menu, orders, payments) (Cấu trúc layout được thiết lập cho các quy trình nhà hàng chính - dashboard, menu, đơn hàng, thanh toán)

## Story 1.3: Flutter Mobile App Foundation Setup (Thiết lập Nền tảng Ứng dụng Di động Flutter)
**As a** restaurant staff member (nhân viên nhà hàng),  
**I want** to access restaurant management functions on mobile devices (tôi muốn truy cập các chức năng quản lý nhà hàng trên thiết bị di động),  
**so that** I can work efficiently from anywhere in the restaurant (để tôi có thể làm việc hiệu quả từ bất kỳ đâu trong nhà hàng).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Flutter project structure established in monorepo with proper folder organization (Cấu trúc dự án Flutter được thiết lập trong monorepo với tổ chức thư mục phù hợp)
2. Basic navigation framework implemented with Vietnamese-only interface (Framework điều hướng cơ bản được triển khai với giao diện chỉ tiếng Việt)
3. Authentication integration with ABP backend APIs using JWT tokens (Tích hợp xác thực với API backend ABP sử dụng JWT token)
4. Vietnamese localization setup with proper date/time and currency formatting (Thiết lập bản địa hóa tiếng Việt với định dạng ngày/giờ và tiền tệ phù hợp)
5. HTTP client configuration for secure API communication with backend (Cấu hình HTTP client cho giao tiếp API an toàn với backend)
6. Basic responsive design framework for tablets and smartphones (Framework thiết kế responsive cơ bản cho tablet và smartphone)

## Story 1.4: Authentication & User Management System (Hệ thống Xác thực & Quản lý Người dùng)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to manage user accounts with role-based permissions (tôi muốn quản lý tài khoản người dùng theo phân quyền vai trò),  
**so that** staff can access appropriate system functions (để nhân viên có thể truy cập đúng các chức năng hệ thống phù hợp).

**Acceptance Criteria:**
1. Role-based authentication implemented for Owner, Manager, Cashier, Kitchen Staff, Waitstaff (Hệ thống phân quyền theo vai trò cho Chủ nhà hàng, Quản lý, Thu ngân, Nhân viên bếp và Nhân viên phục vụ)
2. User registration and management interface completed (Hoàn thành giao diện tạo tài khoản và quản lý nhân viên)
3. JWT token authentication with secure session management (Đăng nhập bằng JWT token với bảo mật phiên làm việc)
4. Password reset functionality implemented (Tính năng đặt lại mật khẩu khi quên)
5. Audit logging for user activities (Ghi lại lịch sử hoạt động của người dùng)

## Story 1.5: Code First Database Schema & Core Entities (Schema Cơ sở dữ liệu Code First & Entities Cốt lõi)
**As a** system administrator (quản trị viên hệ thống),  
**I want** to establish Code First database foundation with ABP domain entities (tôi muốn thiết lập nền tảng cơ sở dữ liệu Code First với domain entity ABP),  
**so that** data can be stored reliably with proper DDD relationships and ABP conventions (để dữ liệu có thể được lưu trữ an toàn với mối quan hệ DDD và quy ước ABP phù hợp).

**Acceptance Criteria:**
1. Core domain entities created inheriting from ABP base classes: MenuCategory (AggregateRoot), MenuItem (Entity), Order (AggregateRoot), Payment (Entity) (Tạo các Entity chính của hệ thống: Danh mục thực đơn, Món ăn, Đơn hàng, Thanh toán theo chuẩn ABP)
2. Entity Framework Core Code First migrations implemented with seed data and Vietnamese collation (Thiết lập database với migration tự động và dữ liệu mẫu, hỗ trợ tiếng Việt)
3. Entity relationships configured using Fluent API with proper navigation properties (Cấu hình mối quan hệ giữa các bảng dữ liệu bằng Fluent API)
4. Vietnamese text search configuration applied with full-text indexing (Tìm kiếm tiếng Việt có dấu với chỉ mục toàn văn)
5. ABP audit properties (CreationTime, CreatorId, etc.) configured for all entities (Tự động ghi lại thời gian tạo, người tạo, sửa đổi cho tất cả dữ liệu)
6. Database backup procedures documented with PostgreSQL-specific commands (Hướng dẫn sao lưu và phục hồi database PostgreSQL)

## Story 1.6: Health Check & Monitoring Foundation (Nền tảng Health Check & Giám sát)
**As a** system operator (người vận hành hệ thống),  
**I want** to monitor system health và performance (tôi muốn giám sát sức khỏe hệ thống và hiệu suất),  
**so that** issues can be detected và resolved quickly (để các vấn đề có thể được phát hiện và giải quyết nhanh chóng).

**Acceptance Criteria:**
1. Health check endpoints implemented for database and external services (Kiểm tra tình trạng hoạt động của database và các dịch vụ liên quan)
2. Basic logging framework configured with Serilog (Thiết lập hệ thống ghi log chi tiết bằng Serilog)
3. Application performance monitoring setup (Giám sát hiệu suất ứng dụng thời gian thực)
4. Error tracking and notification system implemented (Hệ thống phát hiện lỗi và cảnh báo tự động)
5. System status dashboard accessible (Màn hình theo dõi tình trạng hệ thống)



---