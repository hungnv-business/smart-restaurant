# Database Management (Quản lý Cơ sở Dữ liệu)

## EF Core Code-First Approach (Phương pháp EF Core Code-First)

**Automatic Database Generation (Tự động Tạo Database):** ABP Framework with Entity Framework Core automatically generates database schema from C# entities, eliminating manual SQL scripts (ABP Framework với Entity Framework Core tự động tạo lược đồ database từ C# entities, loại bỏ các script SQL thủ công).

**Database Configuration (Cấu hình Database):**
```csharp
// src/SmartRestaurant.EntityFrameworkCore/SmartRestaurantDbContext.cs
public class SmartRestaurantDbContext : AbpDbContext<SmartRestaurantDbContext>
{
    public DbSet<Order> Orders { get; set; }
    public DbSet<MenuItem> MenuItems { get; set; }
    public DbSet<MenuCategory> MenuCategories { get; set; }
    public DbSet<Table> Tables { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<Reservation> Reservations { get; set; }

    public SmartRestaurantDbContext(DbContextOptions<SmartRestaurantDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        /// <summary>Cấu hình cho tìm kiếm tiếng Việt</summary>
        builder.HasCollation("vietnamese", locale: "vi-VN", provider: "icu", deterministic: false);

        /// <summary>Cấu hình entity Order</summary>
        builder.Entity<Order>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Orders", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            // Vietnamese currency (VND) - no decimal places
            b.Property(x => x.TotalAmount).HasColumnType("decimal(18,0)");
            b.Property(x => x.OrderNumber).IsRequired().HasMaxLength(20);
            b.Property(x => x.Notes).HasMaxLength(500);
            
            // Indexes for performance
            b.HasIndex(x => new { x.TableId, x.Status });
            b.HasIndex(x => x.CreationTime);
        });

        /// <summary>Cấu hình entity MenuItem với tìm kiếm tiếng Việt</summary>
        builder.Entity<MenuItem>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "MenuItems", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Name).IsRequired().HasMaxLength(200);
            b.Property(x => x.Description).HasMaxLength(500);
            b.Property(x => x.Price).HasColumnType("decimal(18,0)"); // VND
            b.Property(x => x.ImageUrl).HasMaxLength(500);
            
            // Vietnamese text search configuration
            b.HasIndex(x => x.Name).HasMethod("gin").HasOperators("gin_trgm_ops");
            b.HasIndex(x => x.Description).HasMethod("gin").HasOperators("gin_trgm_ops");
        });

        /// <summary>Cấu hình entity Table</summary>
        builder.Entity<Table>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Tables", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.TableNumber).IsRequired().HasMaxLength(10);
            b.Property(x => x.Location).HasMaxLength(100);
            
            b.HasIndex(x => x.TableNumber).IsUnique();
        });

        /// <summary>Cấu hình entity Payment</summary>
        builder.Entity<Payment>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Payments", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Amount).HasColumnType("decimal(18,0)"); // VND
            b.Property(x => x.QRCodeData).HasColumnType("text");
            b.Property(x => x.ReceiptNumber).HasMaxLength(50);
            
            b.HasIndex(x => x.OrderId);
        });
    }
}
```

**Migration Commands (Lệnh Migration):**
```bash
# Create new migration (Tạo migration mới)
dotnet ef migrations add InitialCreate --project src/SmartRestaurant.EntityFrameworkCore

# Update database (Cập nhật database)
dotnet ef database update --project src/SmartRestaurant.EntityFrameworkCore

# Or use ABP DbMigrator (Hoặc sử dụng ABP DbMigrator)
dotnet run --project src/SmartRestaurant.DbMigrator
```

