# Epic 4: Inventory Management (Quản lý Kho)

**Expanded Goal:** Create comprehensive inventory management system focused on ingredient category management for purchase invoices and stock-in tracking with automatic deduction, cost calculation, and low stock alerts for efficient restaurant inventory control (Tạo hệ thống quản lý kho toàn diện tập trung vào quản lý danh mục nguyên liệu cho hóa đơn mua và theo dõi nhập kho với trừ kho tự động, tính toán chi phí và cảnh báo hết hàng để kiểm soát kho nhà hàng hiệu quả).

## Story 4.1: Ingredient Category Management (Quản lý Danh mục Nguyên liệu)
**As a** inventory manager (quản lý kho),  
**I want** to manage ingredient categories and items for purchase invoice creation (tôi muốn quản lý danh mục và mặt hàng nguyên liệu để tạo hóa đơn mua),  
**so that** purchase invoices can be created systematically and ingredients can be tracked properly (để hóa đơn mua có thể được tạo một cách có hệ thống và nguyên liệu có thể được theo dõi đúng cách).

**Acceptance Criteria:**
1. Ingredient category CRUD with Vietnamese names (tomatoes, onions, meat, etc.) (Tạo, sửa, xóa danh mục nguyên liệu với tên tiếng Việt)
2. Ingredient item management with detailed specifications (Quản lý từng mặt hàng nguyên liệu với thông số chi tiết)
3. Unit of measurement definition (kg, gram, liter, pieces, etc.) (Định nghĩa đơn vị đo lường - kg, gram, lít, cái, v.v.)
4. Cost tracking per unit for purchase invoice creation (Theo dõi giá thành theo đơn vị để tạo hóa đơn mua)
5. Supplier information linking for each ingredient (Liên kết thông tin nhà cung cấp cho từng nguyên liệu)

## Story 4.2: Purchase Invoice & Stock-In Management (Quản lý Hóa đơn Mua & Nhập kho)
**As a** purchase manager (quản lý mua hàng),  
**I want** to create and manage purchase invoices with detailed stock-in tracking (tôi muốn tạo và quản lý hóa đơn mua với theo dõi nhập kho chi tiết),  
**so that** all purchases are recorded for cost calculation, automatic stock deduction, and inventory alerts (để tất cả giao dịch mua được ghi nhận để tính chi phí, trừ kho tự động và cảnh báo tồn kho).

**Acceptance Criteria:**
1. Purchase invoice creation with ingredient selection, quantities, and pricing (Tạo hóa đơn mua với chọn nguyên liệu, số lượng và giá cả)
2. Stock-in recording with purchase date, supplier, and total cost tracking (Ghi nhận nhập kho với ngày mua, nhà cung cấp và theo dõi tổng chi phí)
3. Integration with expense calculation for financial reporting (Tích hợp với tính toán chi phí cho báo cáo tài chính)
4. Automatic inventory level updates upon stock-in confirmation (Cập nhật mức tồn kho tự động khi xác nhận nhập kho)
5. Foundation for automatic stock deduction when orders are processed (Nền tảng cho trừ kho tự động khi xử lý đơn hàng)

## Story 4.3: Inventory Tracking & Alert System (Theo dõi Tồn kho & Hệ thống Cảnh báo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to monitor current stock levels with automatic alerts for low inventory (tôi muốn giám sát mức tồn kho hiện tại với cảnh báo tự động khi sắp hết hàng),  
**so that** restaurant operations are not disrupted by stockouts and purchasing can be planned effectively (để hoạt động nhà hàng không bị gián đoạn do hết hàng và có thể lập kế hoạch mua hàng hiệu quả).

**Acceptance Criteria:**
1. Real-time stock level display with current quantities by ingredient (Hiển thị mức tồn kho thời gian thực theo từng nguyên liệu)
2. Configurable minimum stock level alerts and notifications (Cảnh báo và thông báo mức tồn kho tối thiểu có thể cấu hình)
3. Stock movement history tracking (purchases, usage, adjustments) (Theo dõi lịch sử di chuyển kho - mua, sử dụng, điều chỉnh)
4. Integration foundation for automatic deduction when menu items are ordered (Nền tảng tích hợp để trừ kho tự động khi đặt món)
5. Inventory reports for purchase planning and cost analysis (Báo cáo tồn kho để lập kế hoạch mua hàng và phân tích chi phí)

---