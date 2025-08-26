# Level 3: Complex Business Template (Core Workflow Entities)

## 🚀 Overview

**Khi nào dùng**: Entity điều khiển workflow chính, tích hợp nhiều systems
**Phù hợp cho**: Table (với realtime status), MenuItem (với pricing rules), Kitchen Operations...
**Framework**: Kế thừa từ `IApplicationService` với nhiều dependencies injection
**APIs**: Full business workflow

- `CheckAvailabilityAsync()`, `AssignResourcesAsync()`, `ProcessWorkflowAsync()`
- `GenerateReportsAsync()`, `IntegrateWithExternalAsync()`, `NotifyStakeholdersAsync()`
- `HandleExceptionsAsync()`, `RecoverFromFailureAsync()`

**Đặc điểm**:
- Complex domain services injection
- Real-time updates (SignalR IHubContext)
- External system integration
- Advanced caching strategies (IDistributedCache)
- Background job processing (IBackgroundJobManager)
- Comprehensive audit logging
- **Lý do không dùng ICrudAppService**: Workflow phức tạp, nhiều external dependencies

## ✅ When to Use Level 3

**Level 3 (Complex Business + IApplicationService)**:
- ✅ Table, MenuItem (với pricing), Kitchen Operations, Real-time entities
- ✅ Entities cần SignalR, caching, background jobs  
- ✅ Entities với complex domain services
- ❌ Không dùng cho: Simple transactional data

## 1. 📁 File Structure

```
aspnet-core/
├── src/SmartRestaurant.Domain.Shared/
│   ├── Entities/{Module}/{EntityName}Consts.cs
│   ├── SmartRestaurantDomainErrorCodes.cs
│   └── {Module}/Events/*.cs
├── src/SmartRestaurant.Domain/
│   ├── Entities/{Module}/{EntityName}.cs
│   ├── {Module}/{EntityName}Manager.cs (Complex Domain Service)
│   ├── {Module}/I{EntityName}Repository.cs
│   ├── {Module}/Services/*.cs (Domain Services)
│   └── {Module}/Events/*.cs (Event Handlers)
├── src/SmartRestaurant.EntityFrameworkCore/
│   ├── EntityFrameworkCore/SmartRestaurantDbContext.cs
│   └── {Module}/EfCore{EntityName}Repository.cs
├── src/SmartRestaurant.Application.Contracts/
│   └── {Module}/
│       ├── I{EntityName}AppService.cs
│       └── Dto/
│           ├── {EntityName}Dto.cs
│           ├── {EntityName}DetailDto.cs
│           ├── {EntityName}ListDto.cs
│           └── Input/*.cs (Complex input DTOs)
└── src/SmartRestaurant.Application/
    └── {Module}/
        ├── {EntityName}AppService.cs
        ├── {EntityName}ApplicationAutoMapperProfile.cs
        └── EventHandlers/{EntityName}EventHandler.cs
```

## 2. 🏗️ Domain Layer

