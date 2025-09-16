using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.Kitchen.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Kitchen;

/// <summary>
/// Interface for Kitchen Dashboard Application Service
/// Defines operations for kitchen cooking order management
/// </summary>
public interface IKitchenDashboardAppService : IApplicationService
{
    /// <summary>
    /// Lấy danh sách tất cả order items cần nấu với priority đã được tính toán
    /// </summary>
    /// <returns>Danh sách order items được sắp xếp theo priority</returns>
    Task<List<KitchenTableGroupDto>> GetCookingOrdersGroupedAsync();


    /// <summary>
    /// Cập nhật trạng thái của một order item (Pending → Preparing → Ready → Served)
    /// </summary>
    /// <param name="input">Thông tin cập nhật trạng thái</param>
    Task UpdateOrderItemStatusAsync(UpdateOrderItemStatusInput input);

    /// <summary>
    /// Lấy thống kê nhanh cho kitchen dashboard
    /// </summary>
    /// <returns>Thống kê cooking cho dashboard</returns>
    Task<CookingStatsDto> GetCookingStatsAsync();
}