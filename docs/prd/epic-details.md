# Epic Details (Chi tiết Epic)

## Epic 1: Source Code Foundation & Infrastructure (Tạo Source Code & Hạ tầng Cốt lõi)

**Expanded Goal:** Establish complete project foundation including ABP Framework setup, development environment configuration, basic authentication, core infrastructure, and initial deployment pipeline to enable all subsequent development work (Thiết lập nền tảng dự án hoàn chỉnh bao gồm thiết lập ABP Framework, cấu hình môi trường phát triển, xác thực cơ bản, hạ tầng cốt lõi và pipeline triển khai ban đầu để cho phép tất cả công việc phát triển tiếp theo).

### Story 1.1: Project Structure & Development Environment Setup (Thiết lập Cấu trúc Dự án & Môi trường Phát triển)
**As a** developer (lập trình viên),  
**I want** to establish ABP Framework project structure with proper configuration (tôi muốn thiết lập cấu trúc dự án ABP Framework với cấu hình phù hợp),  
**so that** development can proceed efficiently with all necessary tools (để quá trình phát triển có thể tiếp diễn hiệu quả với đầy đủ các công cụ cần thiết).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. ABP Framework solution created with .NET 8 and Angular 19 templates (Tạo giải pháp ABP Framework với mẫu .NET 8 và Angular 19)
2. PostgreSQL database connection configured with Vietnamese collation (Cấu hình kết nối cơ sở dữ liệu PostgreSQL với sắp xếp tiếng Việt)
3. Docker containerization setup completed with docker-compose (Hoàn thành thiết lập đóng gói Docker với docker-compose)
4. Development environment documented in CLAUDE.md (Tài liệu hóa môi trường phát triển trong CLAUDE.md)
5. Initial CI/CD pipeline configured with basic build and test stages (Cấu hình pipeline CI/CD ban đầu với các giai đoạn build và test cơ bản)

### Story 1.2: Angular Poseidon Theme Integration (Tích hợp Theme Poseidon vào Angular)
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

### Story 1.3: Flutter Mobile App Foundation Setup (Thiết lập Nền tảng Ứng dụng Di động Flutter)
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

### Story 1.4: Authentication & User Management System (Hệ thống Xác thực & Quản lý Người dùng)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to manage user accounts with role-based permissions (tôi muốn quản lý tài khoản người dùng theo phân quyền vai trò),  
**so that** staff can access appropriate system functions (để nhân viên có thể truy cập đúng các chức năng hệ thống phù hợp).

**Acceptance Criteria:**
1. Role-based authentication implemented for Owner, Manager, Cashier, Kitchen Staff, Waitstaff (Hệ thống phân quyền theo vai trò cho Chủ nhà hàng, Quản lý, Thu ngân, Nhân viên bếp và Nhân viên phục vụ)
2. User registration and management interface completed (Hoàn thành giao diện tạo tài khoản và quản lý nhân viên)
3. JWT token authentication with secure session management (Đăng nhập bằng JWT token với bảo mật phiên làm việc)
4. Password reset functionality implemented (Tính năng đặt lại mật khẩu khi quên)
5. Audit logging for user activities (Ghi lại lịch sử hoạt động của người dùng)

### Story 1.5: Code First Database Schema & Core Entities (Schema Cơ sở dữ liệu Code First & Entities Cốt lõi)
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

### Story 1.6: Health Check & Monitoring Foundation (Nền tảng Health Check & Giám sát)
**As a** system operator (người vận hành hệ thống),  
**I want** to monitor system health và performance (tôi muốn giám sát sức khỏe hệ thống và hiệu suất),  
**so that** issues can be detected và resolved quickly (để các vấn đề có thể được phát hiện và giải quyết nhanh chóng).

**Acceptance Criteria:**
1. Health check endpoints implemented for database, in-memory cache, external services (Kiểm tra tình trạng hoạt động của database, in-memory cache và các dịch vụ liên quan)
2. Basic logging framework configured with Serilog (Thiết lập hệ thống ghi log chi tiết bằng Serilog)
3. Application performance monitoring setup (Giám sát hiệu suất ứng dụng thời gian thực)
4. Error tracking and notification system implemented (Hệ thống phát hiện lỗi và cảnh báo tự động)
5. System status dashboard accessible (Màn hình theo dõi tình trạng hệ thống)



## Epic 2: Table Layout Management (Quản lý Bố cục Bàn)

**Expanded Goal:** Design and implement hierarchical table layout management system with layout sections (rows/areas) and table positioning within sections, supporting drag-and-drop table arrangement, status tracking, and integration with reservation and order systems for efficient restaurant floor management (Thiết kế và triển khai hệ thống quản lý bố cục bàn phân cấp với các khu vực bố cục (dãy/khu) và định vị bàn trong khu vực, hỗ trợ sắp xếp bàn kéo-thả, theo dõi trạng thái và tích hợp với hệ thống đặt bàn và đặt món để quản lý sàn nhà hàng hiệu quả).

