# Cross-Epic Dependencies Documentation (Tài liệu Phụ thuộc Liên Epic)

**Dependency Matrix Between Epics (Ma trận Phụ thuộc giữa các Epic)**

This section documents the explicit dependencies between different epics in the Smart Restaurant Management System, ensuring proper implementation order and integration checkpoints (Phần này ghi lại các phụ thuộc rõ ràng giữa các epic khác nhau trong Hệ thống Quản lý Nhà hàng Thông minh, đảm bảo thứ tự triển khai và các điểm kiểm tra tích hợp đúng đắn).

## Epic Dependency Matrix (Ma trận Phụ thuộc Epic)

| Epic | Depends On (Phụ thuộc vào) | Provides To (Cung cấp cho) | Integration Points (Điểm tích hợp) |
|------|------------|-------------|------------------|
| **1. Repository Setup** | None | All epics | Base ABP project structure, development environment |
| **2. Menu Management** | Repository Setup | Order Processing, Kitchen Display | MenuItem entities, MenuCategory enums, menu APIs |
| **3. Order Processing** | Repository Setup, Menu Management | Payment Processing, Kitchen Display | Order entities, OrderItem relationships, order status workflow |
| **4. Payment Processing** | Repository Setup, Order Processing | Reporting | Payment entities, Vietnamese banking integration, order completion |
| **5. Kitchen Display** | Repository Setup, Menu Management, Order Processing | None | Real-time order updates, kitchen station routing, SignalR hubs |
| **6. Reporting** | Repository Setup, Order Processing, Payment Processing | None | Data aggregation services, analytics endpoints |

## Detailed Epic Dependencies (Phụ thuộc Epic Chi tiết)

### Epic 1: Repository and Project Structure Setup (Thiết lập Repository và Cấu trúc Dự án)
**Prerequisites:** None (Điều kiện tiên quyết: Không)
**Deliverables:**
- ABP Framework project structure
- Development environment configuration
- Database setup with PostgreSQL
- Basic authentication and authorization

**Handoff Criteria (Tiêu chí Bàn giao):**
- [ ] ABP project builds successfully with `dotnet build`
- [ ] Angular project starts with `ng serve`
- [ ] Database migrations run successfully
- [ ] Authentication system functional
- [ ] Development environment documented in README

### Epic 2: Menu Management System (Hệ thống Quản lý Menu)
**Prerequisites:** Epic 1 (Repository Setup)
**Dependencies:**
- Database schema from Epic 1
- ABP application services framework
- Authentication system

**Deliverables:**
- MenuCategory and MenuItem entities
- Menu CRUD operations (Create, Read, Update, Delete)
- Vietnamese text search capability
- Two-level menu management (category + item)

**Shared Components for Other Epics:**
```csharp
// Shared entities that other epics depend on
public class MenuItem : FullAuditedEntity<Guid>
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public bool IsAvailable { get; set; }
    public Guid CategoryId { get; set; }
    public virtual MenuCategory Category { get; set; }
}

public enum KitchenStation
{
    General, Hotpot, Grilled, Drinking
}
```

**Integration Checkpoints:**
- [ ] MenuItem entity available for OrderItem relationships
- [ ] Menu availability service ready for order validation
- [ ] Kitchen station enum defined for kitchen routing
- [ ] Vietnamese text search functional for menu filtering

**Handoff Criteria:**
- [ ] Menu CRUD APIs working with Swagger documentation
- [ ] Vietnamese text search returns accurate results
- [ ] Category enable/disable affects item availability
- [ ] Frontend menu display components functional

### Epic 3: Order Processing System (Hệ thống Xử lý Đơn hàng)
**Prerequisites:** Epic 1 (Repository Setup), Epic 2 (Menu Management)
**Dependencies:**
- MenuItem entities from Epic 2
- Menu availability service
- Table management entities

**Deliverables:**
- Order and OrderItem entities
- Order workflow management
- Real-time order status updates
- Table assignment logic

**Shared Components for Other Epics:**
```csharp
// Shared for Payment Processing
public class Order : FullAuditedAggregateRoot<Guid>
{
    public string OrderNumber { get; set; }
    public OrderStatus Status { get; set; }
    public decimal TotalAmount { get; set; }
    public Guid TableId { get; set; }
    public virtual ICollection<OrderItem> OrderItems { get; set; }
}

// Shared for Kitchen Display
public enum OrderStatus
{
    Pending, Confirmed, Preparing, Ready, Served, Paid
}
```

**Integration Checkpoints:**
- [ ] OrderItem correctly references MenuItem with proper pricing
- [ ] Order status changes trigger SignalR notifications
- [ ] Table availability updates when orders are placed
- [ ] Order validation against menu availability works

**Handoff Criteria:**
- [ ] Complete order workflow from creation to completion
- [ ] Real-time status updates functional
- [ ] Order calculation includes correct pricing from menu
- [ ] Table management integrated

### Epic 4: Payment Processing System (Hệ thống Xử lý Thanh toán)
**Prerequisites:** Epic 1 (Repository Setup), Epic 3 (Order Processing)
**Dependencies:**
- Order entities from Epic 3
- Order completion workflow
- Vietnamese banking API integration

**Deliverables:**
- Payment entities and workflows
- Vietnamese QR payment integration
- Payment status tracking
- Receipt generation

