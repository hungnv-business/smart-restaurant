using System;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Interface dịch vụ ứng dụng cho quản lý món ăn
    /// Cung cấp đầy đủ chức năng CRUD và các thao tác đặc biệt
    /// Kế thừa ICrudAppService để có sẵn các thao tác cơ bản
    /// </summary>
    public interface IMenuItemAppService : 
        ICrudAppService<
            MenuItemDto,                      // DTO đầu ra
            Guid,                            // Loại khóa chính
            PagedAndSortedResultRequestDto,   // DTO phân trang và sắp xếp
            CreateUpdateMenuItemDto>          // DTO tạo/cập nhật
    {
        /// <summary>
        /// Cập nhật trạng thái có sẵn của món ăn
        /// Dùng để đánh dấu món còn hàng hay hết hàng
        /// </summary>
        /// <param name="id">ID của món ăn</param>
        /// <param name="isAvailable">Trạng thái có sẵn mới</param>
        /// <returns>Thông tin món ăn sau khi cập nhật</returns>
        Task<MenuItemDto> UpdateAvailabilityAsync(Guid id, bool isAvailable);
    }
}