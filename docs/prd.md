# Smart Restaurant Management System - Product Requirements Document (Hệ thống Quản lý Nhà hàng Thông minh - Tài liệu Yêu cầu Sản phẩm)

**Document Type (Loại Tài liệu):** Product Requirements Document (Tài liệu Yêu cầu Sản phẩm)  
**Created Date (Ngày Tạo):** 2025-08-16  
**Version (Phiên bản):** 1.0  
**Status (Trạng thái):** Complete (Hoàn thành)  

---

## Goals and Background Context (Mục tiêu và Bối cảnh)

### Goals (Mục tiêu)

• Establish operational efficiency for the owner's Vietnamese restaurant through automated order processing and menu management (Thiết lập hiệu quả vận hành cho nhà hàng Việt Nam của chủ sở hữu thông qua xử lý đơn hàng tự động và quản lý menu)

• Implement flexible two-level menu management system supporting seasonal category and individual dish control (Triển khai hệ thống quản lý menu linh hoạt hai cấp hỗ trợ điều khiển danh mục theo mùa và từng món riêng lẻ)

• Create mobile-first responsive interface optimized for restaurant tablet/mobile operations during peak hours (Tạo giao diện responsive ưu tiên mobile được tối ưu cho hoạt động tablet/mobile nhà hàng trong giờ cao điểm)

• Deliver Vietnamese payment workflow with staff confirmation (Cung cấp quy trình thanh toán Việt Nam với xác nhận nhân viên)

• Achieve measurable ROI within 6 months through operational cost savings and efficiency improvements (Đạt ROI có thể đo lường trong 6 tháng thông qua tiết kiệm chi phí vận hành và cải thiện hiệu quả)

### Background Context (Bối cảnh)

The Smart Restaurant Management System addresses critical operational challenges faced by Vietnamese rural restaurants, specifically seasonal menu complexity and lack of affordable, restaurant-specific management solutions. Current generic POS systems fail to accommodate Vietnamese restaurant workflows, two-level menu management needs, and Vietnamese payment preferences common in rural areas. (Hệ thống Quản lý Nhà hàng Thông minh giải quyết những thách thức vận hành quan trọng mà các nhà hàng nông thôn Việt Nam đang gặp phải, đặc biệt là sự phức tạp của thực đơn theo mùa và thiếu các giải pháp quản lý phù hợp với từng nhà hàng. Các hệ thống POS chung hiện tại không đáp ứng được quy trình làm việc của nhà hàng Việt Nam, nhu cầu quản lý thực đơn hai cấp và các tùy chọn thanh toán Việt Nam phổ biến ở vùng nông thôn.)

This PRD builds upon comprehensive market analysis showing that existing solutions are either too expensive for small businesses or lack the cultural and operational specificity required for Vietnamese restaurant operations. The system will serve as an internal operational tool for the owner's restaurant, with potential for future expansion to additional locations and eventual licensing to similar establishments. (PRD này được xây dựng dựa trên phân tích thị trường toàn diện cho thấy các giải pháp hiện tại hoặc quá tốn kém đối với các doanh nghiệp nhỏ hoặc thiếu tính đặc thù về văn hóa và vận hành cần thiết cho hoạt động kinh doanh nhà hàng Việt Nam. Hệ thống sẽ đóng vai trò là công cụ vận hành nội bộ cho nhà hàng của chủ sở hữu, với tiềm năng mở rộng sang các địa điểm khác trong tương lai và cuối cùng là cấp phép cho các cơ sở tương tự.)

### Change Log (Nhật ký Thay đổi)

| Date (Ngày) | Version (Phiên bản) | Description (Mô tả) | Author (Tác giả) |
|-------------|---------------------|---------------------|------------------|
| 2025-08-16 | 1.0 | Initial PRD draft based on approved Project Brief (Bản thảo PRD ban đầu dựa trên Project Brief đã phê duyệt) | PM Agent - John |
| 2025-08-16 | 1.1 | Updated Epic List to reflect comprehensive restaurant operations with 12 detailed epics (Cập nhật Danh sách Epic để phản ánh hoạt động nhà hàng toàn diện với 12 epic chi tiết) | PM Agent - John |
| 2025-08-16 | 1.2 | Added Epic 7 "Takeaway & Delivery Orders" and reordered epics - moved Table Reservation after Reporting (Thêm Epic 7 "Gọi đồ mang về" và sắp xếp lại thứ tự epic - chuyển Đặt bàn sau Báo cáo) | PM Agent - John |
| 2025-08-17 | 1.3 | Fixed story numbering inconsistencies: Epic 6 stories (3.2,3.3→6.2,6.3), removed duplicate stories, added Flutter setup & Poseidon integration stories to Epic 1, corrected bilingual format for all Acceptance Criteria (Sửa lỗi đánh số story: Epic 6 stories, xóa stories trùng lặp, thêm Flutter setup & Poseidon integration vào Epic 1, sửa format song ngữ cho Acceptance Criteria) | Claude Code Assistant |

---

## Requirements (Yêu cầu)

### Functional Requirements (Yêu cầu Chức năng)

**FR1:** The system shall provide two-level menu management allowing category-level enable/disable and individual dish-level control for seasonal variations (Hệ thống sẽ cung cấp quản lý menu hai cấp cho phép bật/tắt cấp danh mục và điều khiển cấp món riêng lẻ cho biến thể theo mùa)

**FR2:** The system shall support Vietnamese payment processing with three methods: cash, debt/credit, and QR code bank transfer with mandatory staff confirmation (Hệ thống sẽ hỗ trợ xử lý thanh toán Việt Nam với ba phương thức: tiền mặt, nợ/tín dụng, và chuyển khoản ngân hàng QR với xác nhận nhân viên bắt buộc)

**FR3:** The system shall process orders with real-time updates via SignalR to kitchen stations categorized by type (hotpot, grilled, drinking stations) (Hệ thống sẽ xử lý đơn hàng với cập nhật thời gian thực qua SignalR đến các trạm bếp được phân loại theo loại - trạm lẩu, nướng, nhậu)

**FR4:** The system shall automatically deduct inventory based on ingredient mapping when orders are confirmed (Hệ thống sẽ tự động trừ kho dựa trên mapping nguyên liệu khi đơn hàng được xác nhận)

**FR5:** The system shall provide role-based access control with distinct permissions for owner, manager, cashier, kitchen staff, and waitstaff (Hệ thống sẽ cung cấp kiểm soát truy cập dựa trên vai trò với quyền riêng biệt cho chủ sở hữu, quản lý, thu ngân, nhân viên bếp, và nhân viên phục vụ)

**FR6:** The system shall support Vietnamese-only interface including currency (VND), timezone (Asia/Ho_Chi_Minh), and Vietnamese text search capabilities (Hệ thống sẽ hỗ trợ giao diện chỉ tiếng Việt bao gồm tiền tệ (VND), múi giờ (Asia/Ho_Chi_Minh), và khả năng tìm kiếm văn bản tiếng Việt)

**FR7:** The system shall operate in offline mode during internet outages with data synchronization when connectivity returns (Hệ thống sẽ hoạt động ở chế độ offline trong thời gian mất kết nối internet với đồng bộ hóa dữ liệu khi kết nối trở lại)

**FR8:** The system shall generate daily, weekly, and monthly revenue reports with category-specific analytics for business decision making (Hệ thống sẽ tạo báo cáo doanh thu hàng ngày, hàng tuần, và hàng tháng với phân tích đặc thù danh mục cho việc ra quyết định kinh doanh)

### Non-Functional Requirements (Yêu cầu Phi chức năng)

**NFR1:** The system shall achieve 99.5% uptime during operating hours (11:30-21:00) with maximum 2-second response time for order processing (Hệ thống sẽ đạt 99.5% thời gian hoạt động trong giờ kinh doanh với thời gian phản hồi tối đa 2 giây cho xử lý đơn hàng)

**NFR2:** The system shall support minimum 30 concurrent orders during peak hours (17:00-21:00) without performance degradation (Hệ thống sẽ hỗ trợ tối thiểu 30 đơn hàng đồng thời trong giờ cao điểm mà không giảm hiệu suất)

**NFR3:** The system shall implement responsive mobile-first design optimized for tablet operations with touch-friendly interfaces (Hệ thống sẽ triển khai thiết kế responsive ưu tiên mobile được tối ưu cho hoạt động tablet với giao diện thân thiện cảm ứng)

**NFR4:** The system shall ensure data backup and recovery with maximum 1-hour Recovery Time Objective (RTO) and 15-minute Recovery Point Objective (RPO) (Hệ thống sẽ đảm bảo sao lưu và khôi phục dữ liệu với Mục tiêu Thời gian Khôi phục tối đa 1 giờ và Mục tiêu Điểm Khôi phục 15 phút)

**NFR5:** The system shall maintain 70% automated test coverage with integration testing for critical business workflows (Hệ thống sẽ duy trì 70% độ bao phủ kiểm thử tự động với kiểm thử tích hợp cho quy trình kinh doanh quan trọng)