### Domain Error Codes (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/SmartRestaurantDomainErrorCodes.cs
namespace SmartRestaurant
{
    public static class SmartRestaurantDomainErrorCodes
    {
        // Table specific (Level 3)
        public const string TableAlreadyOccupied = "SmartRestaurant:02001";
        public const string TableNotFound = "SmartRestaurant:02002";
        public const string NoTablesAvailable = "SmartRestaurant:02003";
        public const string TableOutOfOrder = "SmartRestaurant:02004";
        public const string TableInMaintenance = "SmartRestaurant:02005";
        public const string CannotReleaseEmptyTable = "SmartRestaurant:02006";
        public const string MaintenanceAlreadyInProgress = "SmartRestaurant:02007";
    }
}
```

### Domain Entity Template (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Entities/Tables/Table.cs
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.Entities.Orders;
using SmartRestaurant.Entities.Reservations;

namespace SmartRestaurant.Entities.Tables
{
    /// <summary>Bàn ăn trong nhà hàng với real-time status management</summary>
    public class Table : FullAuditedEntity<Guid>, ITableAvailabilityChecker
    {
        /// <summary>Số bàn (unique trong layout section)</summary>
        [Required]
        [MaxLength(20)]
        public string TableNumber { get; private set; }

        /// <summary>ID khu vực bố cục</summary>
        public Guid LayoutSectionId { get; private set; }

        /// <summary>Số chỗ ngồi tối đa</summary>
        public int MaxSeatingCapacity { get; private set; }

        /// <summary>Trạng thái hiện tại của bàn</summary>
        public TableStatus Status { get; private set; }

        /// <summary>Số khách hiện tại (cho occupied status)</summary>
        public int CurrentGuestCount { get; private set; }

        /// <summary>ID nhân viên phục vụ được assign</summary>
        public Guid? AssignedWaiterId { get; private set; }

        /// <summary>Thời gian bắt đầu phục vụ (khi status = Occupied)</summary>
        public DateTime? ServiceStartTime { get; private set; }

        /// <summary>Thời gian dự kiến kết thúc</summary>
        public DateTime? EstimatedEndTime { get; private set; }

        /// <summary>QR Code cho table ordering</summary>
        public string? QRCode { get; private set; }

        /// <summary>Ghi chú đặc biệt (VIP, gần cửa sổ, wheelchair accessible...)</summary>
        [MaxLength(500)]
        public string? SpecialNotes { get; private set; }

        /// <summary>Tọa độ X trên layout (pixels)</summary>
        public int PositionX { get; private set; }

        /// <summary>Tọa độ Y trên layout (pixels)</summary>
        public int PositionY { get; private set; }

        /// <summary>Thứ tự hiển thị trong section</summary>
        public int DisplayOrder { get; private set; }

        /// <summary>Bàn có đang hoạt động hay không</summary>
        public bool IsActive { get; private set; }

        /// <summary>Cấu hình pricing cho bàn VIP</summary>
        public TablePricingConfig? PricingConfig { get; private set; }

        // Complex navigation properties (Level 3)
        /// <summary>Khu vực bố cục</summary>
        public virtual LayoutSection LayoutSection { get; set; }

        /// <summary>Nhân viên phục vụ được assign</summary>
        public virtual Employee? AssignedWaiter { get; set; }

        /// <summary>Đơn hàng hiện tại (chỉ có 1 active order)</summary>
        public virtual Order? CurrentOrder { get; set; }

        /// <summary>Tất cả đơn hàng lịch sử</summary>
        public virtual ICollection<Order> Orders { get; private set; }

        /// <summary>Đặt bàn hiện tại và tương lai</summary>
        public virtual ICollection<Reservation> Reservations { get; private set; }

        /// <summary>Lịch sử thay đổi trạng thái</summary>
        public virtual ICollection<TableStatusHistory> StatusHistory { get; private set; }

        /// <summary>Báo cáo sự cố kỹ thuật</summary>
        public virtual ICollection<TableIssueReport> IssueReports { get; private set; }

        protected Table()
        {
            Orders = new HashSet<Order>();
            Reservations = new HashSet<Reservation>();
            StatusHistory = new HashSet<TableStatusHistory>();
            IssueReports = new HashSet<TableIssueReport>();
        }

        public Table(
            Guid id,
            string tableNumber,
            Guid layoutSectionId,
            int maxSeatingCapacity,
            int positionX,
            int positionY,
            int displayOrder = 0,
            string? specialNotes = null
        ) : base(id)
        {
            SetTableNumber(tableNumber);
            LayoutSectionId = layoutSectionId;
            MaxSeatingCapacity = maxSeatingCapacity;
            PositionX = positionX;
            PositionY = positionY;
            DisplayOrder = displayOrder;
            SpecialNotes = specialNotes;

            Status = TableStatus.Available;
            CurrentGuestCount = 0;
            IsActive = true;

            Orders = new HashSet<Order>();
            Reservations = new HashSet<Reservation>();
            StatusHistory = new HashSet<TableStatusHistory>();
            IssueReports = new HashSet<TableIssueReport>();

            GenerateQRCode();
            AddStatusHistory(TableStatus.Available, "Bàn được khởi tạo");
        }

        // Complex business methods with real-time integration
        public async Task<bool> CheckAvailabilityAsync(
            DateTime startTime,
            DateTime endTime,
            int guestCount,
            ITableAvailabilityService availabilityService)
        {
            // Check basic constraints
            if (!IsActive || guestCount > MaxSeatingCapacity)
                return false;

            // Check current status
            if (Status == TableStatus.OutOfOrder || Status == TableStatus.Maintenance)
                return false;

            // Check reservations conflict
            var conflictingReservations = Reservations.Where(r =>
                r.Status == ReservationStatus.Confirmed &&
                r.ReservationTime < endTime &&
                r.EstimatedEndTime > startTime
            );

            if (conflictingReservations.Any())
                return false;

            // Use domain service for complex availability logic
            return await availabilityService.CheckAvailabilityWithBufferTimeAsync(
                this, startTime, endTime, guestCount
            );
        }

        public void OccupyTable(int guestCount, Guid? waiterId = null, string? notes = null)
        {
            if (Status != TableStatus.Available && Status != TableStatus.Reserved)
                throw new BusinessException(SmartRestaurantDomainErrorCodes.TableAlreadyOccupied)
                    .WithData("TableId", Id)
                    .WithData("CurrentStatus", Status);

            if (guestCount > MaxSeatingCapacity)
                throw new ArgumentException($"Số khách ({guestCount}) vượt quá sức chứa tối đa ({MaxSeatingCapacity})");

            Status = TableStatus.Occupied;
            CurrentGuestCount = guestCount;
            AssignedWaiterId = waiterId;
            ServiceStartTime = DateTime.UtcNow;
            EstimatedEndTime = CalculateEstimatedEndTime(guestCount);

            AddStatusHistory(TableStatus.Occupied,
                $"Bàn được sử dụng bởi {guestCount} khách" +
                (waiterId.HasValue ? $", phục vụ bởi {waiterId}" : "") +
                (!string.IsNullOrEmpty(notes) ? $". Ghi chú: {notes}" : ""));

            // Domain event for real-time updates
            AddDomainEvent(new TableOccupiedEvent(Id, guestCount, waiterId));
        }

        public void ReleaseTable(decimal? revenue = null)
        {
            if (Status != TableStatus.Occupied && Status != TableStatus.Reserved)
                throw new BusinessException(SmartRestaurantDomainErrorCodes.CannotReleaseEmptyTable)
                    .WithData("TableId", Id)
                    .WithData("CurrentStatus", Status);

            var previousStatus = Status;
            var serviceTime = ServiceStartTime.HasValue ?
                DateTime.UtcNow - ServiceStartTime.Value :
                TimeSpan.Zero;

            Status = TableStatus.Available;
            CurrentGuestCount = 0;
            AssignedWaiterId = null;
            ServiceStartTime = null;
            EstimatedEndTime = null;

            var historyNote = $"Bàn được giải phóng sau {serviceTime.TotalMinutes:F0} phút sử dụng";
            if (revenue.HasValue)
                historyNote += $", doanh thu: {revenue:C}";

            AddStatusHistory(TableStatus.Available, historyNote);

            // Domain event for analytics and real-time updates
            AddDomainEvent(new TableReleasedEvent(Id, previousStatus, serviceTime, revenue));
        }

        public void MarkOutOfOrder(string reason, DateTime? estimatedRepairTime = null)
        {
            if (Status == TableStatus.Occupied)
                throw new BusinessException("Không thể đánh dấu bàn đang sử dụng là hỏng");

            Status = TableStatus.OutOfOrder;
            EstimatedEndTime = estimatedRepairTime;

            var issueReport = new TableIssueReport(
                GuidGenerator.Create(),
                Id,
                reason,
                IssueType.Technical,
                IssuePriority.High,
                estimatedRepairTime
            );

            IssueReports.Add(issueReport);
            AddStatusHistory(TableStatus.OutOfOrder, $"Bàn gặp sự cố: {reason}");
            
            AddDomainEvent(new TableOutOfOrderEvent(Id, reason, estimatedRepairTime));
        }

        // Real-time position updates
        public void UpdatePosition(int newX, int newY)
        {
            PositionX = newX;
            PositionY = newY;

            // Real-time layout update event
            AddDomainEvent(new TablePositionChangedEvent(Id, newX, newY));
        }

        // Analytics and reporting methods
        public TableUtilizationStats CalculateUtilizationStats(DateTime fromDate, DateTime toDate)
        {
            var relevantHistory = StatusHistory.Where(h =>
                h.ChangedAt >= fromDate && h.ChangedAt <= toDate
            ).OrderBy(h => h.ChangedAt).ToList();

            if (!relevantHistory.Any())
                return new TableUtilizationStats { TableId = Id };

            var totalMinutes = (toDate - fromDate).TotalMinutes;
            var occupiedMinutes = 0.0;
            var reservedMinutes = 0.0;
            var outOfOrderMinutes = 0.0;

            for (int i = 0; i < relevantHistory.Count - 1; i++)
            {
                var duration = (relevantHistory[i + 1].ChangedAt - relevantHistory[i].ChangedAt).TotalMinutes;

                switch (relevantHistory[i].NewStatus)
                {
                    case TableStatus.Occupied:
                        occupiedMinutes += duration;
                        break;
                    case TableStatus.Reserved:
                        reservedMinutes += duration;
                        break;
                    case TableStatus.OutOfOrder:
                    case TableStatus.Maintenance:
                        outOfOrderMinutes += duration;
                        break;
                }
            }

            return new TableUtilizationStats
            {
                TableId = Id,
                TableNumber = TableNumber,
                TotalMinutes = totalMinutes,
                OccupiedMinutes = occupiedMinutes,
                ReservedMinutes = reservedMinutes,
                OutOfOrderMinutes = outOfOrderMinutes,
                UtilizationRate = occupiedMinutes / totalMinutes * 100,
                AvailabilityRate = (totalMinutes - outOfOrderMinutes) / totalMinutes * 100
            };
        }

        // External integration methods
        public async Task<string> GenerateDigitalMenuLinkAsync(IQRCodeService qrService)
        {
            if (string.IsNullOrEmpty(QRCode))
                GenerateQRCode();

            var menuUrl = $"https://restaurant.com/menu/{QRCode}";
            await qrService.GenerateQRCodeAsync(QRCode, menuUrl);

            return menuUrl;
        }

        // Private helper methods
        private DateTime CalculateEstimatedEndTime(int guestCount)
        {
            // Business logic: estimate based on guest count and historical data
            var baseMinutes = guestCount <= 2 ? 60 : guestCount <= 4 ? 90 : 120;

            // Apply pricing config modifiers for VIP tables
            if (PricingConfig?.IsVipTable == true)
                baseMinutes = (int)(baseMinutes * 1.3); // VIP gets 30% more time

            return DateTime.UtcNow.AddMinutes(baseMinutes);
        }

        private void GenerateQRCode()
        {
            QRCode = $"TBL_{TableNumber}_{Guid.NewGuid().ToString("N")[..8]}".ToUpper();
        }

        private void AddStatusHistory(TableStatus newStatus, string note)
        {
            StatusHistory.Add(new TableStatusHistory(
                GuidGenerator.Create(),
                Id,
                Status,
                newStatus,
                note
            ));
        }

        private void SetTableNumber(string tableNumber)
        {
            TableNumber = Check.NotNullOrWhiteSpace(tableNumber, nameof(tableNumber), 20);
        }
    }

    /// <summary>Trạng thái bàn ăn</summary>
    public enum TableStatus
    {
        /// <summary>Có sẵn</summary>
        Available = 0,
        /// <summary>Đã đặt trước</summary>
        Reserved = 1,
        /// <summary>Đang sử dụng</summary>
        Occupied = 2,
        /// <summary>Hỏng hóc</summary>
        OutOfOrder = -1,
        /// <summary>Đang bảo trì</summary>
        Maintenance = -2
    }

    /// <summary>Cấu hình pricing cho bàn</summary>
    public class TablePricingConfig
    {
        public bool IsVipTable { get; set; }
        public decimal? ServiceFeeMultiplier { get; set; }
        public decimal? MinimumSpend { get; set; }
        public TimeSpan? MaximumStayDuration { get; set; }
    }
}
```

### Complex Domain Manager (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Tables/TableManager.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Distributed;
using SmartRestaurant.Entities.Tables;
using Volo.Abp.Domain.Services;

