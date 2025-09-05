using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Orders;

/// <summary>
/// Repository interface cho Order aggregate
/// </summary>
public interface IOrderRepository : IBasicRepository<Order, Guid>
{
    /// <summary>
    /// Lấy danh sách đơn hàng theo bàn
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng của bàn</returns>
    Task<List<Order>> GetOrdersByTableIdAsync(
        Guid tableId, 
        bool includeOrderItems = false,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy danh sách đơn hàng theo trạng thái
    /// </summary>
    /// <param name="status">Trạng thái đơn hàng</param>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng theo trạng thái</returns>
    Task<List<Order>> GetOrdersByStatusAsync(
        OrderStatus status, 
        bool includeOrderItems = false,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy danh sách đơn hàng cho bếp (trạng thái Confirmed và Preparing)
    /// </summary>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng cho bếp</returns>
    Task<List<Order>> GetKitchenOrdersAsync(
        bool includeOrderItems = true,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy đơn hàng theo số đơn hàng
    /// </summary>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Đơn hàng nếu tìm thấy</returns>
    Task<Order?> GetByOrderNumberAsync(
        string orderNumber, 
        bool includeOrderItems = false,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy đơn hàng đầy đủ thông tin bao gồm OrderItems và MenuItem
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Đơn hàng với đầy đủ thông tin</returns>
    Task<Order?> GetWithDetailsAsync(
        Guid orderId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Kiểm tra xem số đơn hàng đã tồn tại chưa
    /// </summary>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="excludeOrderId">ID đơn hàng cần loại trừ (dùng cho update)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>True nếu số đơn hàng đã tồn tại</returns>
    Task<bool> IsOrderNumberExistsAsync(
        string orderNumber, 
        Guid? excludeOrderId = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Đếm số đơn hàng theo ngày
    /// </summary>
    /// <param name="date">Ngày cần đếm</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Số đơn hàng trong ngày</returns>
    Task<int> CountOrdersByDateAsync(
        DateTime date,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy danh sách đơn hàng đang hoạt động (chưa thanh toán)
    /// </summary>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng đang hoạt động</returns>
    Task<List<Order>> GetActiveOrdersAsync(
        bool includeOrderItems = false,
        CancellationToken cancellationToken = default);
}