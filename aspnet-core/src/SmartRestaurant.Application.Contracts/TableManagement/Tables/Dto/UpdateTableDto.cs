using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    public class UpdateTableDto
    {
        /// <summary>Số bàn hiển thị (ví dụ: "B01", "B02", "VIP1")</summary>
        [Required]
        [MaxLength(64)]
        public string TableNumber { get; set; }

        /// <summary>Số thứ tự bàn trong khu vực</summary>
        public int DisplayOrder { get; set; }

        /// <summary>Trạng thái bàn</summary>
        public TableStatus Status { get; set; }

        /// <summary>Bàn có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }

        /// <summary>ID khu vực mà bàn này thuộc về</summary>
        [Required]
        public Guid LayoutSectionId { get; set; }
    }
}