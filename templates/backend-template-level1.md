# Level 1: Basic CRUD Template (Master Data)

## 📋 Overview

**Khi nào dùng**: Entity đơn giản, chủ yếu là master data, ít business logic
**Phù hợp cho**: MenuCategory, LayoutSection, UserRole, Settings, Tags...
**Framework**: Kế thừa từ `ICrudAppService` và `CrudAppService` của ABP
**APIs**: GetList, Get, Create, Update, Delete + custom methods (GetActiveList, GetNextDisplayOrder, IsNameExists)

**Đặc điểm**:
- Properties cơ bản (Name, Description, DisplayOrder, IsActive)
- Validation đơn giản (Required, MaxLength)
- Sử dụng ABP's built-in CRUD operations với auto-generated APIs
- Tự động có paging, sorting, filtering từ ABP
- Không có business rules phức tạp
- Relationship 1-to-many đơn giản
- **Ưu điểm**: Ít boilerplate code, tận dụng ABP conventions

## ✅ When to Use Level 1

**Level 1 (Basic CRUD + ICrudAppService)**:
- ✅ MenuCategory, LayoutSection, UserRole, Settings
- ✅ Master data với basic validation
- ✅ Entities không có complex business logic
- ❌ Không dùng cho: Order, Table, Payment

**ICrudAppService Benefits**:
- ✅ Auto-generated APIs theo REST conventions
- ✅ Built-in paging, sorting, filtering
- ✅ Automatic permission policy assignment
- ✅ Less boilerplate code
- ✅ Consistent error handling từ ABP
- ✅ Auto-generated Swagger documentation

## 1. 📁 File Structure

```
aspnet-core/
├── src/SmartRestaurant.Domain.Shared/
│   └── Entities/{Module}/{EntityName}Consts.cs
├── src/SmartRestaurant.Domain/
│   └── Entities/{Module}/{EntityName}.cs
├── src/SmartRestaurant.EntityFrameworkCore/
│   └── EntityFrameworkCore/SmartRestaurantDbContext.cs
├── src/SmartRestaurant.Application.Contracts/
│   └── {Module}/{EntityName}s/
│       ├── I{EntityName}AppService.cs
│       └── Dto/
│           ├── {EntityName}Dto.cs
│           ├── Create{EntityName}Dto.cs
│           └── Update{EntityName}Dto.cs
└── src/SmartRestaurant.Application/
    └── {Module}/{EntityName}s/
        ├── {EntityName}AppService.cs
        └── {EntityName}ApplicationAutoMapperProfile.cs
```

## 2. 🏗️ Domain Layer

### Constants File (ABP Best Practice)
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Entities/{Module}/{EntityName}Consts.cs
namespace SmartRestaurant.Entities.{Module}
{
    /// <summary>
    /// Các hằng số cho {EntityName} entity - định nghĩa giới hạn và cấu hình
    /// </summary>
    public static class {EntityName}Consts
    {
        /// <summary>
        /// Độ dài tối đa của tên {entity-display-name}
        /// </summary>
        public const int MaxNameLength = 128;
        
        /// <summary>
        /// Độ dài tối đa của mô tả {entity-display-name}
        /// </summary>
        public const int MaxDescriptionLength = 512;
        
        /// <summary>
        /// Độ dài tối đa của URL hình ảnh
        /// </summary>
        public const int MaxImageUrlLength = 2048;
    }
}
```

### Domain Error Codes
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/SmartRestaurantDomainErrorCodes.cs
namespace SmartRestaurant
{
    /// <summary>
    /// Các mã lỗi domain cho SmartRestaurant - dùng để internationalization
    /// </summary>
    public static class SmartRestaurantDomainErrorCodes
    {
        /// <summary>
        /// Lỗi trùng tên {entity-display-name} - dùng khi tạo/sửa entity với tên đã tồn tại
        /// </summary>
        public const string {EntityName}AlreadyExists = "SmartRestaurant:00001";
    }
}
```

### Custom Exception Classes
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/{Module}/{EntityName}AlreadyExistsException.cs
using Volo.Abp;