namespace SmartRestaurant.Tables
{
    /// <summary>Domain Manager cho complex table management logic</summary>
    public class TableManager : DomainService
    {
        private readonly ITableRepository _tableRepository;
        private readonly IOrderRepository _orderRepository;
        private readonly IReservationRepository _reservationRepository;
        private readonly IDistributedCache _cache;

        public TableManager(
            ITableRepository tableRepository,
            IOrderRepository orderRepository,
            IReservationRepository reservationRepository,
            IDistributedCache cache)
        {
            _tableRepository = tableRepository;
            _orderRepository = orderRepository;
            _reservationRepository = reservationRepository;
            _cache = cache;
        }

        public async Task<bool> CheckAvailabilityWithBufferTimeAsync(
            Table table,
            DateTime startTime,
            DateTime endTime,
            int guestCount)
        {
            // Get buffer time from configuration (e.g., 15 minutes between bookings)
            var bufferTime = TimeSpan.FromMinutes(15);
            var checkStartTime = startTime.Subtract(bufferTime);
            var checkEndTime = endTime.Add(bufferTime);

            // Check historical service time patterns
            var avgServiceTime = await CalculateAverageServiceTimeAsync(table);
            if (avgServiceTime > (endTime - startTime))
            {
                // Estimated service time exceeds requested duration
                return false;
            }

            // Check for overlapping reservations with buffer
            var overlappingReservations = await _reservationRepository.GetOverlappingReservationsAsync(
                table.Id, checkStartTime, checkEndTime);

            return !overlappingReservations.Any();
        }

        public async Task<List<Table>> FindAvailableTablesAsync(
            DateTime startTime,
            DateTime endTime,
            int guestCount,
            Guid? preferredSectionId = null)
        {
            var allTables = await _tableRepository.GetTablesForCapacityAsync(guestCount, preferredSectionId);
            var availableTables = new List<Table>();

            foreach (var table in allTables)
            {
                if (await CheckAvailabilityWithBufferTimeAsync(table, startTime, endTime, guestCount))
                {
                    availableTables.Add(table);
                }
            }

            return availableTables.OrderBy(t => t.DisplayOrder).ToList();
        }

        public async Task<Table?> FindBestTableAsync(
            DateTime startTime,
            DateTime endTime,
            int guestCount,
            TableSelectionCriteria criteria)
        {
            var availableTables = await FindAvailableTablesAsync(startTime, endTime, guestCount, criteria.PreferredSectionId);

            if (!availableTables.Any())
                return null;

            // Apply selection criteria
            return criteria.SelectionStrategy switch
            {
                TableSelectionStrategy.SmallestSuitable => availableTables.OrderBy(t => t.MaxSeatingCapacity).First(),
                TableSelectionStrategy.LargestAvailable => availableTables.OrderByDescending(t => t.MaxSeatingCapacity).First(),
                TableSelectionStrategy.BestLocation => availableTables.OrderBy(t => CalculateLocationScore(t)).First(),
                TableSelectionStrategy.QuickestService => availableTables.OrderBy(t => CalculateAverageServiceTimeAsync(t).Result).First(),
                _ => availableTables.First()
            };
        }

        public async Task<TimeSpan> CalculateAverageServiceTimeAsync(Table table)
        {
            var cacheKey = $"avg_service_time_{table.Id}";
            var cachedResult = await _cache.GetStringAsync(cacheKey);
            
            if (!string.IsNullOrEmpty(cachedResult) && TimeSpan.TryParse(cachedResult, out var cached))
            {
                return cached;
            }

            // Calculate from recent orders (last 30 days)
            var recentOrders = await _orderRepository.GetRecentCompletedOrdersAsync(
                table.Id, 
                DateTime.UtcNow.AddDays(-30)
            );

            if (!recentOrders.Any())
                return TimeSpan.FromMinutes(90); // Default estimate

            var averageMinutes = recentOrders
                .Where(o => o.PaidTime.HasValue)
                .Average(o => (o.PaidTime!.Value - o.OrderTime).TotalMinutes);

            var result = TimeSpan.FromMinutes(averageMinutes);
            
            // Cache for 1 hour
            await _cache.SetStringAsync(cacheKey, result.ToString(), 
                new DistributedCacheEntryOptions { SlidingExpiration = TimeSpan.FromHours(1) });

            return result;
        }

        private int CalculateLocationScore(Table table)
        {
            // Custom business logic for location scoring
            // Consider proximity to kitchen, windows, restrooms, etc.
            var score = 0;

            // Closer to kitchen = lower score (better for quick service)
            score += Math.Max(0, 100 - (int)Math.Sqrt(Math.Pow(table.PositionX - 50, 2) + Math.Pow(table.PositionY - 50, 2)));

            return score;
        }
    }

    // Supporting classes
    public class TableSelectionCriteria
    {
        public Guid? PreferredSectionId { get; set; }
        public TableSelectionStrategy SelectionStrategy { get; set; }
        public List<string> RequiredFeatures { get; set; } = new();
    }

    public enum TableSelectionStrategy
    {
        SmallestSuitable,
        LargestAvailable,
        BestLocation,
        QuickestService
    }
}
```

## 3. 💾 Data Layer

### Advanced Custom Repository (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Tables/ITableRepository.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Tables
{
    public interface ITableRepository : IRepository<Table, Guid>
    {
        // Basic queries with performance optimization
        Task<List<Table>> GetWithFullDetailsAsync(List<Guid> tableIds);
        Task<Table> GetWithFullDetailsAsync(Guid id);
        Task<List<Table>> GetByLayoutSectionAsync(Guid layoutSectionId);
        Task<List<Table>> GetTablesForCapacityAsync(int minCapacity, Guid? sectionId = null);

        // Real-time status queries
        Task<List<Table>> GetByStatusAsync(TableStatus status);
        Task<List<Table>> GetAvailableTablesAsync(DateTime? fromTime = null);
        Task<List<Table>> GetOccupiedTablesAsync();
        Task<List<Table>> GetTablesNeedingAttentionAsync();

        // Analytics queries
        Task<List<Table>> GetTablesWithUtilizationAsync(DateTime fromDate, DateTime toDate);
        Task<decimal> GetTotalRevenueByTableAsync(Guid tableId, DateTime fromDate, DateTime toDate);
        Task<List<TablePerformanceStats>> GetPerformanceStatsAsync(DateTime fromDate, DateTime toDate);
        Task<List<Table>> GetTopPerformingTablesAsync(DateTime fromDate, DateTime toDate, int count = 10);

        // Maintenance and issues
        Task<List<Table>> GetTablesNeedingMaintenanceAsync();
        Task<List<Table>> GetTablesWithOpenIssuesAsync();
        Task<int> GetAverageServiceTimeMinutesAsync(Guid tableId, DateTime fromDate);

        // Complex business queries
        Task<List<Table>> FindOptimalTablesForGroupAsync(int groupSize, DateTime startTime, DateTime endTime);
        Task<bool> IsTableNumberUniqueAsync(string tableNumber, Guid layoutSectionId, Guid? excludeTableId = null);
        Task<List<Table>> GetTablesRequiringWaiterAttentionAsync();
        
        // Caching support
        Task<Dictionary<Guid, TableStatus>> GetTableStatusMapAsync(List<Guid> tableIds);
        Task<List<Table>> GetTablesLastUpdatedAfterAsync(DateTime lastUpdate);
    }
}
```

