using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.InventoryManagement.Ingredients;

namespace SmartRestaurant.MenuManagement.MenuItemIngredients;

/// <summary>
/// Entity MenuItemIngredient đại diện cho mối quan hệ nhiều-nhiều giữa MenuItem và Ingredient
/// Cho phép một món ăn có nhiều nguyên liệu và một nguyên liệu được sử dụng trong nhiều món ăn
/// </summary>
public class MenuItemIngredient : Entity<Guid>
{
    /// <summary>
    /// ID của món ăn
    /// </summary>
    [Required]
    public Guid MenuItemId { get; set; }

    /// <summary>
    /// ID của nguyên liệu
    /// </summary>
    [Required]
    public Guid IngredientId { get; set; }

    /// <summary>
    /// Số lượng nguyên liệu cần thiết (tính theo đơn vị cơ sở của nguyên liệu)
    /// Ví dụ: 200 (gram thịt bò), 1 (quả trứng)
    /// </summary>
    [Range(0, int.MaxValue, ErrorMessage = "Số lượng nguyên liệu phải lớn hơn hoặc bằng 0")]
    public int RequiredQuantity { get; set; } = 1;

    /// <summary>
    /// Nguyên liệu có tùy chọn hay bắt buộc
    /// - false: Bắt buộc (ví dụ: thịt bò trong phở bò)
    /// - true: Tùy chọn (ví dụ: hành lá, rau thơm)
    /// </summary>
    public bool IsOptional { get; set; } = false;

    /// <summary>
    /// Ghi chú về cách sử dụng nguyên liệu trong món này
    /// Ví dụ: "Cắt lát mỏng", "Thái hạt lựu", "Ướp gia vị 30 phút"
    /// </summary>
    [StringLength(500)]
    public string? PreparationNotes { get; set; }

    /// <summary>
    /// Thứ tự hiển thị nguyên liệu trong công thức (để sắp xếp theo độ quan trọng)
    /// </summary>
    public int DisplayOrder { get; set; } = 0;

    // Navigation Properties

    /// <summary>
    /// Món ăn sử dụng nguyên liệu này
    /// </summary>
    public virtual MenuItem MenuItem { get; set; } = null!;

    /// <summary>
    /// Nguyên liệu được sử dụng
    /// </summary>
    public virtual Ingredient Ingredient { get; set; } = null!;

    // Constructor
    protected MenuItemIngredient()
    {
        // Parameterless constructor for EF Core
    }

    public MenuItemIngredient(
        Guid id,
        Guid menuItemId,
        Guid ingredientId,
        int requiredQuantity,
        bool isOptional = false,
        string? preparationNotes = null,
        int displayOrder = 0) : base(id)
    {
        MenuItemId = menuItemId;
        IngredientId = ingredientId;
        RequiredQuantity = requiredQuantity;
        IsOptional = isOptional;
        PreparationNotes = preparationNotes;
        DisplayOrder = displayOrder;
    }

    /// <summary>
    /// Cập nhật số lượng nguyên liệu cần thiết
    /// </summary>
    /// <param name="newQuantity">Số lượng mới</param>
    public void UpdateRequiredQuantity(int newQuantity)
    {
        if (newQuantity < 0)
        {
            throw new ArgumentException("Số lượng nguyên liệu không thể âm", nameof(newQuantity));
        }

        RequiredQuantity = newQuantity;
    }

    /// <summary>
    /// Cập nhật ghi chú chuẩn bị
    /// </summary>
    /// <param name="notes">Ghi chú mới</param>
    public void UpdatePreparationNotes(string? notes)
    {
        PreparationNotes = notes?.Trim();
    }

    /// <summary>
    /// Đánh dấu nguyên liệu là tùy chọn hoặc bắt buộc
    /// </summary>
    /// <param name="isOptional">True nếu tùy chọn, False nếu bắt buộc</param>
    public void SetOptional(bool isOptional)
    {
        IsOptional = isOptional;
    }
}