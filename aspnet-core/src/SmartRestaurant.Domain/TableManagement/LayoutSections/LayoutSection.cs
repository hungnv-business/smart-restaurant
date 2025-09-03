using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.TableManagement.Tables;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.TableManagement.LayoutSections
{
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

        protected LayoutSection()
        {
            Tables = new HashSet<Table>();
        }

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