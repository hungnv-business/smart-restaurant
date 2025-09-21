using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.TableManagement.LayoutSections;
using SmartRestaurant.Permissions;
using SmartRestaurant.TableManagement.Tables.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.Tables
{
    /// <summary>
    /// Dịch vụ ứng dụng cho quản lý bàn ăn trong nhà hàng
    /// Cung cấp đầy đủ chức năng CRUD và các thao tác đặc biệt
    /// Bao gồm: gán bàn vào khu vực, sắp xếp vị trí, thay đổi trạng thái
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Tables.Table.Default)]
    public class TableAppService : CrudAppService<
        Table,
        TableDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateTableDto,
        UpdateTableDto>, ITableAppService
    {
        /// <summary>Repository chuyên biệt cho việc truy cập dữ liệu bàn ăn</summary>
        private readonly ITableRepository _tableRepository;
        /// <summary>Repository cho việc truy cập dữ liệu khu vực bố cục</summary>
        private readonly ILayoutSectionRepository _layoutSectionRepository;

        /// <summary>
        /// Constructor - khởi tạo dịch vụ quản lý bàn ăn
        /// Thiết lập các policy phân quyền cho từng thao tác
        /// </summary>
        /// <param name="repository">Repository cơ bản từ ABP</param>
        /// <param name="tableRepository">Repository chuyên biệt cho bàn</param>
        /// <param name="layoutSectionRepository">Repository cho khu vực bố cục</param>
        public TableAppService(
            IRepository<Table, Guid> repository,
            ITableRepository tableRepository,
            ILayoutSectionRepository layoutSectionRepository)
            : base(repository)
        {
            _tableRepository = tableRepository;
            _layoutSectionRepository = layoutSectionRepository;

            // Thiết lập các policy phân quyền cho từng thao tác CRUD
            GetPolicyName = SmartRestaurantPermissions.Tables.Table.Default;
            GetListPolicyName = SmartRestaurantPermissions.Tables.Table.Default;
            CreatePolicyName = SmartRestaurantPermissions.Tables.Table.Create;
            UpdatePolicyName = SmartRestaurantPermissions.Tables.Table.Edit;
            DeletePolicyName = SmartRestaurantPermissions.Tables.Table.Delete;
        }

        /// <summary>
        /// Lấy danh sách bàn theo khu vực bố cục
        /// Sắp xếp theo thứ tự hiển thị trong khu vực
        /// </summary>
        /// <param name="layoutSectionId">ID của khu vực bố cục</param>
        /// <returns>Danh sách bàn trong khu vực được chỉ định</returns>
        public async Task<List<TableDto>> GetTablesBySectionAsync(Guid layoutSectionId)
        {
            var tables = await _tableRepository.GetTablesBySectionAsync(layoutSectionId, true);
            return ObjectMapper.Map<List<Table>, List<TableDto>>(tables);
        }

        /// <summary>
        /// Lấy tất cả khu vực cùng với danh sách bàn trong từng khu vực
        /// Dùng cho màn hình kanban board hiển thị toàn bộ layout nhà hàng
        /// </summary>
        /// <returns>Danh sách khu vực kèm theo bàn trong từng khu vực</returns>
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

        /// <summary>
        /// Gán bàn vào khu vực bố cục khác
        /// Có thể chỉ định vị trí cụ thể hoặc để tự động thêm vào cuối
        /// </summary>
        /// <param name="id">ID của bàn cần gán</param>
        /// <param name="input">Thông tin khu vực mới và vị trí</param>
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

        /// <summary>
        /// Cập nhật thứ tự hiển thị của bàn trong khu vực
        /// Hỗ trợ drag & drop trong giao diện kanban
        /// </summary>
        /// <param name="input">Thông tin bàn và vị trí mới</param>
        [Authorize(SmartRestaurantPermissions.Tables.Table.EditTableOrder)]
        public async Task UpdateDisplayOrderAsync(UpdateTableDisplayOrderDto input)
        {
            var table = await Repository.GetAsync(input.TableId);

            if (!table.LayoutSectionId.HasValue)
                throw new TableNotAssignedToSectionException(table.TableNumber);

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

        /// <summary>
        /// Thay đổi trạng thái kích hoạt của bàn
        /// Bàn không kích hoạt sẽ không hiển thị trong giao diện đặt bàn
        /// </summary>
        /// <param name="id">ID của bàn</param>
        /// <param name="input">Trạng thái kích hoạt mới</param>
        [Authorize(SmartRestaurantPermissions.Tables.Table.Edit)]
        public async Task ToggleActiveStatusAsync(Guid id, ToggleActiveStatusDto input)
        {
            var table = await Repository.GetAsync(id);
            table.IsActive = input.IsActive;
            await Repository.UpdateAsync(table);
        }

        /// <summary>
        /// Cập nhật vị trí của nhiều bàn cùng lúc
        /// Dùng cho drag & drop nhiều bàn giữa các khu vực
        /// </summary>
        /// <param name="updates">Danh sách cập nhật vị trí bàn</param>
        [Authorize(SmartRestaurantPermissions.Tables.Table.EditTableOrder)]
        public async Task UpdateMultipleTablePositionsAsync(List<TablePositionUpdateDto> updates)
        {
            if (updates == null || updates.Count == 0)
                return;

            var tableIds = updates.Select(u => u.TableId).ToList();
            var tables = await Repository.GetListAsync(t => tableIds.Contains(t.Id));

            foreach (var update in updates)
            {
                var table = tables.FirstOrDefault(t => t.Id == update.TableId);
                if (table != null)
                {
                    table.LayoutSectionId = update.LayoutSectionId;
                    table.DisplayOrder = update.DisplayOrder;
                }
            }

            await Repository.UpdateManyAsync(tables);
        }


        /// <summary>
        /// Tạo query đã được lọc và sắp xếp cho danh sách bàn
        /// Chỉ lấy bàn đang kích hoạt, sắp xếp theo khu vực và thứ tự
        /// </summary>
        /// <param name="input">Tham số phân trang và sắp xếp</param>
        /// <returns>Query đã được lọc và sắp xếp</returns>
        protected override async Task<IQueryable<Table>> CreateFilteredQueryAsync(PagedAndSortedResultRequestDto input)
        {
            return (await Repository.GetQueryableAsync())
                .Where(t => t.IsActive)
                .OrderBy(t => t.LayoutSection.DisplayOrder)
                .ThenBy(t => t.DisplayOrder)
                .ThenBy(t => t.TableNumber);
        }

        /// <summary>
        /// Map entity bàn thành DTO cho một bàn cụ thể
        /// Bổ sung thêm tên khu vực nếu có
        /// </summary>
        /// <param name="entity">Entity bàn cần map</param>
        /// <returns>DTO đã được bổ sung thông tin</returns>
        protected override async Task<TableDto> MapToGetOutputDtoAsync(Table entity)
        {
            var dto = await base.MapToGetOutputDtoAsync(entity);

            // Bổ sung tên khu vực nếu có
            if (entity.LayoutSection != null)
            {
                dto.LayoutSectionName = entity.LayoutSection.SectionName;
            }

            return dto;
        }

        /// <summary>
        /// Map danh sách entity bàn thành danh sách DTO
        /// Bổ sung tên khu vực cho từng bàn nếu có
        /// </summary>
        /// <param name="entities">Danh sách entity bàn</param>
        /// <returns>Danh sách DTO đã được bổ sung thông tin</returns>
        protected override Task<List<TableDto>> MapToGetListOutputDtosAsync(List<Table> entities)
        {
            var dtos = ObjectMapper.Map<List<Table>, List<TableDto>>(entities);

            // Bổ sung tên khu vực cho từng bàn
            for (int i = 0; i < entities.Count; i++)
            {
                if (entities[i].LayoutSection != null)
                {
                    dtos[i].LayoutSectionName = entities[i].LayoutSection.SectionName;
                }
            }

            return Task.FromResult(dtos);
        }

        /// <summary>
        /// Lấy số thứ tự hiển thị tiếp theo cho bàn mới trong khu vực
        /// Đảm bảo bàn mới luôn hiển thị cuối danh sách
        /// </summary>
        /// <param name="layoutSectionId">ID khu vực bố cục</param>
        /// <returns>Số thứ tự tiếp theo</returns>
        public async Task<int> GetNextDisplayOrderAsync(Guid layoutSectionId)
        {
            var maxDisplayOrder = await _tableRepository.GetMaxDisplayOrderInSectionAsync(layoutSectionId);
            return maxDisplayOrder + 1;
        }
    }
}