using System;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Orders;

/// <summary>
/// Repository interface cho Payment entity
/// </summary>
public interface IPaymentRepository : IRepository<Payment, Guid>
{
    // Có thể thêm các methods đặc biệt cho Payment tại đây nếu cần
}