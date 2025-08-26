# Level 2: Business Logic Template (Transactional Data)

## 🔧 Overview

**Khi nào dùng**: Entity có business rules, calculation, state changes
**Phù hợp cho**: Order, Reservation, Payment, Inventory, CustomerFeedback...
**Framework**: Kế thừa từ `IApplicationService` (không dùng ICrudAppService)
**APIs**: Basic CRUD + Business methods

- `CalculateTotalAsync()`, `ChangeStatusAsync()`, `ValidateRulesAsync()`
- `AddItemAsync()`, `RemoveItemAsync()`, `ApplyDiscountAsync()`
- `ProcessAsync()`, `CancelAsync()`, `ConfirmAsync()`

**Đặc điểm**:
- Có enum Status và state machine
- Business calculations (totals, taxes, discounts)
- Complex validation rules
- Domain events (ILocalEventBus)
- Multiple relationships
- **Lý do không dùng ICrudAppService**: Business logic phức tạp cần custom implementation

## ✅ When to Use Level 2

**Level 2 (Business Logic + IApplicationService)**:
- ✅ Order, Reservation, Payment, Inventory
- ✅ Entities với status changes, calculations
- ✅ Entities với domain events
- ❌ Không dùng cho: Master data đơn giản hoặc core workflow entities

## 1. 📁 File Structure

```
aspnet-core/
├── src/SmartRestaurant.Domain.Shared/
│   ├── Entities/{Module}/{EntityName}Consts.cs
│   └── SmartRestaurantDomainErrorCodes.cs
├── src/SmartRestaurant.Domain/
│   ├── Entities/{Module}/{EntityName}.cs
│   ├── {Module}/{EntityName}Manager.cs (Domain Service)
│   ├── {Module}/I{EntityName}Repository.cs
│   └── {Module}/Exceptions/*.cs
├── src/SmartRestaurant.EntityFrameworkCore/
│   ├── EntityFrameworkCore/SmartRestaurantDbContext.cs
│   └── {Module}/EfCore{EntityName}Repository.cs
├── src/SmartRestaurant.Application.Contracts/
│   └── {Module}/
│       ├── I{EntityName}AppService.cs
│       └── Dto/
│           ├── {EntityName}Dto.cs
│           ├── Create{EntityName}Dto.cs
│           ├── Update{EntityName}Dto.cs
│           └── Get{EntityName}ListDto.cs
└── src/SmartRestaurant.Application/
    └── {Module}/
        ├── {EntityName}AppService.cs
        └── {EntityName}ApplicationAutoMapperProfile.cs
```

## 2. 🏗️ Domain Layer

### Domain Error Codes (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/SmartRestaurantDomainErrorCodes.cs
namespace SmartRestaurant
{
    public static class SmartRestaurantDomainErrorCodes
    {
        // Order specific (Level 2) 
        public const string OrderCannotAddItemsAfterConfirmed = "SmartRestaurant:01001";
        public const string OrderCannotRemoveItemsAfterConfirmed = "SmartRestaurant:01002";
        public const string OrderCanOnlyConfirmFromDraft = "SmartRestaurant:01003";
        public const string OrderCannotConfirmEmptyOrder = "SmartRestaurant:01004";
        public const string OrderCanOnlyStartPreparingFromConfirmed = "SmartRestaurant:01005";
        public const string OrderCanOnlyCompleteFromPreparing = "SmartRestaurant:01006";
        public const string OrderCanOnlyPayFromServed = "SmartRestaurant:01007";
        public const string OrderCannotCancelPaidOrder = "SmartRestaurant:01008";
        public const string OrderNumberAlreadyExists = "SmartRestaurant:01009";
        public const string TableNotAvailable = "SmartRestaurant:01010";
    }
}
```

### Business Exception Classes (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Orders/Exceptions/OrderStateException.cs  
using Volo.Abp;

namespace SmartRestaurant.Orders
{
    public class OrderStateException : BusinessException
    {
        public OrderStateException(string errorCode, Guid orderId, OrderStatus currentStatus)
            : base(errorCode)
        {
            WithData("OrderId", orderId);
            WithData("Status", currentStatus);
        }
    }
    
    public class OrderCannotAddItemsException : OrderStateException
    {
        public OrderCannotAddItemsException(Guid orderId, OrderStatus currentStatus)
            : base(SmartRestaurantDomainErrorCodes.OrderCannotAddItemsAfterConfirmed, orderId, currentStatus)
        {
        }
    }
    
    public class OrderCannotRemoveItemsException : OrderStateException
    {
        public OrderCannotRemoveItemsException(Guid orderId, OrderStatus currentStatus)
            : base(SmartRestaurantDomainErrorCodes.OrderCannotRemoveItemsAfterConfirmed, orderId, currentStatus)
        {
        }
    }
    
    public class OrderCanOnlyConfirmFromDraftException : OrderStateException
    {
        public OrderCanOnlyConfirmFromDraftException(Guid orderId, OrderStatus currentStatus)
            : base(SmartRestaurantDomainErrorCodes.OrderCanOnlyConfirmFromDraft, orderId, currentStatus)
        {
        }
    }
    
    public class OrderCannotConfirmEmptyOrderException : BusinessException
    {
        public OrderCannotConfirmEmptyOrderException(Guid orderId)
            : base(SmartRestaurantDomainErrorCodes.OrderCannotConfirmEmptyOrder)
        {
            WithData("OrderId", orderId);
        }
    }
    
    public class OrderNumberAlreadyExistsException : BusinessException
    {
        public OrderNumberAlreadyExistsException(string orderNumber)
            : base(SmartRestaurantDomainErrorCodes.OrderNumberAlreadyExists)
        {
            WithData("OrderNumber", orderNumber);
        }
    }
    
    public class TableNotAvailableException : BusinessException
    {
        public TableNotAvailableException(Guid tableId)
            : base(SmartRestaurantDomainErrorCodes.TableNotAvailable)
        {
            WithData("TableId", tableId);
        }
    }
}
```

