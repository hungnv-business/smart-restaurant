using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices;

/// <summary>
/// Exception được ném khi số lượng không hợp lệ
/// </summary>
public class InvalidQuantityException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với số lượng không hợp lệ
    /// </summary>
    /// <param name="quantity">Số lượng không hợp lệ</param>
    public InvalidQuantityException(int quantity)
        : base(SmartRestaurantDomainErrorCodes.PurchaseInvoices.InvalidQuantity)
    {
        WithData("Quantity", quantity);
    }
}