namespace SmartRestaurant.{Module}
{
    /// <summary>
    /// Exception ném khi tạo/sửa {entity-display-name} với tên đã tồn tại
    /// Kế thừa BusinessException để ABP tự động xử lý và trả về HTTP 400
    /// </summary>
    public class {EntityName}AlreadyExistsException : BusinessException
    {
        /// <summary>
        /// Constructor với tên {entity-display-name} bị trùng
        /// </summary>
        /// <param name="name">Tên {entity-display-name} bị trùng</param>
        public {EntityName}AlreadyExistsException(string name)
            : base(SmartRestaurantDomainErrorCodes.{EntityName}AlreadyExists)
        {
            WithData("name", name); // Truyền tên vào error message template
        }
    }
}
```

### Domain Entity Template - Dựa trên MenuCategory
```csharp
// File: aspnet-core/src/SmartRestaurant.Domain/Entities/{Module}/{EntityName}.cs
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.{Module};

namespace SmartRestaurant.Entities.{Module}
{
    /// <summary>
    /// Domain Entity cho {Entity Description} - Level 1 CRUD
    /// Kế thừa FullAuditedEntity để có đầy đủ audit fields và soft delete
    /// </summary>
    public class {EntityName} : FullAuditedEntity<Guid>
    {
        /// <summary>
        /// Tên {entity-display-name} - Required field, tối đa 128 ký tự
        /// Ví dụ: "Món khai vị", "Bàn VIP", "Khuyến mãi mùa hè"
        /// </summary>
        [Required]
        [StringLength({EntityName}Consts.MaxNameLength)]
        public string Name { get; set; }

        /// <summary>
        /// Mô tả chi tiết về {entity-display-name} - Optional field, tối đa 512 ký tự
        /// Dùng để giải thích thêm về {entity-display-name}
        /// </summary>
        [StringLength({EntityName}Consts.MaxDescriptionLength)]
        public string? Description { get; set; }

        /// <summary>
        /// Thứ tự hiển thị {entity-display-name} - dùng để sắp xếp
        /// Số nhỏ hơn sẽ hiển thị trước, bắt đầu từ 1
        /// </summary>
        public int DisplayOrder { get; set; }

        /// <summary>
        /// Trạng thái kích hoạt {entity-display-name} - true: hiển thị, false: ẩn
        /// Dùng để tạm thời ẩn/hiện mà không cần xóa
        /// </summary>
        public bool IsEnabled { get; set; }

        /// <summary>
        /// URL hình ảnh đại diện cho {entity-display-name} - Optional, tối đa 2048 ký tự
        /// Dùng để hiển thị icon hoặc banner
        /// </summary>
        [StringLength({EntityName}Consts.MaxImageUrlLength)]
        public string? ImageUrl { get; set; }

        // Navigation properties
        // TODO: Add related navigation properties in higher levels
        // public virtual ICollection<RelatedEntity> RelatedEntities { get; set; }

        // Constructor cho EF Core
        protected {EntityName}()
        {
        }

        // Business constructor với validation - sử dụng trong Application layer
        public {EntityName}(
            Guid id,
            string name,
            string description = null,
            int displayOrder = 0,
            bool isEnabled = true,
            string imageUrl = null) : base(id)
        {
            Name = name;
            Description = description;
            DisplayOrder = displayOrder;
            IsEnabled = isEnabled;
            ImageUrl = imageUrl;
        }
    }
}
```

## 3. 💾 Data Layer

### Entity Framework Configuration
**Note:** Level 1 uses ABP's built-in `IRepository<TEntity, TKey>` via CrudAppService. No custom repository needed.

```csharp
// File: aspnet-core/src/SmartRestaurant.EntityFrameworkCore/EntityFrameworkCore/SmartRestaurantDbContext.cs
public DbSet<{EntityName}> {EntityName}s { get; set; }

// In OnModelCreating method:
protected override void OnModelCreating(ModelBuilder builder)
{
    base.OnModelCreating(builder);

    builder.Entity<{EntityName}>(b =>
    {
        b.ToTable(SmartRestaurantConsts.DbTablePrefix + "{EntityName}s", SmartRestaurantConsts.DbSchema);
        b.ConfigureByConvention();

        b.Property(x => x.Name).IsRequired().HasMaxLength({EntityName}Consts.MaxNameLength);
        b.Property(x => x.Description).HasMaxLength({EntityName}Consts.MaxDescriptionLength);

        b.HasIndex(x => x.Name);
        b.HasIndex(x => x.DisplayOrder);
        b.HasIndex(x => x.IsActive);
        b.HasIndex(x => x.ParentId);
    });
}
```

### Entity Relationship Pattern (Foreign Key Only)
```csharp
public class MenuCategory : AuditedAggregateRoot<Guid>
{
    // Use foreign key properties instead of navigation properties for Level 1
    public Guid? ParentCategoryId { get; private set; }
    
