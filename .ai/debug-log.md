# Development Debug Log

## Epic 4 - Inventory Management Requirements

### Story: Real-time Inventory Calculation with Manual Procurement
**Date**: 2025-08-29
**Discussed with**: User
**Context**: Tính toán tồn kho theo thời gian thực

#### Business Flow Requirements:
```
Khách gọi món đang hết hàng:
1. Nhân viên nhận order
2. Bếp đi lấy hàng
   - Lấy hàng thành công => chế biến và thực hiện như quy trình bình thường
   - Lấy hàng không thành công => nhân viên báo khách và huỷ order
```

#### System Requirements:
- **Stock Status Levels**:
  - AVAILABLE (có sẵn)  
  - ZERO_STOCK_MANUAL_CHECK (hết hàng, cần người đi lấy)
  - UNAVAILABLE (confirmed không có)

- **Order & Procurement Flow**:
  1. Order comes in → Check stock
  2. ZERO_STOCK → Accept order + Create "Procurement Task"
  3. Assigned person goes to get ingredients (có dedicated person đi lấy hàng)
  4. Person reports back: SUCCESS/FAILED (thông báo lại kết quả)
  5. If SUCCESS → Update stock + Process order
  6. If FAILED → Cancel order + Update stock status to UNAVAILABLE

- **Technical Features**:
  - Procurement task assignment
  - Manual stock update interface (person báo kết quả)
  - Order hold/cancel mechanism
  - Real-time status updates
  - Simple mobile interface cho người đi lấy hàng
  - One-tap "Lấy được" / "Không lấy được" buttons
  - Automatic stock calculation updates
  - Order status notifications

#### Key Business Context:
- Nhà hàng có thể lấy hàng gấp trong dưới 30 phút
- Model: Accept order first, then try to procure ingredients
- Manual process với dedicated person đi lấy hàng
- Simple feedback mechanism (có lấy được hay không)

---