**NFR6:** The system shall implement security measures including data encryption at rest and in transit, secure authentication, and audit logging (Hệ thống sẽ triển khai các biện pháp bảo mật bao gồm mã hóa dữ liệu khi nghỉ và khi truyền, xác thực an toàn, và ghi log kiểm toán)

---

## User Interface Design Goals (Mục tiêu Thiết kế Giao diện Người dùng)

### Overall UX Vision (Tầm nhìn UX Tổng thể)
Create intuitive, fast user experience for busy restaurant environment with touch interface optimized for tablets. System prioritizes operation speed during peak hours, minimizing steps required to complete core tasks like ordering, payment, and kitchen management. Design must align with Vietnamese restaurant work culture and support staff with limited technology experience. (Xây dựng trải nghiệm người dùng dễ hiểu và nhanh chóng, phù hợp với môi trường nhà hàng nhộn nhịp thông qua giao diện cảm ứng tối ưu cho máy tính bảng. Hệ thống tập trung vào tốc độ vận hành trong khung giờ đông khách, rút ngắn tối đa các bước thực hiện cho những công việc cốt lõi như gọi món, thanh toán và điều phối bếp. Thiết kế cần hòa hợp với văn hóa làm việc của nhà hàng Việt Nam và dễ sử dụng cho nhân viên chưa quen với công nghệ.)

### Key Interaction Paradigms (Mô hình Tương tác Chính)
- **Touch-First Navigation (Điều hướng Ưu tiên Cảm ứng):** Buttons and controls with minimum 44px size, suitable for finger operations in fast environment (Các nút bấm và điều khiển có kích thước tối thiểu 44px, thuận tiện cho việc chạm tay trong môi trường vận hành nhanh)
- **Visual Menu Categories (Danh mục Menu Trực quan):** Icon-based category selection with clear enable/disable visual indicators (Lựa chọn danh mục bằng biểu tượng với các chỉ báo trực quan rõ ràng để bật/tắt)
- **Swipe Gestures (Cử chỉ Vuốt):** Swipe to navigate between categories, orders, and kitchen views (Vuốt để chuyển đổi giữa các danh mục, đơn hàng và màn hình bếp)
- **Color-Coded Status System (Hệ thống Trạng thái Mã màu):** Quick color recognition for order status, payment status, and kitchen preparation stages (Phân biệt nhanh bằng màu sắc cho trạng thái đơn hàng, thanh toán và các giai đoạn chuẩn bị trong bếp)
- **One-Touch Actions (Hành động Một chạm):** Critical functions like "Add to Order," "Send to Kitchen," "Confirm Payment" require only one tap (Các chức năng quan trọng như "Thêm vào Đơn hàng," "Gửi xuống Bếp," "Xác nhận Thanh toán" chỉ cần chạm một lần)

### Core Screens and Views (Màn hình và Views Cốt lõi)
- **Login Screen (Màn hình Đăng nhập):** Role-based authentication with large touch targets (Xác thực theo vai trò với các vùng chạm lớn)
- **Main Dashboard (Bảng điều khiển Chính):** Overview of active orders, table status, and quick access to all functions (Tổng quan đơn hàng đang hoạt động, tình trạng bàn và truy cập nhanh mọi chức năng)
- **Menu Management Screen (Màn hình Quản lý Thực đơn):** Two-level category and dish management with visual enable/disable controls (Quản lý danh mục và món ăn hai cấp độ với điều khiển bật/tắt trực quan)
- **Order Taking Interface (Giao diện Nhận đơn):** Fast item selection with category filtering and quantity adjustment (Chọn món nhanh với lọc theo danh mục và điều chỉnh số lượng)
- **Kitchen Display Screen (Màn hình Hiển thị Bếp):** Station-specific order views for hotpot, grilled, drinking stations (Hiển thị đơn hàng riêng cho từng khu vực: lẩu, nướng, nhậu)
- **Payment Processing Screen (Màn hình Xử lý Thanh toán):** Vietnamese payment methods with staff confirmation workflow (Các phương thức thanh toán Việt Nam với quy trình xác nhận của nhân viên)
- **Reports Dashboard (Bảng điều khiển Báo cáo):** Revenue analytics with visual charts and category breakdowns (Phân tích doanh thu với biểu đồ trực quan và phân tích theo danh mục)
- **Settings Page (Trang Cài đặt):** System configuration and user management (Cấu hình hệ thống và quản lý người dùng)

### Accessibility: WCAG AA
Comply with WCAG AA standards including contrast ratios, keyboard navigation support, and screen reader compatibility for inclusive usage (Tuân thủ tiêu chuẩn WCAG AA bao gồm tỷ lệ tương phản màu sắc, hỗ trợ điều hướng bằng bàn phím và tương thích với phần mềm đọc màn hình để đảm bảo khả năng tiếp cận toàn diện).

### Branding (Thương hiệu)
Modern Vietnamese restaurant aesthetic with warm color palette (red, yellow, brown) reflecting traditional Vietnamese design elements. Clean, professional interface avoiding clutter in busy environment. Typography must support Vietnamese characters and be readable in various lighting conditions (Phong cách thẩm mỹ nhà hàng Việt Nam hiện đại với bảng màu ấm (đỏ, vàng, nâu) thể hiện các yếu tố thiết kế truyền thống Việt Nam. Giao diện sạch sẽ, chuyên nghiệp tránh sự rối mắt trong môi trường bận rộn. Font chữ phải hỗ trợ tiếng Việt và dễ đọc trong nhiều điều kiện ánh sáng khác nhau).

### Target Device and Platforms: Web Responsive
Primary platform: Web Responsive optimized for tablets (iPad, Android tablets) with secondary support for smartphones and desktop browsers. Flutter mobile app for staff management and customer ordering will be developed in later phases (Nền tảng chính: Web Responsive được tối ưu cho máy tính bảng (iPad, Android tablets) với hỗ trợ phụ cho điện thoại thông minh và trình duyệt máy tính để bàn. Ứng dụng di động Flutter cho quản lý nhân viên và đặt món của khách hàng sẽ được phát triển trong các giai đoạn sau).

---

## Technical Assumptions (Giả định Kỹ thuật)

### Repository Structure: Monorepo
Single repository containing all components: ABP Framework backend, Angular frontend, Flutter mobile app, and shared documentation. This optimizes solo development workflow and simplifies dependency management (Kho mã nguồn đơn chứa tất cả thành phần: ABP Framework backend, Angular frontend, ứng dụng di động Flutter và tài liệu chung. Cách này tối ưu hóa quy trình phát triển một mình và đơn giản hóa việc quản lý phụ thuộc).

### Service Architecture (Kiến trúc Dịch vụ)
**CRITICAL DECISION:** ABP Framework Modular Monolith with Code First Entity Framework Core and Domain-Driven Design patterns. This architecture provides structured scalability while maintaining simplicity for solo development with automatic service proxy generation. Core modules include (Kiến trúc modular monolith ABP Framework với EF Core Code First và các mẫu Domain-Driven Design. Kiến trúc này cung cấp khả năng mở rộng có cấu trúc với tạo service proxy tự động):

#### ABP Framework Layers (Các Lớp ABP Framework)
- **Domain Layer (Lớp Miền):** Core entities inheriting from ABP base classes (AggregateRoot, Entity, ValueObject) with business logic (Thực thể cốt lõi kế thừa từ lớp cơ sở ABP với logic kinh doanh)
- **Application Layer (Lớp Ứng dụng):** Application services with DTOs and auto-generated Angular proxies (Dịch vụ ứng dụng với DTO và proxy Angular tự động tạo)
- **EntityFrameworkCore Layer (Lớp EntityFrameworkCore):** Code First DbContext with PostgreSQL provider and migrations (DbContext Code First với provider PostgreSQL và migration)
- **HttpApi.Host Layer (Lớp HttpApi.Host):** RESTful controllers, SignalR hubs, and authentication (Controller RESTful, hub SignalR và xác thực)

#### Core Business Modules (Module Kinh doanh Cốt lõi)
- **User Management Module:** ABP Identity integration with restaurant-specific roles (Tích hợp ABP Identity với vai trò chuyên biệt nhà hàng)
- **Menu Management Module:** MenuCategory and MenuItem aggregates with flexible enable/disable patterns (Aggregate MenuCategory và MenuItem với mẫu bật/tắt linh hoạt)
- **Order Processing Module:** Order aggregate with real-time SignalR coordination and kitchen routing (Aggregate Order với phối hợp SignalR thời gian thực và định tuyến bếp)
- **Payment Module:** Vietnamese payment domain services with local payment method support (Domain service thanh toán Việt Nam với hỗ trợ phương thức thanh toán địa phương)
- **Inventory Module:** InventoryItem and Recipe aggregates with automatic stock deduction (Aggregate InventoryItem và Recipe với trừ kho tự động)
- **Reporting Module:** Analytics services with data visualization and export capabilities (Dịch vụ phân tích với trực quan hóa dữ liệu và khả năng xuất)