### Domain Entity Template (Level 2)

#### Constants File
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Orders/OrderConsts.cs
namespace SmartRestaurant.Orders
{
    public static class OrderConsts
    {
        public const int MaxOrderNumberLength = 50;
        public const int MaxNotesLength = 1000;
        public const decimal TaxRate = 0.10m; // 10% VAT
        public const decimal ServiceFeeRate = 0.05m; // 5% service fee
    }
}
```

#### Domain Entity (Business Logic)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Orders/Order.cs
using System;
using System.Collections.Generic;
using System.Linq;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Orders
{
    /// <summary>Đơn hàng trong nhà hàng</summary>
    public class Order : FullAuditedAggregateRoot<Guid>
    {
        /// <summary>Mã đơn hàng (tự động generate)</summary>
        public string OrderNumber { get; private set; }

        /// <summary>ID bàn ăn</summary>
        public Guid TableId { get; private set; }

        /// <summary>ID khách hàng (nullable nếu là khách vãng lai)</summary>
        public Guid? CustomerId { get; private set; }

        /// <summary>Trạng thái đơn hàng</summary>
        public OrderStatus Status { get; private set; }

        /// <summary>Ghi chú đơn hàng</summary>
        public string Notes { get; private set; }

        /// <summary>Tổng tiền trước thuế và phí</summary>
        public decimal SubTotal { get; private set; }

        /// <summary>Thuế VAT (10%)</summary>  
        public decimal TaxAmount { get; private set; }

        /// <summary>Phí phục vụ (5%)</summary>
        public decimal ServiceFee { get; private set; }

        /// <summary>Giảm giá</summary>
        public decimal DiscountAmount { get; private set; }

        /// <summary>Tổng tiền cuối cùng</summary>
        public decimal TotalAmount { get; private set; }

        /// <summary>Thời gian đặt hàng</summary>
        public DateTime OrderTime { get; private set; }

        /// <summary>Thời gian phục vụ xong (nullable)</summary>
        public DateTime? ServedTime { get; private set; }

        /// <summary>Thời gian thanh toán (nullable)</summary>
        public DateTime? PaidTime { get; private set; }

        // Collection navigation property for child entities (Level 2 allows collections for business logic)
        public virtual ICollection<OrderItem> Items { get; private set; }

        protected Order()
        {
            // Required by EF Core
            Items = new HashSet<OrderItem>();
        }

        public Order(
            Guid id,
            string orderNumber,
            Guid tableId,
            Guid? customerId = null,
            string notes = null
        ) : base(id)
        {
            SetOrderNumber(orderNumber);
            SetTable(tableId);
            SetCustomer(customerId);
            SetNotes(notes);
            Status = OrderStatus.Draft;
            OrderTime = DateTime.UtcNow; // Use UTC for ABP best practices
            ResetTotals();

            Items = new HashSet<OrderItem>();
        }

        // Business setter methods following ABP patterns
        public void SetOrderNumber(string orderNumber)
        {
            OrderNumber = Check.NotNullOrWhiteSpace(
                orderNumber,
                nameof(orderNumber),
                OrderConsts.MaxOrderNumberLength
            );
        }

        public void SetTable(Guid tableId)
        {
            TableId = Check.NotNull(tableId, nameof(tableId));
        }

        public void SetCustomer(Guid? customerId)
        {
            CustomerId = customerId;
        }

        public void SetNotes(string notes)
        {
            Notes = Check.Length(
                notes,
                nameof(notes), 
                OrderConsts.MaxNotesLength
            );
        }

        private void ResetTotals()
        {
            SubTotal = 0;
            TaxAmount = 0;
            ServiceFee = 0;
            DiscountAmount = 0;
            TotalAmount = 0;
        }

        // Core business methods with proper validation using Check utilities
        public OrderItem AddItem(Guid menuItemId, int quantity, decimal unitPrice, string notes = null)
        {
            Check.NotNull(menuItemId, nameof(menuItemId));
            Check.Range(quantity, nameof(quantity), 1, int.MaxValue);
            Check.Range(unitPrice, nameof(unitPrice), 0, decimal.MaxValue);

            if (Status != OrderStatus.Draft)
            {
                throw new OrderCannotAddItemsException(Id, Status);
            }

            var existingItem = Items.FirstOrDefault(x => x.MenuItemId == menuItemId);
            if (existingItem != null)
            {
                existingItem.UpdateQuantity(existingItem.Quantity + quantity);
                RecalculateTotal();
                return existingItem;
            }

            var orderItem = new OrderItem(
                GuidGenerator.Create(),
                Id,
                menuItemId,
                quantity,
                unitPrice,
                notes
            );
            
            Items.Add(orderItem);
            RecalculateTotal();
            return orderItem;
        }

        public void RemoveItem(Guid orderItemId)
        {
            Check.NotNull(orderItemId, nameof(orderItemId));

            if (Status != OrderStatus.Draft)
            {
                throw new OrderCannotRemoveItemsException(Id, Status);
            }

            var item = Items.FirstOrDefault(x => x.Id == orderItemId);
            if (item == null)
            {
                throw new EntityNotFoundException(typeof(OrderItem), orderItemId);
            }

            Items.Remove(item);
            RecalculateTotal();
        }

        public void ApplyDiscount(decimal discountAmount)
        {
            Check.Range(discountAmount, nameof(discountAmount), 0, SubTotal);
            
            DiscountAmount = discountAmount;
            RecalculateTotal();
        }

        public void ConfirmOrder()
        {
            if (Status != OrderStatus.Draft)
            {
                throw new OrderCanOnlyConfirmFromDraftException(Id, Status);
            }

            if (!Items.Any())
            {
                throw new OrderCannotConfirmEmptyOrderException(Id);
            }

            Status = OrderStatus.Confirmed;
        }

        public void StartPreparing()
        {
            if (Status != OrderStatus.Confirmed)
            {
                throw new BusinessException("SmartRestaurant:OrderCanOnlyStartPreparingFromConfirmed")
                    .WithData("OrderId", Id)
                    .WithData("Status", Status);
            }

            Status = OrderStatus.Preparing;
        }

        public void CompleteServing()
        {
            if (Status != OrderStatus.Preparing)
            {
                throw new BusinessException("SmartRestaurant:OrderCanOnlyCompleteFromPreparing")
                    .WithData("OrderId", Id)
                    .WithData("Status", Status);
            }

            Status = OrderStatus.Served;
            ServedTime = DateTime.UtcNow;
        }

        public void ProcessPayment()
        {
            if (Status != OrderStatus.Served)
            {
                throw new BusinessException("SmartRestaurant:OrderCanOnlyPayFromServed")
                    .WithData("OrderId", Id)
                    .WithData("Status", Status);
            }

            Status = OrderStatus.Paid;
            PaidTime = DateTime.UtcNow;
        }

        public void CancelOrder(string reason)
        {
            Check.NotNullOrWhiteSpace(reason, nameof(reason));

            if (Status == OrderStatus.Paid)
            {
                throw new BusinessException("SmartRestaurant:OrderCannotCancelPaidOrder")
                    .WithData("OrderId", Id);
            }

            Status = OrderStatus.Cancelled;
        }

        private void RecalculateTotal()
        {
            SubTotal = Items.Sum(x => x.TotalPrice);
            TaxAmount = SubTotal * OrderConsts.TaxRate;
            ServiceFee = SubTotal * OrderConsts.ServiceFeeRate;
            TotalAmount = SubTotal + TaxAmount + ServiceFee - DiscountAmount;
        }
    }

    /// <summary>Trạng thái đơn hàng</summary>
    public enum OrderStatus
    {
        /// <summary>Đang soạn thảo</summary>
        Draft = 0,
        /// <summary>Đã xác nhận</summary>
        Confirmed = 1,
        /// <summary>Đang chế biến</summary>
        Preparing = 2,
        /// <summary>Đã phục vụ</summary>
        Served = 3,
        /// <summary>Đã thanh toán</summary>
        Paid = 4,
        /// <summary>Đã hủy</summary>
        Cancelled = -1
    }
}
```

