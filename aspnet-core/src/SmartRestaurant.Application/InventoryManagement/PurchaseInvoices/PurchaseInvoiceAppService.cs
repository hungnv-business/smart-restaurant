using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.Entities.Inventory;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.Entities.Common;
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
        private readonly IRepository<Unit, Guid> _unitRepository;
        private readonly IRepository<DimDate, int> _dimDateRepository;

        public PurchaseInvoiceAppService(
            IPurchaseInvoiceRepository purchaseInvoiceRepository,
            IRepository<Ingredient, Guid> ingredientRepository,
            IRepository<Unit, Guid> unitRepository,
            IRepository<DimDate, int> dimDateRepository)
        {
            _purchaseInvoiceRepository = purchaseInvoiceRepository;
            _ingredientRepository = ingredientRepository;
            _unitRepository = unitRepository;
            _dimDateRepository = dimDateRepository;
        }

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

        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Create)]
        public async Task<PurchaseInvoiceDto> CreateAsync(CreateUpdatePurchaseInvoiceDto input)
        {
            // Normalize input data
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Create master entity
            var purchaseInvoice = new PurchaseInvoice(
                GuidGenerator.Create(),
                input.InvoiceNumber,
                input.InvoiceDateId,
                input.Notes);

            // Add items to collection
            await AddItemsToInvoiceAsync(purchaseInvoice, input.Items);

            // Calculate total amount
            purchaseInvoice.CalculateTotalAmount();

            // Insert master with cascading details
            var insertedEntity = await _purchaseInvoiceRepository.InsertAsync(purchaseInvoice);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(insertedEntity);
        }

        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Edit)]
        public async Task<PurchaseInvoiceDto> UpdateAsync(Guid id, CreateUpdatePurchaseInvoiceDto input)
        {
            // Normalize input data
            input.InvoiceNumber = StringUtility.NormalizeString(input.InvoiceNumber);
            input.Notes = StringUtility.NormalizeStringNullable(input.Notes);

            // Get existing entity with items
            var existingEntity = await _purchaseInvoiceRepository.GetWithDetailsAsync(id);

            if (existingEntity == null)
            {
                throw new EntityNotFoundException(typeof(PurchaseInvoice), id);
            }

            // Trừ stock từ items cũ trước khi update
            foreach (var oldItem in existingEntity.Items.ToList())
            {
                if (oldItem.IngredientId.HasValue)
                {
                    await UpdateIngredientStockAsync(oldItem.IngredientId.Value, -oldItem.Quantity);
                }
            }

            // Update master properties
            existingEntity.InvoiceNumber = input.InvoiceNumber;
            existingEntity.InvoiceDateId = input.InvoiceDateId;
            existingEntity.Notes = input.Notes;

            // Clear existing items
            existingEntity.Items.Clear();

            // Add new items
            await AddItemsToInvoiceAsync(existingEntity, input.Items);

            // Recalculate total amount
            existingEntity.CalculateTotalAmount();

            var updatedEntity = await _purchaseInvoiceRepository.UpdateAsync(existingEntity);

            return ObjectMapper.Map<PurchaseInvoice, PurchaseInvoiceDto>(updatedEntity);
        }

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

        [Authorize(SmartRestaurantPermissions.Inventory.PurchaseInvoices.Delete)]
        public async Task DeleteAsync(Guid id)
        {
            var entity = await _purchaseInvoiceRepository.GetAsync(id);
            entity.ValidateDelete();
            await _purchaseInvoiceRepository.DeleteAsync(entity);
        }

        /// <summary>
        /// Helper method để add items vào invoice và update stock
        /// </summary>
        private async Task AddItemsToInvoiceAsync(PurchaseInvoice invoice, List<CreateUpdatePurchaseInvoiceItemDto> itemDtos)
        {
            foreach (var itemDto in itemDtos)
            {
                await ValidateAndPopulateItemAsync(itemDto);

                var item = new PurchaseInvoiceItem(
                    GuidGenerator.Create(),
                    invoice.Id,
                    itemDto.IngredientName,
                    itemDto.Quantity,
                    itemDto.UnitName,
                    itemDto.TotalPrice ?? 0,
                    itemDto.IngredientId,
                    itemDto.UnitId,
                    itemDto.UnitPrice,
                    itemDto.SupplierInfo);

                invoice.Items.Add(item);

                // Update CurrentStock for ingredients with ID
                if (itemDto.IngredientId.HasValue)
                {
                    await UpdateIngredientStockAsync(itemDto.IngredientId.Value, itemDto.Quantity);
                }
            }
        }

        /// <summary>
        /// Validate và auto-populate item data từ Ingredient/Unit
        /// </summary>
        private async Task ValidateAndPopulateItemAsync(CreateUpdatePurchaseInvoiceItemDto itemDto)
        {
            // Auto-populate from Ingredient if selected
            if (itemDto.IngredientId.HasValue)
            {
                var ingredient = await _ingredientRepository.GetAsync(itemDto.IngredientId.Value);
                itemDto.IngredientName = ingredient.Name;

                // Auto-populate Unit info
                var unit = await _unitRepository.GetAsync(ingredient.UnitId);
                itemDto.UnitId = unit.Id;
                itemDto.UnitName = unit.Name;

                // Auto-populate SupplierInfo if available
                if (!string.IsNullOrEmpty(ingredient.SupplierInfo))
                {
                    itemDto.SupplierInfo = ingredient.SupplierInfo;
                }
            }

            // Auto-calculate TotalPrice if not provided
            if (!itemDto.TotalPrice.HasValue && itemDto.UnitPrice.HasValue)
            {
                itemDto.TotalPrice = itemDto.Quantity * itemDto.UnitPrice.Value;
            }
        }

        /// <summary>
        /// Update CurrentStock cho nguyên liệu chính
        /// </summary>
        private async Task UpdateIngredientStockAsync(Guid ingredientId, int quantity)
        {
            var ingredient = await _ingredientRepository.GetAsync(ingredientId);

            if (quantity > 0)
            {
                ingredient.AddStock(quantity);
            }
            else if (quantity < 0)
            {
                ingredient.SubtractStock(Math.Abs(quantity));
            }
        }

        [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
        public async Task<IngredientLookupDto?> GetIngredientLookupAsync(Guid ingredientId)
        {
            var ingredient = await _ingredientRepository.GetAsync(ingredientId);
            await _ingredientRepository.EnsurePropertyLoadedAsync(ingredient, x => x.Unit);
            
            return ObjectMapper.Map<Ingredient, IngredientLookupDto>(ingredient);
        }
    }
}