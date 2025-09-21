using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.TableManagement.Tables;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    /// <summary>
    /// Entity quản lý khu vực bố cục trong nhà hàng
    /// Ví dụ: "Dãy 1", "Khu VIP", "Sân vườn", "Tầng 2"
    /// Mỗi khu vực chứa nhiều bàn ăn
    /// </summary>
    public class LayoutSection : FullAuditedEntity<Guid>
    {
        /// <summary>Tên khu vực bố cục (ví dụ: "Dãy 1", "Khu VIP", "Sân vườn")</summary>
        [Required]
        [MaxLength(128)]
        public string SectionName { get; set; }

        /// <summary>Mô tả chi tiết khu vực</summary>
        [MaxLength(512)]
        public string? Description { get; set; }

        /// <summary>Thứ tự hiển thị khu vực</summary>
        public int DisplayOrder { get; set; }

        /// <summary>Khu vực có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }

        // Navigation properties
        /// <summary>Danh sách bàn thuộc khu vực này</summary>
        public virtual ICollection<Table> Tables { get; set; }

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected LayoutSection()
        {
            Tables = new HashSet<Table>();
        }

        /// <summary>
        /// Constructor với tham số để tạo khu vực bố cục mới
        /// </summary>
        /// <param name="id">ID của khu vực</param>
        /// <param name="sectionName">Tên khu vực</param>
        /// <param name="description">Mô tả khu vực</param>
        /// <param name="displayOrder">Thứ tự hiển thị</param>
        /// <param name="isActive">Trạng thái hoạt động</param>
        public LayoutSection(
            Guid id,
            string sectionName,
            string? description = null,
            int displayOrder = 0,
            bool isActive = true
        ) : base(id)
        {
            SectionName = sectionName;
            Description = description;
            DisplayOrder = displayOrder;
            IsActive = isActive;
            Tables = new HashSet<Table>();
        }
    }
}