### Testing Requirements (Yêu cầu Kiểm thử)
**CRITICAL DECISION:** Full Testing Pyramid with 70% code coverage target (Kim tự tháp kiểm thử đầy đủ với mục tiêu bao phủ 70% mã nguồn):
- **Unit Tests (Kiểm thử Đơn vị):** Core business logic and domain services (Logic nghiệp vụ cốt lõi và dịch vụ miền)
- **Integration Tests (Kiểm thử Tích hợp):** Database operations, external service integrations (Thao tác cơ sở dữ liệu, tích hợp dịch vụ bên ngoài)
- **API Tests (Kiểm thử API):** REST endpoints and SignalR hubs (Điểm cuối REST và hub SignalR)
- **UI Tests (Kiểm thử Giao diện):** Critical user workflows automation (Tự động hóa các quy trình người dùng quan trọng)
- **Manual Testing (Kiểm thử Thủ công):** Restaurant environment testing with real staff (Kiểm thử môi trường nhà hàng với nhân viên thực tế)

### Additional Technical Assumptions and Requests (Giả định và Yêu cầu Kỹ thuật Bổ sung)

• **Technology Stack (Ngăn xếp Công nghệ):** .NET 8 ABP Framework with Entity Framework Core Code First, Angular 19 with ABP Angular template + PrimeNG + Poseidon theme, PostgreSQL 14+ with Vietnamese collation and JSONB, SignalR for real-time coordination, Redis caching, Docker containerization (.NET 8 ABP Framework với EF Core Code First, Angular 19 với template ABP Angular + PrimeNG + theme Poseidon, PostgreSQL 14+ với sắp xếp tiếng Việt và JSONB, SignalR cho phối hợp thời gian thực, bộ nhớ đệm Redis, đóng gói Docker)

• **Development Environment (Môi trường Phát triển):** Visual Studio Code with ABP extensions, Docker Desktop for local development, ABP CLI for solution generation, ABP Suite for rapid CRUD development, Entity Framework Core tools for Code First migrations (Visual Studio Code với extension ABP, Docker Desktop cho phát triển cục bộ, ABP CLI cho tạo solution, ABP Suite cho phát triển CRUD nhanh, công cụ EF Core cho migration Code First)

• **Database Design (Thiết kế Cơ sở dữ liệu):** Entity Framework Core Code First approach with PostgreSQL provider, Vietnamese collation configuration, JSONB columns for flexible menu attributes, proper entity relationships using ABP conventions, migration-based schema evolution (Định hướng EF Core Code First với provider PostgreSQL, cấu hình sắp xếp tiếng Việt, cột JSONB cho thuộc tính menu linh hoạt, mối quan hệ thực thể phù hợp sử dụng quy ước ABP, tiến hóa schema dựa trên migration)

• **Real-time Communication (Giao tiếp Thời gian thực):** SignalR hubs for order updates, kitchen notifications, and live dashboard updates (Hub SignalR cho cập nhật đơn hàng, thông báo bếp và cập nhật bảng điều khiển trực tiếp)

• **Offline Capability (Khả năng Hoạt động Ngoại tuyến):** Progressive Web App (PWA) features with service workers, local storage for offline order queuing, background sync when connectivity returns (Tính năng ứng dụng web tiến bộ (PWA) với service worker, lưu trữ cục bộ cho xếp hàng đơn hàng ngoại tuyến, đồng bộ nền khi có kết nối trở lại)

• **Security Implementation (Triển khai Bảo mật):** JWT authentication, role-based permissions, data encryption at rest, HTTPS enforcement, audit logging for compliance (Xác thực JWT, phân quyền theo vai trò, mã hóa dữ liệu khi lưu trữ, bắt buộc HTTPS, ghi nhật ký kiểm toán để tuân thủ)

• **Performance Optimization (Tối ưu Hiệu suất):** Redis caching for menu data, database connection pooling, lazy loading for large datasets, image optimization for menu photos (Bộ nhớ đệm Redis cho dữ liệu thực đơn, gộp kết nối cơ sở dữ liệu, tải chậm cho tập dữ liệu lớn, tối ưu hình ảnh cho ảnh thực đơn)

• **Deployment Strategy (Chiến lược Triển khai):** Docker containers with docker-compose for staging, cloud deployment with automated backups, rolling updates to minimize downtime (Container Docker với docker-compose cho môi trường thử nghiệm, triển khai đám mây với sao lưu tự động, cập nhật luân phiên để giảm thiểu thời gian ngừng hoạt động)

• **Monitoring and Logging (Giám sát và Ghi nhật ký):** Structured logging with Serilog, application performance monitoring, error tracking, health checks for system reliability (Ghi nhật ký có cấu trúc với Serilog, giám sát hiệu suất ứng dụng, theo dõi lỗi, kiểm tra sức khỏe để đảm bảo độ tin cậy hệ thống)

• **Vietnamese-Only Configuration (Cấu hình Chỉ tiếng Việt):** Single Vietnamese language interface, proper VND currency formatting, Vietnamese date/time formatting, Vietnamese text search capabilities (Giao diện đơn ngôn ngữ tiếng Việt, định dạng tiền tệ VND chuẩn, định dạng ngày/giờ Việt Nam, khả năng tìm kiếm văn bản tiếng Việt)

---

## Epic List (Danh sách Epic)

### Epic 1: Source Code Foundation & Infrastructure (Tạo Source Code & Hạ tầng Cốt lõi)
**Goal:** Establish project foundation, development environment, basic authentication, and core infrastructure setup to enable all subsequent development work (Thiết lập nền tảng dự án, môi trường phát triển, xác thực cơ bản và thiết lập hạ tầng cốt lõi để cho phép tất cả công việc phát triển tiếp theo).

### Epic 2: User Management & Role System (Quản lý Người dùng & Hệ thống Vai trò)
**Goal:** Create comprehensive user management system with role-based access control for restaurant staff including owners, managers, cashiers, kitchen staff, and waitstaff (Tạo hệ thống quản lý người dùng toàn diện với kiểm soát truy cập dựa trên vai trò cho nhân viên nhà hàng bao gồm chủ sở hữu, quản lý, thu ngân, nhân viên bếp và nhân viên phục vụ).

### Epic 3: Table Layout Management (Quản lý Bố cục Bàn)
**Goal:** Design and implement flexible table layout management system supporting different seating arrangements, table status tracking, and reservation capabilities (Thiết kế và triển khai hệ thống quản lý bố cục bàn linh hoạt hỗ trợ các cách sắp xếp chỗ ngồi khác nhau, theo dõi trạng thái bàn và khả năng đặt bàn).

### Epic 4: Menu Management System (Quản lý Menu)
**Goal:** Implement two-level menu management with category and individual dish control, seasonal enable/disable functionality, pricing, and Vietnamese-only interface (Triển khai quản lý menu hai cấp với điều khiển danh mục và món ăn riêng lẻ, chức năng bật/tắt theo mùa, định giá và giao diện chỉ tiếng Việt).

### Epic 5: Inventory Management (Quản lý Kho)
**Goal:** Create inventory tracking system with automatic deduction based on ingredient mapping, stock level monitoring, and supplier management (Tạo hệ thống theo dõi kho với tự động trừ kho dựa trên ánh xạ nguyên liệu, giám sát mức tồn kho và quản lý nhà cung cấp).

### Epic 6: Order Processing & Kitchen Coordination (Order)
**Goal:** Enable end-to-end order workflow from order taking through real-time kitchen coordination with multi-station printing and order status tracking (Kích hoạt quy trình đơn hàng đầu cuối từ nhận đơn đến phối hợp bếp thời gian thực với in đa trạm và theo dõi trạng thái đơn hàng).

### Epic 7: Takeaway & Delivery Orders (Gọi đồ mang về)
**Goal:** Implement comprehensive takeaway and delivery order management system with customer ordering interface, packaging specifications, delivery tracking, and integration with main order system (Triển khai hệ thống quản lý đơn hàng mang về và giao hàng toàn diện với giao diện đặt món của khách hàng, thông số đóng gói, theo dõi giao hàng và tích hợp với hệ thống đặt món chính).

### Epic 8: Payment Processing (Thanh toán)
**Goal:** Implement Vietnamese payment processing workflows supporting cash, debt/credit, and QR bank transfer with mandatory staff confirmation (Triển khai quy trình xử lý thanh toán Việt Nam hỗ trợ tiền mặt, nợ/tín dụng và chuyển khoản ngân hàng QR với xác nhận nhân viên bắt buộc).

### Epic 9: Deployment & Production Management (Deploy)
**Goal:** Establish deployment pipeline, production monitoring, backup procedures, and maintenance workflows for reliable system operation (Thiết lập pipeline triển khai, giám sát sản xuất, quy trình sao lưu và quy trình bảo trì cho hoạt động hệ thống đáng tin cậy).