### EF Core Repository Implementation (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.EntityFrameworkCore/Tables/EfCoreTableRepository.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.Tables
{
    public class EfCoreTableRepository : EfCoreRepository<SmartRestaurantDbContext, Table, Guid>, ITableRepository
    {
        private readonly IDistributedCache _cache;

        public EfCoreTableRepository(
            IDbContextProvider<SmartRestaurantDbContext> dbContextProvider,
            IDistributedCache cache)
            : base(dbContextProvider)
        {
            _cache = cache;
        }

        public async Task<Table> GetWithFullDetailsAsync(Guid id)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.LayoutSection)
                .Include(x => x.AssignedWaiter)
                .Include(x => x.CurrentOrder)
                .Include(x => x.StatusHistory.OrderByDescending(h => h.ChangedAt).Take(20))
                .Include(x => x.Orders.OrderByDescending(o => o.OrderTime).Take(10))
                .Include(x => x.Reservations.Where(r => r.ReservationTime >= DateTime.Today))
                .Include(x => x.IssueReports.Where(i => i.Status == IssueStatus.Open))
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<List<Table>> GetWithFullDetailsAsync(List<Guid> tableIds)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.LayoutSection)
                .Include(x => x.StatusHistory.OrderByDescending(h => h.ChangedAt).Take(5))
                .Include(x => x.CurrentOrder)
                .Where(x => tableIds.Contains(x.Id))
                .ToListAsync();
        }

        public async Task<List<Table>> GetTablesForCapacityAsync(int minCapacity, Guid? sectionId = null)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet
                .Where(x => x.IsActive && x.MaxSeatingCapacity >= minCapacity);

            if (sectionId.HasValue)
            {
                query = query.Where(x => x.LayoutSectionId == sectionId);
            }

            return await query.OrderBy(x => x.MaxSeatingCapacity).ToListAsync();
        }

        public async Task<List<Table>> GetAvailableTablesAsync(DateTime? fromTime = null)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet
                .Include(x => x.Reservations)
                .Where(x => x.IsActive && x.Status == TableStatus.Available);

            if (fromTime.HasValue)
            {
                // Check for conflicting reservations
                query = query.Where(x => !x.Reservations.Any(r =>
                    r.Status == ReservationStatus.Confirmed &&
                    r.ReservationTime <= fromTime.Value.AddHours(2) &&
                    r.EstimatedEndTime >= fromTime.Value
                ));
            }

            return await query.OrderBy(x => x.DisplayOrder).ToListAsync();
        }

        public async Task<List<Table>> GetTablesWithUtilizationAsync(DateTime fromDate, DateTime toDate)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.StatusHistory.Where(h => h.ChangedAt >= fromDate && h.ChangedAt <= toDate))
                .Include(x => x.Orders.Where(o => o.OrderTime >= fromDate && o.OrderTime <= toDate))
                .Where(x => x.IsActive)
                .ToListAsync();
        }

        public async Task<List<TablePerformanceStats>> GetPerformanceStatsAsync(DateTime fromDate, DateTime toDate)
        {
            var dbContext = await GetDbContextAsync();
            
            // Complex query using raw SQL for performance
            var sql = @"
                SELECT 
                    t.Id,
                    t.TableNumber,
                    COUNT(o.Id) as OrderCount,
                    COALESCE(SUM(o.TotalAmount), 0) as TotalRevenue,
                    AVG(CASE 
                        WHEN o.PaidTime IS NOT NULL AND o.OrderTime IS NOT NULL 
                        THEN DATEDIFF(minute, o.OrderTime, o.PaidTime) 
                        ELSE NULL 
                    END) as AvgServiceTimeMinutes
                FROM Tables t
                LEFT JOIN Orders o ON t.Id = o.TableId 
                    AND o.OrderTime >= @fromDate 
                    AND o.OrderTime <= @toDate
                    AND o.Status = 4 -- Paid
                WHERE t.IsActive = 1
                GROUP BY t.Id, t.TableNumber
                ORDER BY TotalRevenue DESC";

            return await dbContext.Database
                .SqlQueryRaw<TablePerformanceStats>(sql, fromDate, toDate)
                .ToListAsync();
        }

        public async Task<Dictionary<Guid, TableStatus>> GetTableStatusMapAsync(List<Guid> tableIds)
        {
            var cacheKey = $"table_status_map_{string.Join(",", tableIds.Take(10))}";
            var cachedResult = await _cache.GetStringAsync(cacheKey);
            
            if (!string.IsNullOrEmpty(cachedResult))
            {
                return System.Text.Json.JsonSerializer.Deserialize<Dictionary<Guid, TableStatus>>(cachedResult);
            }

            var dbSet = await GetDbSetAsync();
            var result = await dbSet
                .Where(x => tableIds.Contains(x.Id))
                .ToDictionaryAsync(x => x.Id, x => x.Status);

            // Cache for 2 minutes
            await _cache.SetStringAsync(cacheKey, 
                System.Text.Json.JsonSerializer.Serialize(result),
                new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(2) });

            return result;
        }
    }

    public class TablePerformanceStats
    {
        public Guid Id { get; set; }
        public string TableNumber { get; set; }
        public int OrderCount { get; set; }
        public decimal TotalRevenue { get; set; }
        public double? AvgServiceTimeMinutes { get; set; }
    }
}
```

## 4. 🔗 Application Contracts

### Complex Input DTOs (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Tables/Dto/Input/OccupyTableDto.cs
public class OccupyTableDto
{
    [Required]
    public Guid TableId { get; set; }
    
    [Range(1, 20)]
    public int GuestCount { get; set; }
    
    public Guid? WaiterId { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public DateTime? EstimatedEndTime { get; set; }
}

// FindAvailableTablesInput.cs
public class FindAvailableTablesInput
{
    [Required]
    public DateTime StartTime { get; set; }
    
    [Required]
    public DateTime EndTime { get; set; }
    
    [Range(1, 50)]
    public int GuestCount { get; set; }
    
    public Guid? PreferredSectionId { get; set; }
    
    public List<string> RequiredFeatures { get; set; } = new();
    
    public TableSelectionStrategy SelectionStrategy { get; set; } = TableSelectionStrategy.SmallestSuitable;
}

// GetUtilizationReportInput.cs
public class GetUtilizationReportInput
{
    [Required]
    public DateTime FromDate { get; set; }
    
    [Required]
    public DateTime ToDate { get; set; }
    
    public Guid? LayoutSectionId { get; set; }
    
    public bool IncludeInactive { get; set; } = false;
    
    public UtilizationMetric MetricType { get; set; } = UtilizationMetric.Revenue;
}

public enum UtilizationMetric
{
    Revenue,
    Occupancy,
    ServiceTime,
    CustomerSatisfaction
}
```

### Complex Output DTOs (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Tables/Dto/TableDto.cs
public class TableDto : EntityDto<Guid>
{
    public string TableNumber { get; set; }
    public Guid LayoutSectionId { get; set; }
    public string LayoutSectionName { get; set; } // Flattened from navigation
    public int MaxSeatingCapacity { get; set; }
    public TableStatus Status { get; set; }
    public string StatusText { get; set; } // Computed
    public bool IsAvailable { get; set; } // Computed
    public int CurrentGuestCount { get; set; }
    public Guid? AssignedWaiterId { get; set; }
    public string? AssignedWaiterName { get; set; } // Flattened
    public DateTime? ServiceStartTime { get; set; }
    public DateTime? EstimatedEndTime { get; set; }
    public string? QRCode { get; set; }
    public string? SpecialNotes { get; set; }
    public int PositionX { get; set; }
    public int PositionY { get; set; }
    public bool IsActive { get; set; }
    
    // Analytics properties (computed)
    public decimal? UtilizationRate { get; set; }
    public TimeSpan? CurrentServiceDuration { get; set; }
    public decimal? EstimatedRevenue { get; set; }
    
    // Real-time status
    public DateTime LastStatusUpdate { get; set; }
    public int OpenIssuesCount { get; set; }
    public bool HasPendingOrders { get; set; }
}

// TableDetailDto.cs (for complex views)
public class TableDetailDto : TableDto
{
    public List<TableStatusHistoryDto> RecentStatusHistory { get; set; } = new();
    public List<OrderSummaryDto> RecentOrders { get; set; } = new();
    public List<ReservationSummaryDto> UpcomingReservations { get; set; } = new();
    public List<TableIssueDto> OpenIssues { get; set; } = new();
    public TableUtilizationStats UtilizationStats { get; set; }
    public TablePricingConfigDto? PricingConfig { get; set; }
}