### Story 2.1: Layout Section Management (Quản lý Khu vực Bố cục)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to create and manage layout sections like "Dãy 1", "Dãy 2", "Khu VIP" (tôi muốn tạo và quản lý các khu vực bố cục như "Dãy 1", "Dãy 2", "Khu VIP"),  
**so that** I can organize tables into logical sections within the restaurant (để tôi có thể tổ chức bàn thành các khu vực hợp lý trong nhà hàng).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. CRUD operations for layout sections with Vietnamese names (Thao tác CRUD cho khu vực bố cục với tên tiếng Việt)
2. Section ordering and display management (Quản lý thứ tự và hiển thị khu vực)
3. Section status control (active/inactive) (Điều khiển trạng thái khu vực - hoạt động/không hoạt động)

### Story 2.2: Table Positioning within Layout Sections (Quản lý Vị trí Bàn trong Khu vực)
**As a** restaurant staff (nhân viên nhà hàng),  
**I want** to position tables within layout sections using drag-and-drop functionality (tôi muốn định vị bàn trong các khu vực bố cục bằng chức năng kéo-thả),  
**so that** I can arrange tables efficiently and update their positions as needed (để tôi có thể sắp xếp bàn hiệu quả và cập nhật vị trí khi cần thiết).

**Acceptance Criteria (Tiêu chí Chấp nhận):**
1. Table belongs to one layout section (Bàn thuộc về một khu vực bố cục)
2. Drag-and-drop positioning using @angular/cdk/drag-drop (Định vị kéo-thả sử dụng @angular/cdk/drag-drop)
3. Position persistence and visual feedback during drag operations (Lưu trữ vị trí và phản hồi trực quan trong quá trình kéo)
4. Table status management within sections (Quản lý trạng thái bàn trong khu vực)

## Epic 3: Menu Management System (Quản lý Menu)

**Expanded Goal:** Implement comprehensive two-level menu management with category and individual dish control, seasonal enable/disable functionality, pricing management, Vietnamese-only interface, and integration with inventory tracking for complete menu operations (Triển khai quản lý menu hai cấp toàn diện với điều khiển danh mục và món ăn riêng lẻ, chức năng bật/tắt theo mùa, quản lý định giá, giao diện chỉ tiếng Việt và tích hợp với theo dõi kho để vận hành menu hoàn chỉnh).

### Story 3.1: Menu Category Aggregate Management (Quản lý Aggregate Danh mục Menu)
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

### Story 3.2: Individual Dish Management with Single Category (Quản lý Món ăn Riêng lẻ với Một Danh mục)
**As a** kitchen manager (quản lý bếp),  
**I want** to manage individual dishes with basic information and assign each dish to one category (tôi muốn quản lý từng món ăn với thông tin cơ bản và gán mỗi món vào một danh mục),  
**so that** dishes are properly organized in menu sections and accurate information is available to staff and customers (để món ăn được tổ chức hợp lý trong các mục menu và thông tin chính xác có sẵn cho nhân viên và khách hàng).

**Acceptance Criteria:**
1. **Basic Dish Information**: CRUD operations with essential fields: name (Vietnamese), description, price (VND), status (active/inactive) (Thông tin món ăn cơ bản: Thao tác CRUD với các trường thiết yếu - tên tiếng Việt, mô tả, giá VND, trạng thái hoạt động/không hoạt động)
2. **Single Category Assignment**: One-to-many relationship between categories and dishes - each dish belongs to exactly one category (e.g., "Phở Bò" belongs to "Món Phở" category only) (Gán một danh mục: Mối quan hệ một-nhiều giữa danh mục và món ăn - mỗi món thuộc chính xác một danh mục, ví dụ "Phở Bò" chỉ thuộc danh mục "Món Phở")
3. **Category-Independent Status**: Individual dish enable/disable independent of category status - dish can be disabled while remaining in its assigned category (Trạng thái độc lập danh mục: Bật/tắt món ăn riêng lẻ độc lập với trạng thái danh mục - món có thể bị tắt nhưng vẫn thuộc về danh mục được gán)
4. **Single Photo Management**: One primary photo per dish with upload and replacement functionality (Quản lý một ảnh: Một ảnh chính cho mỗi món với chức năng tải lên và thay thế)
5. **Entity Framework Configuration**: Configure one-to-many relationship using foreign key (CategoryId) with proper navigation properties and cascading rules (Cấu hình Entity Framework: Cấu hình mối quan hệ một-nhiều sử dụng khóa ngoại CategoryId với navigation properties và quy tắc cascade phù hợp)


## Epic 4: Inventory Management (Quản lý Kho)

**Expanded Goal:** Create comprehensive inventory management system focused on ingredient category management for purchase invoices and stock-in tracking with automatic deduction, cost calculation, and low stock alerts for efficient restaurant inventory control (Tạo hệ thống quản lý kho toàn diện tập trung vào quản lý danh mục nguyên liệu cho hóa đơn mua và theo dõi nhập kho với trừ kho tự động, tính toán chi phí và cảnh báo hết hàng để kiểm soát kho nhà hàng hiệu quả).

