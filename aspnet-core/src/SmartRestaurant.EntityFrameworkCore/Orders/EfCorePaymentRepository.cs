using System;
using SmartRestaurant.EntityFrameworkCore;
using SmartRestaurant.Orders;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore.Orders
{
    /// <summary>
    /// Entity Framework Core implementation của IPaymentRepository
    /// </summary>
    public class EfCorePaymentRepository : EfCoreRepository<SmartRestaurantDbContext, Payment, Guid>, IPaymentRepository
    {
        public EfCorePaymentRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }
    }
}