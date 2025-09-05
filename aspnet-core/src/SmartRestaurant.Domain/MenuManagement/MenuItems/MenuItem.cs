using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.Orders;
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

        
        // Navigation properties
        /// <summary>Danh mục menu chứa món ăn này</summary>
        public virtual MenuCategory? Category { get; set; }


        /// <summary>
        /// Danh sách nguyên liệu sử dụng trong món ăn này (nhiều-nhiều relationship)
        /// </summary>
        public virtual ICollection<MenuItemIngredient> Ingredients { get; set; } = new List<MenuItemIngredient>();

        /// <summary>
        /// Danh sách OrderItems sử dụng món ăn này
        /// </summary>
        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected MenuItem()
        {
        }

        /// <summary>
        /// Constructor tạo mới món ăn với Recipe system (recommended)
        /// </summary>
        /// <param name="id">ID duy nhất của món ăn</param>
        /// <param name="name">Tên món ăn</param>
        /// <param name="description">Mô tả chi tiết món ăn</param>
        /// <param name="price">Giá món ăn (VND)</param>
        /// <param name="isAvailable">Tình trạng có sẵn</param>
        /// <param name="imageUrl">URL hình ảnh món ăn</param>
        /// <param name="categoryId">ID danh mục chứa món ăn</param>
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
            
            // Initialize collections
            Ingredients = new List<MenuItemIngredient>();
            OrderItems = new List<OrderItem>();
        }


        /// <summary>
        /// Thêm nguyên liệu vào recipe của món ăn
        /// </summary>
        /// <param name="ingredientId">ID nguyên liệu</param>
        /// <param name="requiredQuantity">Số lượng cần thiết</param>
        /// <param name="isOptional">Có tùy chọn không</param>
        /// <param name="preparationNotes">Ghi chú chuẩn bị</param>
        /// <param name="displayOrder">Thứ tự hiển thị</param>
        /// <returns>MenuItemIngredient được tạo</returns>
        public MenuItemIngredient AddIngredient(
            Guid ingredientId, 
            int requiredQuantity, 
            bool isOptional = false, 
            string? preparationNotes = null, 
            int displayOrder = 0)
        {
            var ingredient = new MenuItemIngredient(
                Guid.NewGuid(),
                Id,
                ingredientId,
                requiredQuantity,
                isOptional,
                preparationNotes,
                displayOrder);

            Ingredients.Add(ingredient);
            return ingredient;
        }
    }
}