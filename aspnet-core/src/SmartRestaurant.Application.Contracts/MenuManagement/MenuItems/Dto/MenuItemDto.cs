using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.MenuManagement.MenuItems.Dto
{
    public class MenuItemDto : FullAuditedEntityDto<Guid>
    {
        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }

        public int Price { get; set; }

        public bool IsAvailable { get; set; }

        public string? ImageUrl { get; set; }

        public Guid CategoryId { get; set; }

        public string? CategoryName { get; set; }

        /// <summary>
        /// Món ăn có thể nấu nhanh không
        /// </summary>
        public bool IsQuickCook { get; set; }

        /// <summary>
        /// Món ăn có cần phải nấu không
        /// </summary>
        public bool RequiresCooking { get; set; }

        /// <summary>
        /// Số lượng đã bán ra (tổng từ tất cả orders đã hoàn thành)
        /// </summary>
        public int SoldQuantity { get; set; }

        /// <summary>
        /// Món có phổ biến không (dựa trên số lượng bán)
        /// </summary>
        public bool IsPopular { get; set; }

        /// <summary>
        /// Số lượng tối đa có thể làm được dựa vào tồn kho nguyên liệu
        /// int.MaxValue nếu không có giới hạn
        /// </summary>
        public int MaximumQuantityAvailable { get; set; }

        /// <summary>
        /// Món có hết hàng không (không thể làm được)
        /// </summary>
        public bool IsOutOfStock { get; set; }

        /// <summary>
        /// Có tồn kho hạn chế không (< 10 phần)
        /// </summary>
        public bool HasLimitedStock { get; set; }

        /// <summary>
        /// Danh sách nguyên liệu cho món ăn
        /// </summary>
        public List<MenuItemIngredientDto> Ingredients { get; set; } = [];
    }
}