### Epic 10: Reporting & Analytics (Báo cáo)
**Goal:** Provide comprehensive reporting dashboard with revenue analytics, operational metrics, and business intelligence for data-driven decisions (Cung cấp bảng điều khiển báo cáo toàn diện với phân tích doanh thu, chỉ số vận hành và thông tin kinh doanh cho các quyết định dựa trên dữ liệu).

### Epic 11: Table Reservation System (Đặt bàn)
**Goal:** Implement comprehensive table reservation system with advance booking, walk-in management, and integration with table layout system (Triển khai hệ thống đặt bàn toàn diện với đặt chỗ trước, quản lý khách vãng lai và tích hợp với hệ thống bố cục bàn).

### Epic 12: Customer Management (Khách hàng)
**Goal:** Create customer relationship management system with customer profiles, loyalty programs, order history, and feedback collection (Tạo hệ thống quản lý quan hệ khách hàng với hồ sơ khách hàng, chương trình khách hàng thân thiết, lịch sử đơn hàng và thu thập phản hồi).

### Epic 13: Payroll & HR Management (Tính lương)
**Goal:** Implement staff payroll calculation system with work hour tracking, salary management, and integration with user role system (Triển khai hệ thống tính lương nhân viên với theo dõi giờ làm việc, quản lý lương và tích hợp với hệ thống vai trò người dùng).

---

## Epic Details (Chi tiết Epic)

### Epic 1: Source Code Foundation & Infrastructure (Tạo Source Code & Hạ tầng Cốt lõi)

**Expanded Goal:** Establish complete project foundation including ABP Framework setup, development environment configuration, basic authentication, core infrastructure, and initial deployment pipeline to enable all subsequent development work (Thiết lập nền tảng dự án hoàn chỉnh bao gồm thiết lập ABP Framework, cấu hình môi trường phát triển, xác thực cơ bản, hạ tầng cốt lõi và pipeline triển khai ban đầu để cho phép tất cả công việc phát triển tiếp theo).

#### Story 1.1: Project Structure & Development Environment Setup (Thiết lập Cấu trúc Dự án & Môi trường Phát triển)
**As a** developer (lập trình viên),  
**I want** to establish ABP Framework project structure with proper configuration (tôi muốn thiết lập cấu trúc dự án ABP Framework với cấu hình phù hợp),  
**so that** development can proceed efficiently with all necessary tools (để quá trình phát triển có thể tiếp diễn hiệu quả với đầy đủ các công cụ cần thiết).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. ABP Framework solution created with .NET 8 and Angular 19 templates (Tạo giải pháp ABP Framework với mẫu .NET 8 và Angular 19)
2. PostgreSQL database connection configured with Vietnamese collation (Cấu hình kết nối cơ sở dữ liệu PostgreSQL với sắp xếp tiếng Việt)
3. Docker containerization setup completed with docker-compose (Hoàn thành thiết lập đóng gói Docker với docker-compose)
4. Development environment documented in CLAUDE.md (Tài liệu hóa môi trường phát triển trong CLAUDE.md)
5. Initial CI/CD pipeline configured with basic build and test stages (Cấu hình pipeline CI/CD ban đầu với các giai đoạn build và test cơ bản)

#### Story 1.2: Angular Poseidon Theme Integration (Tích hợp Theme Poseidon vào Angular)
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

#### Story 1.3: Flutter Mobile App Foundation Setup (Thiết lập Nền tảng Ứng dụng Di động Flutter)
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

#### Story 1.4: Authentication & User Management System (Hệ thống Xác thực & Quản lý Người dùng)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to manage user accounts with role-based permissions (tôi muốn quản lý tài khoản người dùng theo phân quyền vai trò),  
**so that** staff can access appropriate system functions (để nhân viên có thể truy cập đúng các chức năng hệ thống phù hợp).

**Acceptance Criteria:**
1. Role-based authentication implemented for Owner, Manager, Cashier, Kitchen Staff, Waitstaff (Hệ thống phân quyền theo vai trò cho Chủ nhà hàng, Quản lý, Thu ngân, Nhân viên bếp và Nhân viên phục vụ)
2. User registration and management interface completed (Hoàn thành giao diện tạo tài khoản và quản lý nhân viên)
3. JWT token authentication with secure session management (Đăng nhập bằng JWT token với bảo mật phiên làm việc)
4. Password reset functionality implemented (Tính năng đặt lại mật khẩu khi quên)
5. Audit logging for user activities (Ghi lại lịch sử hoạt động của người dùng)

#### Story 1.5: Code First Database Schema & Core Entities (Schema Cơ sở dữ liệu Code First & Entities Cốt lõi)
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

#### Story 1.6: Health Check & Monitoring Foundation (Nền tảng Health Check & Giám sát)
**As a** system operator (người vận hành hệ thống),  
**I want** to monitor system health và performance (tôi muốn giám sát sức khỏe hệ thống và hiệu suất),  
**so that** issues can be detected và resolved quickly (để các vấn đề có thể được phát hiện và giải quyết nhanh chóng).

**Acceptance Criteria:**
1. Health check endpoints implemented for database, Redis, external services (Kiểm tra tình trạng hoạt động của database, Redis và các dịch vụ liên quan)
2. Basic logging framework configured with Serilog (Thiết lập hệ thống ghi log chi tiết bằng Serilog)
3. Application performance monitoring setup (Giám sát hiệu suất ứng dụng thời gian thực)
4. Error tracking and notification system implemented (Hệ thống phát hiện lỗi và cảnh báo tự động)
5. System status dashboard accessible (Màn hình theo dõi tình trạng hệ thống)



### Epic 2: User Management & Role System (Quản lý Người dùng & Hệ thống Vai trò)

**Expanded Goal:** Create comprehensive user management system with role-based access control, authentication workflows, and permission management specifically designed for restaurant staff hierarchy and Vietnamese restaurant operations (Tạo hệ thống quản lý người dùng toàn diện với kiểm soát truy cập dựa trên vai trò, quy trình xác thực và quản lý quyền được thiết kế đặc biệt cho cấu trúc nhân viên nhà hàng và hoạt động nhà hàng Việt Nam).

#### Story 2.1: Role-Based Access Control System (Hệ thống Kiểm soát Truy cập theo Vai trò)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to define different user roles with specific permissions (tôi muốn định nghĩa các vai trò người dùng khác nhau với quyền cụ thể),  
**so that** each staff member can access only the functions relevant to their job (để mỗi nhân viên chỉ có thể truy cập các chức năng liên quan đến công việc của họ).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Define roles: Owner, Manager, Cashier, Kitchen Staff, Waitstaff with specific permissions (Định nghĩa vai trò: Chủ sở hữu, Quản lý, Thu ngân, Nhân viên bếp, Nhân viên phục vụ với quyền cụ thể)
2. Permission matrix implementation for each role (Triển khai ma trận quyền cho mỗi vai trò)
3. Role assignment and modification interface (Giao diện phân công và sửa đổi vai trò)
4. Role-based menu and feature visibility (Hiển thị menu và tính năng dựa trên vai trò)
5. Audit trail for role changes (Đường kiểm toán cho thay đổi vai trò)

#### Story 2.2: User Account Management (Quản lý Tài khoản Người dùng)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to create and manage staff accounts efficiently (tôi muốn tạo và quản lý tài khoản nhân viên một cách hiệu quả),  
**so that** all staff can access the system with appropriate credentials (để tất cả nhân viên có thể truy cập hệ thống với thông tin đăng nhập phù hợp).

**Acceptance Criteria:**
1. User creation with Vietnamese name support (Tạo người dùng với hỗ trợ tên tiếng Việt)
2. Profile management with contact information (Quản lý hồ sơ với thông tin liên lạc)
3. Password reset and security features (Đặt lại mật khẩu và tính năng bảo mật)
4. User deactivation and reactivation (Vô hiệu hóa và kích hoạt lại người dùng)
5. Bulk user operations for staff management (Thao tác hàng loạt cho quản lý nhân viên)

#### Story 2.3: Authentication & Session Management (Xác thực & Quản lý Phiên)
**As a** system user (người dùng hệ thống),  
**I want** secure and convenient login experience (tôi muốn trải nghiệm đăng nhập an toàn và thuận tiện),  
**so that** I can access the system quickly during busy restaurant hours (để tôi có thể truy cập hệ thống nhanh chóng trong giờ cao điểm của nhà hàng).

**Acceptance Criteria:**
1. Touch-friendly login interface for tablets (Giao diện đăng nhập thân thiện cảm ứng cho tablet)
2. Session management with auto-logout for security (Quản lý phiên với tự động đăng xuất để bảo mật)
3. Remember device functionality for trusted devices (Chức năng nhớ thiết bị cho các thiết bị tin cậy)
4. Multi-session support for shared devices (Hỗ trợ đa phiên cho thiết bị dùng chung)
5. Failed login attempt monitoring (Giám sát các lần đăng nhập không thành công)

