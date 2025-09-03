using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.TableManagement.LayoutSections;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.TableManagement.Tables
{
    public class Table : FullAuditedEntity<Guid>
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
        public Guid? LayoutSectionId { get; set; }
        
        // Navigation properties
        /// <summary>Khu vực mà bàn này thuộc về</summary>
        public virtual LayoutSection LayoutSection { get; set; }

        protected Table()
        {
        }

        public Table(
            Guid id,
            string tableNumber,
            int displayOrder = 0,
            TableStatus status = TableStatus.Available,
            bool isActive = true,
            Guid? layoutSectionId = null
        ) : base(id)
        {
            TableNumber = tableNumber;
            DisplayOrder = displayOrder;
            Status = status;
            IsActive = isActive;
            LayoutSectionId = layoutSectionId;
        }

        public void AssignToSection(Guid layoutSectionId)
        {
            LayoutSectionId = layoutSectionId;
        }

        public void UpdateDisplayOrder(int displayOrder)
        {
            DisplayOrder = displayOrder;
        }

        public void UpdateStatus(TableStatus status)
        {
            Status = status;
        }
    }
}