using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.MenuManagement.MenuItems.Dto;

namespace SmartRestaurant.Application.Contracts.Orders;

/// <summary>
/// Application Service interface cho Order management
/// Theo ABP convention: IApplicationService cho auto API generation
/// </summary>
public interface IOrderAppService : IApplicationService
{

    /// <summary>
    /// Tạo đơn hàng mới với validation business logic
    /// </summary>
    /// <param name="input">Thông tin đơn hàng mới</param>
    Task CreateAsync(CreateOrderDto input);


    /// <summary>
    /// Lấy danh sách tất cả các bàn active trong hệ thống
    /// Chỉ lấy table từ table section active và table cũng phải active
    /// </summary>
    /// <param name="tableNameFilter">Lọc theo tên bàn (tìm kiếm gần đúng)</param>
    /// <param name="statusFilter">Lọc theo trạng thái bàn</param>
    /// <returns>Danh sách bàn active trong hệ thống</returns>
    Task<ListResultDto<ActiveTableDto>> GetActiveTablesAsync(
        string? tableNameFilter = null,
        TableStatus? statusFilter = null);

    /// <summary>
    /// Lấy thông tin chi tiết bàn với đơn hàng để hiển thị trên mobile
    /// Bao gồm thông tin bàn, tổng quan đơn hàng và chi tiết từng món
    /// </summary>
    /// <param name="tableId">ID bàn cần xem chi tiết</param>
    /// <returns>Thông tin chi tiết bàn và đơn hàng đầy đủ cho mobile</returns>
    Task<TableDetailDto> GetTableDetailsAsync(Guid tableId);

    /// <summary>
    /// Lấy danh sách tất cả danh mục món ăn đang hoạt động
    /// Dùng cho dropdown/selector khi tạo đơn hàng
    /// </summary>
    /// <returns>Danh sách danh mục món ăn sắp xếp theo DisplayOrder</returns>
    Task<ListResultDto<GuidLookupItemDto>> GetActiveMenuCategoriesAsync();

    /// <summary>
    /// Lấy danh sách món ăn với filtering cho việc tạo đơn hàng
    /// </summary>
    /// <param name="input">Bộ lọc tìm kiếm món ăn</param>
    /// <returns>Danh sách món ăn phù hợp với điều kiện lọc</returns>
    Task<ListResultDto<MenuItemDto>> GetMenuItemsForOrderAsync(GetMenuItemsForOrderDto input);

    /// <summary>
    /// Gọi thêm món vào order hiện có của bàn
    /// Chỉ cho phép với order ở trạng thái Active
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="input">Danh sách món muốn thêm</param>
    Task AddItemsToOrderAsync(Guid orderId, AddItemsToOrderDto input);

    /// <summary>
    /// Xóa món khỏi order hiện có
    /// Chỉ cho phép với order ở trạng thái Active và OrderItem ở trạng thái Pending
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="orderItemId">ID món cần xóa</param>
    Task RemoveOrderItemAsync(Guid orderId, Guid orderItemId);

    /// <summary>
    /// Cập nhật số lượng món ăn trong đơn hàng
    /// Chỉ cho phép với order ở trạng thái Active và OrderItem ở trạng thái Pending
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="orderItemId">ID món cần cập nhật số lượng</param>
    /// <param name="input">Thông tin số lượng mới</param>
    Task UpdateOrderItemQuantityAsync(Guid orderId, Guid orderItemId, UpdateOrderItemQuantityDto input);

    /// <summary>
    /// Kiểm tra tình trạng nguyên liệu có đủ để làm các món trong order không
    /// Trả về thông tin chi tiết về nguyên liệu thiếu (nếu có)
    /// </summary>
    /// <param name="input">Danh sách món cần kiểm tra</param>
    /// <returns>Kết quả kiểm tra với thông tin nguyên liệu thiếu</returns>
    Task<IngredientAvailabilityResultDto> VerifyIngredientsAvailabilityAsync(VerifyIngredientsRequestDto input);

    /// <summary>
    /// Lấy thông tin đơn hàng để chuẩn bị thanh toán
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <returns>Thông tin đơn hàng đã sẵn sàng thanh toán</returns>
    Task<OrderForPaymentDto> GetOrderForPaymentAsync(Guid orderId);

    /// <summary>
    /// Thanh toán hóa đơn cho bàn
    /// Chỉ cho phép thanh toán khi tất cả món đã được phục vụ hoặc hủy
    /// </summary>
    /// <param name="input">Thông tin thanh toán</param>
    /// <returns>Kết quả thanh toán với thông tin hóa đơn</returns>
    Task ProcessPaymentAsync(PaymentRequestDto input);
}