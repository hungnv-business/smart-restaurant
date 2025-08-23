using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.Permissions;
using SmartRestaurant.Repositories;
using SmartRestaurant.TableManagement.Tables.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.Tables
{
    [Authorize(SmartRestaurantPermissions.Tables.Table.Default)]
    public class TableAppService : CrudAppService<
        Table,
        TableDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateTableDto,
        UpdateTableDto>, ITableAppService
    {
        private readonly ITableRepository _tableRepository;
        private readonly ILayoutSectionRepository _layoutSectionRepository;

        public TableAppService(
            IRepository<Table, Guid> repository,
            ITableRepository tableRepository,
            ILayoutSectionRepository layoutSectionRepository)
            : base(repository)
        {
            _tableRepository = tableRepository;
            _layoutSectionRepository = layoutSectionRepository;
            
            GetPolicyName = SmartRestaurantPermissions.Tables.Table.Default;
            GetListPolicyName = SmartRestaurantPermissions.Tables.Table.Default;
            CreatePolicyName = SmartRestaurantPermissions.Tables.Table.Create;
            UpdatePolicyName = SmartRestaurantPermissions.Tables.Table.Edit;
            DeletePolicyName = SmartRestaurantPermissions.Tables.Table.Delete;
        }

        public async Task<List<TableDto>> GetTablesBySectionAsync(Guid layoutSectionId)
        {
            var tables = await _tableRepository.GetTablesBySectionAsync(layoutSectionId, true);
            return ObjectMapper.Map<List<Table>, List<TableDto>>(tables);
        }

        public async Task<List<SectionWithTablesDto>> GetAllSectionsWithTablesAsync()
        {
            // Lấy tất cả sections
            var sections = await _layoutSectionRepository.GetListAsync();
            
            // Lấy tất cả tables
            var tables = await _tableRepository.GetAllTablesOrderedAsync(true);
            
            var result = new List<SectionWithTablesDto>();
            
            // Group tables by section (only tables with valid LayoutSectionId)
            var tablesBySection = tables
                .Where(t => t.LayoutSectionId.HasValue)
                .GroupBy(t => t.LayoutSectionId!.Value)
                .ToDictionary(g => g.Key, g => g.ToList());
            
            foreach (var section in sections.OrderBy(s => s.DisplayOrder))
            {
                var sectionDto = new SectionWithTablesDto
                {
                    Id = section.Id,
                    SectionName = section.SectionName,
                    Description = section.Description,
                    DisplayOrder = section.DisplayOrder,
                    IsActive = section.IsActive,
                    Tables = []
                };
                
                // Add tables for this section if any exist
                if (tablesBySection.TryGetValue(section.Id, out var sectionTables))
                {
                    sectionDto.Tables = ObjectMapper.Map<List<Table>, List<TableDto>>(
                        [.. sectionTables.OrderBy(t => t.DisplayOrder).ThenBy(t => t.TableNumber)]
                    );
                    
                    // Set layout section name for each table
                    foreach (var tableDto in sectionDto.Tables)
                    {
                        tableDto.LayoutSectionName = section.SectionName;
                    }
                }
                
                result.Add(sectionDto);
            }
            
            return result;
        }

        [Authorize(SmartRestaurantPermissions.Tables.Table.AssignTableToSection)]
        public async Task AssignToSectionAsync(Guid id, AssignTableToSectionDto input)
        {
            var table = await Repository.GetAsync(id);
            
            // Validate that the layout section exists
            var layoutSection = await _layoutSectionRepository.GetAsync(input.LayoutSectionId);
            
            // Set new section
            table.LayoutSectionId = input.LayoutSectionId;
            
            if (input.NewPosition.HasValue)
            {
                // Insert at specific position
                var tablesInTargetSection = await _tableRepository.GetTablesBySectionAsync(input.LayoutSectionId, true);
                var orderedTables = tablesInTargetSection.OrderBy(t => t.DisplayOrder).ThenBy(t => t.TableNumber).ToList();
                
                // Insert the table at the specified position (convert 1-based to 0-based)
                var insertIndex = Math.Min(input.NewPosition.Value - 1, orderedTables.Count);
                orderedTables.Insert(insertIndex, table);
                
                // Renumber all tables from 1 to n
                for (int i = 0; i < orderedTables.Count; i++)
                {
                    orderedTables[i].DisplayOrder = i + 1;
                }
                
                // Update all tables in target section
                await Repository.UpdateManyAsync(orderedTables);
            }
            else
            {
                // Default behavior: add to end
                var maxDisplayOrder = await _tableRepository.GetMaxDisplayOrderInSectionAsync(input.LayoutSectionId);
                table.DisplayOrder = maxDisplayOrder + 1;
                await Repository.UpdateAsync(table);
            }
        }

        [Authorize(SmartRestaurantPermissions.Tables.Table.EditTableOrder)]
        public async Task UpdateDisplayOrderAsync(UpdateTableDisplayOrderDto input)
        {
            var table = await Repository.GetAsync(input.TableId);
            
            if (!table.LayoutSectionId.HasValue)
                throw new InvalidOperationException("Bàn chưa được gán vào khu vực nào");
                
            var sectionId = table.LayoutSectionId.Value;
            
            // Get all tables in the section, ordered by current display order
            var allTablesInSection = await _tableRepository.GetTablesBySectionAsync(sectionId, true);
            var orderedTables = allTablesInSection.OrderBy(t => t.DisplayOrder).ThenBy(t => t.TableNumber).ToList();
            
            // Remove the dragged table from its current position
            var draggedTable = orderedTables.FirstOrDefault(t => t.Id == input.TableId);
            if (draggedTable != null)
            {
                orderedTables.Remove(draggedTable);
                
                // Insert the dragged table at the new position (convert 1-based to 0-based)
                var insertIndex = Math.Min(input.NewPosition - 1, orderedTables.Count);
                orderedTables.Insert(insertIndex, draggedTable);
                
                // Renumber all tables from 1 to n
                for (int i = 0; i < orderedTables.Count; i++)
                {
                    orderedTables[i].DisplayOrder = i + 1;
                }
                
                // Update all tables with new display orders
                await Repository.UpdateManyAsync(orderedTables);
            }
        }

        [Authorize(SmartRestaurantPermissions.Tables.Table.Edit)]
        public async Task ToggleActiveStatusAsync(Guid id, ToggleActiveStatusDto input)
        {
            var table = await Repository.GetAsync(id);
            table.IsActive = input.IsActive;
            await Repository.UpdateAsync(table);
        }


        protected override async Task<IQueryable<Table>> CreateFilteredQueryAsync(PagedAndSortedResultRequestDto input)
        {
            return (await Repository.GetQueryableAsync())
                .Where(t => t.IsActive)
                .OrderBy(t => t.LayoutSection.DisplayOrder)
                .ThenBy(t => t.DisplayOrder)
                .ThenBy(t => t.TableNumber);
        }

        protected override async Task<TableDto> MapToGetOutputDtoAsync(Table entity)
        {
            var dto = await base.MapToGetOutputDtoAsync(entity);
            
            // Add layout section name if available
            if (entity.LayoutSection != null)
            {
                dto.LayoutSectionName = entity.LayoutSection.SectionName;
            }
            
            return dto;
        }

        protected override Task<List<TableDto>> MapToGetListOutputDtosAsync(List<Table> entities)
        {
            var dtos = ObjectMapper.Map<List<Table>, List<TableDto>>(entities);
            
            // Set layout section names
            for (int i = 0; i < entities.Count; i++)
            {
                if (entities[i].LayoutSection != null)
                {
                    dtos[i].LayoutSectionName = entities[i].LayoutSection.SectionName;
                }
            }
            
            return Task.FromResult(dtos);
        }

        public async Task<int> GetNextDisplayOrderAsync(Guid layoutSectionId)
        {
            var maxDisplayOrder = await _tableRepository.GetMaxDisplayOrderInSectionAsync(layoutSectionId);
            return maxDisplayOrder + 1;
        }
    }
}