using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    public class AssignTableToSectionDto
    {
        /// <summary>ID khu vực mà bàn sẽ được gán vào</summary>
        [Required]
        public Guid LayoutSectionId { get; set; }
        
        /// <summary>Vị trí mới trong section đích (1-based, optional - mặc định sẽ thêm vào cuối)</summary>
        [Range(1, int.MaxValue)]
        public int? NewPosition { get; set; }
    }
}