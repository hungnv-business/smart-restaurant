namespace SmartRestaurant;

public static class SmartRestaurantDomainErrorCodes
{
    /* You can add your business exception error codes here, as constants */
    
    /// <summary>
    /// Mã lỗi liên quan đến quản lý danh mục món ăn
    /// </summary>
    public static class MenuCategories
    {
        /// <summary>
        /// Tên danh mục món ăn đã tồn tại trong hệ thống
        /// </summary>
        public const string NameAlreadyExists = "SmartRestaurant:MenuCategory:0001";

        /// <summary>
        /// Không thể xóa danh mục món ăn vì còn chứa món ăn
        /// </summary>
        public const string CannotDeleteCategoryWithMenuItems = "SmartRestaurant:MenuCategory:0002";
    }

    /// <summary>
    /// Mã lỗi liên quan đến quản lý món ăn
    /// </summary>
    public static class MenuItems
    {
        /// <summary>
        /// Danh mục món ăn không tồn tại trong hệ thống
        /// </summary>
        public const string CategoryNotFound = "SmartRestaurant:MenuItem:0001";

        /// <summary>
        /// Tên món ăn đã tồn tại trong cùng danh mục
        /// </summary>
        public const string NameAlreadyExistsInCategory = "SmartRestaurant:MenuItem:0002";
    }

    /// <summary>
    /// Mã lỗi liên quan đến quản lý danh mục nguyên liệu
    /// </summary>
    public static class IngredientCategories
    {
        /// <summary>
        /// Tên danh mục nguyên liệu đã tồn tại trong hệ thống
        /// </summary>
        public const string NameAlreadyExists = "SmartRestaurant:IngredientCategory:0001";
    }

    /// <summary>
    /// Mã lỗi liên quan đến quản lý đơn vị
    /// </summary>
    public static class Units
    {
        /// <summary>
        /// Tên đơn vị đã tồn tại trong hệ thống
        /// </summary>
        public const string NameAlreadyExists = "SmartRestaurant:Unit:0001";
    }

    /// <summary>
    /// Mã lỗi liên quan đến quản lý nguyên liệu
    /// </summary>
    public static class Ingredients
    {
        /// <summary>
        /// Không đủ tồn kho để thực hiện thao tác
        /// </summary>
        public const string InsufficientStock = "SmartRestaurant:Ingredient:0001";
        
        /// <summary>
        /// Không thể xóa nguyên liệu vì đang được sử dụng
        /// </summary>
        public const string IsBeingUsed = "SmartRestaurant:Ingredient:0002";
    }

    /// <summary>
    /// Mã lỗi liên quan đến hóa đơn mua hàng
    /// </summary>
    public static class PurchaseInvoices
    {
        /// <summary>
        /// Số lượng không hợp lệ
        /// </summary>
        public const string InvalidQuantity = "SmartRestaurant:PurchaseInvoice:0001";
        
        /// <summary>
        /// Tổng tiền không hợp lệ
        /// </summary>
        public const string InvalidTotalPrice = "SmartRestaurant:PurchaseInvoice:0002";
        
        /// <summary>
        /// Không thể xóa hóa đơn sau 6 giờ
        /// </summary>
        public const string CannotDeleteAfterSixHours = "SmartRestaurant:PurchaseInvoice:0003";
    }
}