// Analytics DTOs
public class TableUtilizationReportDto
{
    public Guid? LayoutSectionId { get; set; }
    public string? LayoutSectionName { get; set; }
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public List<TableUtilizationStats> TableStats { get; set; } = new();
    public double AverageUtilizationRate { get; set; }
    public double AverageAvailabilityRate { get; set; }
    public decimal TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
    public TimeSpan AverageServiceTime { get; set; }
}
```

### Application Service Interface (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Tables/ITableAppService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Tables
{
    public interface ITableAppService : IApplicationService
    {
        // Basic CRUD
        Task<PagedResultDto<TableDto>> GetListAsync(GetTableListInput input);
        Task<TableDetailDto> GetAsync(Guid id);
        Task<TableDto> CreateAsync(CreateTableDto input);
        Task<TableDto> UpdateAsync(Guid id, UpdateTableDto input);
        Task DeleteAsync(Guid id);

        // Complex business operations
        Task<TableDto> OccupyTableAsync(OccupyTableDto input);
        Task<TableDto> ReleaseTableAsync(ReleaseTableDto input);
        Task<TableDto> ReserveTableAsync(ReserveTableDto input);
        Task<TableDto> MarkOutOfOrderAsync(MarkTableOutOfOrderDto input);
        Task<TableDto> StartMaintenanceAsync(StartMaintenanceDto input);
        Task<TableDto> CompleteMaintenanceAsync(CompleteMaintenanceDto input);

        // Real-time position management
        Task<TableDto> UpdatePositionAsync(Guid id, UpdateTablePositionDto input);
        Task<List<TableDto>> BulkUpdatePositionsAsync(List<BulkPositionUpdateDto> updates);

        // Advanced querying & analytics
        Task<List<AvailableTableDto>> FindAvailableTablesAsync(FindAvailableTablesInput input);
        Task<TableDto> FindBestTableAsync(FindBestTableInput input);
        Task<List<TimeSlotDto>> GetAvailableTimeSlotsAsync(GetAvailableTimeSlotsInput input);
        Task<TableUtilizationReportDto> GetUtilizationReportAsync(GetUtilizationReportInput input);
        Task<List<TablePerformanceDto>> GetPerformanceAnalyticsAsync(GetPerformanceAnalyticsInput input);

        // Integration features
        Task<string> GenerateQRMenuLinkAsync(Guid tableId);
        Task<byte[]> GetQRCodeImageAsync(Guid tableId);
        Task<string> GetDigitalMenuUrlAsync(string qrCode);

        // Staff operations
        Task<TableDto> AssignWaiterAsync(Guid tableId, Guid waiterId);
        Task<TableDto> UnassignWaiterAsync(Guid tableId);
        Task<List<TableDto>> GetTablesForWaiterAsync(Guid waiterId);
        Task<List<TableDto>> GetTablesRequiringAttentionAsync();

        // Maintenance & issues
        Task<List<TableIssueDto>> GetOpenIssuesAsync();
        Task<TableDto> ReportIssueAsync(ReportTableIssueDto input);
        Task ResolveIssueAsync(Guid issueId, ResolveIssueDto input);

        // Background operations
        Task ProcessMaintenanceScheduleAsync();
        Task SendServiceRemindersAsync();
        Task UpdateAvailabilityCacheAsync();
    }
}
```

## 5. 🚀 Application Layer

### Complex Application Service (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Tables/TableAppService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Caching.Distributed;
using SmartRestaurant.Tables.Dto;
using SmartRestaurant.Permissions;
using SmartRestaurant.Hubs;
using Volo.Abp.Application.Services;
using Volo.Abp.BackgroundJobs;
using Volo.Abp.Caching;

namespace SmartRestaurant.Tables
{
    [Authorize(SmartRestaurantPermissions.Tables.Default)]
    public class TableAppService : ApplicationService, ITableAppService
    {
        private readonly ITableRepository _tableRepository;
        private readonly TableManager _tableManager;
        private readonly IQRCodeService _qrCodeService;
        private readonly IHubContext<TableStatusHub> _hubContext;
        private readonly IBackgroundJobManager _backgroundJobManager;
        private readonly IDistributedCache _cache;

        public TableAppService(
            ITableRepository tableRepository,
            TableManager tableManager,
            IQRCodeService qrCodeService,
            IHubContext<TableStatusHub> hubContext,
            IBackgroundJobManager backgroundJobManager,
            IDistributedCache cache)
        {
            _tableRepository = tableRepository;
            _tableManager = tableManager;
            _qrCodeService = qrCodeService;
            _hubContext = hubContext;
            _backgroundJobManager = backgroundJobManager;
            _cache = cache;
        }

        // Complex business operations with real-time updates
        [Authorize(SmartRestaurantPermissions.Tables.ManageOccupancy)]
        public async Task<TableDto> OccupyTableAsync(OccupyTableDto input)
        {
            var table = await _tableRepository.GetWithFullDetailsAsync(input.TableId);

            // Complex business validation through domain manager
            var isAvailable = await _tableManager.CheckAvailabilityWithBufferTimeAsync(
                table, DateTime.UtcNow, DateTime.UtcNow.AddHours(3), input.GuestCount);

            if (!isAvailable)
                throw new BusinessException("Bàn không khả dụng cho thời gian yêu cầu");

            table.OccupyTable(input.GuestCount, input.WaiterId, input.Notes);

            await _tableRepository.UpdateAsync(table, autoSave: true);

            // Real-time notification to all clients
            await _hubContext.Clients.All.SendAsync("TableStatusChanged", new
            {
                TableId = table.Id,
                Status = table.Status,
                GuestCount = table.CurrentGuestCount,
                WaiterId = table.AssignedWaiterId,
                Timestamp = DateTime.UtcNow
            });

            // Schedule automatic service reminder
            await _backgroundJobManager.EnqueueAsync<TableServiceReminderJob>(
                new TableServiceReminderArgs { TableId = table.Id },
                delay: TimeSpan.FromMinutes(30));

            // Invalidate related caches
            await InvalidateTableCachesAsync(table.Id);

            return ObjectMapper.Map<Table, TableDto>(table);
        }

        [Authorize(SmartRestaurantPermissions.Tables.ManageOccupancy)]
        public async Task<TableDto> ReleaseTableAsync(ReleaseTableDto input)
        {
            var table = await _tableRepository.GetWithFullDetailsAsync(input.TableId);

            // Calculate revenue from associated order
            decimal? revenue = null;
            if (input.OrderId.HasValue)
            {
                var order = await _orderRepository.GetAsync(input.OrderId.Value);
                revenue = order.TotalAmount;
            }

            table.ReleaseTable(revenue);

            await _tableRepository.UpdateAsync(table, autoSave: true);

            // Real-time update with analytics
            await _hubContext.Clients.All.SendAsync("TableReleased", new
            {
                TableId = table.Id,
                Revenue = revenue,
                ServiceDuration = table.ServiceStartTime.HasValue ?
                    DateTime.UtcNow - table.ServiceStartTime.Value :
                    TimeSpan.Zero,
                Timestamp = DateTime.UtcNow
            });

            // Update analytics in background
            await _backgroundJobManager.EnqueueAsync<UpdateTableAnalyticsJob>(
                new UpdateTableAnalyticsArgs 
                { 
                    TableId = table.Id, 
                    Revenue = revenue,
                    ServiceTime = DateTime.UtcNow - (table.ServiceStartTime ?? DateTime.UtcNow)
                });

            await InvalidateTableCachesAsync(table.Id);

            return ObjectMapper.Map<Table, TableDto>(table);
        }

        // Advanced querying with caching
        public async Task<List<AvailableTableDto>> FindAvailableTablesAsync(FindAvailableTablesInput input)
        {
            // Use distributed caching for frequently requested availability
            var cacheKey = $"available_tables_{input.StartTime:yyyyMMddHHmm}_{input.EndTime:yyyyMMddHHmm}_{input.GuestCount}_{input.PreferredSectionId}";

            var cachedResult = await _cache.GetStringAsync(cacheKey);
            if (!string.IsNullOrEmpty(cachedResult))
            {
                return System.Text.Json.JsonSerializer.Deserialize<List<AvailableTableDto>>(cachedResult);
            }

            var availableTables = await _tableManager.FindAvailableTablesAsync(
                input.StartTime,
                input.EndTime,
                input.GuestCount,
                input.PreferredSectionId);

            var result = ObjectMapper.Map<List<Table>, List<AvailableTableDto>>(availableTables);

            // Enhance with real-time calculations
            foreach (var tableDto in result)
            {
                var table = availableTables.First(t => t.Id == tableDto.Id);
                tableDto.EstimatedServiceTime = await _tableManager.CalculateAverageServiceTimeAsync(table);
                tableDto.RecommendationScore = CalculateRecommendationScore(table, input);
            }

            // Cache for 5 minutes
            await _cache.SetStringAsync(cacheKey, System.Text.Json.JsonSerializer.Serialize(result),
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
                });

            return result;
        }

