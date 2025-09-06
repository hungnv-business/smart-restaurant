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
    // /// <summary>
    // /// Lấy danh sách đơn hàng với filtering và paging
    // /// </summary>
    // /// <param name="input">Điều kiện lọc và phân trang</param>
    // /// <returns>Danh sách đơn hàng</returns>
    // Task<PagedResultDto<OrderDto>> GetListAsync(GetOrderListDto input);

    // /// <summary>
    // /// Lấy chi tiết đơn hàng theo ID
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <returns>Chi tiết đơn hàng bao gồm các món</returns>
    // Task<OrderDto> GetAsync(Guid id);

    /// <summary>
    /// Tạo đơn hàng mới với validation business logic
    /// </summary>
    /// <param name="input">Thông tin đơn hàng mới</param>
    /// <returns>Đơn hàng đã tạo</returns>
    Task<OrderDto> CreateAsync(CreateOrderDto input);

    // /// <summary>
    // /// Cập nhật trạng thái đơn hàng theo workflow
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <param name="input">Trạng thái mới</param>
    // /// <returns>Đơn hàng đã cập nhật</returns>
    // Task<OrderDto> UpdateStatusAsync(Guid id, UpdateOrderStatusDto input);

    // /// <summary>
    // /// Xác nhận đơn hàng (Pending -> Confirmed)
    // /// Tự động thực hiện: validation, trừ kho, thông báo bếp
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <returns>Đơn hàng đã xác nhận</returns>
    // Task<OrderDto> ConfirmOrderAsync(Guid id);

    // /// <summary>
    // /// Hoàn thành phục vụ đơn hàng (Ready -> Served)
    // /// Tự động cập nhật trạng thái bàn
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <returns>Đơn hàng đã hoàn thành</returns>
    // Task<OrderDto> CompleteOrderAsync(Guid id);

    // /// <summary>
    // /// In bill bếp cho đơn hàng hoặc các món được chọn
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <param name="input">Thông tin in bill</param>
    // /// <returns>Kết quả in bill</returns>
    // Task PrintKitchenBillAsync(Guid id, PrintKitchenBillDto input);

    // /// <summary>
    // /// Lấy danh sách đơn hàng theo ID bàn
    // /// </summary>
    // /// <param name="tableId">ID bàn</param>
    // /// <returns>Danh sách đơn hàng của bàn</returns>
    // Task<ListResultDto<OrderDto>> GetOrdersByTableAsync(Guid tableId);

    // /// <summary>
    // /// Lấy danh sách đơn hàng cho bếp (Confirmed + Preparing)
    // /// </summary>
    // /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    // /// <returns>Danh sách đơn hàng cho bếp</returns>
    // Task<ListResultDto<OrderDto>> GetKitchenOrdersAsync(bool includeOrderItems = true);

    // /// <summary>
    // /// Lấy danh sách đơn hàng đang hoạt động (chưa thanh toán)
    // /// </summary>
    // /// <returns>Danh sách đơn hàng đang hoạt động</returns>
    // Task<ListResultDto<OrderDto>> GetActiveOrdersAsync();

    // /// <summary>
    // /// Lấy đơn hàng theo số đơn hàng
    // /// </summary>
    // /// <param name="orderNumber">Số đơn hàng</param>
    // /// <returns>Đơn hàng nếu tìm thấy</returns>
    // Task<OrderDto?> GetByOrderNumberAsync(string orderNumber);

    // /// <summary>
    // /// Xóa đơn hàng (chỉ khi ở trạng thái Pending)
    // /// </summary>
    // /// <param name="id">ID đơn hàng</param>
    // /// <returns>Task</returns>
    // Task DeleteAsync(Guid id);

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
    /// Lấy thông tin chi tiết bàn khi click vào từ danh sách
    /// Bao gồm thông tin bàn và các đơn hàng đang hoạt động
    /// </summary>
    /// <param name="tableId">ID bàn cần xem chi tiết</param>
    /// <returns>Thông tin chi tiết bàn và đơn hàng</returns>
    Task<TableDetailsDto> GetTableDetailsAsync(Guid tableId);

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
}