### Story 4.1: Ingredient Category Management (Quản lý Danh mục Nguyên liệu)
**As a** inventory manager (quản lý kho),  
**I want** to manage ingredient categories and items for purchase invoice creation (tôi muốn quản lý danh mục và mặt hàng nguyên liệu để tạo hóa đơn mua),  
**so that** purchase invoices can be created systematically and ingredients can be tracked properly (để hóa đơn mua có thể được tạo một cách có hệ thống và nguyên liệu có thể được theo dõi đúng cách).

**Acceptance Criteria:**
1. Ingredient category CRUD with Vietnamese names (tomatoes, onions, meat, etc.) (Tạo, sửa, xóa danh mục nguyên liệu với tên tiếng Việt)
2. Ingredient item management with detailed specifications (Quản lý từng mặt hàng nguyên liệu với thông số chi tiết)
3. Unit of measurement definition (kg, gram, liter, pieces, etc.) (Định nghĩa đơn vị đo lường - kg, gram, lít, cái, v.v.)
4. Cost tracking per unit for purchase invoice creation (Theo dõi giá thành theo đơn vị để tạo hóa đơn mua)
5. Supplier information linking for each ingredient (Liên kết thông tin nhà cung cấp cho từng nguyên liệu)

### Story 4.2: Purchase Invoice & Stock-In Management (Quản lý Hóa đơn Mua & Nhập kho) ✅ **COMPLETED**
**As a** purchase manager (quản lý mua hàng),  
**I want** to create and manage purchase invoices with detailed stock-in tracking (tôi muốn tạo và quản lý hóa đơn mua với theo dõi nhập kho chi tiết),  
**so that** all purchases are recorded for cost calculation, automatic stock deduction, and inventory alerts (để tất cả giao dịch mua được ghi nhận để tính chi phí, trừ kho tự động và cảnh báo tồn kho).

**Acceptance Criteria:** ✅ **ALL COMPLETED**
1. ✅ Purchase invoice creation with ingredient selection, quantities, and pricing (Tạo hóa đơn mua với chọn nguyên liệu, số lượng và giá cả)
2. ✅ Stock-in recording with purchase date, supplier, and total cost tracking (Ghi nhận nhập kho với ngày mua, nhà cung cấp và theo dõi tổng chi phí)
3. ✅ Integration with expense calculation for financial reporting (Tích hợp với tính toán chi phí cho báo cáo tài chính)
4. ✅ Automatic inventory level updates upon stock-in confirmation (Cập nhật mức tồn kho tự động khi xác nhận nhập kho)
5. ✅ Foundation for automatic stock deduction when orders are processed (Nền tảng cho trừ kho tự động khi xử lý đơn hàng)

**Implementation Status:** Production Ready (Sẵn sàng Production)
- **QA Score:** 4.6/5.0 (HIGH confidence level)
- **Test Coverage:** 100% backend (47/47 tests pass), 96.9% frontend (62/64 tests pass)
- **Quality Gate:** PASSED - Production Ready with Recommendations
- **Review Date:** 2025-09-01

### Story 4.3: Multi-Unit System for Ingredients (Hệ thống Đa đơn vị cho Nguyên liệu)
**As a** inventory manager (quản lý kho),  
**I want** to manage ingredients with multiple purchase units while maintaining consistent base unit tracking (tôi muốn quản lý nguyên liệu với nhiều đơn vị mua khác nhau trong khi duy trì theo dõi đơn vị cơ sở nhất quán),  
**so that** I can purchase ingredients in different units (boxes, cases, bulk) but track inventory in standardized base units for accurate stock management (để tôi có thể mua nguyên liệu theo các đơn vị khác nhau - thùng, lốc, bao - nhưng theo dõi kho bằng đơn vị cơ sở chuẩn hóa để quản lý tồn kho chính xác).

**Acceptance Criteria:**
1. **Base Unit Configuration**: Each ingredient has one fixed base unit for inventory tracking (e.g., bia → base unit: lon/can) (Cấu hình đơn vị cơ sở: Mỗi nguyên liệu có một đơn vị cơ sở cố định để theo dõi kho - ví dụ: bia → đơn vị cơ sở: lon)
2. **Multiple Purchase Units**: Support multiple purchase units with conversion rates to base unit (e.g., bia: 1 keng = 24 lon, 1 bom = 6 keng = 144 lon) (Nhiều đơn vị mua: Hỗ trợ nhiều đơn vị mua với tỷ lệ chuyển đổi về đơn vị cơ sở - ví dụ: bia: 1 keng = 24 lon, 1 bom = 6 keng = 144 lon)
3. **Purchase Invoice Multi-Unit Support**: Purchase invoices can use any configured purchase unit with automatic base unit conversion for stock tracking (Hỗ trợ đa đơn vị trong hóa đơn mua: Hóa đơn mua có thể sử dụng bất kỳ đơn vị mua đã cấu hình nào với chuyển đổi tự động về đơn vị cơ sở để theo dõi kho)
4. **Stock Display Flexibility**: Display current stock in base units but allow viewing in any configured purchase unit for practical reference (Hiển thị kho linh hoạt: Hiển thị tồn kho hiện tại bằng đơn vị cơ sở nhưng cho phép xem theo bất kỳ đơn vị mua đã cấu hình nào để tham khảo thực tế)
5. **Unit Conversion Validation**: Business rules to ensure conversion rates are logically consistent and prevent circular references (Xác thực chuyển đổi đơn vị: Quy tắc kinh doanh đảm bảo tỷ lệ chuyển đổi nhất quán về logic và ngăn tham chiếu vòng tròn)

