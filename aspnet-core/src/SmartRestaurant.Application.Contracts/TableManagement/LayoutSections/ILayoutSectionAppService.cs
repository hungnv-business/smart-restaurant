using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.TableManagement.LayoutSections.Dto;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    /// <summary>
    /// Interface dịch vụ ứng dụng cho quản lý khu vực bố cục
    /// Cung cấp các phương thức CRUD cho khu vực bàn trong nhà hàng
    /// </summary>
    public interface ILayoutSectionAppService : IApplicationService
    {
        /// <summary>
        /// Lấy danh sách tất cả khu vực bố cục
        /// Sắp xếp theo thứ tự hiển thị và tên khu vực
        /// </summary>
        /// <returns>Danh sách DTO khu vực bố cục</returns>
        Task<IList<LayoutSectionDto>> GetListAsync();

        /// <summary>
        /// Lấy thông tin chi tiết một khu vực bố cục theo ID
        /// </summary>
        /// <param name="id">ID của khu vực bố cục</param>
        /// <returns>DTO thông tin khu vực</returns>
        Task<LayoutSectionDto> GetAsync(Guid id);

        /// <summary>
        /// Tạo mới một khu vực bố cục
        /// </summary>
        /// <param name="input">Dữ liệu tạo khu vực mới</param>
        /// <returns>DTO khu vực vừa được tạo</returns>
        Task<LayoutSectionDto> CreateAsync(CreateLayoutSectionDto input);

        /// <summary>
        /// Cập nhật thông tin khu vực bố cục
        /// </summary>
        /// <param name="id">ID của khu vực cần cập nhật</param>
        /// <param name="input">Dữ liệu cập nhật</param>
        /// <returns>DTO khu vực sau khi cập nhật</returns>
        Task<LayoutSectionDto> UpdateAsync(Guid id, UpdateLayoutSectionDto input);

        /// <summary>
        /// Xóa một khu vực bố cục
        /// </summary>
        /// <param name="id">ID của khu vực cần xóa</param>
        Task DeleteAsync(Guid id);

        /// <summary>
        /// Lấy số thứ tự hiển thị tiếp theo cho khu vực mới
        /// </summary>
        /// <returns>Số thứ tự hiển thị tiếp theo</returns>
        Task<int> GetNextDisplayOrderAsync();
    }
}