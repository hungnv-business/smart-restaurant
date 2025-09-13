using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.MenuManagement.MenuItems.Dto
{
    /// <summary>
    /// DTO cho nguyên liệu trong MenuItem
    /// </summary>
    public class MenuItemIngredientDto : EntityDto<Guid?>
    {
        [Required]
        public Guid IngredientId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
        public int RequiredQuantity { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Thứ tự hiển thị phải lớn hơn hoặc bằng 0")]
        public int DisplayOrder { get; set; } = 0;
    }
}