        public async Task<TableUtilizationReportDto> GetUtilizationReportAsync(GetUtilizationReportInput input)
        {
            var tables = input.LayoutSectionId.HasValue
                ? await _tableRepository.GetByLayoutSectionAsync(input.LayoutSectionId.Value)
                : await _tableRepository.GetWithUtilizationAsync(input.FromDate, input.ToDate);

            var utilizationStats = new List<TableUtilizationStats>();

            // Use parallel processing for large datasets
            var tasks = tables.Select(async table =>
            {
                var stats = table.CalculateUtilizationStats(input.FromDate, input.ToDate);
                
                // Enhance with revenue data
                stats.TotalRevenue = await _tableRepository.GetTotalRevenueByTableAsync(
                    table.Id, input.FromDate, input.ToDate);

                return stats;
            });

            utilizationStats = (await Task.WhenAll(tasks)).ToList();

            return new TableUtilizationReportDto
            {
                LayoutSectionId = input.LayoutSectionId,
                FromDate = input.FromDate,
                ToDate = input.ToDate,
                TableStats = utilizationStats,
                AverageUtilizationRate = utilizationStats.Average(s => s.UtilizationRate),
                AverageAvailabilityRate = utilizationStats.Average(s => s.AvailabilityRate),
                TotalRevenue = utilizationStats.Sum(s => s.TotalRevenue ?? 0),
                TotalOrders = utilizationStats.Sum(s => s.OrderCount),
                AverageServiceTime = TimeSpan.FromMinutes(utilizationStats.Average(s => s.AvgServiceTimeMinutes ?? 0))
            };
        }

        // Integration with external services
        [Authorize(SmartRestaurantPermissions.Tables.GenerateQR)]
        public async Task<string> GenerateQRMenuLinkAsync(Guid tableId)
        {
            var table = await _tableRepository.GetAsync(tableId);
            var menuLink = await table.GenerateDigitalMenuLinkAsync(_qrCodeService);

            await _tableRepository.UpdateAsync(table, autoSave: true);

            return menuLink;
        }

        public async Task<byte[]> GetQRCodeImageAsync(Guid tableId)
        {
            var table = await _tableRepository.GetAsync(tableId);
            
            if (string.IsNullOrEmpty(table.QRCode))
                throw new BusinessException("QR Code chưa được tạo cho bàn này");

            return await _qrCodeService.GenerateQRCodeImageAsync(table.QRCode);
        }

        // Background job integration
        [UnitOfWork]
        public async Task ProcessMaintenanceScheduleAsync()
        {
            var tablesNeedingMaintenance = await _tableRepository.GetTablesNeedingMaintenanceAsync();

            foreach (var table in tablesNeedingMaintenance)
            {
                await _backgroundJobManager.EnqueueAsync<TableMaintenanceJob>(
                    new TableMaintenanceArgs
                    {
                        TableId = table.Id,
                        MaintenanceType = "Định kỳ",
                        ScheduledTime = DateTime.UtcNow.AddDays(1)
                    });
            }
        }

        public async Task SendServiceRemindersAsync()
        {
            var occupiedTables = await _tableRepository.GetByStatusAsync(TableStatus.Occupied);
            
            var longServiceTables = occupiedTables.Where(t => 
                t.ServiceStartTime.HasValue && 
                DateTime.UtcNow - t.ServiceStartTime.Value > TimeSpan.FromMinutes(90)
            ).ToList();

            foreach (var table in longServiceTables)
            {
                await _hubContext.Clients.Group($"Waiter_{table.AssignedWaiterId}")
                    .SendAsync("ServiceReminder", new
                    {
                        TableId = table.Id,
                        TableNumber = table.TableNumber,
                        ServiceDuration = DateTime.UtcNow - table.ServiceStartTime!.Value,
                        Message = $"Bàn {table.TableNumber} đã được sử dụng hơn 90 phút"
                    });
            }
        }

        // Cache management
        private async Task InvalidateTableCachesAsync(Guid tableId)
        {
            var cacheKeys = new[]
            {
                $"table_details_{tableId}",
                $"table_availability_{tableId}",
                $"table_status_map_*",
                "available_tables_*"
            };

            foreach (var pattern in cacheKeys)
            {
                if (pattern.EndsWith("*"))
                {
                    // Invalidate pattern-based cache keys (implementation depends on cache provider)
                    await InvalidateCachePatternAsync(pattern);
                }
                else
                {
                    await _cache.RemoveAsync(pattern);
                }
            }
        }

        private async Task InvalidateCachePatternAsync(string pattern)
        {
            // Implementation varies by cache provider
            // For Redis, use SCAN with pattern matching
            // For in-memory cache, maintain a registry of keys
        }

        private int CalculateRecommendationScore(Table table, FindAvailableTablesInput criteria)
        {
            var score = 100;

            // Capacity optimization
            var capacityDiff = table.MaxSeatingCapacity - criteria.GuestCount;
            if (capacityDiff == 0) score += 20; // Perfect fit
            else if (capacityDiff == 1) score += 10; // One extra seat
            else if (capacityDiff > 3) score -= 5; // Too big

            // Location preferences
            if (criteria.RequiredFeatures?.Contains("window") == true && table.SpecialNotes?.Contains("window") == true)
                score += 15;

            return score;
        }
    }
}
```

### Advanced AutoMapper Profile (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Tables/TableApplicationAutoMapperProfile.cs
using AutoMapper;
using System.Linq;

namespace SmartRestaurant.Tables
{
    public class TableApplicationAutoMapperProfile : Profile
    {
        public TableApplicationAutoMapperProfile()
        {
            // Complex entity to DTO with flattening and calculations
            CreateMap<Table, TableDto>()
                .ForMember(dest => dest.LayoutSectionName, opt => opt.MapFrom(src => src.LayoutSection.Name))
                .ForMember(dest => dest.AssignedWaiterName, opt => opt.MapFrom(src => src.AssignedWaiter.FullName))
                .ForMember(dest => dest.StatusText, opt => opt.MapFrom(src => GetStatusText(src.Status)))
                .ForMember(dest => dest.IsAvailable, opt => opt.MapFrom(src => src.Status == TableStatus.Available))
                .ForMember(dest => dest.UtilizationRate, opt => opt.MapFrom(src => 
                    CalculateUtilizationRate(src.StatusHistory)))
                .ForMember(dest => dest.CurrentServiceDuration, opt => opt.MapFrom(src =>
                    src.ServiceStartTime.HasValue ? DateTime.UtcNow - src.ServiceStartTime.Value : (TimeSpan?)null))
                .ForMember(dest => dest.LastStatusUpdate, opt => opt.MapFrom(src =>
                    src.StatusHistory.OrderByDescending(h => h.ChangedAt).FirstOrDefault().ChangedAt))
                .ForMember(dest => dest.OpenIssuesCount, opt => opt.MapFrom(src =>
                    src.IssueReports.Count(i => i.Status == IssueStatus.Open)))
                .ForMember(dest => dest.HasPendingOrders, opt => opt.MapFrom(src =>
                    src.CurrentOrder != null && 
                    (src.CurrentOrder.Status == OrderStatus.Confirmed || src.CurrentOrder.Status == OrderStatus.Preparing)));

            // Detailed DTO with navigation properties
            CreateMap<Table, TableDetailDto>()
                .IncludeBase<Table, TableDto>()
                .ForMember(dest => dest.RecentStatusHistory, opt => opt.MapFrom(src => 
                    src.StatusHistory.OrderByDescending(h => h.ChangedAt).Take(10)))
                .ForMember(dest => dest.RecentOrders, opt => opt.MapFrom(src => 
                    src.Orders.OrderByDescending(o => o.OrderTime).Take(5)))
                .ForMember(dest => dest.UpcomingReservations, opt => opt.MapFrom(src =>
                    src.Reservations.Where(r => r.ReservationTime >= DateTime.Today && r.Status == ReservationStatus.Confirmed)
                                   .OrderBy(r => r.ReservationTime).Take(3)))
                .ForMember(dest => dest.OpenIssues, opt => opt.MapFrom(src =>
                    src.IssueReports.Where(i => i.Status == IssueStatus.Open)))
                .ForMember(dest => dest.UtilizationStats, opt => opt.MapFrom(src =>
                    src.CalculateUtilizationStats(DateTime.Today.AddDays(-7), DateTime.Today.AddDays(1))));

            // List DTO (optimized for performance)
            CreateMap<Table, TableListDto>()
                .ForMember(dest => dest.StatusText, opt => opt.MapFrom(src => GetStatusText(src.Status)))
                .ForMember(dest => dest.IsAvailable, opt => opt.MapFrom(src => src.Status == TableStatus.Available))
                .ForMember(dest => dest.HasActiveOrder, opt => opt.MapFrom(src => src.CurrentOrder != null))
                .ForMember(dest => dest.ServiceDurationMinutes, opt => opt.MapFrom(src =>
                    src.ServiceStartTime.HasValue ? (int)(DateTime.UtcNow - src.ServiceStartTime.Value).TotalMinutes : (int?)null));

            // Available table DTO with enhanced information
            CreateMap<Table, AvailableTableDto>()
                .IncludeBase<Table, TableDto>()
                .ForMember(dest => dest.EstimatedServiceTime, opt => opt.Ignore()) // Set in service
                .ForMember(dest => dest.RecommendationScore, opt => opt.Ignore()) // Set in service
                .ForMember(dest => dest.Features, opt => opt.MapFrom(src => ExtractFeatures(src.SpecialNotes)))
                .ForMember(dest => dest.DistanceFromKitchen, opt => opt.MapFrom(src =>
                    Math.Sqrt(Math.Pow(src.PositionX - 50, 2) + Math.Pow(src.PositionY - 50, 2))));

            // Supporting DTOs
            CreateMap<TableStatusHistory, TableStatusHistoryDto>();
            CreateMap<Order, OrderSummaryDto>();
            CreateMap<Reservation, ReservationSummaryDto>();
            CreateMap<TableIssueReport, TableIssueDto>();
            CreateMap<TablePricingConfig, TablePricingConfigDto>();

            // No Create/Update mappings for Level 3 - use domain services exclusively
        }

        private static decimal CalculateUtilizationRate(ICollection<TableStatusHistory> history)
        {
            if (!history.Any()) return 0;
            
            var today = DateTime.Today;
            var todayHistory = history.Where(h => h.ChangedAt.Date == today).OrderBy(h => h.ChangedAt).ToList();
            
            if (!todayHistory.Any()) return 0;

            var totalMinutes = (DateTime.UtcNow - today).TotalMinutes;
            var occupiedMinutes = 0.0;

            for (int i = 0; i < todayHistory.Count - 1; i++)
            {
                if (todayHistory[i].NewStatus == TableStatus.Occupied)
                {
                    var nextChange = todayHistory[i + 1].ChangedAt;
                    occupiedMinutes += (nextChange - todayHistory[i].ChangedAt).TotalMinutes;
                }
            }

            // Handle last status if still occupied
            if (todayHistory.Last().NewStatus == TableStatus.Occupied)
            {
                occupiedMinutes += (DateTime.UtcNow - todayHistory.Last().ChangedAt).TotalMinutes;
            }

            return (decimal)(occupiedMinutes / totalMinutes * 100);
        }
        
        private static string GetStatusText(TableStatus status) => status switch
        {
            TableStatus.Available => "Trống",
            TableStatus.Reserved => "Đã đặt",
            TableStatus.Occupied => "Đang dùng",
            TableStatus.OutOfOrder => "Hỏng",
            TableStatus.Maintenance => "Bảo trì",
            _ => "Không xác định"
        };

        private static List<string> ExtractFeatures(string? specialNotes)
        {
            if (string.IsNullOrEmpty(specialNotes)) return new List<string>();

            var features = new List<string>();
            var notes = specialNotes.ToLower();

            if (notes.Contains("window")) features.Add("window");
            if (notes.Contains("vip")) features.Add("vip");
            if (notes.Contains("wheelchair")) features.Add("wheelchair");
            if (notes.Contains("quiet")) features.Add("quiet");

            return features;
        }
    }
}
```

