# Epic 3: Menu Management System (Quản lý Menu)

**Expanded Goal:** Implement comprehensive two-level menu management with category and individual dish control supporting one-to-many relationships, seasonal enable/disable functionality, basic dish information management, Vietnamese-only interface, and integration with inventory tracking for complete menu operations (Triển khai quản lý menu hai cấp toàn diện với điều khiển danh mục và món ăn riêng lẻ hỗ trợ mối quan hệ một-nhiều, chức năng bật/tắt theo mùa, quản lý thông tin món ăn cơ bản, giao diện chỉ tiếng Việt và tích hợp với theo dõi kho để vận hành menu hoàn chỉnh).

## Story 3.1: Menu Category Aggregate Management (Quản lý Aggregate Danh mục Menu)
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

## Story 3.2: Individual Dish Management with Single Category (Quản lý Món ăn Riêng lẻ với Một Danh mục)
**As a** kitchen manager (quản lý bếp),  
**I want** to manage individual dishes with basic information and assign each dish to one category (tôi muốn quản lý từng món ăn với thông tin cơ bản và gán mỗi món vào một danh mục),  
**so that** dishes are properly organized in menu sections and accurate information is available to staff and customers (để món ăn được tổ chức hợp lý trong các mục menu và thông tin chính xác có sẵn cho nhân viên và khách hàng).

**Acceptance Criteria:**
1. **Basic Dish Information**: CRUD operations with essential fields: name (Vietnamese), description, price (VND), status (active/inactive) (Thông tin món ăn cơ bản: Thao tác CRUD với các trường thiết yếu - tên tiếng Việt, mô tả, giá VND, trạng thái hoạt động/không hoạt động)
2. **Single Category Assignment**: One-to-many relationship between categories and dishes - each dish belongs to exactly one category (e.g., "Phở Bò" belongs to "Món Phở" category only) (Gán một danh mục: Mối quan hệ một-nhiều giữa danh mục và món ăn - mỗi món thuộc chính xác một danh mục, ví dụ "Phở Bò" chỉ thuộc danh mục "Món Phở")
3. **Category-Independent Status**: Individual dish enable/disable independent of category status - dish can be disabled while remaining in its assigned category (Trạng thái độc lập danh mục: Bật/tắt món ăn riêng lẻ độc lập với trạng thái danh mục - món có thể bị tắt nhưng vẫn thuộc về danh mục được gán)
4. **Single Photo Management**: One primary photo per dish with upload and replacement functionality (Quản lý một ảnh: Một ảnh chính cho mỗi món với chức năng tải lên và thay thế)
5. **Entity Framework Configuration**: Configure one-to-many relationship using foreign key (CategoryId) with proper navigation properties and cascading rules (Cấu hình Entity Framework: Cấu hình mối quan hệ một-nhiều sử dụng khóa ngoại CategoryId với navigation properties và quy tắc cascade phù hợp)

---