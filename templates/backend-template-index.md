# SmartRestaurant Backend Template - Navigation

## 🎯 Template Selection Guide

### Quick Decision Tree
```
┌─ Entity chỉ có basic properties? ────────────────────────────────────► Level 1
│
├─ Entity có calculations/status changes? ────────────────────────────► Level 2
│
├─ Entity điều khiển core business workflow? ─────────────────────────► Level 3
│
└─ Không chắc? ────────────────────────────────────────────────────────► Start với Level 1, sau đó migrate lên
```

## 📄 Template Files

### 📋 [Level 1: Basic CRUD Template](./backend-template-level1.md)
**Khi nào dùng**: Entity đơn giản, chủ yếu là master data, ít business logic
**Phù hợp cho**: MenuCategory, LayoutSection, UserRole, Settings, Tags...
**Framework**: ICrudAppService và CrudAppService của ABP
**Đặc điểm**: Ít boilerplate code, tận dụng ABP conventions

### 🔧 [Level 2: Business Logic Template](./backend-template-level2.md)
**Khi nào dùng**: Entity có business rules, calculation, state changes
**Phù hợp cho**: Order, Reservation, Payment, Inventory, CustomerFeedback...
**Framework**: IApplicationService (không dùng ICrudAppService)
**Đặc điểm**: Custom CRUD + business methods, domain events

### 🚀 [Level 3: Complex Business Template](./backend-template-level3.md)
**Khi nào dùng**: Entity điều khiển workflow chính, tích hợp nhiều systems
**Phù hợp cho**: Table (với realtime status), MenuItem (với pricing rules), Kitchen Operations...
**Framework**: IApplicationService với nhiều dependencies injection
**Đặc điểm**: Full workflow với SignalR, external integration, background jobs

## 🔄 Migration Path

1. **Bắt đầu với Level 1** cho entities mới
2. **Migrate lên Level 2** khi cần business logic
3. **Migrate lên Level 3** khi cần workflow phức tạp

## 📖 Common Resources

Tất cả các level đều sử dụng chung:
- ABP Framework conventions
- Domain error codes và localization
- EF Core configuration patterns
- DTO mapping strategies
- Testing approaches