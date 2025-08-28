using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.TableManagement.Tables.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.TableManagement.Tables
{
    public interface ITableAppService : ICrudAppService<
        TableDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateTableDto,
        UpdateTableDto>
    {
        /// <summary>Lấy danh sách bàn theo khu vực</summary>
        Task<List<TableDto>> GetTablesBySectionAsync(Guid layoutSectionId);
        
        /// <summary>Lấy danh sách tất cả khu vực cùng với danh sách bàn trong từng khu vực</summary>
        Task<List<SectionWithTablesDto>> GetAllSectionsWithTablesAsync();
        
        /// <summary>Gán bàn vào khu vực khác</summary>
        Task AssignToSectionAsync(Guid id, AssignTableToSectionDto input);
        
        /// <summary>Cập nhật thứ tự hiển thị của bàn trong section</summary>
        Task UpdateDisplayOrderAsync(UpdateTableDisplayOrderDto input);
        
        /// <summary>Thay đổi trạng thái kích hoạt của bàn</summary>
        Task ToggleActiveStatusAsync(Guid id, ToggleActiveStatusDto input);
        
        /// <summary>Lấy display order tiếp theo cho bàn mới trong khu vực</summary>
        Task<int> GetNextDisplayOrderAsync(Guid layoutSectionId);
        
        /// <summary>Cập nhật vị trí của nhiều bàn cùng lúc</summary>
        Task UpdateMultipleTablePositionsAsync(List<TablePositionUpdateDto> updates);
    }
}