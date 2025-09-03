using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.TableManagement.LayoutSections;
using SmartRestaurant.Permissions;
using SmartRestaurant.TableManagement.LayoutSections.Dto;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Default)]
    public class LayoutSectionAppService : ApplicationService, ILayoutSectionAppService
    {
        private readonly IRepository<LayoutSection, Guid> _repository;

        public LayoutSectionAppService(IRepository<LayoutSection, Guid> repository)
        {
            _repository = repository;
        }

        public async Task<IList<LayoutSectionDto>> GetListAsync()
        {
            var sections = await _repository.GetListAsync();
            return sections
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.SectionName)
                .Select(section => ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section))
                .ToList();
        }

        public async Task<LayoutSectionDto> GetAsync(Guid id)
        {
            var section = await _repository.GetAsync(id);
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }

        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Create)]
        public async Task<LayoutSectionDto> CreateAsync(CreateLayoutSectionDto input)
        {
            var section = new LayoutSection(
                GuidGenerator.Create(),
                input.SectionName,
                input.Description,
                input.DisplayOrder,
                input.IsActive
            );

            await _repository.InsertAsync(section, autoSave: true);
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }

        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Edit)]
        public async Task<LayoutSectionDto> UpdateAsync(Guid id, UpdateLayoutSectionDto input)
        {
            var section = await _repository.GetAsync(id);
            
            ObjectMapper.Map(input, section);
            await _repository.UpdateAsync(section, autoSave: true);
            
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }

        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            await _repository.DeleteAsync(id);
        }

        public async Task<int> GetNextDisplayOrderAsync()
        {
            var hasAny = await _repository.AnyAsync();
            if (!hasAny)
                return 1; // First section gets display order 1
                
            var maxOrder = await _repository.MaxAsync(x => x.DisplayOrder);
            return maxOrder + 1;
        }
    }
}