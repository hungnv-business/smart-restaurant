using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.IngredientCategories.Dto;

public class CreateUpdateIngredientCategoryDto
{
    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(512)]
    public string? Description { get; set; }
    
    public int DisplayOrder { get; set; }
    
    public bool IsActive { get; set; } = true;
}