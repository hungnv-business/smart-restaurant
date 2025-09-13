using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.MenuManagement.MenuItems.Dto
{
    public class CreateUpdateMenuItemDto
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Giá phải lớn hơn 0")]
        public decimal Price { get; set; }
        
        public bool IsAvailable { get; set; } = true;
        
        [MaxLength(500)]
        public string? ImageUrl { get; set; }
        
        [Required]
        public Guid CategoryId { get; set; }
        
        /// <summary>
        /// Danh sách nguyên liệu cho món ăn
        /// </summary>
        public List<MenuItemIngredientDto> Ingredients { get; set; } = [];
    }
}