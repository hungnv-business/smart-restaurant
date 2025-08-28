using System;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;

namespace SmartRestaurant.MenuManagement.MenuItems.Dto
{
    public class MenuItemDto : FullAuditedEntityDto<Guid>
    {
        public string Name { get; set; } = string.Empty;
        
        public string? Description { get; set; }
        
        public decimal Price { get; set; }
        
        public bool IsAvailable { get; set; }
        
        public string? ImageUrl { get; set; }
        
        public Guid CategoryId { get; set; }
        
        public MenuCategoryDto? Category { get; set; }
    }
}