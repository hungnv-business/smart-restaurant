# Technical Assumptions (Giả định Kỹ thuật)

## Repository Structure: Monorepo
Single repository containing all components: ABP Framework backend, Angular frontend, Flutter mobile app, and shared documentation. This optimizes solo development workflow and simplifies dependency management (Kho mã nguồn đơn chứa tất cả thành phần: ABP Framework backend, Angular frontend, ứng dụng di động Flutter và tài liệu chung. Cách này tối ưu hóa quy trình phát triển một mình và đơn giản hóa việc quản lý phụ thuộc).

## Service Architecture (Kiến trúc Dịch vụ)
**CRITICAL DECISION:** ABP Framework Modular Monolith with Code First Entity Framework Core and Domain-Driven Design patterns. This architecture provides structured scalability while maintaining simplicity for solo development with automatic service proxy generation. Core modules include (Kiến trúc modular monolith ABP Framework với EF Core Code First và các mẫu Domain-Driven Design. Kiến trúc này cung cấp khả năng mở rộng có cấu trúc với tạo service proxy tự động):

### ABP Framework Layers (Các Lớp ABP Framework)
- **Domain Layer (Lớp Miền):** Core entities inheriting from ABP base classes (AggregateRoot, Entity, ValueObject) with business logic (Thực thể cốt lõi kế thừa từ lớp cơ sở ABP với logic kinh doanh)
- **Application Layer (Lớp Ứng dụng):** Application services with DTOs and auto-generated Angular proxies (Dịch vụ ứng dụng với DTO và proxy Angular tự động tạo)
- **EntityFrameworkCore Layer (Lớp EntityFrameworkCore):** Code First DbContext with PostgreSQL provider and migrations (DbContext Code First với provider PostgreSQL và migration)
- **HttpApi.Host Layer (Lớp HttpApi.Host):** RESTful controllers, SignalR hubs, and authentication (Controller RESTful, hub SignalR và xác thực)

### Core Business Modules (Module Kinh doanh Cốt lõi)
- **User Management Module:** ABP Identity integration with restaurant-specific roles (Tích hợp ABP Identity với vai trò chuyên biệt nhà hàng)
- **Menu Management Module:** MenuCategory and MenuItem aggregates with flexible enable/disable patterns (Aggregate MenuCategory và MenuItem với mẫu bật/tắt linh hoạt)
- **Order Processing Module:** Order aggregate with real-time SignalR coordination and kitchen routing (Aggregate Order với phối hợp SignalR thời gian thực và định tuyến bếp)
- **Payment Module:** Vietnamese payment domain services with local payment method support (Domain service thanh toán Việt Nam với hỗ trợ phương thức thanh toán địa phương)
- **Inventory Module:** InventoryItem and Recipe aggregates with automatic stock deduction (Aggregate InventoryItem và Recipe với trừ kho tự động)
- **Reporting Module:** Analytics services with data visualization and export capabilities (Dịch vụ phân tích với trực quan hóa dữ liệu và khả năng xuất)

## Testing Requirements (Yêu cầu Kiểm thử)
**CRITICAL DECISION:** Full Testing Pyramid with 70% code coverage target (Kim tự tháp kiểm thử đầy đủ với mục tiêu bao phủ 70% mã nguồn):
- **Unit Tests (Kiểm thử Đơn vị):** Core business logic and domain services (Logic nghiệp vụ cốt lõi và dịch vụ miền)
- **Integration Tests (Kiểm thử Tích hợp):** Database operations, external service integrations (Thao tác cơ sở dữ liệu, tích hợp dịch vụ bên ngoài)
- **API Tests (Kiểm thử API):** REST endpoints and SignalR hubs (Điểm cuối REST và hub SignalR)
- **UI Tests (Kiểm thử Giao diện):** Critical user workflows automation (Tự động hóa các quy trình người dùng quan trọng)
- **Manual Testing (Kiểm thử Thủ công):** Restaurant environment testing with real staff (Kiểm thử môi trường nhà hàng với nhân viên thực tế)

## Additional Technical Assumptions and Requests (Giả định và Yêu cầu Kỹ thuật Bổ sung)

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