### Epic 3: Table Layout Management (Quản lý Bố cục Bàn)

**Expanded Goal:** Design and implement flexible table layout management system supporting different seating arrangements, table status tracking, visual layout editor, and integration with reservation and order systems for efficient restaurant floor management (Thiết kế và triển khai hệ thống quản lý bố cục bàn linh hoạt hỗ trợ các cách sắp xếp chỗ ngồi khác nhau, theo dõi trạng thái bàn, trình chỉnh sửa bố cục trực quan và tích hợp với hệ thống đặt bàn và đặt món để quản lý sàn nhà hàng hiệu quả).

#### Story 3.1: Visual Table Layout Editor (Trình chỉnh sửa Bố cục Bàn Trực quan)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to design and modify table layouts visually (tôi muốn thiết kế và chỉnh sửa bố cục bàn một cách trực quan),  
**so that** the system reflects the actual restaurant floor plan (để hệ thống phản ánh đúng mặt bằng thực tế của nhà hàng).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Drag-and-drop table layout editor with grid system (Trình chỉnh sửa bố cục bàn kéo-thả với hệ thống lưới)
2. Support for different table shapes and sizes (Hỗ trợ các hình dạng và kích thước bàn khác nhau)
3. Table numbering and naming system (Hệ thống đánh số và đặt tên bàn)
4. Save and load multiple layout configurations (Lưu và tải nhiều cấu hình bố cục)
5. Visual representation matching restaurant floor (Biểu diễn trực quan khớp với sàn nhà hàng)

### Epic 4: Menu Management System (Quản lý Menu)

**Expanded Goal:** Implement comprehensive two-level menu management with category and individual dish control, seasonal enable/disable functionality, pricing management, Vietnamese-only interface, and integration with inventory tracking for complete menu operations (Triển khai quản lý menu hai cấp toàn diện với điều khiển danh mục và món ăn riêng lẻ, chức năng bật/tắt theo mùa, quản lý định giá, giao diện chỉ tiếng Việt và tích hợp với theo dõi kho để vận hành menu hoàn chỉnh).

#### Story 4.1: Menu Category Aggregate Management (Quản lý Aggregate Danh mục Menu)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to create and manage menu categories using ABP aggregate patterns with seasonal control (tôi muốn tạo và quản lý danh mục menu sử dụng mẫu aggregate ABP với điều khiển theo mùa),  
**so that** menu can be adapted to seasonal availability with proper domain boundaries (để menu có thể được thích ứng với sự có sẵn theo mùa với rành giới miền phù hợp).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. MenuCategory aggregate root with CRUD operations via ABP Application Services and auto-generated Angular proxies (Aggregate root MenuCategory với thao tác CRUD qua ABP Application Service và proxy Angular tự động tạo)
2. IsEnabled domain property with business rules for seasonal enable/disable functionality (Thuộc tính miền IsEnabled với quy tắc kinh doanh cho chức năng bật/tắt theo mùa)
3. DisplayOrder value object for category ordering and priority management (Value object DisplayOrder cho quản lý thứ tự và ưu tiên danh mục)
4. Entity Framework configuration for image upload with JSONB metadata storage (Cấu hình Entity Framework cho tải lên hình ảnh với lưu trữ metadata JSONB)
5. PostgreSQL full-text search configuration with Vietnamese language support (Cấu hình tìm kiếm toàn văn PostgreSQL với hỗ trợ ngôn ngữ tiếng Việt)
6. ABP audit logging automatically applied to all category changes (ABP audit logging tự động áp dụng cho tất cả thay đổi danh mục)

#### Story 4.2: Individual Dish Management (Quản lý Món ăn Riêng lẻ)
**As a** kitchen manager (quản lý bếp),  
**I want** to manage individual dishes with detailed information and pricing (tôi muốn quản lý từng món ăn với thông tin chi tiết và định giá),  
**so that** accurate dish information and costs are available to staff and customers (để thông tin món ăn và chi phí chính xác có sẵn cho nhân viên và khách hàng).

**Acceptance Criteria:**
1. Dish CRUD operations with name, description, price, ingredients in Vietnamese (Thao tác CRUD món ăn với tên, mô tả, giá, nguyên liệu bằng tiếng Việt)
2. Individual dish enable/disable independent of category status (Bật/tắt món ăn riêng lẻ độc lập với trạng thái danh mục)
3. Photo upload and management for dishes with multiple angles (Tải lên và quản lý ảnh cho món ăn với nhiều góc độ)
4. Dietary restrictions, allergen information, and spice level indicators (Thông tin hạn chế chế độ ăn, dị ứng và chỉ báo độ cay)
5. Cooking time, preparation notes, and kitchen station assignment (Thời gian nấu, ghi chú chuẩn bị và phân công trạm bếp)


### Epic 5: Inventory Management (Quản lý Kho)

**Expanded Goal:** Create comprehensive inventory management system focused on ingredient category management for purchase invoices and stock-in tracking with automatic deduction, cost calculation, and low stock alerts for efficient restaurant inventory control (Tạo hệ thống quản lý kho toàn diện tập trung vào quản lý danh mục nguyên liệu cho hóa đơn mua và theo dõi nhập kho với trừ kho tự động, tính toán chi phí và cảnh báo hết hàng để kiểm soát kho nhà hàng hiệu quả).

#### Story 5.1: Ingredient Category Management (Quản lý Danh mục Nguyên liệu)
**As a** inventory manager (quản lý kho),  
**I want** to manage ingredient categories and items for purchase invoice creation (tôi muốn quản lý danh mục và mặt hàng nguyên liệu để tạo hóa đơn mua),  
**so that** purchase invoices can be created systematically and ingredients can be tracked properly (để hóa đơn mua có thể được tạo một cách có hệ thống và nguyên liệu có thể được theo dõi đúng cách).

**Acceptance Criteria:**
1. Ingredient category CRUD with Vietnamese names (tomatoes, onions, meat, etc.) (Tạo, sửa, xóa danh mục nguyên liệu với tên tiếng Việt)
2. Ingredient item management with detailed specifications (Quản lý từng mặt hàng nguyên liệu với thông số chi tiết)
3. Unit of measurement definition (kg, gram, liter, pieces, etc.) (Định nghĩa đơn vị đo lường - kg, gram, lít, cái, v.v.)
4. Cost tracking per unit for purchase invoice creation (Theo dõi giá thành theo đơn vị để tạo hóa đơn mua)
5. Supplier information linking for each ingredient (Liên kết thông tin nhà cung cấp cho từng nguyên liệu)

#### Story 5.2: Purchase Invoice & Stock-In Management (Quản lý Hóa đơn Mua & Nhập kho)
**As a** purchase manager (quản lý mua hàng),  
**I want** to create and manage purchase invoices with detailed stock-in tracking (tôi muốn tạo và quản lý hóa đơn mua với theo dõi nhập kho chi tiết),  
**so that** all purchases are recorded for cost calculation, automatic stock deduction, and inventory alerts (để tất cả giao dịch mua được ghi nhận để tính chi phí, trừ kho tự động và cảnh báo tồn kho).

**Acceptance Criteria:**
1. Purchase invoice creation with ingredient selection, quantities, and pricing (Tạo hóa đơn mua với chọn nguyên liệu, số lượng và giá cả)
2. Stock-in recording with purchase date, supplier, and total cost tracking (Ghi nhận nhập kho với ngày mua, nhà cung cấp và theo dõi tổng chi phí)
3. Integration with expense calculation for financial reporting (Tích hợp với tính toán chi phí cho báo cáo tài chính)
4. Automatic inventory level updates upon stock-in confirmation (Cập nhật mức tồn kho tự động khi xác nhận nhập kho)
5. Foundation for automatic stock deduction when orders are processed (Nền tảng cho trừ kho tự động khi xử lý đơn hàng)

#### Story 5.3: Inventory Tracking & Alert System (Theo dõi Tồn kho & Hệ thống Cảnh báo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to monitor current stock levels with automatic alerts for low inventory (tôi muốn giám sát mức tồn kho hiện tại với cảnh báo tự động khi sắp hết hàng),  
**so that** restaurant operations are not disrupted by stockouts and purchasing can be planned effectively (để hoạt động nhà hàng không bị gián đoạn do hết hàng và có thể lập kế hoạch mua hàng hiệu quả).

**Acceptance Criteria:**
1. Real-time stock level display with current quantities by ingredient (Hiển thị mức tồn kho thời gian thực theo từng nguyên liệu)
2. Configurable minimum stock level alerts and notifications (Cảnh báo và thông báo mức tồn kho tối thiểu có thể cấu hình)
3. Stock movement history tracking (purchases, usage, adjustments) (Theo dõi lịch sử di chuyển kho - mua, sử dụng, điều chỉnh)
4. Integration foundation for automatic deduction when menu items are ordered (Nền tảng tích hợp để trừ kho tự động khi đặt món)
5. Inventory reports for purchase planning and cost analysis (Báo cáo tồn kho để lập kế hoạch mua hàng và phân tích chi phí)

