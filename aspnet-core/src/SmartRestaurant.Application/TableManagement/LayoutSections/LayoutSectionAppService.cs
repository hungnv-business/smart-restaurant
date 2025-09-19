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
    /// <summary>
    /// Dịch vụ ứng dụng cho quản lý khu vực bố cục bàn
    /// Xử lý tất cả business logic liên quan đến khu vực bàn ăn
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Default)]
    public class LayoutSectionAppService : ApplicationService, ILayoutSectionAppService
    {
        /// <summary>Repository để truy cập dữ liệu khu vực bố cục</summary>
        private readonly IRepository<LayoutSection, Guid> _repository;

        /// <summary>
        /// Constructor - khởi tạo dịch vụ quản lý khu vực bố cục
        /// </summary>
        /// <param name="repository">Repository để truy cập dữ liệu</param>
        public LayoutSectionAppService(IRepository<LayoutSection, Guid> repository)
        {
            _repository = repository;
        }

        /// <summary>
        /// Lấy danh sách tất cả khu vực bố cục trong nhà hàng
        /// Sắp xếp theo thứ tự hiển thị và tên khu vực
        /// </summary>
        /// <returns>Danh sách khu vực được sắp xếp</returns>
        public async Task<IList<LayoutSectionDto>> GetListAsync()
        {
            var sections = await _repository.GetListAsync();
            return sections
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.SectionName)
                .Select(section => ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section))
                .ToList();
        }

        /// <summary>
        /// Lấy thông tin chi tiết một khu vực bố cục
        /// </summary>
        /// <param name="id">ID của khu vực cần lấy</param>
        /// <returns>Thông tin chi tiết khu vực</returns>
        public async Task<LayoutSectionDto> GetAsync(Guid id)
        {
            var section = await _repository.GetAsync(id);
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }

        /// <summary>
        /// Tạo mới một khu vực bố cục trong nhà hàng
        /// Ví dụ: "Dãy 1", "Khu VIP", "Sân vườn"
        /// </summary>
        /// <param name="input">Dữ liệu khu vực mới</param>
        /// <returns>Thông tin khu vực vừa được tạo</returns>
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

        /// <summary>
        /// Cập nhật thông tin khu vực bố cục
        /// Có thể thay đổi tên, mô tả, thứ tự hiển thị
        /// </summary>
        /// <param name="id">ID của khu vực cần cập nhật</param>
        /// <param name="input">Dữ liệu cập nhật</param>
        /// <returns>Thông tin khu vực sau khi cập nhật</returns>
        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Edit)]
        public async Task<LayoutSectionDto> UpdateAsync(Guid id, UpdateLayoutSectionDto input)
        {
            var section = await _repository.GetAsync(id);
            
            ObjectMapper.Map(input, section);
            await _repository.UpdateAsync(section, autoSave: true);
            
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }

        /// <summary>
        /// Xóa một khu vực bố cục khỏi hệ thống
        /// Lưu ý: Chỉ xóa được khi không còn bàn nào trong khu vực
        /// </summary>
        /// <param name="id">ID của khu vực cần xóa</param>
        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            await _repository.DeleteAsync(id);
        }

        /// <summary>
        /// Tính toán số thứ tự hiển thị tiếp theo cho khu vực mới
        /// Đảm bảo khu vực mới luôn hiển thị cuối danh sách
        /// </summary>
        /// <returns>Số thứ tự tiếp theo (bắt đầu từ 1)</returns>
        public async Task<int> GetNextDisplayOrderAsync()
        {
            var hasAny = await _repository.AnyAsync();
            if (!hasAny)
                return 1; // Khu vực đầu tiên có thứ tự là 1
                
            var maxOrder = await _repository.MaxAsync(x => x.DisplayOrder);
            return maxOrder + 1;
        }

        /// <summary>
        /// Cập nhật trạng thái kích hoạt của khu vực bố cục
        /// Cho phép nhanh chóng bật/tắt khu vực mà không cần cập nhật toàn bộ thông tin
        /// </summary>
        /// <param name="id">ID của khu vực cần cập nhật trạng thái</param>
        /// <param name="isActive">Trạng thái mới (true = kích hoạt, false = vô hiệu hóa)</param>
        /// <returns>Thông tin khu vực sau khi cập nhật trạng thái</returns>
        [Authorize(SmartRestaurantPermissions.Tables.LayoutSection.Edit)]
        public async Task<LayoutSectionDto> UpdateStatusAsync(Guid id, bool isActive)
        {
            var section = await _repository.GetAsync(id);
            section.IsActive = isActive;
            
            await _repository.UpdateAsync(section, autoSave: true);
            
            return ObjectMapper.Map<LayoutSection, LayoutSectionDto>(section);
        }
    }
}