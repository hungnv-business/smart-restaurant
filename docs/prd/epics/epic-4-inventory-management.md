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

## Story 4.2: Purchase Invoice & Stock-In Management (Quản lý Hóa đơn Mua & Nhập kho) ✅ **COMPLETED**
**As a** purchase manager (quản lý mua hàng),  
**I want** to create and manage purchase invoices with detailed stock-in tracking (tôi muốn tạo và quản lý hóa đơn mua với theo dõi nhập kho chi tiết),  
**so that** all purchases are recorded for cost calculation, automatic stock deduction, and inventory alerts (để tất cả giao dịch mua được ghi nhận để tính chi phí, trừ kho tự động và cảnh báo tồn kho).

**Acceptance Criteria:** ✅ **ALL COMPLETED**
1. ✅ Purchase invoice creation with ingredient selection, quantities, and pricing (Tạo hóa đơn mua với chọn nguyên liệu, số lượng và giá cả)
2. ✅ Stock-in recording with purchase date, supplier, and total cost tracking (Ghi nhận nhập kho với ngày mua, nhà cung cấp và theo dõi tổng chi phí)
3. ✅ Integration with expense calculation for financial reporting (Tích hợp với tính toán chi phí cho báo cáo tài chính)
4. ✅ Automatic inventory level updates upon stock-in confirmation (Cập nhật mức tồn kho tự động khi xác nhận nhập kho)
5. ✅ Foundation for automatic stock deduction when orders are processed (Nền tảng cho trừ kho tự động khi xử lý đơn hàng)

**QA Status:** PASSED (4.6/5.0) - Production Ready | **Review Date:** 2025-09-01

## Story 4.3: Multi-Unit System for Ingredients (Hệ thống Đa đơn vị cho Nguyên liệu)
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

## Story 4.4: Inventory Tracking & Alert System (Theo dõi Tồn kho & Hệ thống Cảnh báo)
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

---