### Domain Service Template (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Orders/OrderManager.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;
using Volo.Abp.EventBus.Local;

namespace SmartRestaurant.Orders
{
    public class OrderManager : DomainService
    {
        private readonly IRepository<Order, Guid> _orderRepository;
        private readonly ILocalEventBus _localEventBus;

        public OrderManager(
            IRepository<Order, Guid> orderRepository,
            ILocalEventBus localEventBus)
        {
            _orderRepository = orderRepository;
            _localEventBus = localEventBus;
        }

        public async Task<Order> CreateOrderAsync(
            string orderNumber,
            Guid tableId,
            Guid? customerId = null,
            string notes = null)
        {
            // Business validation - ensure order number is unique
            await CheckOrderNumberUniqueAsync(orderNumber);

            // Business validation - ensure table is available
            await ValidateTableAvailabilityAsync(tableId);

            var order = new Order(
                GuidGenerator.Create(),
                orderNumber,
                tableId,
                customerId,
                notes
            );

            // Domain event
            await _localEventBus.PublishAsync(new OrderCreatedEvent
            {
                Order = order
            });

            return await _orderRepository.InsertAsync(order, autoSave: true);
        }

        public async Task<string> GenerateOrderNumberAsync()
        {
            // Business logic for generating unique order numbers
            var today = DateTime.Today;
            var prefix = $"ORD{today:yyyyMMdd}";
            
            var todayOrders = await _orderRepository.CountAsync(
                x => x.OrderNumber.StartsWith(prefix)
            );

            return $"{prefix}{(todayOrders + 1):D4}";
        }

