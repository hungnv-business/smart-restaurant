using System;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Interface dịch vụ ứng dụng cho quản lý món ăn
    /// Cung cấp đầy đủ chức năng CRUD cho món ăn và các tính năng đặc biệt
    /// Hỗ trợ quản lý nguyên liệu, trạng thái available và thống kê phổ biến
    /// </summary>
    public interface IMenuItemAppService : IApplicationService
    {
        /// <summary>Lấy danh sách món ăn với phân trang và filter (bao gồm nguyên liệu)</summary>
        Task<PagedResultDto<MenuItemDto>> GetListAsync(GetMenuItemListRequestDto input);

        /// <summary>Lấy chi tiết món ăn theo ID (bao gồm nguyên liệu)</summary>
        Task<MenuItemDto> GetAsync(Guid id);

        /// <summary>Tạo món ăn mới với nguyên liệu</summary>
        Task CreateAsync(CreateUpdateMenuItemDto input);

        /// <summary>Cập nhật món ăn và nguyên liệu</summary>
        Task UpdateAsync(Guid id, CreateUpdateMenuItemDto input);

        /// <summary>Xóa món ăn</summary>
        Task DeleteAsync(Guid id);

        // === Availability Management Methods ===

        /// <summary>Cập nhật trạng thái có sẵn của món ăn</summary>
        Task UpdateAvailabilityAsync(Guid id, bool isAvailable);
    }
}