**Examples (Ví dụ):**
- **Bia (Beer)**: Base unit = lon → Purchase units: 1 keng = 24 lon, 1 bom = 144 lon
- **Coca**: Base unit = lon → Purchase units: 1 lốc = 6 lon, 1 thùng = 24 lon
- **Thịt bò (Beef)**: Base unit = kg → Purchase units: 1 bao = 10 kg, 1 thùng đông lạnh = 50 kg

### Story 4.4: Inventory Tracking & Alert System (Theo dõi Tồn kho & Hệ thống Cảnh báo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to monitor current stock levels with automatic alerts for low inventory (tôi muốn giám sát mức tồn kho hiện tại với cảnh báo tự động khi sắp hết hàng),  
**so that** restaurant operations are not disrupted by stockouts and purchasing can be planned effectively (để hoạt động nhà hàng không bị gián đoạn do hết hàng và có thể lập kế hoạch mua hàng hiệu quả).

**Acceptance Criteria:**
1. Real-time stock level display with current quantities by ingredient (Hiển thị mức tồn kho thời gian thực theo từng nguyên liệu)
2. Configurable minimum stock level alerts and notifications (Cảnh báo và thông báo mức tồn kho tối thiểu có thể cấu hình)
3. Stock movement history tracking (purchases, usage, adjustments) (Theo dõi lịch sử di chuyển kho - mua, sử dụng, điều chỉnh)
4. **Recipe Management System**: Menu item ingredient configuration for automatic stock deduction (Hệ thống quản lý công thức: cấu hình nguyên liệu món ăn cho trừ kho tự động)
   - MenuItemIngredient entity linking MenuItem to Ingredient with required quantities
   - Recipe setup interface for configuring ingredient requirements per menu item
   - Automatic stock deduction when orders are processed based on recipe configuration
5. Inventory reports for purchase planning and cost analysis (Báo cáo tồn kho để lập kế hoạch mua hàng và phân tích chi phí)

## Epic 5: Order Processing & Kitchen Coordination (Order)

**Expanded Goal:** Enable complete end-to-end order workflow from table selection through real-time kitchen coordination, implementing the complete waitstaff workflow: view table status → select customer table → browse menu → order items → confirm order → print to kitchen → serve customers → confirm completion (Kích hoạt quy trình đơn hàng đầu cuối hoàn chỉnh từ chọn bàn đến phối hợp bếp thời gian thực, triển khai quy trình nhân viên phục vụ hoàn chỉnh: xem trạng thái bàn → chọn bàn khách → duyệt menu → gọi món → xác nhận đơn → in cho bếp → phục vụ khách → xác nhận hoàn thành).

### Story 5.1: Waitstaff Order Management Workflow (Quy trình Gọi món của Nhân viên Phục vụ)
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

### Story 5.2: Kitchen Priority Management Dashboard (Bảng điều khiển Quản lý Ưu tiên Bếp)
**As a** kitchen staff (nhân viên bếp),  
**I want** to see all tables with pending orders prioritized by order time and dish preparation speed (tôi muốn xem tất cả các bàn có đơn hàng chưa phục vụ được ưu tiên theo thời gian gọi món và tốc độ chế biến),  
**so that** I can optimize cooking sequence to serve quick dishes first while maintaining order priority (để tôi có thể tối ưu thứ tự nấu ăn, phục vụ món nhanh trước trong khi vẫn duy trì ưu tiên đơn hàng).

**Acceptance Criteria:**
1. Table-based order display showing all pending orders sorted by order time (Hiển thị đơn hàng theo bàn cho tất cả đơn chưa phục vụ, sắp xếp theo thời gian gọi)
2. Quick-cook dish indicators (vegetables, tofu, light dishes) with visual priority markers (Đánh dấu món nấu nhanh - rau, đậu phụ, món nhẹ - với chỉ báo ưu tiên trực quan)
3. Cooking time estimates for each dish with color-coded urgency levels (Ước tính thời gian nấu cho từng món với mức độ khẩn cấp mã màu)
4. Smart preparation suggestions balancing FIFO order priority with quick-serve opportunities (Gợi ý chuẩn bị thông minh cân bằng ưu tiên đơn hàng đến trước với cơ hội phục vụ nhanh)
5. Real-time updates when dishes are completed and served to tables (Cập nhật thời gian thực khi món được hoàn thành và phục vụ cho bàn)

## Epic 6: Takeaway & Delivery Orders (Gọi đồ mang về)

