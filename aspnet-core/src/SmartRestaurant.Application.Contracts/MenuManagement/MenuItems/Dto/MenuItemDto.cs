using System;
using Volo.Abp.Application.Dtos;

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
        
        public string? CategoryName { get; set; }
        
        /// <summary>
        /// Số lượng đã bán ra (tổng từ tất cả orders đã hoàn thành)
        /// </summary>
        public int SoldQuantity { get; set; }
        
        /// <summary>
        /// Món có phổ biến không (dựa trên số lượng bán)
        /// </summary>
        public bool IsPopular { get; set; }
    }
}