using Microsoft.EntityFrameworkCore;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.TableManagement.LayoutSections;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.Orders;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.Common;
using Volo.Abp.AuditLogging.EntityFrameworkCore;
using Volo.Abp.BackgroundJobs.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore.Modeling;
using Volo.Abp.FeatureManagement.EntityFrameworkCore;
using Volo.Abp.Identity;
using Volo.Abp.Identity.EntityFrameworkCore;
using Volo.Abp.OpenIddict.EntityFrameworkCore;
using Volo.Abp.PermissionManagement.EntityFrameworkCore;
using Volo.Abp.SettingManagement.EntityFrameworkCore;
using Volo.Abp.TenantManagement;
using Volo.Abp.TenantManagement.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore;

[ReplaceDbContext(typeof(IIdentityDbContext))]
[ReplaceDbContext(typeof(ITenantManagementDbContext))]
[ConnectionStringName("Default")]
public class SmartRestaurantDbContext :
    AbpDbContext<SmartRestaurantDbContext>,
    IIdentityDbContext,
    ITenantManagementDbContext
{
    /* Add DbSet properties for your Aggregate Roots / Entities here. */
    
    // Table Management
    public DbSet<LayoutSection> LayoutSections { get; set; }
    public DbSet<Table> Tables { get; set; }
    
    // Menu Management
    public DbSet<MenuCategory> MenuCategories { get; set; }
    public DbSet<MenuItem> MenuItems { get; set; }
    public DbSet<MenuItemIngredient> MenuItemIngredients { get; set; }
    
    // Inventory Management
    public DbSet<IngredientCategory> IngredientCategories { get; set; }
    public DbSet<Ingredient> Ingredients { get; set; }
    public DbSet<IngredientPurchaseUnit> IngredientPurchaseUnits { get; set; }
    
    // Purchase Invoice Management
    public DbSet<PurchaseInvoice> PurchaseInvoices { get; set; }
    public DbSet<PurchaseInvoiceItem> PurchaseInvoiceItems { get; set; }
    
    // Order Management
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<Payment> Payments { get; set; }
    
    // Common
    public DbSet<Unit> Units { get; set; }
    public DbSet<DimDate> DimDates { get; set; }

    #region Entities from the modules

    /* Notice: We only implemented IIdentityDbContext and ITenantManagementDbContext
     * and replaced them for this DbContext. This allows you to perform JOIN
     * queries for the entities of these modules over the repositories easily. You
     * typically don't need that for other modules. But, if you need, you can
     * implement the DbContext interface of the needed module and use ReplaceDbContext
     * attribute just like IIdentityDbContext and ITenantManagementDbContext.
     *
     * More info: Replacing a DbContext of a module ensures that the related module
     * uses this DbContext on runtime. Otherwise, it will use its own DbContext class.
     */

    //Identity
    public DbSet<IdentityUser> Users { get; set; }
    public DbSet<IdentityRole> Roles { get; set; }
    public DbSet<IdentityClaimType> ClaimTypes { get; set; }
    public DbSet<OrganizationUnit> OrganizationUnits { get; set; }
    public DbSet<IdentitySecurityLog> SecurityLogs { get; set; }
    public DbSet<IdentityLinkUser> LinkUsers { get; set; }
    public DbSet<IdentityUserDelegation> UserDelegations { get; set; }
    public DbSet<IdentitySession> Sessions { get; set; }
    // Tenant Management
    public DbSet<Tenant> Tenants { get; set; }
    public DbSet<TenantConnectionString> TenantConnectionStrings { get; set; }

    #endregion

    public SmartRestaurantDbContext(DbContextOptions<SmartRestaurantDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        /* Include modules to your migration db context */

        builder.ConfigurePermissionManagement();
        builder.ConfigureSettingManagement();
        builder.ConfigureBackgroundJobs();
        builder.ConfigureAuditLogging();
        builder.ConfigureIdentity();
        builder.ConfigureOpenIddict();
        builder.ConfigureFeatureManagement();
        builder.ConfigureTenantManagement();

        /* Configure your own tables/entities inside here */

        // Configure LayoutSection entity
        builder.Entity<LayoutSection>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "LayoutSections", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.SectionName).IsRequired().HasMaxLength(128);
            b.Property(x => x.Description).HasMaxLength(512);
            b.Property(x => x.DisplayOrder).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasIndex(x => x.DisplayOrder);
            b.HasIndex(x => new { x.IsActive, x.DisplayOrder });
        });
        
        // Configure Table entity
        builder.Entity<Table>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Tables", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.TableNumber).IsRequired().HasMaxLength(64);
            b.Property(x => x.DisplayOrder).IsRequired();
            b.Property(x => x.Status).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasOne(x => x.LayoutSection)
                .WithMany(x => x.Tables)
                .HasForeignKey(x => x.LayoutSectionId)
                .IsRequired(false);
                
            b.HasOne(x => x.CurrentOrder)
                .WithOne()
                .HasForeignKey<Table>(x => x.CurrentOrderId)
                .IsRequired(false);
                
            b.HasMany(x => x.Orders)
                .WithOne(x => x.Table)
                .HasForeignKey(x => x.TableId)
                .IsRequired(false);
                
            b.HasIndex(x => x.LayoutSectionId);
            b.HasIndex(x => new { x.LayoutSectionId, x.DisplayOrder });
            b.HasIndex(x => new { x.IsActive, x.DisplayOrder });
        });
        
        // Configure MenuCategory entity
        builder.Entity<MenuCategory>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "MenuCategories", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Name).IsRequired().HasMaxLength(128);
            b.Property(x => x.Description).HasMaxLength(512);
            b.Property(x => x.DisplayOrder).IsRequired();
            b.Property(x => x.IsEnabled).IsRequired();
            b.Property(x => x.ImageUrl).HasMaxLength(2048);
            
            b.HasIndex(x => x.DisplayOrder);
            b.HasIndex(x => new { x.IsEnabled, x.DisplayOrder });
            b.HasIndex(x => x.Name);
        });
        
        // Configure MenuItem entity
        builder.Entity<MenuItem>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "MenuItems", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Name).IsRequired().HasMaxLength(200);
            b.Property(x => x.Description).HasMaxLength(1000);
            b.Property(x => x.Price).IsRequired().HasColumnType("integer");
            b.Property(x => x.IsAvailable).IsRequired();
            b.Property(x => x.ImageUrl).HasMaxLength(500);
            b.Property(x => x.CategoryId).IsRequired();
            
            b.HasOne(x => x.Category)
                .WithMany()
                .HasForeignKey(x => x.CategoryId)
                .IsRequired();
                
            b.HasIndex(x => x.CategoryId);
            b.HasIndex(x => new { x.CategoryId, x.IsAvailable });
            b.HasIndex(x => x.Name);
        });
        
        // Configure MenuItemIngredient entity
        builder.Entity<MenuItemIngredient>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "MenuItemIngredients", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.MenuItemId).IsRequired();
            b.Property(x => x.IngredientId).IsRequired();
            b.Property(x => x.RequiredQuantity).IsRequired();
            b.Property(x => x.DisplayOrder).IsRequired();
            
            b.HasOne(x => x.MenuItem)
                .WithMany(x => x.Ingredients)
                .HasForeignKey(x => x.MenuItemId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);
                
            b.HasOne(x => x.Ingredient)
                .WithMany()
                .HasForeignKey(x => x.IngredientId)
                .IsRequired();
                
            // Performance indexes
            b.HasIndex(x => x.MenuItemId);
            b.HasIndex(x => x.IngredientId);
            b.HasIndex(x => new { x.MenuItemId, x.IngredientId }).IsUnique();
            b.HasIndex(x => new { x.MenuItemId, x.DisplayOrder });
        });
        
        // Configure IngredientCategory entity
        builder.Entity<IngredientCategory>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "IngredientCategories", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Name).IsRequired().HasMaxLength(128);
            b.Property(x => x.Description).HasMaxLength(512);
            b.Property(x => x.DisplayOrder).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasIndex(x => x.DisplayOrder);
            b.HasIndex(x => new { x.IsActive, x.DisplayOrder });
            b.HasIndex(x => x.Name);
        });
        
        // Configure Ingredient entity
        builder.Entity<Ingredient>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Ingredients", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.CategoryId).IsRequired();
            b.Property(x => x.Name).IsRequired().HasMaxLength(128);
            b.Property(x => x.Description).HasMaxLength(512);
            b.Property(x => x.UnitId).IsRequired();
            b.Property(x => x.CostPerUnit).HasColumnType("integer");
            b.Property(x => x.SupplierInfo).HasMaxLength(512);
            b.Property(x => x.CurrentStock).IsRequired();
            b.Property(x => x.IsStockTrackingEnabled).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasOne(x => x.Category)
                .WithMany(x => x.Ingredients)
                .HasForeignKey(x => x.CategoryId)
                .IsRequired();
                
            b.HasOne(x => x.Unit)
                .WithMany()
                .HasForeignKey(x => x.UnitId)
                .IsRequired();
                
            b.HasIndex(x => x.CategoryId);
            b.HasIndex(x => x.UnitId);
            b.HasIndex(x => new { x.CategoryId, x.IsActive });
            b.HasIndex(x => x.Name);
        });
        
        // Configure IngredientPurchaseUnit entity
        builder.Entity<IngredientPurchaseUnit>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "IngredientPurchaseUnits", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.IngredientId).IsRequired();
            b.Property(x => x.UnitId).IsRequired();
            b.Property(x => x.ConversionRatio).IsRequired();
            b.Property(x => x.IsBaseUnit).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasOne(x => x.Ingredient)
                .WithMany(x => x.PurchaseUnits)
                .HasForeignKey(x => x.IngredientId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);
                
            b.HasOne(x => x.Unit)
                .WithMany()
                .HasForeignKey(x => x.UnitId)
                .IsRequired();
            
            // Performance optimization indexes
            b.HasIndex(x => new { x.IngredientId, x.IsActive });
            b.HasIndex(x => x.UnitId);
            
            // Business constraint: exactly one base unit per ingredient
            b.HasIndex(x => x.IngredientId)
                .IsUnique()
                .HasFilter("\"IsBaseUnit\" = true");
        });
        
        // Configure Unit entity
        builder.Entity<Unit>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Units", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.Name).IsRequired().HasMaxLength(64);
            b.Property(x => x.DisplayOrder).IsRequired();
            b.Property(x => x.IsActive).IsRequired();
            
            b.HasIndex(x => x.DisplayOrder);
            b.HasIndex(x => new { x.IsActive, x.DisplayOrder });
            b.HasIndex(x => x.Name).IsUnique();
        });
        
        // Configure DimDate entity
        builder.Entity<DimDate>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "DimDates", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.HasKey(x => x.Id);
            b.Property(x => x.Date).IsRequired();
            b.Property(x => x.DateVnFormat).IsRequired().HasMaxLength(10);
            b.Property(x => x.DateVnShortFormat).IsRequired().HasMaxLength(10);
            
            b.HasIndex(x => x.Date).IsUnique();
        });

        // Configure PurchaseInvoice entity
        builder.Entity<PurchaseInvoice>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "PurchaseInvoices", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.InvoiceNumber).IsRequired().HasMaxLength(50);
            b.Property(x => x.InvoiceDateId).IsRequired();
            b.Property(x => x.TotalAmount).IsRequired();
            b.Property(x => x.Notes).HasMaxLength(500);
            
            b.HasOne(x => x.InvoiceDate)
                .WithMany()
                .HasForeignKey(x => x.InvoiceDateId)
                .IsRequired();
            
            b.HasIndex(x => x.InvoiceNumber);
            b.HasIndex(x => x.InvoiceDateId);
        });
        
        // Configure PurchaseInvoiceItem entity  
        builder.Entity<PurchaseInvoiceItem>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "PurchaseInvoiceItems", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.PurchaseInvoiceId).IsRequired();
            b.Property(x => x.IngredientId).IsRequired();
            b.Property(x => x.Quantity).IsRequired();
            b.Property(x => x.PurchaseUnitId).IsRequired();
            b.Property(x => x.BaseUnitQuantity).IsRequired();
            b.Property(x => x.UnitPrice);
            b.Property(x => x.TotalPrice).IsRequired();
            b.Property(x => x.SupplierInfo).HasMaxLength(500);
            b.Property(x => x.Notes).HasMaxLength(500);
            
            b.HasOne(x => x.PurchaseInvoice)
                .WithMany(x => x.Items)
                .HasForeignKey(x => x.PurchaseInvoiceId)
                .IsRequired();

            b.HasOne(x => x.Ingredient)
                .WithMany()
                .HasForeignKey(x => x.IngredientId)
                .IsRequired(false);

            b.HasOne(x => x.PurchaseUnit)
                .WithMany()
                .HasForeignKey(x => x.PurchaseUnitId)
                .IsRequired();
                
            b.HasIndex(x => x.PurchaseInvoiceId);
            b.HasIndex(x => x.IngredientId);
            b.HasIndex(x => x.PurchaseUnitId);
        });

        // Configure Order entity
        builder.Entity<Order>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Orders", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.OrderNumber).IsRequired().HasMaxLength(20);
            b.Property(x => x.TableId);
            b.Property(x => x.OrderType).IsRequired();
            b.Property(x => x.Status).IsRequired();
            b.Property(x => x.TotalAmount).IsRequired().HasColumnType("integer");
            b.Property(x => x.Notes).HasMaxLength(500);
            b.Property(x => x.PaidTime);
            
            // Table relationship is configured in Table entity
                
            b.HasIndex(x => x.OrderNumber).IsUnique();
            b.HasIndex(x => x.TableId);
            b.HasIndex(x => x.Status);
            b.HasIndex(x => new { x.Status, x.CreationTime });
            b.HasIndex(x => x.CreationTime);
        });
        
        // Configure OrderItem entity
        builder.Entity<OrderItem>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "OrderItems", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.OrderId).IsRequired();
            b.Property(x => x.MenuItemId).IsRequired();
            b.Property(x => x.MenuItemName).IsRequired().HasMaxLength(200);
            b.Property(x => x.Quantity).IsRequired();
            b.Property(x => x.UnitPrice).IsRequired().HasColumnType("integer");
            b.Property(x => x.Notes).HasMaxLength(300);
            b.Property(x => x.Status).IsRequired();
            b.Property(x => x.PreparationStartTime);
            b.Property(x => x.PreparationCompleteTime);
            
            b.HasOne(x => x.Order)
                .WithMany(x => x.OrderItems)
                .HasForeignKey(x => x.OrderId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);
                
            b.HasOne(x => x.MenuItem)
                .WithMany(x => x.OrderItems)
                .HasForeignKey(x => x.MenuItemId)
                .IsRequired();
                
            b.HasIndex(x => x.OrderId);
            b.HasIndex(x => x.MenuItemId);
            b.HasIndex(x => new { x.OrderId, x.Status });
        });
        
        // Configure Payment entity
        builder.Entity<Payment>(b =>
        {
            b.ToTable(SmartRestaurantConsts.DbTablePrefix + "Payments", SmartRestaurantConsts.DbSchema);
            b.ConfigureByConvention();
            
            b.Property(x => x.OrderId).IsRequired();
            b.Property(x => x.PaymentTime).IsRequired();
            b.Property(x => x.TotalAmount).IsRequired().HasColumnType("integer");
            b.Property(x => x.CustomerMoney).IsRequired().HasColumnType("integer");
            b.Property(x => x.PaymentMethod).IsRequired();
            b.Property(x => x.Notes).HasMaxLength(500);
            
            b.HasOne(x => x.Order)
                .WithOne(o => o.Payment)
                .HasForeignKey<Payment>(x => x.OrderId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);
                
            b.HasIndex(x => x.OrderId);
            b.HasIndex(x => x.PaymentTime);
            b.HasIndex(x => new { x.PaymentMethod, x.PaymentTime });
        });
    }
}
