using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.LayoutSections.Dto
{
    /// <summary>
    /// DTO dùng để cập nhật thông tin khu vực bố cục bàn ăn
    /// Chứa thông tin có thể thay đổi của khu vực đã tồn tại
    /// </summary>
    public class UpdateLayoutSectionDto
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
        public bool IsActive { get; set; }
    }
}