using System;

namespace SmartRestaurant.Ingredients
{
    /// <summary>
    /// Value object để represent stock change cho một ingredient
    /// </summary>
    public record StockChangeItem(Guid IngredientId, int QuantityChange)
    {
        /// <summary>
        /// Tạo StockChangeItem từ old và new quantity
        /// </summary>
        public static StockChangeItem FromQuantities(Guid ingredientId, int oldQuantity, int newQuantity)
        {
            return new StockChangeItem(ingredientId, newQuantity - oldQuantity);
        }

        /// <summary>
        /// Tạo StockChangeItem cho việc thêm stock
        /// </summary>
        public static StockChangeItem ForAddition(Guid ingredientId, int quantity)
        {
            return new StockChangeItem(ingredientId, quantity);
        }

        /// <summary>
        /// Tạo StockChangeItem cho việc trừ stock
        /// </summary>
        public static StockChangeItem ForSubtraction(Guid ingredientId, int quantity)
        {
            return new StockChangeItem(ingredientId, -quantity);
        }

        /// <summary>
        /// Kiểm tra có thay đổi stock không
        /// </summary>
        public bool HasChange => QuantityChange != 0;

        /// <summary>
        /// Kiểm tra có tăng stock không
        /// </summary>
        public bool IsIncrease => QuantityChange > 0;

        /// <summary>
        /// Kiểm tra có giảm stock không
        /// </summary>
        public bool IsDecrease => QuantityChange < 0;
    }
}