        private async Task CheckOrderNumberUniqueAsync(string orderNumber)
        {
            if (await _orderRepository.AnyAsync(x => x.OrderNumber == orderNumber))
            {
                throw new OrderNumberAlreadyExistsException(orderNumber);
            }
        }

        private async Task ValidateTableAvailabilityAsync(Guid tableId)
        {
            // Check if table has active orders
            var hasActiveOrder = await _orderRepository.AnyAsync(
                x => x.TableId == tableId && 
                     x.Status != OrderStatus.Paid && 
                     x.Status != OrderStatus.Cancelled
            );

            if (hasActiveOrder)
            {
                throw new TableNotAvailableException(tableId);
            }
        }
    }
}
```

## 3. 💾 Data Layer

### Custom Repository Interface (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Orders/IOrderRepository.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Orders
{
    public interface IOrderRepository : IRepository<Order, Guid>
    {
        Task<List<Order>> GetListAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string filter = null
        );

        Task<List<Order>> GetByTableIdAsync(Guid tableId);
        Task<List<Order>> GetByStatusAsync(OrderStatus status);
        Task<Order?> GetActiveOrderByTableAsync(Guid tableId);
        Task<bool> IsOrderNumberExistsAsync(string orderNumber);
        Task<List<Order>> GetTodayOrdersAsync();
        Task<int> GetTodayOrderCountAsync();
        
        // Performance queries
        Task<Order> GetWithItemsAsync(Guid id);
        Task<Order> GetWithFullDetailsAsync(Guid id);
        
        // Business validations
        Task<bool> HasActiveOrderAsync(Guid tableId);
        Task<string> GenerateOrderNumberAsync();
        Task<decimal> GetTotalRevenueByDateAsync(DateTime date);
        Task<int> GetOrderCountByStatusAsync(OrderStatus status, DateTime date);
        Task<List<Order>> GetPendingOrdersAsync();
    }
}
```

### EF Core Repository Implementation (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.EntityFrameworkCore/Orders/EfCoreOrderRepository.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.Orders
{
    public class EfCoreOrderRepository : EfCoreRepository<SmartRestaurantDbContext, Order, Guid>, IOrderRepository
    {
        public EfCoreOrderRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        public async Task<List<Order>> GetListAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string filter = null)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet
                .Include(x => x.Items) // Load navigation properties for Level 2
                .AsQueryable();

            // Apply filtering
            if (!string.IsNullOrWhiteSpace(filter))
            {
                query = query.Where(x => x.OrderNumber.Contains(filter));
            }

            // Apply sorting
            query = query.OrderBy(sorting.IsNullOrEmpty() ? "OrderTime DESC" : sorting);

            // Apply paging
            return await query.Skip(skipCount).Take(maxResultCount).ToListAsync();
        }

        public async Task<Order> GetWithItemsAsync(Guid id)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Items)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<Order> GetWithFullDetailsAsync(Guid id)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Items)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<List<Order>> GetTodayOrdersAsync()
        {
            var today = DateTime.Today;
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Items)
                .Where(x => x.OrderTime.Date == today)
                .OrderByDescending(x => x.OrderTime)
                .ToListAsync();
        }

        public async Task<bool> HasActiveOrderAsync(Guid tableId)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet.AnyAsync(
                x => x.TableId == tableId && 
                     x.Status != OrderStatus.Paid && 
                     x.Status != OrderStatus.Cancelled
            );
        }

        public async Task<string> GenerateOrderNumberAsync()
        {
            var today = DateTime.Today;
            var prefix = $"ORD{today:yyyyMMdd}";
            
            var dbSet = await GetDbSetAsync();
            var todayOrders = await dbSet.CountAsync(
                x => x.OrderNumber.StartsWith(prefix)
            );

            return $"{prefix}{(todayOrders + 1):D4}";
        }

        public async Task<decimal> GetTotalRevenueByDateAsync(DateTime date)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Where(x => x.OrderTime.Date == date.Date && x.Status == OrderStatus.Paid)
                .SumAsync(x => x.TotalAmount);
        }

        public async Task<List<Order>> GetPendingOrdersAsync()
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Items)
                .Where(x => x.Status == OrderStatus.Confirmed || x.Status == OrderStatus.Preparing)
                .OrderBy(x => x.OrderTime)
                .ToListAsync();
        }
    }
}
```

### Navigation Properties Strategy (Level 2)
```csharp
public class Order : FullAuditedAggregateRoot<Guid>
{
    // Foreign keys for simple references
    public Guid TableId { get; private set; }
    public Guid? CustomerId { get; private set; }
    
