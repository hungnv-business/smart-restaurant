using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.MenuManagement;

namespace SmartRestaurant.Entities.MenuManagement
{
    /// <summary>
    /// Domain Entity cho Danh mục món ăn - Level 1 CRUD
    /// Kế thừa FullAuditedEntity để có đầy đủ audit fields và soft delete
    /// </summary>
    public class MenuCategory : FullAuditedEntity<Guid>
    {
        /// <summary>
        /// Tên danh mục món ăn - Required field, tối đa 128 ký tự
        /// Ví dụ: "Món khai vị", "Món chính", "Tráng miệng"
        /// </summary>
        [Required]
        [StringLength(MenuCategoryConsts.MaxNameLength)]
        public string Name { get; set; }

        /// <summary>
        /// Mô tả chi tiết về danh mục - Optional field, tối đa 512 ký tự
        /// Dùng để giải thích thêm về loại món ăn trong danh mục
        /// </summary>
        [StringLength(MenuCategoryConsts.MaxDescriptionLength)]
        public string? Description { get; set; }

        /// <summary>
        /// Thứ tự hiển thị danh mục trong menu - dùng để sắp xếp
        /// Số nhỏ hơn sẽ hiển thị trước, bắt đầu từ 1
        /// </summary>
        public int DisplayOrder { get; set; }

        /// <summary>
        /// Trạng thái kích hoạt danh mục - true: hiển thị, false: ẩn
        /// Dùng để tạm thời ẩn/hiện danh mục mà không cần xóa
        /// </summary>
        public bool IsEnabled { get; set; }

        /// <summary>
        /// URL hình ảnh đại diện cho danh mục - Optional, tối đa 2048 ký tự
        /// Dùng để hiển thị icon hoặc banner cho danh mục
        /// </summary>
        [StringLength(MenuCategoryConsts.MaxImageUrlLength)]
        public string? ImageUrl { get; set; }


        // Navigation properties
        /// <summary>
        /// Danh sách món ăn trong danh mục này
        /// </summary>
        public virtual ICollection<MenuItem> MenuItems { get; set; } = new List<MenuItem>();

        // Constructor cho EF Core
        protected MenuCategory()
        {
        }

        // Business constructor với validation - sử dụng trong Application layer
        public MenuCategory(
            Guid id,
            string name,
            string description = null,
            int displayOrder = 0,
            bool isEnabled = true,
            string imageUrl = null) : base(id)
        {
            Name = name;
            Description = description;
            DisplayOrder = displayOrder;
            IsEnabled = isEnabled;
            ImageUrl = imageUrl;
        }
    }
}