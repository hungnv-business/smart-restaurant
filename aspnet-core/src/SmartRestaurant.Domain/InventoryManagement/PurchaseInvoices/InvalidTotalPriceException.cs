using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices;

/// <summary>
/// Exception được ném khi tổng tiền không hợp lệ
/// </summary>
public class InvalidTotalPriceException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tổng tiền không hợp lệ
    /// </summary>
    /// <param name="totalPrice">Tổng tiền không hợp lệ</param>
    public InvalidTotalPriceException(int totalPrice) 
        : base(SmartRestaurantDomainErrorCodes.PurchaseInvoices.InvalidTotalPrice)
    {
        WithData("TotalPrice", totalPrice);
    }
}