    // Collection navigation property for business logic operations
    public virtual ICollection<OrderItem> Items { get; private set; }
    
    // Business methods using the collection
    public OrderItem AddItem(Guid menuItemId, int quantity, decimal unitPrice, string notes = null)
    {
        var orderItem = new OrderItem(GuidGenerator.Create(), Id, menuItemId, quantity, unitPrice, notes);
        Items.Add(orderItem);
        RecalculateTotal();
        return orderItem;
    }
}
```

### EF Core Configuration (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.EntityFrameworkCore/EntityFrameworkCore/SmartRestaurantDbContext.cs
public DbSet<Order> Orders { get; set; }
public DbSet<OrderItem> OrderItems { get; set; }

// In OnModelCreating method:
protected override void OnModelCreating(ModelBuilder builder)
{
    base.OnModelCreating(builder);

    builder.Entity<Order>(b =>
    {
        b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Orders", SmartRestaurantConsts.DbSchema);
        b.ConfigureByConvention();

        b.Property(x => x.OrderNumber).IsRequired().HasMaxLength(OrderConsts.MaxOrderNumberLength);
        b.Property(x => x.Notes).HasMaxLength(OrderConsts.MaxNotesLength);
        b.Property(x => x.SubTotal).HasColumnType("decimal(18,2)");
        b.Property(x => x.TaxAmount).HasColumnType("decimal(18,2)");
        b.Property(x => x.ServiceFee).HasColumnType("decimal(18,2)");
        b.Property(x => x.DiscountAmount).HasColumnType("decimal(18,2)");
        b.Property(x => x.TotalAmount).HasColumnType("decimal(18,2)");

        // Indexes for performance
        b.HasIndex(x => x.OrderNumber).IsUnique();
        b.HasIndex(x => x.TableId);
        b.HasIndex(x => x.Status);
        b.HasIndex(x => x.OrderTime);

        // Navigation property configuration (Level 2)
        b.HasMany(x => x.Items)
            .WithOne()
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Cascade);
    });

    builder.Entity<OrderItem>(b =>
    {
        b.ToTable(SmartRestaurantConsts.DbTablePrefix + "OrderItems", SmartRestaurantConsts.DbSchema);
        b.ConfigureByConvention();

        b.Property(x => x.UnitPrice).HasColumnType("decimal(18,2)").IsRequired();
        b.Property(x => x.TotalPrice).HasColumnType("decimal(18,2)").IsRequired();
        b.Property(x => x.Notes).HasMaxLength(500);

        b.HasIndex(x => x.OrderId);
        b.HasIndex(x => x.MenuItemId);
    });
}
```

## 4. 🔗 Application Contracts

### Input DTOs (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Orders/Dto/GetOrderListDto.cs
public class GetOrderListDto : PagedAndSortedResultRequestDto
{
    public string? Filter { get; set; }
    public OrderStatus? Status { get; set; }
    public Guid? TableId { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
}

// CreateOrderDto.cs
public class CreateOrderDto
{
    [Required]
    public Guid TableId { get; set; }
    
    public Guid? CustomerId { get; set; }
    
    [StringLength(OrderConsts.MaxNotesLength)]
    public string? Notes { get; set; }
}

// Business DTOs
public class AddOrderItemDto
{
    [Required]
    public Guid MenuItemId { get; set; }
    
    [Range(1, int.MaxValue)]
    public int Quantity { get; set; }
    
    [Range(0, double.MaxValue)]
    public decimal UnitPrice { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
}

public class ChangeOrderStatusDto
{
    [Required]
    public OrderStatus NewStatus { get; set; }
    
