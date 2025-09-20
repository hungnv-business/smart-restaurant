using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Orders;

/// <summary>
/// Repository interface cho Order aggregate
/// </summary>
public interface IOrderRepository : IRepository<Order, Guid>
{

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
    /// Đếm số đơn hàng theo ngày
    /// </summary>
    /// <param name="date">Ngày cần đếm</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Số đơn hàng trong ngày</returns>
    Task<int> CountOrdersByDateAsync(
        DateTime date,
        CancellationToken cancellationToken = default);


    /// <summary>
    /// Lấy danh sách đơn hàng đang hoạt động của một bàn cụ thể
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    /// <param name="includeOrderItems">Có bao gồm OrderItems không</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng đang hoạt động của bàn</returns>
    Task<List<Order>> GetActiveOrdersByTableIdAsync(
        Guid tableId,
        bool includeOrderItems = false,
        CancellationToken cancellationToken = default);


    /// <summary>
    /// Lấy đơn hàng với đầy đủ thông tin để thanh toán
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Đơn hàng với OrderItems và Table (nếu có)</returns>
    Task<Order?> GetOrderForPaymentAsync(
        Guid orderId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy đơn hàng chứa OrderItem cụ thể
    /// </summary>
    /// <param name="orderItemId">ID của OrderItem</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Đơn hàng chứa OrderItem (nếu có)</returns>
    Task<Order?> GetByOrderItemIdAsync(
        Guid orderItemId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy tất cả đơn hàng đang hoạt động (Serving) với đầy đủ thông tin
    /// Bao gồm: OrderItems, MenuItem, và Table để phục vụ Kitchen Priority Dashboard
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng đang hoạt động với đầy đủ relations</returns>
    Task<List<Order>> GetActiveOrdersWithDetailsAsync(
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy danh sách đơn hàng takeaway trong ngày hôm nay
    /// </summary>
    /// <param name="status">Trạng thái đơn hàng cần lọc (optional)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng takeaway hôm nay với đầy đủ thông tin</returns>
    Task<List<Order>> GetTakeawayOrdersTodayAsync(
        OrderStatus? status = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lấy danh sách đơn hàng với filtering chung (unified method)
    /// </summary>
    /// <param name="orderTypeFilter">Lọc theo loại đơn hàng</param>
    /// <param name="statusFilter">Lọc theo trạng thái</param>
    /// <param name="date">Lọc theo ngày (mặc định là hôm nay)</param>
    /// <param name="searchText">Tìm kiếm theo text</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Danh sách đơn hàng với đầy đủ thông tin</returns>
    Task<List<Order>> GetOrdersAsync(
        OrderType? orderTypeFilter = null,
        OrderStatus? statusFilter = null,
        DateTime? date = null,
        string? searchText = null,
        CancellationToken cancellationToken = default);

}