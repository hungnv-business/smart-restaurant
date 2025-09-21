using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.LayoutSections.Dto
{
    /// <summary>
    /// DTO dùng để tạo mới khu vực bố cục bàn ăn
    /// Chứa thông tin cần thiết để khởi tạo khu vực mới trong nhà hàng
    /// </summary>
    public class CreateLayoutSectionDto
    {
        /// <summary>Tên khu vực bố cục (ví dụ: "Dãy 1", "Khu VIP", "Sân vườn")</summary>
        [Required]
        [MaxLength(128)]
        public string SectionName { get; set; } = string.Empty;

        /// <summary>Mô tả chi tiết khu vực</summary>
        [MaxLength(512)]
        public string? Description { get; set; }

        /// <summary>Thứ tự hiển thị khu vực</summary>
        public int DisplayOrder { get; set; }

        /// <summary>Khu vực có đang hoạt động hay không</summary>
        public bool IsActive { get; set; } = true;
    }
}