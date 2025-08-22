using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.TableManagement.LayoutSections.Dto;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    public interface ILayoutSectionAppService : IApplicationService
    {
        Task<IList<LayoutSectionDto>> GetListAsync();
        Task<LayoutSectionDto> GetAsync(Guid id);
        Task<LayoutSectionDto> CreateAsync(CreateLayoutSectionDto input);
        Task<LayoutSectionDto> UpdateAsync(Guid id, UpdateLayoutSectionDto input);
        Task DeleteAsync(Guid id);
        Task<int> GetNextDisplayOrderAsync();
    }
}