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
    }
}
