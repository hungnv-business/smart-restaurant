using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Entities.Inventory;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.Ingredients;
using SmartRestaurant.Repositories;
using SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;
using Volo.Abp.Guids;

namespace SmartRestaurant.Inventory
{
    /// <summary>
    /// Domain Service để quản lý PurchaseInvoice operations
    /// </summary>
    public class PurchaseInvoiceManager : DomainService
    {
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;
        private readonly IIngredientRepository _ingredientDetailRepository;
        private readonly IngredientManager _ingredientManager;
        private readonly IGuidGenerator _guidGenerator;

        public PurchaseInvoiceManager(
            IRepository<Ingredient, Guid> ingredientRepository,
            IIngredientRepository ingredientDetailRepository,
            IngredientManager ingredientManager,
            IGuidGenerator guidGenerator)
        {
            _ingredientRepository = ingredientRepository;
            _ingredientDetailRepository = ingredientDetailRepository;
            _ingredientManager = ingredientManager;
            _guidGenerator = guidGenerator;
        }

        /// <summary>
        /// Thêm items vào PurchaseInvoice với stock management
        /// </summary>
        public async Task AddPurchaseInvoiceItemsAsync<TItemDto>(
            PurchaseInvoice invoice, 
            IEnumerable<TItemDto> itemDtos) where TItemDto : class
        {
            var stockChanges = new List<StockChangeItem>();
            var displayOrder = 1;

            foreach (dynamic itemDto in itemDtos)
            {
                // Auto-populate data from ingredient
                await PopulateItemDataAsync(itemDto);

                // Calculate base unit quantity
                var baseUnitQuantity = await CalculateBaseUnitQuantityAsync(
                    (Guid)itemDto.IngredientId, 
                    (Guid)itemDto.PurchaseUnitId, 
                    (int)itemDto.Quantity);

                // Add item to invoice
                invoice.AddItem(
                    _guidGenerator.Create(),
                    (Guid)itemDto.IngredientId,
                    (int)itemDto.Quantity,
                    (Guid)itemDto.PurchaseUnitId,
                    baseUnitQuantity,
                    (int)(itemDto.TotalPrice ?? 0),
                    displayOrder++,
                    (int?)itemDto.UnitPrice,
                    (string?)itemDto.SupplierInfo,
                    (string?)itemDto.Notes);

                // Track stock change
                stockChanges.Add(StockChangeItem.ForAddition((Guid)itemDto.IngredientId, baseUnitQuantity));
            }

            // Apply stock changes
            await _ingredientManager.ProcessStockChangesAsync(stockChanges);
        }

