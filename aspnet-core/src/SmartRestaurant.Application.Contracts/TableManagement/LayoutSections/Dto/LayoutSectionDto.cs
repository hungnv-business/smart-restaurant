using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.TableManagement.LayoutSections.Dto
{
    /// <summary>
    /// DTO chứa thông tin khu vực bố cục bàn ăn
    /// Dùng để truyền dữ liệu khu vực giữa các tầng ứng dụng
    /// Bao gồm thông tin audit (tạo, sửa, xóa) từ ABP Framework
    /// </summary>
    public class LayoutSectionDto : FullAuditedEntityDto<Guid>
    {
        /// <summary>Tên khu vực bố cục (ví dụ: "Dãy 1", "Khu VIP", "Sân vườn")</summary>
        public string SectionName { get; set; } = string.Empty;
        
        /// <summary>Mô tả chi tiết khu vực</summary>
        public string? Description { get; set; }
        
        /// <summary>Thứ tự hiển thị khu vực</summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>Khu vực có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }
    }
}