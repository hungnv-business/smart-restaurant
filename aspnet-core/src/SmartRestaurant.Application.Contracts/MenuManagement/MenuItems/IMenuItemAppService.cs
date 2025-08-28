using System;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    public interface IMenuItemAppService : 
        ICrudAppService<
            MenuItemDto, 
            Guid, 
            PagedAndSortedResultRequestDto, 
            CreateUpdateMenuItemDto>
    {
        /// <summary>
        /// Cập nhật trạng thái có sẵn của món ăn (còn hàng/hết hàng)
        /// </summary>
        Task<MenuItemDto> UpdateAvailabilityAsync(Guid id, bool isAvailable);
    }
}