**Simplified Goal:** Enable simple takeaway order processing workflow: customer arrives → staff takes order → prints kitchen bill → confirms completion → processes payment. Orders display on kitchen screen with takeaway marking to differentiate from dine-in orders (Kích hoạt quy trình xử lý đơn mang về đơn giản: khách tới quán → nhân viên gọi món → in bill bếp → xác nhận hoàn thành → xử lý thanh toán. Đơn hàng hiển thị trên màn hình bếp với đánh dấu mang về để phân biệt với đơn ăn tại quán).

### Story 6.1: Takeaway Order Processing Workflow (Quy trình Xử lý Đơn hàng Mang về)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process takeaway orders with a simple workflow without table assignment (tôi muốn xử lý đơn hàng mang về với quy trình đơn giản không cần phân bàn),  
**so that** customers can quickly order food for takeaway (để khách hàng có thể nhanh chóng gọi món mang về).

**Acceptance Criteria:**
1. **Takeaway Order Creation**: Direct menu access without table selection for takeaway orders (Tạo đơn mang về: Truy cập menu trực tiếp không cần chọn bàn cho đơn mang về)
2. **Menu Browsing & Item Selection**: Same menu interface as dine-in with quantity and notes functionality (Duyệt menu và chọn món: Giao diện menu giống như ăn tại quán với chức năng số lượng và ghi chú)
3. **Kitchen Integration with Takeaway Marking**: Orders print to kitchen with clear "TAKEAWAY" marking and display on Story 5.2 kitchen screen (Tích hợp bếp với đánh dấu mang về: Đơn hàng in ra bếp với dấu hiệu "MANG VỀ" rõ ràng và hiển thị trên màn hình bếp Story 5.2)
4. **Order Status Tracking**: Real-time status updates (Confirmed, Preparing, Ready for Pickup) (Theo dõi trạng thái đơn: Cập nhật trạng thái thời gian thực - Đã xác nhận, Đang chuẩn bị, Sẵn sàng lấy)
5. **Payment Processing Integration**: Direct integration with Epic 8 payment processing (Tích hợp xử lý thanh toán: Tích hợp trực tiếp với xử lý thanh toán Epic 8)

## Epic 7: Payment Processing (Thanh toán)

**Integrated Goal:** Implement integrated payment processing within order management interface supporting Vietnamese payment methods (cash, QR bank transfer) with payment buttons directly accessible from order lists for seamless workflow (Triển khai xử lý thanh toán tích hợp trong giao diện quản lý đơn hàng hỗ trợ phương thức thanh toán Việt Nam - tiền mặt, chuyển khoản QR - với nút thanh toán truy cập trực tiếp từ danh sách đơn hàng để quy trình mượt mà).

### Story 7.1: Integrated Payment Processing (Xử lý Thanh toán Tích hợp)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process customer payments with a simple one-step workflow that automatically prints invoices (tôi muốn xử lý thanh toán khách hàng với quy trình một bước đơn giản tự động in hóa đơn),  
**so that** I can quickly complete payment processing and reset table availability (để tôi có thể nhanh chóng hoàn thành xử lý thanh toán và đặt lại trạng thái bàn khả dụng).

**Acceptance Criteria:**
1. **Auto-Print Payment Invoice**: Click "Payment" button automatically prints detailed invoice with restaurant info, itemized order details, total amount, and restaurant QR code for customer payment (Tự động in hóa đơn thanh toán: Bấm nút "Thanh toán" tự động in hóa đơn chi tiết với thông tin quán, chi tiết đơn hàng từng món, tổng tiền và QR code thanh toán của quán)
2. **Payment Confirmation Button**: Single "Payment Completed" button appears after invoice printing for staff to confirm when customer has paid (cash or bank transfer) (Nút xác nhận thanh toán: Nút "Đã thanh toán" xuất hiện sau khi in hóa đơn để nhân viên xác nhận khi khách đã thanh toán - tiền mặt hoặc chuyển khoản)
3. **Automatic Table Reset**: After clicking "Payment Completed", system automatically resets table status to "Available" and clears order data for next customers (Tự động đặt lại bàn: Sau khi bấm "Đã thanh toán", hệ thống tự động đặt lại trạng thái bàn thành "Khả dụng" và xóa dữ liệu đơn hàng cho khách tiếp theo)
4. **Invoice Content Requirements**: Printed invoice must include restaurant name, contact info, itemized dishes with prices, total amount, timestamp, and restaurant payment QR code (Yêu cầu nội dung hóa đơn: Hóa đơn in phải bao gồm tên quán, thông tin liên hệ, chi tiết món ăn với giá, tổng tiền, thời gian và QR code thanh toán của quán)

### Story 7.2: Financial Reconciliation & Reporting (Đối soát Tài chính & Báo cáo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to track all payment transactions with detailed reporting (tôi muốn theo dõi tất cả giao dịch thanh toán với báo cáo chi tiết),  
**so that** financial records are accurate and auditable (để hồ sơ tài chính chính xác và có thể kiểm toán).