### Epic 6: Order Processing & Kitchen Coordination (Order)

**Expanded Goal:** Enable complete end-to-end order workflow from table selection through real-time kitchen coordination, implementing the complete waitstaff workflow: view table status → select customer table → browse menu → order items → confirm order → print to kitchen → serve customers → confirm completion (Kích hoạt quy trình đơn hàng đầu cuối hoàn chỉnh từ chọn bàn đến phối hợp bếp thời gian thực, triển khai quy trình nhân viên phục vụ hoàn chỉnh: xem trạng thái bàn → chọn bàn khách → duyệt menu → gọi món → xác nhận đơn → in cho bếp → phục vụ khách → xác nhận hoàn thành).

#### Story 6.1: Waitstaff Order Management Workflow (Quy trình Gọi món của Nhân viên Phục vụ)
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

#### Story 6.2: Kitchen Priority Management Dashboard (Bảng điều khiển Quản lý Ưu tiên Bếp)
**As a** kitchen staff (nhân viên bếp),  
**I want** to see all tables with pending orders prioritized by order time and dish preparation speed (tôi muốn xem tất cả các bàn có đơn hàng chưa phục vụ được ưu tiên theo thời gian gọi món và tốc độ chế biến),  
**so that** I can optimize cooking sequence to serve quick dishes first while maintaining order priority (để tôi có thể tối ưu thứ tự nấu ăn, phục vụ món nhanh trước trong khi vẫn duy trì ưu tiên đơn hàng).

**Acceptance Criteria:**
1. Table-based order display showing all pending orders sorted by order time (Hiển thị đơn hàng theo bàn cho tất cả đơn chưa phục vụ, sắp xếp theo thời gian gọi)
2. Quick-cook dish indicators (vegetables, tofu, light dishes) with visual priority markers (Đánh dấu món nấu nhanh - rau, đậu phụ, món nhẹ - với chỉ báo ưu tiên trực quan)
3. Cooking time estimates for each dish with color-coded urgency levels (Ước tính thời gian nấu cho từng món với mức độ khẩn cấp mã màu)
4. Smart preparation suggestions balancing FIFO order priority with quick-serve opportunities (Gợi ý chuẩn bị thông minh cân bằng ưu tiên đơn hàng đến trước với cơ hội phục vụ nhanh)
5. Real-time updates when dishes are completed and served to tables (Cập nhật thời gian thực khi món được hoàn thành và phục vụ cho bàn)

### Epic 7: Takeaway & Delivery Orders (Gọi đồ mang về)

**Simplified Goal:** Enable simple takeaway order processing workflow: customer arrives → staff takes order → prints kitchen bill → confirms completion → processes payment. Orders display on kitchen screen with takeaway marking to differentiate from dine-in orders (Kích hoạt quy trình xử lý đơn mang về đơn giản: khách tới quán → nhân viên gọi món → in bill bếp → xác nhận hoàn thành → xử lý thanh toán. Đơn hàng hiển thị trên màn hình bếp với đánh dấu mang về để phân biệt với đơn ăn tại quán).

#### Story 7.1: Takeaway Order Processing Workflow (Quy trình Xử lý Đơn hàng Mang về)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process takeaway orders with a simple workflow without table assignment (tôi muốn xử lý đơn hàng mang về với quy trình đơn giản không cần phân bàn),  
**so that** customers can quickly order food for takeaway (để khách hàng có thể nhanh chóng gọi món mang về).

**Acceptance Criteria:**
1. **Takeaway Order Creation**: Direct menu access without table selection for takeaway orders (Tạo đơn mang về: Truy cập menu trực tiếp không cần chọn bàn cho đơn mang về)
2. **Menu Browsing & Item Selection**: Same menu interface as dine-in with quantity and notes functionality (Duyệt menu và chọn món: Giao diện menu giống như ăn tại quán với chức năng số lượng và ghi chú)
3. **Kitchen Integration with Takeaway Marking**: Orders print to kitchen with clear "TAKEAWAY" marking and display on Story 6.2 kitchen screen (Tích hợp bếp với đánh dấu mang về: Đơn hàng in ra bếp với dấu hiệu "MANG VỀ" rõ ràng và hiển thị trên màn hình bếp Story 6.2)
4. **Order Status Tracking**: Real-time status updates (Confirmed, Preparing, Ready for Pickup) (Theo dõi trạng thái đơn: Cập nhật trạng thái thời gian thực - Đã xác nhận, Đang chuẩn bị, Sẵn sàng lấy)
5. **Payment Processing Integration**: Direct integration with Epic 8 payment processing (Tích hợp xử lý thanh toán: Tích hợp trực tiếp với xử lý thanh toán Epic 8)

### Epic 8: Payment Processing (Thanh toán)

**Integrated Goal:** Implement integrated payment processing within order management interface supporting Vietnamese payment methods (cash, QR bank transfer) with payment buttons directly accessible from order lists for seamless workflow (Triển khai xử lý thanh toán tích hợp trong giao diện quản lý đơn hàng hỗ trợ phương thức thanh toán Việt Nam - tiền mặt, chuyển khoản QR - với nút thanh toán truy cập trực tiếp từ danh sách đơn hàng để quy trình mượt mà).

#### Story 8.1: Integrated Payment Processing (Xử lý Thanh toán Tích hợp)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process customer payments with a simple one-step workflow that automatically prints invoices (tôi muốn xử lý thanh toán khách hàng với quy trình một bước đơn giản tự động in hóa đơn),  
**so that** I can quickly complete payment processing and reset table availability (để tôi có thể nhanh chóng hoàn thành xử lý thanh toán và đặt lại trạng thái bàn khả dụng).

**Acceptance Criteria:**
1. **Auto-Print Payment Invoice**: Click "Payment" button automatically prints detailed invoice with restaurant info, itemized order details, total amount, and restaurant QR code for customer payment (Tự động in hóa đơn thanh toán: Bấm nút "Thanh toán" tự động in hóa đơn chi tiết với thông tin quán, chi tiết đơn hàng từng món, tổng tiền và QR code thanh toán của quán)
2. **Payment Confirmation Button**: Single "Payment Completed" button appears after invoice printing for staff to confirm when customer has paid (cash or bank transfer) (Nút xác nhận thanh toán: Nút "Đã thanh toán" xuất hiện sau khi in hóa đơn để nhân viên xác nhận khi khách đã thanh toán - tiền mặt hoặc chuyển khoản)
3. **Automatic Table Reset**: After clicking "Payment Completed", system automatically resets table status to "Available" and clears order data for next customers (Tự động đặt lại bàn: Sau khi bấm "Đã thanh toán", hệ thống tự động đặt lại trạng thái bàn thành "Khả dụng" và xóa dữ liệu đơn hàng cho khách tiếp theo)
4. **Invoice Content Requirements**: Printed invoice must include restaurant name, contact info, itemized dishes with prices, total amount, timestamp, and restaurant payment QR code (Yêu cầu nội dung hóa đơn: Hóa đơn in phải bao gồm tên quán, thông tin liên hệ, chi tiết món ăn với giá, tổng tiền, thời gian và QR code thanh toán của quán)

#### Story 8.2: Financial Reconciliation & Reporting (Đối soát Tài chính & Báo cáo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to track all payment transactions with detailed reporting (tôi muốn theo dõi tất cả giao dịch thanh toán với báo cáo chi tiết),  
**so that** financial records are accurate and auditable (để hồ sơ tài chính chính xác và có thể kiểm toán).

**Acceptance Criteria:**
1. **Daily Payment Reconciliation**: Cash counting and payment method reconciliation with daily totals (Đối soát thanh toán hàng ngày: Kiểm đếm tiền mặt và đối soát phương thức thanh toán với tổng số hàng ngày)
2. **Payment Analytics**: Payment method breakdown analysis and daily/weekly/monthly trends (Phân tích thanh toán: Phân tích phương thức thanh toán và xu hướng hàng ngày/tuần/tháng)
3. **Financial Reporting**: Export capabilities for accounting software with Vietnamese tax compliance (Báo cáo tài chính: Khả năng xuất cho phần mềm kế toán với tuân thủ thuế Việt Nam)
4. **Transaction History**: Complete payment transaction history with search and filter capabilities (Lịch sử giao dịch: Lịch sử giao dịch thanh toán đầy đủ với khả năng tìm kiếm và lọc)
5. **Backend Integration**: Database integration to track all payments processed through the integrated interface (Tích hợp backend: Tích hợp cơ sở dữ liệu để theo dõi tất cả thanh toán được xử lý qua giao diện tích hợp)

### Epic 9: Deployment & Production Management (Deploy)

**VPS Deployment Goal:** Establish production deployment on VPS using Docker containers with GitHub Actions CI/CD, Nginx reverse proxy, PostgreSQL database, and Redis caching for reliable and cost-effective restaurant system operation (Thiết lập triển khai production trên VPS sử dụng Docker containers với GitHub Actions CI/CD, Nginx reverse proxy, PostgreSQL database và Redis caching để vận hành hệ thống nhà hàng đáng tin cậy và tiết kiệm chi phí).

