using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices;

/// <summary>
/// Exception được ném khi không đủ tồn kho
/// </summary>
public class InsufficientStockException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin tồn kho
    /// </summary>
    /// <param name="ingredientName">Tên nguyên liệu</param>
    /// <param name="currentStock">Tồn kho hiện tại</param>
    /// <param name="requiredQuantity">Số lượng yêu cầu</param>
    public InsufficientStockException(string ingredientName, int currentStock, int requiredQuantity)
        : base(SmartRestaurantDomainErrorCodes.Ingredients.InsufficientStock)
    {
        WithData("IngredientName", ingredientName);
        WithData("CurrentStock", currentStock);
        WithData("RequiredQuantity", requiredQuantity);
    }
}