    public string? Reason { get; set; }
}
```

### Output DTOs (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Orders/Dto/OrderDto.cs
public class OrderDto : EntityDto<Guid>
{
    public string OrderNumber { get; set; }
    public Guid TableId { get; set; }
    public Guid? CustomerId { get; set; }
    public OrderStatus Status { get; set; }
    public string StatusText { get; set; } // Computed property
    public string Notes { get; set; }
    public decimal SubTotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal ServiceFee { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime OrderTime { get; set; }
    public DateTime? ServedTime { get; set; }
    public DateTime? PaidTime { get; set; }
    public DateTime CreationTime { get; set; }
    
    // Business properties
    public int ItemCount { get; set; } // Computed from Items.Count
    public List<OrderItemDto> Items { get; set; } = new();
}

public class OrderItemDto : EntityDto<Guid>
{
    public Guid OrderId { get; set; }
    public Guid MenuItemId { get; set; }
    public string MenuItemName { get; set; } // From navigation
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; } // Computed
    public string Notes { get; set; }
}

// Stats DTOs
public class OrderStatsDto
{
    public DateTime Date { get; set; }
    public int TotalOrders { get; set; }
    public int PendingOrders { get; set; }
    public decimal TotalRevenue { get; set; }
}
```

### Application Service Interface (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Orders/IOrderAppService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Orders
{
    public interface IOrderAppService : IApplicationService
    {
        // Basic CRUD
        Task<PagedResultDto<OrderDto>> GetListAsync(GetOrderListDto input);
        Task<OrderDto> GetAsync(Guid id);
        Task<OrderDto> CreateAsync(CreateOrderDto input);
        Task DeleteAsync(Guid id);

        // Business Methods
        Task<OrderDto> AddItemAsync(Guid orderId, AddOrderItemDto input);
        Task<OrderDto> RemoveItemAsync(Guid orderId, Guid orderItemId);
        Task<OrderDto> ConfirmOrderAsync(Guid orderId);
        Task<OrderDto> ChangeStatusAsync(Guid orderId, ChangeOrderStatusDto input);
        Task<OrderDto> ApplyDiscountAsync(Guid orderId, decimal discountAmount);

        // Business Queries
        Task<decimal> CalculateTotalAsync(Guid orderId);
        Task<List<OrderDto>> GetTodayOrdersAsync();
        Task<List<OrderDto>> GetPendingOrdersAsync();
        Task<decimal> GetTotalRevenueAsync(DateTime date);
        Task<OrderStatsDto> GetOrderStatsAsync(DateTime date);
        Task<List<OrderDto>> GetOrdersByTableAsync(Guid tableId);
    }
}
```

## 5. 🚀 Application Layer

### Application Service Implementation (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Orders/OrderAppService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Orders.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.EventBus.Local;

namespace SmartRestaurant.Orders
{
    [Authorize(SmartRestaurantPermissions.Orders.Default)]
    public class OrderAppService : ApplicationService, IOrderAppService
    {
        private readonly IOrderRepository _orderRepository;
        private readonly OrderManager _orderManager;
        private readonly ILocalEventBus _localEventBus;

        public OrderAppService(
            IOrderRepository orderRepository,
            OrderManager orderManager,
            ILocalEventBus localEventBus)
        {
            _orderRepository = orderRepository;
            _orderManager = orderManager;
            _localEventBus = localEventBus;
        }

        // Level 2 - Use custom repository methods
        public async Task<PagedResultDto<OrderDto>> GetListAsync(GetOrderListDto input)
        {
            if (input.Sorting.IsNullOrWhiteSpace())
            {
                input.Sorting = nameof(Order.OrderTime) + " DESC";
            }

            var orders = await _orderRepository.GetListAsync(
                input.SkipCount,
                input.MaxResultCount,
                input.Sorting,
                input.Filter
            );

            var totalCount = input.Filter == null
                ? await _orderRepository.CountAsync()
                : await _orderRepository.CountAsync(
                    x => x.OrderNumber.Contains(input.Filter));

            return new PagedResultDto<OrderDto>(
                totalCount,
                ObjectMapper.Map<List<Order>, List<OrderDto>>(orders)
            );
        }

        public async Task<OrderDto> GetAsync(Guid id)
        {
            var order = await _orderRepository.GetWithFullDetailsAsync(id);
            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        [Authorize(SmartRestaurantPermissions.Orders.Create)]
        public async Task<OrderDto> CreateAsync(CreateOrderDto input)
        {
            // Use domain service for complex creation logic
            var orderNumber = await _orderRepository.GenerateOrderNumberAsync();
            var order = await _orderManager.CreateOrderAsync(
                orderNumber,
                input.TableId,
                input.CustomerId,
                input.Notes
            );

            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        [Authorize(SmartRestaurantPermissions.Orders.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            await _orderRepository.DeleteAsync(id);
        }

        // Business Methods
        [Authorize(SmartRestaurantPermissions.Orders.Edit)]
        public async Task<OrderDto> AddItemAsync(Guid orderId, AddOrderItemDto input)
        {
            var order = await _orderRepository.GetWithItemsAsync(orderId);

            order.AddItem(input.MenuItemId, input.Quantity, input.UnitPrice, input.Notes);

            await _orderRepository.UpdateAsync(order, autoSave: true);

            // Domain event
            await _localEventBus.PublishAsync(new OrderItemAddedEvent
            {
                OrderId = orderId,
                MenuItemId = input.MenuItemId,
                Quantity = input.Quantity
            });

            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        [Authorize(SmartRestaurantPermissions.Orders.Edit)]
        public async Task<OrderDto> RemoveItemAsync(Guid orderId, Guid orderItemId)
        {
            var order = await _orderRepository.GetWithItemsAsync(orderId);

            order.RemoveItem(orderItemId);

            await _orderRepository.UpdateAsync(order, autoSave: true);

            await _localEventBus.PublishAsync(new OrderItemRemovedEvent
            {
                OrderId = orderId,
                OrderItemId = orderItemId
            });

            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        [Authorize(SmartRestaurantPermissions.Orders.Process)]
        public async Task<OrderDto> ConfirmOrderAsync(Guid orderId)
        {
            var order = await _orderRepository.GetAsync(orderId);

            order.ConfirmOrder();

            await _orderRepository.UpdateAsync(order, autoSave: true);

            // Notify kitchen
            await _localEventBus.PublishAsync(new OrderConfirmedEvent 
            { 
                OrderId = orderId,
                TableId = order.TableId 
            });

            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        [Authorize(SmartRestaurantPermissions.Orders.Process)]
        public async Task<OrderDto> ChangeStatusAsync(Guid orderId, ChangeOrderStatusDto input)
        {
            var order = await _orderRepository.GetAsync(orderId);
            var oldStatus = order.Status;

            switch (input.NewStatus)
            {
                case OrderStatus.Confirmed:
                    order.ConfirmOrder();
                    break;
                case OrderStatus.Preparing:
                    order.StartPreparing();
                    break;
                case OrderStatus.Served:
                    order.CompleteServing();
                    break;
                case OrderStatus.Paid:
                    order.ProcessPayment();
                    break;
                case OrderStatus.Cancelled:
                    order.CancelOrder(input.Reason ?? "Không có lý do");
                    break;
                default:
                    throw new ArgumentException($"Trạng thái {input.NewStatus} không được hỗ trợ");
            }

            await _orderRepository.UpdateAsync(order, autoSave: true);

            await _localEventBus.PublishAsync(new OrderStatusChangedEvent
            {
                OrderId = orderId,
                OldStatus = oldStatus,
                NewStatus = input.NewStatus,
                Reason = input.Reason
            });

            return ObjectMapper.Map<Order, OrderDto>(order);
        }

        // Business Queries
        public async Task<decimal> CalculateTotalAsync(Guid orderId)
        {
            var order = await _orderRepository.GetWithItemsAsync(orderId);
            return order.TotalAmount;
        }

        public async Task<List<OrderDto>> GetTodayOrdersAsync()
        {
            var orders = await _orderRepository.GetTodayOrdersAsync();
            return ObjectMapper.Map<List<Order>, List<OrderDto>>(orders);
        }

        public async Task<List<OrderDto>> GetPendingOrdersAsync()
        {
            var orders = await _orderRepository.GetPendingOrdersAsync();
            return ObjectMapper.Map<List<Order>, List<OrderDto>>(orders);
        }

        public async Task<decimal> GetTotalRevenueAsync(DateTime date)
        {
            return await _orderRepository.GetTotalRevenueByDateAsync(date);
        }

        public async Task<OrderStatsDto> GetOrderStatsAsync(DateTime date)
        {
            return new OrderStatsDto
            {
                TotalOrders = await _orderRepository.GetOrderCountByStatusAsync(OrderStatus.Paid, date),
                PendingOrders = await _orderRepository.GetOrderCountByStatusAsync(OrderStatus.Confirmed, date) +
                               await _orderRepository.GetOrderCountByStatusAsync(OrderStatus.Preparing, date),
                TotalRevenue = await _orderRepository.GetTotalRevenueByDateAsync(date),
                Date = date
            };
        }
    }
}
```

### AutoMapper Profile (Level 2)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Orders/OrderApplicationAutoMapperProfile.cs
using AutoMapper;

namespace SmartRestaurant.Orders
{
    public class OrderApplicationAutoMapperProfile : Profile
    {
        public OrderApplicationAutoMapperProfile()
        {
            // Entity to DTO (includes complex relationships)
            CreateMap<Order, OrderDto>()
                .ForMember(dest => dest.ItemCount, opt => opt.MapFrom(src => src.Items.Count))
                .ForMember(dest => dest.StatusText, opt => opt.MapFrom(src => GetStatusText(src.Status)))
                .ForMember(dest => dest.Items, opt => opt.MapFrom(src => src.Items));

            CreateMap<OrderItem, OrderItemDto>()
                .ForMember(dest => dest.TotalPrice, opt => opt.MapFrom(src => src.Quantity * src.UnitPrice));

            // Create DTOs (no direct entity mapping - use domain service)
            CreateMap<CreateOrderDto, Order>().ConvertUsing<CreateOrderDtoToOrderConverter>();
            
            CreateMap<UpdateOrderDto, Order>()
                .ForAllMembers(opt => opt.Ignore()); // Use domain methods

            // Lookup DTOs
            CreateMap<Order, OrderLookupDto>()
                .ForMember(dest => dest.DisplayText, opt => opt.MapFrom(src => 
                    $"{src.OrderNumber} - {src.TotalAmount:C}"));
        }