**Acceptance Criteria:**
1. **Daily Payment Reconciliation**: Cash counting and payment method reconciliation with daily totals (Đối soát thanh toán hàng ngày: Kiểm đếm tiền mặt và đối soát phương thức thanh toán với tổng số hàng ngày)
2. **Payment Analytics**: Payment method breakdown analysis and daily/weekly/monthly trends (Phân tích thanh toán: Phân tích phương thức thanh toán và xu hướng hàng ngày/tuần/tháng)
3. **Financial Reporting**: Export capabilities for accounting software with Vietnamese tax compliance (Báo cáo tài chính: Khả năng xuất cho phần mềm kế toán với tuân thủ thuế Việt Nam)
4. **Transaction History**: Complete payment transaction history with search and filter capabilities (Lịch sử giao dịch: Lịch sử giao dịch thanh toán đầy đủ với khả năng tìm kiếm và lọc)
5. **Backend Integration**: Database integration to track all payments processed through the integrated interface (Tích hợp backend: Tích hợp cơ sở dữ liệu để theo dõi tất cả thanh toán được xử lý qua giao diện tích hợp)

## Epic 8: Deployment & Production Management (Deploy)

**VPS Deployment Goal:** Establish production deployment on VPS using Docker containers with GitHub Actions CI/CD, Nginx reverse proxy, PostgreSQL database, and in-memory cache caching for reliable and cost-effective restaurant system operation (Thiết lập triển khai production trên VPS sử dụng Docker containers với GitHub Actions CI/CD, Nginx reverse proxy, PostgreSQL database và in-memory cache caching để vận hành hệ thống nhà hàng đáng tin cậy và tiết kiệm chi phí).

### Story 8.1: VPS Setup & Docker Deployment (Thiết lập VPS & Triển khai Docker)
**As a** system administrator (quản trị viên hệ thống),  
**I want** to setup production VPS environment with Docker containers and automated deployment from GitHub (tôi muốn thiết lập môi trường VPS production với Docker containers và triển khai tự động từ GitHub),  
**so that** the restaurant system runs reliably on cost-effective VPS infrastructure (để hệ thống nhà hàng chạy ổn định trên hạ tầng VPS tiết kiệm chi phí).

**Acceptance Criteria:**
1. **VPS Infrastructure Setup**: Ubuntu 22.04 LTS VPS with minimum 4GB RAM, 2 CPU cores, 40GB SSD storage (Thiết lập hạ tầng VPS: Ubuntu 22.04 LTS VPS với tối thiểu 4GB RAM, 2 CPU cores, 40GB SSD storage)
2. **Docker Environment**: Docker and Docker Compose installation with containers for .NET API, Angular frontend, PostgreSQL, in-memory cache, and Nginx reverse proxy (Môi trường Docker: Cài đặt Docker và Docker Compose với containers cho .NET API, Angular frontend, PostgreSQL, in-memory cache và Nginx reverse proxy)
3. **GitHub Actions CI/CD**: Automated deployment pipeline triggered by GitHub push to main branch with build, test, and deploy stages (GitHub Actions CI/CD: Pipeline triển khai tự động kích hoạt bởi GitHub push to main branch với các giai đoạn build, test và deploy)
4. **SSL Certificate**: Let's Encrypt SSL certificate setup with automatic renewal for HTTPS access (Chứng chỉ SSL: Thiết lập chứng chỉ SSL Let's Encrypt với gia hạn tự động cho truy cập HTTPS)
5. **Domain Configuration**: Domain name setup with DNS pointing to VPS IP address for production access (Cấu hình domain: Thiết lập tên miền với DNS trỏ về IP VPS để truy cập production)

### Story 8.2: Production Configuration & Security (Cấu hình Production & Bảo mật)
**As a** system administrator (quản trị viên hệ thống),  
**I want** to configure production environment with proper security and performance settings (tôi muốn cấu hình môi trường production với cài đặt bảo mật và hiệu suất phù hợp),  
**so that** the restaurant system operates securely and efficiently in production (để hệ thống nhà hàng hoạt động an toàn và hiệu quả trong production).

**Acceptance Criteria:**
1. **Production Environment Variables**: Secure configuration management with environment-specific settings for database connections, API keys, and application secrets (Biến môi trường Production: Quản lý cấu hình bảo mật với cài đặt theo môi trường cho kết nối database, API keys và application secrets)
2. **Firewall & Security**: UFW firewall configuration allowing only ports 80, 443, and SSH with fail2ban for brute force protection (Firewall & Bảo mật: Cấu hình UFW firewall chỉ cho phép ports 80, 443 và SSH với fail2ban để bảo vệ brute force)
3. **Database Security**: PostgreSQL with restricted access, encrypted connections, and regular security updates (Bảo mật Database: PostgreSQL với truy cập hạn chế, kết nối mã hóa và cập nhật bảo mật thường xuyên)
4. **Performance Optimization**: Nginx optimization for static files, gzip compression, caching headers, and rate limiting (Tối ưu hiệu suất: Tối ưu Nginx cho static files, nén gzip, cache headers và rate limiting)
5. **Backup Strategy**: Automated daily database backups stored locally and optionally uploaded to cloud storage (Chiến lược Backup: Backup database tự động hàng ngày lưu trữ local và tùy chọn upload lên cloud storage)