**Data Seeding (Khởi tạo Dữ liệu):**
```csharp
// src/SmartRestaurant.Domain/Data/SmartRestaurantDataSeedContributor.cs
public class SmartRestaurantDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<MenuCategory, Guid> _categoryRepository;
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;
    private readonly IRepository<Table, Guid> _tableRepository;

    public SmartRestaurantDataSeedContributor(
        IRepository<MenuCategory, Guid> categoryRepository,
        IRepository<MenuItem, Guid> menuItemRepository,
        IRepository<Table, Guid> tableRepository)
    {
        _categoryRepository = categoryRepository;
        _menuItemRepository = menuItemRepository;
        _tableRepository = tableRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        /// <summary>Tạo dữ liệu mẫu cho danh mục menu</summary>
        await SeedMenuCategoriesAsync();
        
        /// <summary>Tạo dữ liệu mẫu cho món ăn</summary>
        await SeedMenuItemsAsync();
        
        /// <summary>Tạo dữ liệu mẫu cho bàn ăn</summary>
        await SeedTablesAsync();
    }

    private async Task SeedMenuCategoriesAsync()
    {
        var categories = new[]
        {
            new MenuCategory { Name = "Khai vị", Description = "Các món khai vị", IsEnabled = true, DisplayOrder = 1 },
            new MenuCategory { Name = "Món chính", Description = "Các món ăn chính", IsEnabled = true, DisplayOrder = 2 },
            new MenuCategory { Name = "Lẩu", Description = "Các loại lẩu", IsEnabled = true, DisplayOrder = 3 },
            new MenuCategory { Name = "Nướng", Description = "Các món nướng", IsEnabled = true, DisplayOrder = 4 },
            new MenuCategory { Name = "Đồ uống", Description = "Các loại đồ uống", IsEnabled = true, DisplayOrder = 5 }
        };

        foreach (var category in categories)
        {
            await _categoryRepository.InsertAsync(category, autoSave: true);
        }
    }

    private async Task SeedMenuItemsAsync()
    {
        // Sample Vietnamese dishes
        var menuItems = new[]
        {
            new MenuItem { Name = "Phở Bò", Description = "Phở bò truyền thống", Price = 65000, KitchenStation = KitchenStation.General },
            new MenuItem { Name = "Cơm Tấm", Description = "Cơm tấm sườn nướng", Price = 70000, KitchenStation = KitchenStation.Grilled },
            new MenuItem { Name = "Lẩu Thái", Description = "Lẩu Thái chua cay", Price = 250000, KitchenStation = KitchenStation.Hotpot },
            new MenuItem { Name = "Bia Saigon", Description = "Bia Saigon lon", Price = 25000, KitchenStation = KitchenStation.Drinking }
        };

        foreach (var item in menuItems)
        {
            await _menuItemRepository.InsertAsync(item, autoSave: true);
        }
    }

    private async Task SeedTablesAsync()
    {
        var tables = new[]
        {
            new Table { TableNumber = "B01", Capacity = 4, Location = "Tầng 1" },
            new Table { TableNumber = "B02", Capacity = 6, Location = "Tầng 1" },
            new Table { TableNumber = "VIP1", Capacity = 8, Location = "Khu VIP" }
        };

        foreach (var table in tables)
        {
            await _tableRepository.InsertAsync(table, autoSave: true);
        }
    }
}
```

**Development Workflow (Quy trình Phát triển):**
```bash
# 1. Add new entity or modify existing entity (Thêm entity mới hoặc sửa entity hiện có)
# Edit: src/SmartRestaurant.Domain/Entities/

# 2. Add/Update DbSet in DbContext (Thêm/Cập nhật DbSet trong DbContext)
# Edit: src/SmartRestaurant.EntityFrameworkCore/SmartRestaurantDbContext.cs

# 3. Create migration (Tạo migration)
dotnet ef migrations add AddNewFeature --project src/SmartRestaurant.EntityFrameworkCore

# 4. Apply migration to database (Áp dụng migration vào database)
dotnet run --project src/SmartRestaurant.DbMigrator

# 5. Generate frontend proxies (Tạo proxy frontend)
npm run generate-proxy
```

**Vietnamese Text Search Configuration (Cấu hình Tìm kiếm Tiếng Việt):**
```csharp
// src/SmartRestaurant.EntityFrameworkCore/Extensions/DbContextExtensions.cs
public static class DbContextExtensions
{
    /// <summary>Cấu hình tìm kiếm tiếng Việt cho PostgreSQL</summary>
    public static void ConfigureVietnameseTextSearch(this ModelBuilder builder)
    {
        // Enable PostgreSQL extensions for Vietnamese text search
        builder.HasPostgresExtension("unaccent");
        builder.HasPostgresExtension("pg_trgm");
        
        // Configure Vietnamese collation
        builder.HasCollation("vietnamese", locale: "vi-VN", provider: "icu", deterministic: false);
    }
}

// Usage in DbContext
protected override void OnModelCreating(ModelBuilder builder)
{
    base.OnModelCreating(builder);
    builder.ConfigureVietnameseTextSearch();
    // ... other configurations
}
```

**Performance Monitoring (Giám sát Hiệu suất):**
```csharp
// src/SmartRestaurant.EntityFrameworkCore/Performance/PerformanceInterceptor.cs
public class PerformanceInterceptor : DbCommandInterceptor
{
    private readonly ILogger<PerformanceInterceptor> _logger;

    public PerformanceInterceptor(ILogger<PerformanceInterceptor> logger)
    {
        _logger = logger;
    }

    /// <summary>Theo dõi các truy vấn chậm (> 1 giây)</summary>
    public override ValueTask<DbDataReader> ReaderExecutedAsync(
        DbCommand command, 
        CommandExecutedEventData eventData, 
        DbDataReader result, 
        CancellationToken cancellationToken = default)
    {
        var elapsed = eventData.Duration;
        if (elapsed.TotalSeconds > 1)
        {
            _logger.LogWarning("Slow query detected: {SQL} - Duration: {Duration}ms", 
                command.CommandText, elapsed.TotalMilliseconds);
        }
        
        return base.ReaderExecutedAsync(command, eventData, result, cancellationToken);
    }
}

// Configuration in SmartRestaurantDbContext
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.AddInterceptors(new PerformanceInterceptor(_serviceProvider.GetService<ILogger<PerformanceInterceptor>>()));
}
```