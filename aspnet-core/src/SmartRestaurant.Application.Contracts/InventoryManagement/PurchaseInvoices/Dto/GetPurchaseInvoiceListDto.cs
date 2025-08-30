using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class GetPurchaseInvoiceListDto : PagedAndSortedResultRequestDto
    {
        /// <summary>
        /// Tìm kiếm theo số hóa đơn hoặc tên nhà cung cấp
        /// </summary>
        public string? Filter { get; set; }

        /// <summary>
        /// Lọc từ ngày (DimDate ID)
        /// </summary>
        public int? FromDateId { get; set; }

        /// <summary>
        /// Lọc đến ngày (DimDate ID)
        /// </summary>
        public int? ToDateId { get; set; }
    }
}