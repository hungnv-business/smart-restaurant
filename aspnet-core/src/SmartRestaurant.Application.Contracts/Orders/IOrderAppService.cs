using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders;

/// <summary>
/// Application Service interface cho Order management
/// Theo ABP convention: IApplicationService cho auto API generation
/// </summary>
public interface IOrderAppService : IApplicationService
{

    #region Lấy danh sách
    /// <summary>
    /// Lấy danh sách bàn cho màn hình DineIn mobile (tối ưu hóa cho table grid)
    /// Logic base từ GetActiveTablesAsync nhưng response format tối ưu cho mobile
    /// </summary>
    /// <param name="input">Filter parameters cho danh sách bàn</param>
    /// <returns>Danh sách bàn với thông tin tối ưu cho mobile UI</returns>
    Task<ListResultDto<DineInTableDto>> GetDineInTablesAsync(GetDineInTablesDto input);

    /// <summary>
    /// Lấy danh sách tất cả đơn hàng takeaway với filtering
    /// Chỉ lấy đơn hàng có OrderType = Takeaway
    /// </summary>
    /// <param name="input">Filter parameters cho takeaway orders</param>
    /// <returns>Danh sách đơn hàng takeaway</returns>
    Task<ListResultDto<TakeawayOrderDto>> GetTakeawayOrdersAsync(GetTakeawayOrdersDto input);

    #endregion

    #region Chi tiết

    /// <summary>
    /// API thống nhất lấy chi tiết đơn hàng (thay thế GetTableDetailsAsync và GetTakeawayOrderDetailsAsync)
    /// Hỗ trợ cả DineIn và Takeaway orders với cùng một response format
    /// </summary>
    /// <param name="orderId">ID đơn hàng cần lấy chi tiết</param>
    /// <returns>Thông tin chi tiết đơn hàng với format thống nhất</returns>
    Task<OrderDetailsDto> GetOrderDetailsAsync(Guid orderId);

    #endregion

    #region Lấy món ăn
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

    #endregion

    #region Thêm, sửa, xoá
    /// <summary>
    /// Tạo đơn hàng mới với validation business logic
    /// </summary>
    /// <param name="input">Thông tin đơn hàng mới</param>
    Task CreateAsync(CreateOrderDto input);

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
    /// Cập nhật trạng thái món sang "Đã phục vụ" từ mobile app
    /// Chỉ cho phép khi món ở trạng thái "Ready" (đã hoàn thành)
    /// </summary>
    /// <param name="orderItemId">ID của món cần đánh dấu đã phục vụ</param>
    Task MarkOrderItemServedAsync(Guid orderItemId);
    #endregion

    #region thanh toán
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
    #endregion

    /// <summary>
    /// Cập nhật trạng thái đơn hàng takeaway
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="status">Trạng thái mới</param>
    Task UpdateTakeawayOrderStatusAsync(Guid orderId, TakeawayStatus status);
}