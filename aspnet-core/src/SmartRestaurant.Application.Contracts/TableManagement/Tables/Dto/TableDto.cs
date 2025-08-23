using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    public class TableDto : FullAuditedEntityDto<Guid>
    {
        /// <summary>Số bàn hiển thị (ví dụ: "B01", "B02", "VIP1")</summary>
        public string TableNumber { get; set; }
        
        /// <summary>Số thứ tự bàn trong khu vực</summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>Trạng thái bàn</summary>
        public TableStatus Status { get; set; }
        
        /// <summary>Bàn có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }
        
        /// <summary>ID khu vực mà bàn này thuộc về</summary>
        public Guid? LayoutSectionId { get; set; }
        
        /// <summary>Tên khu vực (được lấy từ LayoutSection)</summary>
        public string LayoutSectionName { get; set; }
    }
}