    // Business method to set relationship
    public void SetParentCategory(Guid? parentCategoryId)
    {
        ParentCategoryId = parentCategoryId;
    }
}

// EF Core Configuration
builder.Entity<MenuCategory>(b =>
{
    // Configure foreign key relationship without navigation property
    b.HasIndex(x => x.ParentCategoryId);
    
    // Optional: Add foreign key constraint with specific behavior
    b.Property(x => x.ParentCategoryId)
        .HasComment("Reference to parent category for hierarchical structure");
});
```

### Migration Command
```bash
# Tạo migration mới
cd aspnet-core
dotnet ef migrations add Add{EntityName} -p src/SmartRestaurant.EntityFrameworkCore

# Apply migration
dotnet run --project src/SmartRestaurant.DbMigrator
```

## 4. 🔗 Application Contracts

### DTO Templates - Dựa trên MenuCategory DTOs
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/{Module}/{EntityName}s/Dto/{EntityName}Dto.cs
using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.{Module}.{EntityName}s.Dto
{
    /// <summary>
    /// DTO đọc dữ liệu {entity-display-name} - dùng cho các API Get và GetList
    /// Chứa tất cả thông tin cần thiết để hiển thị trên UI
    /// </summary>
    public class {EntityName}Dto : EntityDto<Guid>
    {
        /// <summary>
        /// Tên {entity-display-name}
        /// </summary>
        public string Name { get; set; }
        
        /// <summary>
        /// Mô tả chi tiết {entity-display-name}
        /// </summary>
        public string Description { get; set; }
        
        /// <summary>
        /// Thứ tự hiển thị để sắp xếp
        /// </summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>
        /// Trạng thái kích hoạt - true: hiển thị, false: ẩn
        /// </summary>
        public bool IsEnabled { get; set; }
        
        /// <summary>
        /// URL hình ảnh đại diện
        /// </summary>
        public string ImageUrl { get; set; }
        
        /// <summary>
        /// Thời gian tạo {entity-display-name}
        /// </summary>
        public DateTime CreationTime { get; set; }
        
        /// <summary>
        /// Thời gian sửa lần cuối (null nếu chưa sửa)
        /// </summary>
        public DateTime? LastModificationTime { get; set; }
    }
}

// File: aspnet-core/src/SmartRestaurant.Application.Contracts/{Module}/{EntityName}s/Dto/CreateUpdate{EntityName}Dto.cs
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.{Module};

namespace SmartRestaurant.{Module}.{EntityName}s.Dto
{
    /// <summary>
    /// DTO tạo mới và cập nhật {entity-display-name} - dùng chung cho Create và Update API
    /// Chứa các field có thể chỉnh sửa, không bao gồm audit fields
    /// </summary>
    public class CreateUpdate{EntityName}Dto
    {
        /// <summary>
        /// Tên {entity-display-name} - Bắt buộc, tối đa 128 ký tự
        /// </summary>
        [Required(ErrorMessage = "Tên {entity-display-name} là bắt buộc")]
        [StringLength({EntityName}Consts.MaxNameLength, ErrorMessage = "Tên {entity-display-name} không được vượt quá {1} ký tự")]
        public string Name { get; set; }

        /// <summary>
        /// Mô tả chi tiết {entity-display-name} - Tùy chọn, tối đa 512 ký tự
        /// </summary>
        [StringLength({EntityName}Consts.MaxDescriptionLength, ErrorMessage = "Mô tả không được vượt quá {1} ký tự")]
        public string Description { get; set; }

        /// <summary>
        /// Thứ tự hiển thị - Dùng để sắp xếp, số nhỏ hơn hiển thị trước
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "Thứ tự hiển thị phải lớn hơn 0")]
        public int DisplayOrder { get; set; }
        
        /// <summary>
        /// Trạng thái kích hoạt - Mặc định true (hiển thị)
        /// </summary>
        public bool IsEnabled { get; set; } = true;

        /// <summary>
        /// URL hình ảnh đại diện - Tùy chọn, tối đa 2048 ký tự
        /// </summary>
        [StringLength({EntityName}Consts.MaxImageUrlLength, ErrorMessage = "URL hình ảnh không được vượt quá {1} ký tự")]
        [Url(ErrorMessage = "URL hình ảnh không đúng định dạng")]
        public string ImageUrl { get; set; }
    }
}
```