**Shared Components for Other Epics:**
```csharp
// Shared for Reporting
public class Payment : FullAuditedEntity<Guid>
{
    public Guid OrderId { get; set; }
    public decimal Amount { get; set; }
    public PaymentMethod Method { get; set; }
    public PaymentStatus Status { get; set; }
    public DateTime PaidAt { get; set; }
    public virtual Order Order { get; set; }
}

public enum PaymentMethod
{
    Cash, BankTransfer, QrCode
}
```

**Integration Checkpoints:**
- [ ] Payment completion updates order status to 'Paid'
- [ ] Payment amount matches order total amount
- [ ] Vietnamese banking QR codes generated successfully
- [ ] Payment status updates via webhook integration

**Handoff Criteria:**
- [ ] All payment methods functional (cash, bank transfer, QR)
- [ ] Payment status synchronization with external banking APIs
- [ ] Receipt generation with Vietnamese formatting
- [ ] Payment failure handling and retry logic

### Epic 5: Kitchen Display System (Hệ thống Hiển thị Bếp)
**Prerequisites:** Epic 1 (Repository Setup), Epic 2 (Menu Management), Epic 3 (Order Processing)
**Dependencies:**
- Order entities and status workflow from Epic 3
- MenuItem kitchen station assignments from Epic 2
- SignalR infrastructure

**Deliverables:**
- Real-time kitchen displays
- Kitchen station routing
- Order priority management
- Kitchen printer integration

**Integration Checkpoints:**
- [ ] Receives order notifications when status changes to 'Confirmed'
- [ ] Kitchen station routing based on MenuItem.KitchenStation
- [ ] Order completion updates sent back to order processing
- [ ] Printer integration functional for order tickets

**Handoff Criteria:**
- [ ] Real-time order updates appear on kitchen displays
- [ ] Orders route to correct kitchen stations
- [ ] Kitchen staff can update order status
- [ ] Printer integration working with ESC/POS commands

### Epic 6: Reporting and Analytics (Báo cáo và Phân tích)
**Prerequisites:** Epic 1 (Repository Setup), Epic 3 (Order Processing), Epic 4 (Payment Processing)
**Dependencies:**
- Order data from Epic 3
- Payment data from Epic 4
- Historical data accumulation

**Deliverables:**
- Sales reports
- Menu performance analytics
- Revenue tracking
- Vietnamese business hour analysis

**Integration Checkpoints:**
- [ ] Access to completed orders with all related data
- [ ] Payment data available for revenue calculations
- [ ] Real-time dashboard updates as orders are processed
- [ ] Vietnamese date/time formatting for local business analysis

**Handoff Criteria:**
- [ ] Daily, weekly, monthly sales reports functional
- [ ] Menu item popularity analytics accurate
- [ ] Revenue tracking matches payment records
- [ ] Performance optimized for Vietnamese peak hours

## Integration Handoff Criteria (Tiêu chí Bàn giao Tích hợp)

**Between Menu Management → Order Processing:**
- [ ] MenuItem pricing correctly flows to OrderItem
- [ ] Menu availability validation prevents ordering unavailable items
- [ ] Category disable cascades to prevent ordering from disabled categories
- [ ] Kitchen station assignment flows from MenuItem to kitchen routing

**Between Order Processing → Payment Processing:**
- [ ] Order total calculation matches payment amount requirements
- [ ] Order status 'Served' enables payment processing
- [ ] Payment completion updates order status to 'Paid'
- [ ] Order-Payment relationship maintains data integrity

**Between Order Processing → Kitchen Display:**
- [ ] Order status 'Confirmed' triggers kitchen notification
- [ ] Kitchen station routing works based on MenuItem assignments
- [ ] Kitchen status updates flow back to order processing
- [ ] Real-time SignalR connections functional

**Between Payment Processing → Reporting:**
- [ ] Payment completion data available for revenue calculation
- [ ] Payment method analysis functional
- [ ] Vietnamese payment timing analysis accurate
- [ ] Financial reconciliation data complete

## Shared Services and Components (Dịch vụ và Thành phần Chia sẻ)

**Cross-Epic Shared Services:**
```csharp
// Shared across multiple epics
public interface IVietnameseLocalizationService
{
    string FormatCurrency(decimal amount);
    string FormatDateTime(DateTime dateTime);
    string NormalizeVietnameseText(string text);
}

// Used by Menu, Order, and Kitchen epics
public interface ISignalRNotificationService
{
    Task NotifyOrderStatusChange(Guid orderId, OrderStatus newStatus);
    Task NotifyKitchenStation(KitchenStation station, Order order);
    Task NotifyTableStatus(Guid tableId, TableStatus newStatus);
}

// Used by Order and Payment epics
public interface IAuditLogService
{
    Task LogOrderAction(Guid orderId, string action, object details);
    Task LogPaymentAction(Guid paymentId, string action, object details);
}
```

**Shared Constants and Enums:**
```csharp
// aspnet-core/src/SmartRestaurant.Domain.Shared/Constants/VietnameseBusinessConstants.cs
public static class VietnameseBusinessConstants
{
    public const string CURRENCY_SYMBOL = "₫";
    public const string TIMEZONE = "Asia/Ho_Chi_Minh";
    
    public static readonly TimeSpan[] PEAK_HOURS = {
        new TimeSpan(11, 30, 0), // Lunch start
        new TimeSpan(13, 30, 0), // Lunch end
        new TimeSpan(18, 0, 0),  // Dinner start
        new TimeSpan(21, 0, 0)   // Dinner end
    };
}
```
