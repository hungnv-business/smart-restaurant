using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.Tables
{
    public class Table : FullAuditedEntity<Guid>
    {
        /// <summary>Tên bàn (ví dụ: "Bàn 01", "Bàn VIP A1")</summary>
        [Required]
        [MaxLength(64)]
        public string TableName { get; set; }
        
        /// <summary>Số thứ tự bàn trong khu vực</summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>Trạng thái bàn</summary>
        public TableStatus Status { get; set; }
        
        /// <summary>Bàn có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }
        
        /// <summary>ID khu vực mà bàn này thuộc về</summary>
        public Guid? LayoutSectionId { get; set; }
        
        // Navigation properties
        /// <summary>Khu vực mà bàn này thuộc về</summary>
        public virtual LayoutSection LayoutSection { get; set; }

        protected Table()
        {
        }

        public Table(
            Guid id,
            string tableName,
            int displayOrder = 0,
            TableStatus status = TableStatus.Available,
            bool isActive = true,
            Guid? layoutSectionId = null
        ) : base(id)
        {
            TableName = tableName;
            DisplayOrder = displayOrder;
            Status = status;
            IsActive = isActive;
            LayoutSectionId = layoutSectionId;
        }
    }
}