### Application Service Interface - Dựa trên IMenuCategoryAppService
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/{Module}/{EntityName}s/I{EntityName}AppService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.{Module}.{EntityName}s.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.{Module}.{EntityName}s;

/// <summary>
/// Application Service Interface cho {EntityName} - Level 1 CRUD Pattern
/// Kế thừa ICrudAppService để có sẵn: GetListAsync, GetAsync, CreateAsync, UpdateAsync, DeleteAsync
/// Chỉ định nghĩa thêm các method custom không có sẵn trong ICrudAppService
/// </summary>
public interface I{EntityName}AppService : ICrudAppService<
    {EntityName}Dto,                      // Entity DTO cho output
    Guid,                                 // Primary key type
    PagedAndSortedResultRequestDto,       // GetList input với paging/sorting
    CreateUpdate{EntityName}Dto>          // Create/Update input DTO
{
    /// <summary>
    /// Custom method: Lấy display order tiếp theo cho entity mới
    /// </summary>
    Task<int> GetNextDisplayOrderAsync();

    /// <summary>
    /// Custom method: Bulk delete - không có sẵn trong ICrudAppService
    /// </summary>
    Task DeleteManyAsync(List<Guid> ids);
}
```

## 5. 🚀 Application Layer

### Application Service Implementation - Dựa trên MenuCategoryAppService
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/{Module}/{EntityName}s/{EntityName}AppService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.Entities.{Module};
using SmartRestaurant.Exceptions;
using SmartRestaurant.{Module}.{EntityName}s.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.{Module}.{EntityName}s;

/// <summary>
/// Application Service cho {EntityName} - Level 1 CRUD Pattern
/// Kế thừa CrudAppService của ABP để có sẵn các operations: GetList, Get, Create, Update, Delete
/// Chỉ cần override khi cần business logic đặc biệt
/// </summary>
[Authorize(SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Default)]
public class {EntityName}AppService :
    CrudAppService<
        {EntityName},                         // Domain Entity
        {EntityName}Dto,                      // Output DTO  
        Guid,                                 // Primary Key Type
        PagedAndSortedResultRequestDto,       // GetList Input (có sẵn paging/sorting)
        CreateUpdate{EntityName}Dto>,         // Create/Update Input DTO
    I{EntityName}AppService
{
    public {EntityName}AppService(IRepository<{EntityName}, Guid> repository)
        : base(repository)
    {
        // Cấu hình permissions cho từng operation
        GetPolicyName = SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Default;
        GetListPolicyName = SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Default;
        CreatePolicyName = SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Create;
        UpdatePolicyName = SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Edit;
        DeletePolicyName = SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Delete;
    }

    /// <summary>
    /// Lấy thứ tự hiển thị tiếp theo có sẵn cho entity mới
    /// </summary>
    /// <returns>Số thứ tự hiển thị tiếp theo</returns>
    [Authorize(SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Default)]
    public virtual async Task<int> GetNextDisplayOrderAsync()
    {
        var maxOrder = await Repository.GetQueryableAsync()
            .Select(x => x.DisplayOrder)
            .DefaultIfEmpty(0)
            .MaxAsync();
        return maxOrder + 1;
    }

    /// <summary>
    /// Override CreateAsync để thêm business logic: validate name unique và auto-assign display order
    /// </summary>
    public override async Task<{EntityName}Dto> CreateAsync(CreateUpdate{EntityName}Dto input)
    {
        // Chuẩn hóa dữ liệu đầu vào để tránh khoảng trắng thừa
        input.Name = StringUtility.NormalizeString(input.Name);
        input.Description = StringUtility.NormalizeStringNullable(input.Description);

        // Business validation: kiểm tra trùng tên
        await ValidateNameNotExistsAsync(input.Name);

        // Auto-assign display order nếu chưa có
        if (input.DisplayOrder == 0)
        {
            input.DisplayOrder = await GetNextDisplayOrderAsync();
        }

        return await base.CreateAsync(input);
    }

    /// <summary>
    /// Override UpdateAsync để thêm business validation
    /// </summary>
    public override async Task<{EntityName}Dto> UpdateAsync(Guid id, CreateUpdate{EntityName}Dto input)
    {
        // Chuẩn hóa dữ liệu đầu vào
        input.Name = StringUtility.NormalizeString(input.Name);
        input.Description = StringUtility.NormalizeStringNullable(input.Description);

        // Business validation: kiểm tra trùng tên (loại trừ chính nó)
        await ValidateNameNotExistsAsync(input.Name, id);

        return await base.UpdateAsync(id, input);
    }

    /// <summary>
    /// Custom method: Xóa nhiều entities cùng lúc - không có sẵn trong CrudAppService
    /// </summary>
    [Authorize(SmartRestaurantPermissions.{ModuleName}.{EntityName}s.Delete)]
    public virtual async Task DeleteManyAsync(List<Guid> ids)
    {
        if (ids == null || !ids.Any())
        {
            return;
        }

        var entitiesToDelete = await Repository.GetListAsync(x => ids.Contains(x.Id));
        
        if (entitiesToDelete.Any())
        {
            await Repository.DeleteManyAsync(entitiesToDelete);
        }
    }

    /// <summary>
    /// Private helper: Validate name uniqueness - business rule của {EntityName}
    /// </summary>
    private async Task ValidateNameNotExistsAsync(string name, Guid? excludeId = null)
    {
        if (StringUtility.IsNullOrWhiteSpaceNormalized(name))
        {
            return;
        }

        // Kiểm tra trùng tên không phân biệt hoa thường và khoảng trắng
        var existingEntities = await Repository.GetListAsync();
        var duplicateEntity = existingEntities.FirstOrDefault(c => 
            (excludeId == null || c.Id != excludeId) && 
            StringUtility.AreNormalizedEqual(c.Name, name));

        if (duplicateEntity != null)
        {
            throw new {EntityName}NameAlreadyExistsException(name);
        }
    }
}
```

