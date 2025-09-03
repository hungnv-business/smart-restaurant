using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.MenuManagement.MenuCategories;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Entity món ăn đại diện cho từng món trong thực đơn nhà hàng
    /// Mỗi món ăn thuộc về một danh mục và có thể liên kết với nguyên liệu chính
    /// Hỗ trợ quản lý giá cả, tình trạng có sẵn và hình ảnh
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

        /// <summary>ID nguyên liệu chính cho món ăn (để tracking inventory)</summary>
        public Guid? PrimaryIngredientId { get; set; }

        /// <summary>Số lượng nguyên liệu chính cần dùng (theo base unit)</summary>
        public int? RequiredQuantity { get; set; }
        
        // Navigation properties
        /// <summary>Danh mục menu chứa món ăn này</summary>
        public virtual MenuCategory? Category { get; set; }

        /// <summary>Nguyên liệu chính của món ăn</summary>
        public virtual Ingredient PrimaryIngredient { get; set; } = null!;

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected MenuItem()
        {
        }

        /// <summary>
        /// Constructor tạo mới món ăn với đầy đủ thông tin
        /// </summary>
        /// <param name="id">ID duy nhất của món ăn</param>
        /// <param name="name">Tên món ăn</param>
        /// <param name="description">Mô tả chi tiết món ăn</param>
        /// <param name="price">Giá món ăn (VND)</param>
        /// <param name="isAvailable">Tình trạng có sẵn</param>
        /// <param name="imageUrl">URL hình ảnh món ăn</param>
        /// <param name="categoryId">ID danh mục chứa món ăn</param>
        /// <param name="primaryIngredientId">ID nguyên liệu chính (tùy chọn)</param>
        /// <param name="requiredQuantity">Số lượng nguyên liệu cần dùng (tùy chọn)</param>
        public MenuItem(
            Guid id,
            string name,
            string? description,
            decimal price,
            bool isAvailable,
            string? imageUrl,
            Guid categoryId,
            Guid? primaryIngredientId = null,
            int? requiredQuantity = null) : base(id)
        {
            if (requiredQuantity.HasValue && requiredQuantity <= 0)
            {
                throw new ArgumentException("Required quantity must be greater than 0", nameof(requiredQuantity));
            }

            Name = name;
            Description = description;
            Price = price;
            IsAvailable = isAvailable;
            ImageUrl = imageUrl;
            CategoryId = categoryId;
            PrimaryIngredientId = primaryIngredientId;
            RequiredQuantity = requiredQuantity;
        }
    }
}