#### Story 9.1: VPS Setup & Docker Deployment (Thiết lập VPS & Triển khai Docker)
**As a** system administrator (quản trị viên hệ thống),  
**I want** to setup production VPS environment with Docker containers and automated deployment from GitHub (tôi muốn thiết lập môi trường VPS production với Docker containers và triển khai tự động từ GitHub),  
**so that** the restaurant system runs reliably on cost-effective VPS infrastructure (để hệ thống nhà hàng chạy ổn định trên hạ tầng VPS tiết kiệm chi phí).

**Acceptance Criteria:**
1. **VPS Infrastructure Setup**: Ubuntu 22.04 LTS VPS with minimum 4GB RAM, 2 CPU cores, 40GB SSD storage (Thiết lập hạ tầng VPS: Ubuntu 22.04 LTS VPS với tối thiểu 4GB RAM, 2 CPU cores, 40GB SSD storage)
2. **Docker Environment**: Docker and Docker Compose installation with containers for .NET API, Angular frontend, PostgreSQL, Redis, and Nginx reverse proxy (Môi trường Docker: Cài đặt Docker và Docker Compose với containers cho .NET API, Angular frontend, PostgreSQL, Redis và Nginx reverse proxy)
3. **GitHub Actions CI/CD**: Automated deployment pipeline triggered by GitHub push to main branch with build, test, and deploy stages (GitHub Actions CI/CD: Pipeline triển khai tự động kích hoạt bởi GitHub push to main branch với các giai đoạn build, test và deploy)
4. **SSL Certificate**: Let's Encrypt SSL certificate setup with automatic renewal for HTTPS access (Chứng chỉ SSL: Thiết lập chứng chỉ SSL Let's Encrypt với gia hạn tự động cho truy cập HTTPS)
5. **Domain Configuration**: Domain name setup with DNS pointing to VPS IP address for production access (Cấu hình domain: Thiết lập tên miền với DNS trỏ về IP VPS để truy cập production)

#### Story 9.2: Production Configuration & Security (Cấu hình Production & Bảo mật)
**As a** system administrator (quản trị viên hệ thống),  
**I want** to configure production environment with proper security and performance settings (tôi muốn cấu hình môi trường production với cài đặt bảo mật và hiệu suất phù hợp),  
**so that** the restaurant system operates securely and efficiently in production (để hệ thống nhà hàng hoạt động an toàn và hiệu quả trong production).

**Acceptance Criteria:**
1. **Production Environment Variables**: Secure configuration management with environment-specific settings for database connections, API keys, and application secrets (Biến môi trường Production: Quản lý cấu hình bảo mật với cài đặt theo môi trường cho kết nối database, API keys và application secrets)
2. **Firewall & Security**: UFW firewall configuration allowing only ports 80, 443, and SSH with fail2ban for brute force protection (Firewall & Bảo mật: Cấu hình UFW firewall chỉ cho phép ports 80, 443 và SSH với fail2ban để bảo vệ brute force)
3. **Database Security**: PostgreSQL with restricted access, encrypted connections, and regular security updates (Bảo mật Database: PostgreSQL với truy cập hạn chế, kết nối mã hóa và cập nhật bảo mật thường xuyên)
4. **Performance Optimization**: Nginx optimization for static files, gzip compression, caching headers, and rate limiting (Tối ưu hiệu suất: Tối ưu Nginx cho static files, nén gzip, cache headers và rate limiting)
5. **Backup Strategy**: Automated daily database backups stored locally and optionally uploaded to cloud storage (Chiến lược Backup: Backup database tự động hàng ngày lưu trữ local và tùy chọn upload lên cloud storage)

#### Story 9.3: Monitoring & Maintenance (Giám sát & Bảo trì)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to monitor system health and receive alerts for any issues (tôi muốn giám sát sức khỏe hệ thống và nhận cảnh báo cho bất kỳ sự cố nào),  
**so that** restaurant operations continue smoothly without technical disruptions (để hoạt động nhà hàng tiếp tục diễn ra suôn sẻ mà không bị gián đoạn kỹ thuật).

**Acceptance Criteria:**
1. **System Health Monitoring**: Simple monitoring setup using Docker container health checks and basic system metrics (CPU, memory, disk, database status) (Giám sát sức khỏe hệ thống: Thiết lập giám sát đơn giản sử dụng Docker container health checks và metrics hệ thống cơ bản)
2. **Automated Alerts**: Email notifications for system failures, high resource usage, or database connection issues (Cảnh báo tự động: Thông báo email cho lỗi hệ thống, sử dụng tài nguyên cao hoặc sự cố kết nối database)
3. **Log Management**: Centralized logging for all containers with log rotation and retention policies (Quản lý Log: Logging tập trung cho tất cả containers với chính sách rotate và retention log)
4. **Maintenance Procedures**: Documentation and scripts for common maintenance tasks like database cleanup, log rotation, and system updates (Quy trình bảo trì: Tài liệu và scripts cho các tác vụ bảo trì thường gặp như dọn dẹp database, rotate log và cập nhật hệ thống)
5. **Disaster Recovery**: Simple backup restoration procedures and emergency contact information for technical support (Khôi phục thảm họa: Quy trình phục hồi backup đơn giản và thông tin liên hệ khẩn cấp cho hỗ trợ kỹ thuật)

### Epic 10: Reporting & Analytics (Báo cáo)

**Expanded Goal:** Provide comprehensive reporting dashboard with revenue analytics, operational metrics, business intelligence, and data visualization to enable data-driven business decisions for restaurant optimization (Cung cấp bảng điều khiển báo cáo toàn diện với phân tích doanh thu, chỉ số vận hành, thông tin kinh doanh và trực quan hóa dữ liệu để cho phép các quyết định kinh doanh dựa trên dữ liệu để tối ưu hóa nhà hàng).

#### Story 10.1: Revenue Analytics & Financial Reporting (Phân tích Doanh thu & Báo cáo Tài chính)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to analyze revenue trends and financial performance (tôi muốn phân tích xu hướng doanh thu và hiệu suất tài chính),  
**so that** I can make informed business decisions (để tôi có thể đưa ra quyết định kinh doanh có thông tin).

**Acceptance Criteria:**
1. Interactive revenue dashboards with time period filtering (Bảng điều khiển doanh thu tương tác với lọc theo thời gian)
2. Category and dish performance analysis (Phân tích hiệu suất danh mục và món ăn)
3. Payment method distribution and trends (Phân phối và xu hướng phương thức thanh toán)
4. Profit margin analysis by menu items (Phân tích tỷ suất lợi nhuận theo món trong menu)
5. Financial forecasting and goal tracking (Dự báo tài chính và theo dõi mục tiêu)

#### Story 10.2: Operational Performance Analytics (Phân tích Hiệu suất Vận hành)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to monitor operational efficiency and identify improvement areas (tôi muốn giám sát hiệu quả vận hành và xác định các khu vực cần cải thiện),  
**so that** restaurant operations can be optimized (để hoạt động nhà hàng có thể được tối ưu hóa).

**Acceptance Criteria:**
1. Order processing time analytics and bottleneck identification (Phân tích thời gian xử lý đơn hàng và xác định nút thắt cổ chai)
2. Kitchen performance metrics and station efficiency (Chỉ số hiệu suất bếp và hiệu quả trạm)
3. Table turnover analysis and optimization suggestions (Phân tích vòng quay bàn và gợi ý tối ưu)
4. Staff productivity tracking and performance reports (Theo dõi năng suất nhân viên và báo cáo hiệu suất)
5. Customer satisfaction indicators and feedback analysis (Chỉ báo hài lòng khách hàng và phân tích phản hồi)

### Epic 11: Table Reservation System (Đặt bàn)

**Simple Goal:** Enable phone-based table reservations with pre-ordering capability that reuses existing order management workflow from Story 6.1 for efficient and familiar operation (Kích hoạt đặt bàn qua điện thoại với khả năng đặt món trước sử dụng lại quy trình quản lý đơn hàng hiện tại từ Story 6.1 để vận hành hiệu quả và quen thuộc).

#### Story 11.1: Phone Reservation Processing (Xử lý Đặt bàn qua Điện thoại)
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

### Epic 12: Customer Management (Khách hàng)

**Expanded Goal:** Create comprehensive customer relationship management system with customer profiles, loyalty programs, order history, feedback collection, and personalized service features to enhance customer experience and retention (Tạo hệ thống quản lý quan hệ khách hàng toàn diện với hồ sơ khách hàng, chương trình khách hàng thân thiết, lịch sử đơn hàng, thu thập phản hồi và tính năng dịch vụ cá nhân hóa để nâng cao trải nghiệm và giữ chân khách hàng).

