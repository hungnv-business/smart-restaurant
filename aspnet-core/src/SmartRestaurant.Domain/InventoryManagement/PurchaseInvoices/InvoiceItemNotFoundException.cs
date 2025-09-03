using System;
using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices;

/// <summary>
/// Exception được ném khi không tìm thấy item trong hóa đơn
/// </summary>
public class InvoiceItemNotFoundException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin item
    /// </summary>
    /// <param name="itemId">ID của item không tìm thấy</param>
    public InvoiceItemNotFoundException(Guid itemId) 
        : base(SmartRestaurantDomainErrorCodes.PurchaseInvoices.InvoiceItemNotFound)
    {
        WithData("ItemId", itemId);
    }
}