## 6. ⚡ Real-time Integration

### SignalR Hub (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Hubs/TableStatusHub.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace SmartRestaurant.Hubs
{
    [Authorize]
    public class TableStatusHub : Hub
    {
        public async Task JoinTableGroup(string tableId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"Table_{tableId}");
        }

        public async Task LeaveTableGroup(string tableId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Table_{tableId}");
        }

        public async Task JoinWaiterGroup(string waiterId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"Waiter_{waiterId}");
        }

        public async Task JoinManagerGroup()
        {
            if (Context.User.IsInRole("Manager"))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, "Managers");
            }
        }
    }
}
```

### Domain Events (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Tables/Events.cs
namespace SmartRestaurant.Tables.Events
{
    public class TableOccupiedEvent : DomainEventData
    {
        public Guid TableId { get; set; }
        public int GuestCount { get; set; }
        public Guid? WaiterId { get; set; }
        public DateTime Timestamp { get; set; }

        public TableOccupiedEvent(Guid tableId, int guestCount, Guid? waiterId)
        {
            TableId = tableId;
            GuestCount = guestCount;
            WaiterId = waiterId;
            Timestamp = DateTime.UtcNow;
        }
    }

    public class TableReleasedEvent : DomainEventData
    {
        public Guid TableId { get; set; }
        public TableStatus PreviousStatus { get; set; }
        public TimeSpan ServiceTime { get; set; }
        public decimal? Revenue { get; set; }

        public TableReleasedEvent(Guid tableId, TableStatus previousStatus, TimeSpan serviceTime, decimal? revenue)
        {
            TableId = tableId;
            PreviousStatus = previousStatus;
            ServiceTime = serviceTime;
            Revenue = revenue;
        }
    }

    public class TablePositionChangedEvent : DomainEventData
    {
        public Guid TableId { get; set; }
        public int NewX { get; set; }
        public int NewY { get; set; }

        public TablePositionChangedEvent(Guid tableId, int newX, int newY)
        {
            TableId = tableId;
            NewX = newX;
            NewY = newY;
        }
    }
}
```

### Event Handlers (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Tables/EventHandlers/TableEventHandler.cs
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Hubs;
using SmartRestaurant.Tables.Events;
using System.Threading.Tasks;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;