        /// <summary>
        /// Cập nhật items trong PurchaseInvoice với smart diff
        /// </summary>
        public async Task UpdatePurchaseInvoiceItemsAsync<TItemDto>(
            PurchaseInvoice invoice,
            IEnumerable<TItemDto> itemDtos) where TItemDto : class
        {
            var itemDtosList = itemDtos.ToList();
            var oldItems = invoice.GetItems().ToList();
            var oldItemIds = oldItems.Select(i => i.Id).ToHashSet();
            var newItemIds = itemDtosList
                .Select(dto => (Guid?)((dynamic)dto).Id)
                .Where(id => id.HasValue)
                .Select(id => id!.Value)
                .ToHashSet();

            var stockChanges = new List<StockChangeItem>();

            // 1. XÓA items (có trong old, không có trong new)
            var itemsToRemove = oldItems.Where(item => !newItemIds.Contains(item.Id)).ToList();
            foreach (var item in itemsToRemove)
            {
                invoice.RemoveItem(item.Id);
                stockChanges.Add(StockChangeItem.ForSubtraction(item.IngredientId, item.BaseUnitQuantity));
            }

            // 2. THÊM items mới (không có Id hoặc Id không tồn tại)
            var itemsToAdd = itemDtosList.Where(dto => 
            {
                var id = ((dynamic)dto).Id as Guid?;
                return !id.HasValue || !oldItemIds.Contains(id.Value);
            }).ToList();

            var displayOrder = 1;
            foreach (dynamic itemDto in itemsToAdd)
            {
                await PopulateItemDataAsync(itemDto);
                var baseUnitQuantity = await CalculateBaseUnitQuantityAsync(
                    (Guid)itemDto.IngredientId, 
                    (Guid)itemDto.PurchaseUnitId, 
                    (int)itemDto.Quantity);

                invoice.AddItem(
                    (Guid?)itemDto.Id ?? _guidGenerator.Create(),
                    (Guid)itemDto.IngredientId,
                    (int)itemDto.Quantity,
                    (Guid)itemDto.PurchaseUnitId,
                    baseUnitQuantity,
                    (int)(itemDto.TotalPrice ?? 0),
                    displayOrder++,
                    (int?)itemDto.UnitPrice,
                    (string?)itemDto.SupplierInfo,
                    (string?)itemDto.Notes);

                stockChanges.Add(StockChangeItem.ForAddition((Guid)itemDto.IngredientId, baseUnitQuantity));
            }

            // 3. CẬP NHẬT items hiện có
            var itemsToUpdate = itemDtosList.Where(dto => 
            {
                var id = ((dynamic)dto).Id as Guid?;
                return id.HasValue && oldItemIds.Contains(id.Value);
            }).ToList();

            foreach (dynamic itemDto in itemsToUpdate)
            {
                await PopulateItemDataAsync(itemDto);
                var newBaseUnitQuantity = await CalculateBaseUnitQuantityAsync(
                    (Guid)itemDto.IngredientId, 
                    (Guid)itemDto.PurchaseUnitId, 
                    (int)itemDto.Quantity);
                var oldItem = oldItems.First(i => i.Id == (Guid)itemDto.Id);
                var stockDifference = newBaseUnitQuantity - oldItem.BaseUnitQuantity;

                invoice.UpdateItem(
                    (Guid)itemDto.Id,
                    (int)itemDto.Quantity,
                    (Guid)itemDto.PurchaseUnitId,
                    newBaseUnitQuantity,
                    (int)(itemDto.TotalPrice ?? 0),
                    displayOrder++,
                    (int?)itemDto.UnitPrice,
                    (string?)itemDto.SupplierInfo,
                    (string?)itemDto.Notes);

                var stockChangeItem = new StockChangeItem((Guid)itemDto.IngredientId, stockDifference);
                if (stockChangeItem.HasChange)
                {
                    stockChanges.Add(stockChangeItem);
                }
            }

            await _ingredientManager.ProcessStockChangesAsync(stockChanges);
        }

        /// <summary>
        /// Xóa PurchaseInvoice và xử lý stock
        /// </summary>
        public async Task DeletePurchaseInvoiceAsync(PurchaseInvoice invoice)
        {
            // Validate có thể xóa không
            invoice.ValidateDelete();

            // Trừ stock từ tất cả items
            var stockChanges = invoice.GetItems().Select(item => 
                StockChangeItem.ForSubtraction(item.IngredientId, item.BaseUnitQuantity)).ToList();
            
            await _ingredientManager.ProcessStockChangesAsync(stockChanges);

            // Clear tất cả items
            invoice.ClearItems();
        }

        /// <summary>
        /// Auto-populate item data từ ingredient
        /// </summary>
        private async Task PopulateItemDataAsync(dynamic itemDto)
        {
            var ingredient = await _ingredientRepository.GetAsync((Guid)itemDto.IngredientId);

            // Auto-populate SupplierInfo nếu chưa có
            if (!string.IsNullOrEmpty(ingredient.SupplierInfo) && string.IsNullOrEmpty((string?)itemDto.SupplierInfo))
            {
                itemDto.SupplierInfo = ingredient.SupplierInfo;
            }

            // Auto-calculate TotalPrice nếu chưa có
            if (itemDto.TotalPrice == null && itemDto.UnitPrice != null)
            {
                itemDto.TotalPrice = (int)itemDto.Quantity * (int)itemDto.UnitPrice;
            }
        }

        /// <summary>
        /// Tính BaseUnitQuantity từ PurchaseUnit
        /// </summary>
        private async Task<int> CalculateBaseUnitQuantityAsync(Guid ingredientId, Guid purchaseUnitId, int quantity)
        {
            var ingredient = await _ingredientDetailRepository.GetWithDetailsAsync(ingredientId);
            if (ingredient == null) return quantity;
            
            var purchaseUnit = ingredient.PurchaseUnits.FirstOrDefault(pu => pu.Id == purchaseUnitId);
            if (purchaseUnit == null) return quantity;
            
            return quantity * purchaseUnit.ConversionRatio;
        }
    }
}