#### Story 12.1: Customer Profile & History Management (Quản lý Hồ sơ & Lịch sử Khách hàng)
**As a** customer service staff (nhân viên chăm sóc khách hàng),  
**I want** to maintain detailed customer profiles and order history (tôi muốn duy trì hồ sơ khách hàng chi tiết và lịch sử đơn hàng),  
**so that** personalized service can be provided (để có thể cung cấp dịch vụ cá nhân hóa).

**Acceptance Criteria:**
1. Customer profile creation with contact information and preferences (Tạo hồ sơ khách hàng với thông tin liên lạc và sở thích)
2. Order history tracking with dish preferences and frequency (Theo dõi lịch sử đơn hàng với sở thích món ăn và tần suất)
3. Special dietary requirements and allergy information (Yêu cầu chế độ ăn đặc biệt và thông tin dị ứng)
4. Customer visit tracking and behavior analysis (Theo dõi lượt ghé thăm và phân tích hành vi khách hàng)
5. Personalized recommendations based on history (Gợi ý cá nhân hóa dựa trên lịch sử)

#### Story 12.2: Loyalty Program & Feedback System (Chương trình Khách hàng Thân thiết & Hệ thống Phản hồi)
**As a** marketing manager (quản lý marketing),  
**I want** to implement loyalty programs and collect customer feedback (tôi muốn triển khai chương trình khách hàng thân thiết và thu thập phản hồi khách hàng),  
**so that** customer retention and satisfaction can be improved (để giữ chân khách hàng và sự hài lòng có thể được cải thiện).

**Acceptance Criteria:**
1. Points-based loyalty program with rewards tracking (Chương trình khách hàng thân thiết dựa trên điểm với theo dõi phần thưởng)
2. Special offers and promotions for loyal customers (Ưu đãi đặc biệt và khuyến mãi cho khách hàng thân thiết)
3. Customer feedback collection system with ratings (Hệ thống thu thập phản hồi khách hàng với đánh giá)
4. Birthday and anniversary special recognition (Nhận biết đặc biệt sinh nhật và kỷ niệm)
5. Customer satisfaction survey automation (Tự động hóa khảo sát sự hài lòng khách hàng)

### Epic 13: Payroll & HR Management (Tính lương)

**Expanded Goal:** Implement comprehensive staff payroll calculation system with work hour tracking, salary management, attendance monitoring, and integration with user role system for efficient human resource management in restaurant operations (Triển khai hệ thống tính lương nhân viên toàn diện với theo dõi giờ làm việc, quản lý lương, giám sát chuyên cần và tích hợp với hệ thống vai trò người dùng để quản lý nguồn nhân lực hiệu quả trong hoạt động nhà hàng).

#### Story 13.1: Employee Leave Management (Quản lý Nghỉ phép Nhân viên)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to record and manage employee leave days (tôi muốn ghi nhận và quản lý ngày nghỉ của nhân viên),  
**so that** work scheduling and payroll deductions can be properly managed (để lên lịch làm việc và khấu trừ lương có thể được quản lý đúng cách).

**Acceptance Criteria:**
1. **Leave Entry Interface**: Simple form to input employee leave dates with reason (sick leave, personal leave, vacation) (Giao diện nhập nghỉ phép: Form đơn giản nhập ngày nghỉ nhân viên với lý do - nghỉ ốm, nghỉ phép cá nhân, nghỉ phép)
2. **Employee Selection**: Dropdown or search to select employee from staff list (Chọn nhân viên: Dropdown hoặc tìm kiếm để chọn nhân viên từ danh sách nhân viên)
3. **Leave Calendar View**: Calendar display showing all employee leave days for scheduling reference (Xem lịch nghỉ phép: Hiển thị lịch tất cả ngày nghỉ nhân viên để tham khảo lập lịch)
4. **Leave History**: List view of all recorded leave days by employee with dates and reasons (Lịch sử nghỉ phép: Danh sách tất cả ngày nghỉ đã ghi nhận theo nhân viên với ngày và lý do)
5. **Monthly Summary**: Simple report showing total leave days per employee per month for payroll calculation (Tóm tắt hàng tháng: Báo cáo đơn giản hiển thị tổng ngày nghỉ mỗi nhân viên mỗi tháng để tính lương)

#### Story 13.2: Payroll Calculation & Management (Tính toán & Quản lý Lương)
**As a** payroll administrator (quản trị viên lương),  
**I want** to calculate employee salaries automatically based on work days and rates (tôi muốn tính lương nhân viên tự động dựa trên ngày làm việc và mức lương),  
**so that** payroll processing is efficient and error-free (để xử lý lương hiệu quả và không có lỗi).

**Acceptance Criteria:**
1. Automated salary calculation based on days worked (Tính lương tự động dựa trên số ngày làm việc)
2. Different pay rates for different roles and shifts (Mức lương khác nhau cho các vai trò và ca làm việc khác nhau)
3. Bonus and incentive management system (Hệ thống quản lý tiền thưởng và ưu đãi)
4. Payroll report generation with Vietnamese formatting (Tạo báo cáo lương với định dạng tiếng Việt)

---

## Checklist Results Report (Báo cáo Kết quả Checklist)

### PM Checklist Validation Summary (Tóm tắt Validation Checklist PM)

**Overall PRD Completeness:** 92% complete (92% hoàn thành)  
**MVP Scope Appropriateness:** Just Right - suitable for 30-week development timeline (Vừa đúng - phù hợp cho lịch trình phát triển 30 tuần)  
**Readiness for Architecture Phase:** Ready - prepared for architect with minor clarifications needed (Sẵn sàng - đã chuẩn bị cho kiến trúc sư với một số làm rõ nhỏ cần thiết)  

### Category Analysis (Phân tích Danh mục)

| Category (Danh mục) | Status | Critical Issues (Vấn đề Nghiêm trọng) |
|---------------------|--------|----------------------------------------|
| Problem Definition & Context | PASS | None - excellent problem articulation with Vietnamese restaurant focus (Không có - phân tích vấn đề xuất sắc với trọng tâm nhà hàng Việt Nam) |
| MVP Scope Definition | PASS | Strong epic sequencing, clear boundaries (Thứ tự epic mạnh mẽ, rành giới rõ ràng) |
| User Experience Requirements | PASS | Comprehensive UI goals with touch-first design (Mục tiêu UI toàn diện với thiết kế ưu tiên cảm ứng) |
| Functional Requirements | PASS | Well-structured FR/NFR with Vietnamese-only interface (FR/NFR có cấu trúc tốt với giao diện chỉ tiếng Việt) |
| Non-Functional Requirements | PASS | Clear performance targets, security considerations (Mục tiêu hiệu suất rõ ràng, cân nhắc bảo mật) |
| Epic & Story Structure | PASS | Logical sequencing, appropriate story sizing (Thứ tự logic, kích thước story phù hợp) |
| Technical Guidance | PARTIAL | ABP Framework specifics need architect deep-dive (Chi tiết ABP Framework cần kiến trúc sư tìm hiểu sâu) |
| Cross-Functional Requirements | PASS | Database design, integration points identified (Thiết kế cơ sở dữ liệu, điểm tích hợp đã xác định) |
| Clarity & Communication | PASS | Excellent bilingual documentation following CLAUDE.md (Tài liệu song ngữ xuất sắc theo CLAUDE.md) |

**Final Decision: READY FOR ARCHITECT** ✅

---

## Next Steps (Bước tiếp theo)

### UX Expert Prompt (Prompt cho Chuyên gia UX)
`*create-architecture` - Use this comprehensive PRD to design user experience architecture for Smart Restaurant Management System. Focus on touch-first mobile interface, Vietnamese restaurant workflows, and two-level menu management UX patterns (Sử dụng PRD toàn diện này để thiết kế kiến trúc trải nghiệm người dùng cho Hệ thống Quản lý Nhà hàng Thông minh. Tập trung vào giao diện di động ưu tiên cảm ứng, quy trình làm việc nhà hàng Việt Nam và các mẫu UX quản lý thực đơn hai cấp).

### Architect Prompt (Prompt cho Kiến trúc sư)
`*create-architecture` - Design technical architecture for Smart Restaurant Management System using this PRD. Prioritize ABP Framework modular monolith, PostgreSQL with Vietnamese text search, SignalR real-time coordination, and offline-capable Progressive Web App architecture (Thiết kế kiến trúc kỹ thuật cho Hệ thống Quản lý Nhà hàng Thông minh sử dụng PRD này. Ưu tiên ABP Framework modular monolith, PostgreSQL với tìm kiếm văn bản tiếng Việt, phối hợp thời gian thực SignalR và kiến trúc ứng dụng web tiến bộ có khả năng hoạt động ngoại tuyến).

---

*Generated by PM Agent - John 📋 (Được tạo bởi PM Agent - John 📋)*  
*Project: Smart Restaurant Management System (Dự án: Hệ thống Quản lý Nhà hàng Thông minh)*  
*Date: 2025-08-16 (Ngày: 2025-08-16)*