        private static string GetStatusText(OrderStatus status)
        {
            return status switch
            {
                OrderStatus.Draft => "Đang soạn thảo",
                OrderStatus.Confirmed => "Đã xác nhận", 
                OrderStatus.Preparing => "Đang chế biến",
                OrderStatus.Served => "Đã phục vụ",
                OrderStatus.Paid => "Đã thanh toán",
                OrderStatus.Cancelled => "Đã hủy",
                _ => "Không xác định"
            };
        }
    }

    // Custom converter for complex creation logic
    public class CreateOrderDtoToOrderConverter : ITypeConverter<CreateOrderDto, Order>
    {
        public Order Convert(CreateOrderDto source, Order destination, ResolutionContext context)
        {
            // This should not be used directly - use OrderManager domain service instead
            throw new InvalidOperationException("Use OrderManager.CreateOrderAsync for order creation");
        }
    }
}
```

## 6. ⚡ Domain Events

### Domain Event Classes
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Orders/Events.cs
namespace SmartRestaurant.Orders
{
    public class OrderCreatedEvent
    {
        public Order Order { get; set; }
    }

    public class OrderConfirmedEvent
    {
        public Guid OrderId { get; set; }
        public Guid TableId { get; set; }
        public List<OrderItem> Items { get; set; }
    }

    public class OrderItemAddedEvent
    {
        public Guid OrderId { get; set; }
        public Guid MenuItemId { get; set; }
        public int Quantity { get; set; }
    }

    public class OrderStatusChangedEvent
    {
        public Guid OrderId { get; set; }
        public OrderStatus OldStatus { get; set; }
        public OrderStatus NewStatus { get; set; }
        public string Reason { get; set; }
    }
}
```

### Event Handlers
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Orders/OrderEventHandler.cs
using System.Threading.Tasks;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;

namespace SmartRestaurant.Orders
{
    public class OrderEventHandler : ILocalEventHandler<OrderConfirmedEvent>, ITransientDependency
    {
        public async Task HandleEventAsync(OrderConfirmedEvent eventData)
        {
            // Send notification to kitchen
            // Log business activity
            // Update inventory
            // etc.
        }
    }
}
```

## 7. 🧪 Testing

### Application Service Tests (Level 2)
```csharp
// File: aspnet-core/test/SmartRestaurant.Application.Tests/Orders/OrderAppServiceTests.cs
public class OrderAppServiceTests : SmartRestaurantApplicationTestBase
{
    private readonly IOrderAppService _orderAppService;
    private readonly IOrderRepository _orderRepository;

