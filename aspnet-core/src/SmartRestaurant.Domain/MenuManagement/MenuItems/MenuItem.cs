using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using JetBrains.Annotations;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.Orders;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.Guids;

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
        /// Thêm nhiều MenuItemIngredient vào món ăn
        /// </summary>
        public void AddMenuItemIngredients(IGuidGenerator guidGenerator, IEnumerable<MenuItemIngredient> ingredients)
        {
            Check.NotNull(guidGenerator, nameof(guidGenerator));
            Check.NotNull(ingredients, nameof(ingredients));

            foreach (var ingredient in ingredients)
            {
                AddMenuItemIngredient(guidGenerator, ingredient);
            }
        }

        /// <summary>
        /// Thêm một MenuItemIngredient vào món ăn
        /// </summary>
        public void AddMenuItemIngredient(IGuidGenerator guidGenerator, MenuItemIngredient ingredient)
        {
            Check.NotNull(guidGenerator, nameof(guidGenerator));
            Check.NotNull(ingredient, nameof(ingredient));

            if (IsInMenuItemIngredient(ingredient.Id))
            {
                var existing = Ingredients.First(i => i.Id == ingredient.Id);
                existing.UpdateEntity(ingredient.IngredientId, ingredient.RequiredQuantity, ingredient.DisplayOrder);
                return;
            }

            var newIngredient = new MenuItemIngredient(
                guidGenerator.Create(),
                Id,
                ingredient.IngredientId,
                ingredient.RequiredQuantity,
                ingredient.DisplayOrder);

            Ingredients.Add(newIngredient);
        }


        /// <summary>
        /// Kiểm tra MenuItemIngredient có tồn tại trong món ăn không (theo Id)
        /// </summary>
        public bool IsInMenuItemIngredient(Guid? id)
        {
            Check.NotNull(id, nameof(id));
            return Ingredients.Any(i => i.Id == id);
        }


        /// <summary>
        /// Xóa nhiều MenuItemIngredient
        /// </summary>
        public void RemoveMenuItemIngredients(IEnumerable<MenuItemIngredient> ingredients)
        {
            Check.NotNull(ingredients, nameof(ingredients));

            foreach (var ingredient in ingredients)
            {
                RemoveMenuItemIngredient(ingredient);
            }
        }

        /// <summary>
        /// Xóa một MenuItemIngredient
        /// </summary>
        public void RemoveMenuItemIngredient(MenuItemIngredient ingredient)
        {
            Check.NotNull(ingredient, nameof(ingredient));

            if (!IsInMenuItemIngredient(ingredient.Id))
            {
                return;
            }

            Ingredients.Remove(ingredient);
        }


        /// <summary>
        /// Xóa tất cả nguyên liệu khỏi món ăn
        /// </summary>
        public void ClearIngredients()
        {
            Ingredients.Clear();
        }

        /// <summary>
        /// Cập nhật toàn bộ entity với ingredients mới
        /// </summary>
        public void UpdateEntity(
            IGuidGenerator guidGenerator,
            [NotNull] string name,
            string? description,
            decimal price,
            bool isAvailable,
            string? imageUrl,
            [NotNull] Guid categoryId,
            IEnumerable<MenuItemIngredient> ingredients)
        {
            Check.NotNull(guidGenerator, nameof(guidGenerator));
            Check.NotNullOrWhiteSpace(name, nameof(name));
            Check.NotNull(categoryId, nameof(categoryId));

            Name = name;
            Description = description;
            Price = price;
            IsAvailable = isAvailable;
            ImageUrl = imageUrl;
            CategoryId = categoryId;

            // Xóa nguyên liệu
            var currentIds = this.Ingredients.Select(e => e.Id).ToList();
            var inputIds = ingredients.Select(e => e.Id).ToList();

            var remove = this.Ingredients.Where(e => !inputIds.Contains(e.Id)).ToList();
            this.RemoveMenuItemIngredients(remove);

            AddMenuItemIngredients(guidGenerator, ingredients);
        }
    }
}