### AutoMapper Profile - Dựa trên MenuCategoryAutoMapperProfile
```csharp
// File: aspnet-core/src/SmartRestaurant.Application/{Module}/{EntityName}s/{EntityName}AutoMapperProfile.cs
using AutoMapper;
using SmartRestaurant.Entities.{Module};
using SmartRestaurant.{Module}.{EntityName}s.Dto;

namespace SmartRestaurant.{Module}.{EntityName}s;

/// <summary>
/// AutoMapper Profile cho {EntityName} - Level 1 CRUD Pattern
/// Đơn giản, chỉ mapping property-to-property, để CrudAppService handle business logic
/// </summary>
public class {EntityName}AutoMapperProfile : Profile
{
    public {EntityName}AutoMapperProfile()
    {
        /// <summary>
        /// Entity to DTO mapping - dùng cho read operations (Get, GetList)
        /// </summary>
        CreateMap<{EntityName}, {EntityName}Dto>();
        
        /// <summary>
        /// DTO to Entity mapping - dùng cho write operations (Create, Update)
        /// CrudAppService sẽ handle business logic trong MapToEntityAsync override
        /// </summary>
        CreateMap<CreateUpdate{EntityName}Dto, {EntityName}>();
    }
}
```

## 6. 🔐 Permissions

