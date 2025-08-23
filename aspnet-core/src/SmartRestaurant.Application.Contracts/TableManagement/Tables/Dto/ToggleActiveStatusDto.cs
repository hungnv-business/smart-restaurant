using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    /// <summary>
    /// DTO để thay đổi trạng thái kích hoạt của bàn
    /// </summary>
    public class ToggleActiveStatusDto
    {
        /// <summary>Trạng thái kích hoạt mới</summary>
        [Required]
        public bool IsActive { get; set; }
    }
}