namespace SmartRestaurant.Tables.EventHandlers
{
    public class TableEventHandler : 
        ILocalEventHandler<TableOccupiedEvent>,
        ILocalEventHandler<TableReleasedEvent>,
        ILocalEventHandler<TablePositionChangedEvent>,
        ITransientDependency
    {
        private readonly IHubContext<TableStatusHub> _hubContext;
        private readonly ILogger<TableEventHandler> _logger;

        public TableEventHandler(
            IHubContext<TableStatusHub> hubContext,
            ILogger<TableEventHandler> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task HandleEventAsync(TableOccupiedEvent eventData)
        {
            // Real-time notification to all clients
            await _hubContext.Clients.All.SendAsync("TableOccupied", new
            {
                TableId = eventData.TableId,
                GuestCount = eventData.GuestCount,
                WaiterId = eventData.WaiterId,
                Timestamp = eventData.Timestamp
            });

            // Notify specific waiter if assigned
            if (eventData.WaiterId.HasValue)
            {
                await _hubContext.Clients.Group($"Waiter_{eventData.WaiterId}")
                    .SendAsync("TableAssigned", new
                    {
                        TableId = eventData.TableId,
                        GuestCount = eventData.GuestCount,
                        Message = $"Bàn mới được gán với {eventData.GuestCount} khách"
                    });
            }

            _logger.LogInformation("Table {TableId} occupied by {GuestCount} guests", 
                eventData.TableId, eventData.GuestCount);
        }

        public async Task HandleEventAsync(TableReleasedEvent eventData)
        {
            // Real-time analytics update
            await _hubContext.Clients.Group("Managers").SendAsync("TableAnalytics", new
            {
                TableId = eventData.TableId,
                ServiceTime = eventData.ServiceTime,
                Revenue = eventData.Revenue,
                EventType = "TableReleased"
            });

            // General notification
            await _hubContext.Clients.All.SendAsync("TableAvailable", new
            {
                TableId = eventData.TableId,
                ServiceDuration = eventData.ServiceTime,
                Revenue = eventData.Revenue
            });

            _logger.LogInformation("Table {TableId} released after {ServiceTime} with revenue {Revenue}", 
                eventData.TableId, eventData.ServiceTime, eventData.Revenue);
        }

        public async Task HandleEventAsync(TablePositionChangedEvent eventData)
        {
            // Real-time layout update
            await _hubContext.Clients.All.SendAsync("TablePositionChanged", new
            {
                TableId = eventData.TableId,
                X = eventData.NewX,
                Y = eventData.NewY
            });

            _logger.LogDebug("Table {TableId} position updated to ({X}, {Y})", 
                eventData.TableId, eventData.NewX, eventData.NewY);
        }
    }
}
```

## 7. 🏗️ Background Jobs

### Background Job Classes (Level 3)
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/Tables/BackgroundJobs/TableServiceReminderJob.cs
using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using SmartRestaurant.Hubs;
using Volo.Abp.BackgroundJobs;
using Volo.Abp.DependencyInjection;

namespace SmartRestaurant.Tables.BackgroundJobs
{
    public class TableServiceReminderJob : AsyncBackgroundJob<TableServiceReminderArgs>, ITransientDependency
    {
        private readonly ITableRepository _tableRepository;
        private readonly IHubContext<TableStatusHub> _hubContext;

        public TableServiceReminderJob(
            ITableRepository tableRepository,
            IHubContext<TableStatusHub> hubContext)
        {
            _tableRepository = tableRepository;
            _hubContext = hubContext;
        }

        public override async Task ExecuteAsync(TableServiceReminderArgs args)
        {
            var table = await _tableRepository.GetWithDetailsAsync(args.TableId);
            
            if (table.Status == TableStatus.Occupied && table.ServiceStartTime.HasValue)
            {
                var serviceDuration = DateTime.UtcNow - table.ServiceStartTime.Value;
                
                if (serviceDuration.TotalMinutes >= 30) // Send reminder after 30 minutes
                {
                    await _hubContext.Clients.Group($"Waiter_{table.AssignedWaiterId}")
                        .SendAsync("ServiceReminder", new
                        {
                            TableId = table.Id,
                            TableNumber = table.TableNumber,
                            ServiceDuration = serviceDuration,
                            Message = $"Bàn {table.TableNumber} cần được kiểm tra"
                        });
                }
            }
        }
    }

    public class TableServiceReminderArgs
    {
        public Guid TableId { get; set; }
    }
}

// TableMaintenanceJob.cs
public class TableMaintenanceJob : AsyncBackgroundJob<TableMaintenanceArgs>, ITransientDependency
{
    private readonly ITableRepository _tableRepository;
    private readonly IHubContext<TableStatusHub> _hubContext;

    public TableMaintenanceJob(
        ITableRepository tableRepository,
        IHubContext<TableStatusHub> hubContext)
    {
        _tableRepository = tableRepository;
        _hubContext = hubContext;
    }

    public override async Task ExecuteAsync(TableMaintenanceArgs args)
    {
        var table = await _tableRepository.GetAsync(args.TableId);
        
        if (table.Status == TableStatus.Available)
        {
            table.StartMaintenance(args.MaintenanceType);
            await _tableRepository.UpdateAsync(table, autoSave: true);

            // Notify maintenance team
            await _hubContext.Clients.Group("MaintenanceTeam")
                .SendAsync("MaintenanceScheduled", new
                {
                    TableId = table.Id,
                    TableNumber = table.TableNumber,
                    MaintenanceType = args.MaintenanceType,
                    ScheduledTime = args.ScheduledTime
                });
        }
    }
}

public class TableMaintenanceArgs
{
    public Guid TableId { get; set; }
    public string MaintenanceType { get; set; }
    public DateTime ScheduledTime { get; set; }
}
```

## 8. 🧪 Testing

### Integration Tests (Level 3)
```csharp
// File: aspnet-core/test/SmartRestaurant.Application.Tests/Tables/TableAppServiceIntegrationTests.cs
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Shouldly;
using SmartRestaurant.Tables;
using SmartRestaurant.Tables.Dto;
using Xunit;

namespace SmartRestaurant.Tables
{
    public class TableAppServiceIntegrationTests : SmartRestaurantApplicationTestBase
    {
        private readonly ITableAppService _tableAppService;
        private readonly ITableRepository _tableRepository;

        public TableAppServiceIntegrationTests()
        {
            _tableAppService = GetRequiredService<ITableAppService>();
            _tableRepository = GetRequiredService<ITableRepository>();
        }

        [Fact]
        public async Task Should_Find_Available_Tables_With_Cache()
        {
            // Arrange
            var startTime = DateTime.Now.AddHours(1);
            var endTime = startTime.AddHours(2);
            
            var input = new FindAvailableTablesInput
            {
                StartTime = startTime,
                EndTime = endTime,
                GuestCount = 4
            };

            // Act - First call (should hit database)
            var result1 = await _tableAppService.FindAvailableTablesAsync(input);
            
            // Act - Second call (should hit cache)
            var result2 = await _tableAppService.FindAvailableTablesAsync(input);

            // Assert
            result1.ShouldNotBeEmpty();
            result2.Count.ShouldBe(result1.Count);
            result1.All(t => t.EstimatedServiceTime.HasValue).ShouldBeTrue();
        }

        [Fact]
        public async Task Should_Handle_Complex_Occupy_And_Release_Workflow()
        {
            // Arrange
            var table = await CreateTestTableAsync();
            var occupyDto = new OccupyTableDto
            {
                TableId = table.Id,
                GuestCount = 4,
                Notes = "Anniversary dinner"
            };

            // Act - Occupy table
            var occupiedTable = await _tableAppService.OccupyTableAsync(occupyDto);

            // Assert - Occupied
            occupiedTable.Status.ShouldBe(TableStatus.Occupied);
            occupiedTable.CurrentGuestCount.ShouldBe(4);
            occupiedTable.ServiceStartTime.ShouldNotBeNull();

            // Act - Release table
            var releaseDto = new ReleaseTableDto
            {
                TableId = table.Id
            };
            
            var releasedTable = await _tableAppService.ReleaseTableAsync(releaseDto);

            // Assert - Released
            releasedTable.Status.ShouldBe(TableStatus.Available);
            releasedTable.CurrentGuestCount.ShouldBe(0);
        }

        [Fact]
        public async Task Should_Generate_Utilization_Report_With_Analytics()
        {
            // Arrange
            var table = await CreateTestTableWithHistory();
            var input = new GetUtilizationReportInput
            {
                FromDate = DateTime.Today.AddDays(-7),
                ToDate = DateTime.Today.AddDays(1)
            };

            // Act
            var report = await _tableAppService.GetUtilizationReportAsync(input);

            // Assert
            report.TableStats.ShouldNotBeEmpty();
            report.AverageUtilizationRate.ShouldBeGreaterThan(0);
            report.TotalRevenue.ShouldBeGreaterThanOrEqualTo(0);
        }

        private async Task<Table> CreateTestTableAsync()
        {
            var table = new Table(
                Guid.NewGuid(),
                "T001",
                Guid.NewGuid(),
                4,
                100, 100
            );

            return await _tableRepository.InsertAsync(table, autoSave: true);
        }
    }
}
```

## 9. 🔄 Migration Path

1. **Start với Level 1**: Basic CRUD cho simple entities
2. **Migrate lên Level 2**: Khi cần business logic, calculations, state management  
3. **Migrate lên Level 3**: Khi cần real-time updates, advanced caching, background jobs, external integrations, complex analytics

## 📊 Architecture Comparison

| Feature | Level 1 | Level 2 | **Level 3** |
|---------|---------|---------|-------------|
| Framework | ICrudAppService | IApplicationService | IApplicationService + Dependencies |
| Navigation Props | ❌ Foreign keys only | ✅ Strategic collections | ✅ Complex relationships |
| Repository | Built-in | Custom + Built-in | Advanced custom with caching |
| Real-time | ❌ | ❌ | ✅ SignalR integration |
| Caching | ABP built-in | Manual | Advanced distributed caching |
| Background Jobs | ❌ | ❌ | ✅ Complex job processing |
| Domain Events | ❌ | ✅ Basic events | ✅ Complex event workflows |
| External Integration | ❌ | ❌ | ✅ QR codes, analytics, notifications |
| Analytics | ❌ | Basic calculations | ✅ Complex reporting & insights |

## ⚡ Performance Optimizations

- **Distributed caching** for frequently accessed data
- **Parallel processing** for bulk operations
- **Background jobs** for heavy computations
- **SignalR** for real-time updates without polling
- **Custom SQL queries** for complex analytics
- **Strategic eager loading** with navigation properties
- **Cache invalidation strategies** for data consistency