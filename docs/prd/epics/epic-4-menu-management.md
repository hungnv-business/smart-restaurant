# Epic 4: Menu Management System (Quản lý Menu)

**Expanded Goal:** Implement comprehensive two-level menu management with category and individual dish control, seasonal enable/disable functionality, pricing management, Vietnamese-only interface, and integration with inventory tracking for complete menu operations (Triển khai quản lý menu hai cấp toàn diện với điều khiển danh mục và món ăn riêng lẻ, chức năng bật/tắt theo mùa, quản lý định giá, giao diện chỉ tiếng Việt và tích hợp với theo dõi kho để vận hành menu hoàn chỉnh).

## Story 4.1: Menu Category Aggregate Management (Quản lý Aggregate Danh mục Menu)
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

## Story 4.2: Individual Dish Management (Quản lý Món ăn Riêng lẻ)
**As a** kitchen manager (quản lý bếp),  
**I want** to manage individual dishes with detailed information and pricing (tôi muốn quản lý từng món ăn với thông tin chi tiết và định giá),  
**so that** accurate dish information and costs are available to staff and customers (để thông tin món ăn và chi phí chính xác có sẵn cho nhân viên và khách hàng).

**Acceptance Criteria:**
1. Dish CRUD operations with name, description, price, ingredients in Vietnamese (Thao tác CRUD món ăn với tên, mô tả, giá, nguyên liệu bằng tiếng Việt)
2. Individual dish enable/disable independent of category status (Bật/tắt món ăn riêng lẻ độc lập với trạng thái danh mục)
3. Photo upload and management for dishes with multiple angles (Tải lên và quản lý ảnh cho món ăn với nhiều góc độ)
4. Dietary restrictions, allergen information, and spice level indicators (Thông tin hạn chế chế độ ăn, dị ứng và chỉ báo độ cay)
5. Cooking time, preparation notes, and kitchen station assignment (Thời gian nấu, ghi chú chuẩn bị và phân công trạm bếp)

---