### Story 8.3: Monitoring & Maintenance (Giám sát & Bảo trì)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to monitor system health and receive alerts for any issues (tôi muốn giám sát sức khỏe hệ thống và nhận cảnh báo cho bất kỳ sự cố nào),  
**so that** restaurant operations continue smoothly without technical disruptions (để hoạt động nhà hàng tiếp tục diễn ra suôn sẻ mà không bị gián đoạn kỹ thuật).

**Acceptance Criteria:**
1. **System Health Monitoring**: Simple monitoring setup using Docker container health checks and basic system metrics (CPU, memory, disk, database status) (Giám sát sức khỏe hệ thống: Thiết lập giám sát đơn giản sử dụng Docker container health checks và metrics hệ thống cơ bản)
2. **Automated Alerts**: Email notifications for system failures, high resource usage, or database connection issues (Cảnh báo tự động: Thông báo email cho lỗi hệ thống, sử dụng tài nguyên cao hoặc sự cố kết nối database)
3. **Log Management**: Centralized logging for all containers with log rotation and retention policies (Quản lý Log: Logging tập trung cho tất cả containers với chính sách rotate và retention log)
4. **Maintenance Procedures**: Documentation and scripts for common maintenance tasks like database cleanup, log rotation, and system updates (Quy trình bảo trì: Tài liệu và scripts cho các tác vụ bảo trì thường gặp như dọn dẹp database, rotate log và cập nhật hệ thống)
5. **Disaster Recovery**: Simple backup restoration procedures and emergency contact information for technical support (Khôi phục thảm họa: Quy trình phục hồi backup đơn giản và thông tin liên hệ khẩn cấp cho hỗ trợ kỹ thuật)

## Epic 9: Reporting & Analytics (Báo cáo)

**Expanded Goal:** Provide comprehensive reporting dashboard with revenue analytics, operational metrics, business intelligence, and data visualization to enable data-driven business decisions for restaurant optimization (Cung cấp bảng điều khiển báo cáo toàn diện với phân tích doanh thu, chỉ số vận hành, thông tin kinh doanh và trực quan hóa dữ liệu để cho phép các quyết định kinh doanh dựa trên dữ liệu để tối ưu hóa nhà hàng).

### Story 9.1: Revenue Analytics & Financial Reporting (Phân tích Doanh thu & Báo cáo Tài chính)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to analyze revenue trends and financial performance (tôi muốn phân tích xu hướng doanh thu và hiệu suất tài chính),  
**so that** I can make informed business decisions (để tôi có thể đưa ra quyết định kinh doanh có thông tin).

**Acceptance Criteria:**
1. Interactive revenue dashboards with time period filtering (Bảng điều khiển doanh thu tương tác với lọc theo thời gian)
2. Category and dish performance analysis (Phân tích hiệu suất danh mục và món ăn)
3. Payment method distribution and trends (Phân phối và xu hướng phương thức thanh toán)
4. Profit margin analysis by menu items (Phân tích tỷ suất lợi nhuận theo món trong menu)
5. Financial forecasting and goal tracking (Dự báo tài chính và theo dõi mục tiêu)

### Story 9.2: Operational Performance Analytics (Phân tích Hiệu suất Vận hành)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to monitor operational efficiency and identify improvement areas (tôi muốn giám sát hiệu quả vận hành và xác định các khu vực cần cải thiện),  
**so that** restaurant operations can be optimized (để hoạt động nhà hàng có thể được tối ưu hóa).

**Acceptance Criteria:**
1. Order processing time analytics and bottleneck identification (Phân tích thời gian xử lý đơn hàng và xác định nút thắt cổ chai)
2. Kitchen performance metrics and station efficiency (Chỉ số hiệu suất bếp và hiệu quả trạm)
3. Table turnover analysis and optimization suggestions (Phân tích vòng quay bàn và gợi ý tối ưu)
4. Staff productivity tracking and performance reports (Theo dõi năng suất nhân viên và báo cáo hiệu suất)
5. Customer satisfaction indicators and feedback analysis (Chỉ báo hài lòng khách hàng và phân tích phản hồi)

## Epic 10: Table Reservation System (Đặt bàn)

**Simple Goal:** Enable phone-based table reservations with pre-ordering capability that reuses existing order management workflow from Story 6.1 for efficient and familiar operation (Kích hoạt đặt bàn qua điện thoại với khả năng đặt món trước sử dụng lại quy trình quản lý đơn hàng hiện tại từ Story 6.1 để vận hành hiệu quả và quen thuộc).

### Story 10.1: Phone Reservation Processing (Xử lý Đặt bàn qua Điện thoại)
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

## Epic 11: Customer Management (Khách hàng)

**Expanded Goal:** Create comprehensive customer relationship management system with customer profiles, loyalty programs, order history, feedback collection, and personalized service features to enhance customer experience and retention (Tạo hệ thống quản lý quan hệ khách hàng toàn diện với hồ sơ khách hàng, chương trình khách hàng thân thiết, lịch sử đơn hàng, thu thập phản hồi và tính năng dịch vụ cá nhân hóa để nâng cao trải nghiệm và giữ chân khách hàng).

