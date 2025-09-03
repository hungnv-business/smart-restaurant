using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Entities.InventoryManagement;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;

namespace SmartRestaurant.Ingredients
{
    /// <summary>
    /// Domain Service để quản lý operations liên quan đến Ingredient
    /// Centralized logic cho stock management, validation, và business rules
    /// </summary>
    public class IngredientManager : DomainService
    {
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;

        public IngredientManager(IRepository<Ingredient, Guid> ingredientRepository)
        {
            _ingredientRepository = ingredientRepository;
        }

        /// <summary>
        /// Xử lý thay đổi stock cho nhiều ingredients cùng lúc
        /// </summary>
        public async Task ProcessStockChangesAsync(IEnumerable<StockChangeItem> stockChanges)
        {
            var changes = stockChanges.Where(sc => sc.HasChange).ToList();
            
            foreach (var change in changes)
            {
                await UpdateIngredientStockAsync(change);
            }
        }


        /// <summary>
        /// Update stock cho một ingredient
        /// </summary>
        public async Task UpdateIngredientStockAsync(StockChangeItem stockChange)
        {
            if (!stockChange.HasChange) return;

            var ingredient = await _ingredientRepository.GetAsync(stockChange.IngredientId);

            // Chỉ cập nhật stock nếu ingredient có bật stock tracking
            if (!ingredient.IsStockTrackingEnabled)
            {
                return;
            }

            if (stockChange.IsIncrease)
            {
                ingredient.AddStock(stockChange.QuantityChange);
            }
            else if (stockChange.IsDecrease)
            {
                ingredient.SubtractStock(Math.Abs(stockChange.QuantityChange));
            }
        }

        /// <summary>
        /// Update stock cho một ingredient (backward compatibility)
        /// </summary>
        public async Task UpdateIngredientStockAsync(Guid ingredientId, int quantityChange)
        {
            await UpdateIngredientStockAsync(new StockChangeItem(ingredientId, quantityChange));
        }
    }
}