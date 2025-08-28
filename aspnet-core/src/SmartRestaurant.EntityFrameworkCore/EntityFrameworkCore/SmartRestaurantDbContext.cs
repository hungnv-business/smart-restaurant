using Microsoft.EntityFrameworkCore;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.Entities.MenuManagement;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.Entities.Common;
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
    
    // Inventory Management
    public DbSet<IngredientCategory> IngredientCategories { get; set; }
    public DbSet<Ingredient> Ingredients { get; set; }
    
    // Common
    public DbSet<Unit> Units { get; set; }

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
            b.Property(x => x.Price).IsRequired().HasColumnType("decimal(18,2)");
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
            b.Property(x => x.CostPerUnit).HasColumnType("decimal(18,2)");
            b.Property(x => x.SupplierInfo).HasMaxLength(512);
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
    }
}
