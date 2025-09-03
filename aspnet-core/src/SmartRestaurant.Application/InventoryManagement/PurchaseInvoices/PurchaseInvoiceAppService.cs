using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Permissions;
using SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Entities;
using System.Linq.Dynamic.Core;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    /// <summary>
    /// Application Service cho PurchaseInvoice - Level 2 Custom Repository Pattern
    /// Implement trực tiếp IPurchaseInvoiceAppService với custom repository
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
    public class PurchaseInvoiceAppService : ApplicationService, IPurchaseInvoiceAppService
    {
        private readonly IPurchaseInvoiceRepository _purchaseInvoiceRepository;
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;
        private readonly IIngredientRepository _ingredientDetailRepository;
        private readonly PurchaseInvoiceManager _purchaseInvoiceManager;

        public PurchaseInvoiceAppService(
            IPurchaseInvoiceRepository purchaseInvoiceRepository,
            IRepository<Ingredient, Guid> ingredientRepository,
            IIngredientRepository ingredientDetailRepository,
            PurchaseInvoiceManager purchaseInvoiceManager)
        {
            _purchaseInvoiceRepository = purchaseInvoiceRepository;
            _ingredientRepository = ingredientRepository;
            _ingredientDetailRepository = ingredientDetailRepository;
            _purchaseInvoiceManager = purchaseInvoiceManager;
        }

        /// <summary>
        /// Lấy thông tin chi tiết hóa đơn mua theo ID
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
        public async Task<PurchaseInvoiceDto> GetAsync(Guid id)
        {
            var purchaseInvoice = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);

            if (purchaseInvoice == null)
            {
                throw new EntityNotFoundException(typeof(PurchaseInvoice), id);
            }

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(purchaseInvoice);
        }

        /// <summary>
        /// Tạo mới hóa đơn mua với các mặt hàng
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Create)]
        public async Task<PurchaseInvoiceDto> CreateAsync(CreateUpdatePurchaseInvoiceDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Tạo entity chính
            var purchaseInvoice = new PurchaseInvoice(
                GuidGenerator.Create(),
                input.InvoiceNumber,
                input.InvoiceDateId,
                input.Notes);

            // Thêm các mặt hàng sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.AddPurchaseInvoiceItemsAsync(purchaseInvoice, input.Items);

            // Tính tổng tiền hóa đơn
            purchaseInvoice.CalculateTotalAmount();

            // Lưu hóa đơn cùng với chi tiết mặt hàng
            var insertedEntity = await _purchaseInvoiceRepository.InsertAsync(purchaseInvoice);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(insertedEntity);
        }

        /// <summary>
        /// Cập nhật hóa đơn mua và các mặt hàng
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Edit)]
        public async Task<PurchaseInvoiceDto> UpdateAsync(Guid id, CreateUpdatePurchaseInvoiceDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Lấy entity hiện có cùng với chi tiết mặt hàng
            var existingEntity = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);

            if (existingEntity is null)
                throw new EntityNotFoundException(typeof(PurchaseInvoice), id);

            // Kiểm tra có thể chỉnh sửa không
            existingEntity.ValidateCanEdit();

            // Cập nhật thông tin cơ bản
            existingEntity.InvoiceNumber = input.InvoiceNumber;
            existingEntity.InvoiceDateId = input.InvoiceDateId;
            existingEntity.Notes = input.Notes;

            // Cập nhật danh sách mặt hàng sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.UpdatePurchaseInvoiceItemsAsync(existingEntity, input.Items);

            // Tính lại tổng tiền
            existingEntity.CalculateTotalAmount();

            var updatedEntity = await _purchaseInvoiceRepository.UpdateAsync(existingEntity);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(updatedEntity);
        }

        /// <summary>
        /// Lấy danh sách hóa đơn mua có phân trang và lọc
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Default)]
        public async Task<PagedResultDto<PurchaseInvoiceDto>> GetListAsync(GetPurchaseInvoiceListDto input)
        {
            if (string.IsNullOrEmpty(input.Sorting))
            {
                input.Sorting = "InvoiceDate.Date DESC";
            }

            var items = await _purchaseInvoiceRepository.GetListAsync(
                input.SkipCount,
                input.MaxResultCount,
                input.Sorting,
                input.Filter,
                input.FromDateId,
                input.ToDateId
            );

            var totalCount = await _purchaseInvoiceRepository.GetCountAsync(
                input.Filter,
                input.FromDateId,
                input.ToDateId
            );

            return new PagedResultDto<PurchaseInvoiceDto>(
                totalCount,
                ObjectMapper.Map<List<PurchaseInvoice>, List<PurchaseInvoiceDto>>(items)
            );
        }

        /// <summary>
        /// Xóa hóa đơn mua và xử lý stock nguyên liệu
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            var entity = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);
            
            // Xóa hóa đơn và xử lý stock sử dụng PurchaseInvoiceManager
            await _purchaseInvoiceManager.DeletePurchaseInvoiceAsync(entity);
            await _purchaseInvoiceRepository.DeleteAsync(entity);
        }


        /// <summary>
        /// Lấy thông tin nguyên liệu để sử dụng trong hóa đơn mua
        /// Bao gồm các đơn vị mua và giá cơ bản
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
        public async Task<IngredientForPurchaseDto> GetIngredientForPurchaseAsync(Guid ingredientId)
        {
            var ingredient = await _ingredientDetailRepository.GetWithDetailsAsync(ingredientId);
            if (ingredient is null) 
                throw new EntityNotFoundException(typeof(Ingredient), ingredientId);
            
            var result = new IngredientForPurchaseDto
            {
                Id = ingredient.Id,
                Name = ingredient.Name,
                CostPerUnit = ingredient.CostPerUnit,
                SupplierInfo = ingredient.SupplierInfo,
                PurchaseUnits = ObjectMapper.Map<List<IngredientPurchaseUnit>, List<IngredientPurchaseUnitDto>>(
                    [.. ingredient.PurchaseUnits.Where(pu => pu.IsActive)
                        .OrderByDescending(pu => pu.IsBaseUnit)
                        .ThenBy(pu => pu.ConversionRatio)])
            };
            
            return result;
        }

    }
}