### Story 11.1: Customer Profile & History Management (Quản lý Hồ sơ & Lịch sử Khách hàng)
**As a** customer service staff (nhân viên chăm sóc khách hàng),  
**I want** to maintain detailed customer profiles and order history (tôi muốn duy trì hồ sơ khách hàng chi tiết và lịch sử đơn hàng),  
**so that** personalized service can be provided (để có thể cung cấp dịch vụ cá nhân hóa).

**Acceptance Criteria:**
1. Customer profile creation with contact information and preferences (Tạo hồ sơ khách hàng với thông tin liên lạc và sở thích)
2. Order history tracking with dish preferences and frequency (Theo dõi lịch sử đơn hàng với sở thích món ăn và tần suất)
3. Special dietary requirements and allergy information (Yêu cầu chế độ ăn đặc biệt và thông tin dị ứng)
4. Customer visit tracking and behavior analysis (Theo dõi lượt ghé thăm và phân tích hành vi khách hàng)
5. Personalized recommendations based on history (Gợi ý cá nhân hóa dựa trên lịch sử)

### Story 11.2: Loyalty Program & Feedback System (Chương trình Khách hàng Thân thiết & Hệ thống Phản hồi)
**As a** marketing manager (quản lý marketing),  
**I want** to implement loyalty programs and collect customer feedback (tôi muốn triển khai chương trình khách hàng thân thiết và thu thập phản hồi khách hàng),  
**so that** customer retention and satisfaction can be improved (để giữ chân khách hàng và sự hài lòng có thể được cải thiện).

**Acceptance Criteria:**
1. Points-based loyalty program with rewards tracking (Chương trình khách hàng thân thiết dựa trên điểm với theo dõi phần thưởng)
2. Special offers and promotions for loyal customers (Ưu đãi đặc biệt và khuyến mãi cho khách hàng thân thiết)
3. Customer feedback collection system with ratings (Hệ thống thu thập phản hồi khách hàng với đánh giá)
4. Birthday and anniversary special recognition (Nhận biết đặc biệt sinh nhật và kỷ niệm)
5. Customer satisfaction survey automation (Tự động hóa khảo sát sự hài lòng khách hàng)

## Epic 12: Payroll & HR Management (Tính lương)

**Expanded Goal:** Implement comprehensive staff payroll calculation system with work hour tracking, salary management, attendance monitoring, and integration with user role system for efficient human resource management in restaurant operations (Triển khai hệ thống tính lương nhân viên toàn diện với theo dõi giờ làm việc, quản lý lương, giám sát chuyên cần và tích hợp với hệ thống vai trò người dùng để quản lý nguồn nhân lực hiệu quả trong hoạt động nhà hàng).

### Story 12.1: Employee Leave Management (Quản lý Nghỉ phép Nhân viên)
**As a** restaurant manager (quản lý nhà hàng),  
**I want** to record and manage employee leave days (tôi muốn ghi nhận và quản lý ngày nghỉ của nhân viên),  
**so that** work scheduling and payroll deductions can be properly managed (để lên lịch làm việc và khấu trừ lương có thể được quản lý đúng cách).

**Acceptance Criteria:**
1. **Leave Entry Interface**: Simple form to input employee leave dates with reason (sick leave, personal leave, vacation) (Giao diện nhập nghỉ phép: Form đơn giản nhập ngày nghỉ nhân viên với lý do - nghỉ ốm, nghỉ phép cá nhân, nghỉ phép)
2. **Employee Selection**: Dropdown or search to select employee from staff list (Chọn nhân viên: Dropdown hoặc tìm kiếm để chọn nhân viên từ danh sách nhân viên)
3. **Leave Calendar View**: Calendar display showing all employee leave days for scheduling reference (Xem lịch nghỉ phép: Hiển thị lịch tất cả ngày nghỉ nhân viên để tham khảo lập lịch)
4. **Leave History**: List view of all recorded leave days by employee with dates and reasons (Lịch sử nghỉ phép: Danh sách tất cả ngày nghỉ đã ghi nhận theo nhân viên với ngày và lý do)
5. **Monthly Summary**: Simple report showing total leave days per employee per month for payroll calculation (Tóm tắt hàng tháng: Báo cáo đơn giản hiển thị tổng ngày nghỉ mỗi nhân viên mỗi tháng để tính lương)

### Story 12.2: Payroll Calculation & Management (Tính toán & Quản lý Lương)
**As a** payroll administrator (quản trị viên lương),  
**I want** to calculate employee salaries automatically based on work days and rates (tôi muốn tính lương nhân viên tự động dựa trên ngày làm việc và mức lương),  
**so that** payroll processing is efficient and error-free (để xử lý lương hiệu quả và không có lỗi).

**Acceptance Criteria:**
1. Automated salary calculation based on days worked (Tính lương tự động dựa trên số ngày làm việc)
2. Different pay rates for different roles and shifts (Mức lương khác nhau cho các vai trò và ca làm việc khác nhau)
3. Bonus and incentive management system (Hệ thống quản lý tiền thưởng và ưu đãi)
4. Payroll report generation with Vietnamese formatting (Tạo báo cáo lương với định dạng tiếng Việt)

---
