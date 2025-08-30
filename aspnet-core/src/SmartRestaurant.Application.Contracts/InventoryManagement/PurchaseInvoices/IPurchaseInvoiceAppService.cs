using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    public interface IPurchaseInvoiceAppService : IApplicationService
    {
        Task<PurchaseInvoiceDto> GetAsync(Guid id);
        Task<PurchaseInvoiceDto> CreateAsync(CreateUpdatePurchaseInvoiceDto input);
        Task<PurchaseInvoiceDto> UpdateAsync(Guid id, CreateUpdatePurchaseInvoiceDto input);
        Task DeleteAsync(Guid id);
        Task<PagedResultDto<PurchaseInvoiceDto>> GetListAsync(GetPurchaseInvoiceListDto input);
        Task<IngredientLookupDto?> GetIngredientLookupAsync(Guid ingredientId);
    }
}