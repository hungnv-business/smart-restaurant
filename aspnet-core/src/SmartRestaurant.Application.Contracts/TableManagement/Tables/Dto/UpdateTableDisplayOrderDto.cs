using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    public class UpdateTableDisplayOrderDto
    {
        /// <summary>ID của bàn được di chuyển</summary>
        public Guid TableId { get; set; }
        
        /// <summary>Vị trí mới trong danh sách (1-based)</summary>
        [Range(1, int.MaxValue)]
        public int NewPosition { get; set; }
    }
}