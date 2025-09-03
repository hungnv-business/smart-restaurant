using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.InventoryManagement.Ingredients;

public interface IIngredientAppService : IApplicationService
{
    /// <summary>Lấy danh sách nguyên liệu với phân trang và filter (bao gồm PurchaseUnits)</summary>
    Task<PagedResultDto<IngredientDto>> GetListAsync(GetIngredientListRequestDto input);
    
    /// <summary>Lấy chi tiết nguyên liệu theo ID (bao gồm PurchaseUnits)</summary>
    Task<IngredientDto> GetAsync(Guid id);
    
    /// <summary>Tạo nguyên liệu mới với các đơn vị mua hàng</summary>
    Task<IngredientDto> CreateAsync(CreateUpdateIngredientDto input);
    
    /// <summary>Cập nhật nguyên liệu và đơn vị mua hàng</summary>
    Task<IngredientDto> UpdateAsync(Guid id, CreateUpdateIngredientDto input);
    
    /// <summary>Xóa nguyên liệu</summary>
    Task DeleteAsync(Guid id);
    
}