    public OrderAppServiceTests()
    {
        _orderAppService = GetRequiredService<IOrderAppService>();
        _orderRepository = GetRequiredService<IOrderRepository>();
    }

    [Fact]
    public async Task Should_Create_Order_With_Valid_Input()
    {
        // Arrange
        var input = new CreateOrderDto
        {
            TableId = Guid.NewGuid(),
            Notes = "Test order"
        };

        // Act
        var result = await _orderAppService.CreateAsync(input);

        // Assert
        result.Id.ShouldNotBe(Guid.Empty);
        result.TableId.ShouldBe(input.TableId);
        result.Status.ShouldBe(OrderStatus.Draft);
    }

    [Fact]
    public async Task Should_Add_Item_To_Draft_Order()
    {
        // Arrange
        var order = await CreateTestOrderAsync();
        var addItemInput = new AddOrderItemDto
        {
            MenuItemId = Guid.NewGuid(),
            Quantity = 2,
            UnitPrice = 50000
        };

        // Act
        var result = await _orderAppService.AddItemAsync(order.Id, addItemInput);

        // Assert
        result.Items.ShouldContain(x => x.MenuItemId == addItemInput.MenuItemId);
        result.ItemCount.ShouldBe(1);
        result.SubTotal.ShouldBe(100000); // 2 * 50000
    }
}
```

## 8. 🔄 Migration Path

1. **Start với Level 1**: Basic CRUD cho simple entities
2. **Migrate lên Level 2**: Khi cần business logic, calculations, state management
3. **Migrate lên [Level 3](./backend-template-level3.md)**: Khi cần real-time, external integration, complex workflows

## 📊 Comparison Table

| Level | Framework | Navigation Props | Repository | Use Case |
|-------|-----------|-----------------|------------|----------|
| Level 1 | ICrudAppService | ❌ Foreign keys only | Built-in | Master data |
| **Level 2** | IApplicationService | ✅ Strategic collections | Custom + Built-in | Business logic |
| Level 3 | IApplicationService + Dependencies | ✅ Complex relationships | Advanced custom | Complex workflows |

## ⚡ Performance Considerations

- Use `Include()` strategically for navigation properties
- Implement proper indexes for business queries
- Use custom repository methods for performance-critical operations
- Consider read-only DTOs for reporting queries
- Implement caching for frequently accessed business data