### Permission Definition
```csharp
// File: aspnet-core/src/SmartRestaurant.Application.Contracts/Permissions/SmartRestaurantPermissions.cs
public static class SmartRestaurantPermissions
{
    public const string GroupName = "SmartRestaurant";

    public static class {ModuleName}
    {
        public const string Default = GroupName + ".{ModuleName}";

        public static class {EntityName}
        {
            public const string Default = {ModuleName}.Default + ".{EntityName}";
            public const string Create = Default + ".Create";
            public const string Edit = Default + ".Edit";
            public const string Delete = Default + ".Delete";
        }
    }
}

// In SmartRestaurantPermissionDefinitionProvider.cs
var {moduleName}Group = context.AddGroup(SmartRestaurantPermissions.{ModuleName}.Default, L("Permission:{ModuleName}"));

var {entityName}Permission = {moduleName}Group.AddPermission(SmartRestaurantPermissions.{ModuleName}.{EntityName}.Default, L("Permission:{ModuleName}.{EntityName}"));
{entityName}Permission.AddChild(SmartRestaurantPermissions.{ModuleName}.{EntityName}.Create, L("Permission:{ModuleName}.{EntityName}.Create"));
{entityName}Permission.AddChild(SmartRestaurantPermissions.{ModuleName}.{EntityName}.Edit, L("Permission:{ModuleName}.{EntityName}.Edit"));
{entityName}Permission.AddChild(SmartRestaurantPermissions.{ModuleName}.{EntityName}.Delete, L("Permission:{ModuleName}.{EntityName}.Delete"));
```

## 7. 🌐 Localization

### Error Messages
```json
// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Localization/SmartRestaurant/vi.json
{
  "SmartRestaurant:00001": "Đã tồn tại danh mục với tên: {name}"
}

// File: aspnet-core/src/SmartRestaurant.Domain.Shared/Localization/SmartRestaurant/en.json
{
  "SmartRestaurant:00001": "There is already a category with the same name: {name}"
}
```

## 8. 🧪 Testing

### Application Service Tests
```csharp
// File: aspnet-core/test/SmartRestaurant.Application.Tests/{Module}/{EntityName}AppServiceTests.cs
using System;
using System.Threading.Tasks;
using Shouldly;
using Volo.Abp.Validation;
using Xunit;

namespace SmartRestaurant.{Module}
{
    public class {EntityName}AppServiceTests : SmartRestaurantApplicationTestBase
    {
        private readonly I{EntityName}AppService _{entityName}AppService;

        public {EntityName}AppServiceTests()
        {
            _{entityName}AppService = GetRequiredService<I{EntityName}AppService>();
        }

        [Fact]
        public async Task Should_Get_List_Of_{EntityName}s()
        {
            // Act
            var result = await _{entityName}AppService.GetListAsync(new PagedAndSortedResultRequestDto());

            // Assert
            result.TotalCount.ShouldBeGreaterThan(0);
            result.Items.ShouldContain(x => x.Name.Contains("Test"));
        }

        [Fact]
        public async Task Should_Create_{EntityName}()
        {
            // Arrange
            var input = new Create{EntityName}Dto
            {
                Name = "Test {EntityName}",
                Description = "Test Description",
                DisplayOrder = 1,
                IsActive = true
            };

            // Act
            var result = await _{entityName}AppService.CreateAsync(input);

            // Assert
            result.Id.ShouldNotBe(Guid.Empty);
            result.Name.ShouldBe(input.Name);
        }

        [Fact]
        public async Task Should_Not_Create_{EntityName}_With_Same_Name()
        {
            // Arrange
            var input = new Create{EntityName}Dto
            {
                Name = "Existing Name",
                Description = "Test Description"
            };

            await _{entityName}AppService.CreateAsync(input);

            // Act & Assert
            var exception = await Assert.ThrowsAsync<MenuCategoryAlreadyExistsException>(
                () => _{entityName}AppService.CreateAsync(input)
            );
        }
    }
}
```

## 🔄 Migration Path

1. **Start nhỏ**: Bắt đầu với Level 1 (ICrudAppService)
2. **Add business logic**: Migrate lên [Level 2](./backend-template-level2.md) (IApplicationService) khi cần calculations/status
3. **Add complexity**: Migrate lên [Level 3](./backend-template-level3.md) (IApplicationService + dependencies) khi cần real-time/integration/analytics

## 📊 Navigation Properties Guidelines

| Level | Navigation Properties | Use Case |
|-------|---------------------|----------|
| **Level 1** | ❌ None | Foreign keys only, simple CRUD |
| Level 2 | ✅ Strategic | Business logic collections, parent-child operations |
| Level 3 | ✅ Complex | Advanced scenarios, reporting, multi-entity workflows |

## ⚡ Performance Tips

- Level 1 entities are optimized for simplicity and performance
- Use indexes on commonly queried fields (Name, DisplayOrder, IsActive)
- Foreign key relationships without navigation properties reduce memory usage
- ABP's built-in caching works automatically with ICrudAppService