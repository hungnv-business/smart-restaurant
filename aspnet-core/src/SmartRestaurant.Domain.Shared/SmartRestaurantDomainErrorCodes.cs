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
        
        /// <summary>
        /// Đơn vị đã tồn tại trong nguyên liệu
        /// </summary>
        public const string DuplicateUnit = "SmartRestaurant:Ingredient:0003";
        
        /// <summary>
        /// Không thể có nhiều đơn vị cơ sở
        /// </summary>
        public const string MultipleBaseUnit = "SmartRestaurant:Ingredient:0004";
        
        /// <summary>
        /// Đơn vị cơ sở phải có tỷ lệ quy đổi bằng 1
        /// </summary>
        public const string InvalidBaseUnitConversion = "SmartRestaurant:Ingredient:0005";
        
        /// <summary>
        /// Nguyên liệu chưa cấu hình đơn vị cơ sở
        /// </summary>
        public const string BaseUnitNotConfigured = "SmartRestaurant:Ingredient:0006";
        
        /// <summary>
        /// Không thể xóa đơn vị cơ sở
        /// </summary>
        public const string CannotRemoveBaseUnit = "SmartRestaurant:Ingredient:0007";
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
        
        /// <summary>
        /// Không tìm thấy item trong hóa đơn
        /// </summary>
        public const string InvoiceItemNotFound = "SmartRestaurant:PurchaseInvoice:0004";
    }

    /// <summary>
    /// Mã lỗi liên quan đến quản lý bàn
    /// </summary>
    public static class Tables
    {
        /// <summary>
        /// Bàn chưa được gán vào khu vực nào
        /// </summary>
        public const string NotAssignedToSection = "SmartRestaurant:Table:0001";
    }
}
