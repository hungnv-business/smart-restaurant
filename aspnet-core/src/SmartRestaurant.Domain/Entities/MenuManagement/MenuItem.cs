using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.MenuManagement
{
    /// <summary>
    /// MenuItem entity representing individual dishes in the restaurant menu
    /// </summary>
    public class MenuItem : FullAuditedEntity<Guid>
    {
        /// <summary>Tên món ăn (ví dụ: "Phở Bò", "Cơm Tấm", "Chả Cá Lá Vọng")</summary>
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        /// <summary>Mô tả chi tiết về món ăn</summary>
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        /// <summary>Giá món ăn (VND)</summary>
        [Required]
        public decimal Price { get; set; }
        
        /// <summary>Món có sẵn để đặt hay không</summary>
        public bool IsAvailable { get; set; }
        
        /// <summary>URL hình ảnh món ăn</summary>
        [MaxLength(500)]
        public string? ImageUrl { get; set; }
        
        /// <summary>ID danh mục menu mà món ăn này thuộc về</summary>
        [Required]
        public Guid CategoryId { get; set; }
        
        // Navigation property cho one-to-many với MenuCategory
        /// <summary>Danh mục menu chứa món ăn này</summary>
        public virtual MenuCategory? Category { get; set; }

        protected MenuItem()
        {
        }

        public MenuItem(
            Guid id,
            string name,
            string? description,
            decimal price,
            bool isAvailable,
            string? imageUrl,
            Guid categoryId) : base(id)
        {
            Name = name;
            Description = description;
            Price = price;
            IsAvailable = isAvailable;
            ImageUrl = imageUrl;
            CategoryId = categoryId;
        }
    }
}