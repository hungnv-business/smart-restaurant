using System;
using System.Threading.Tasks;
using SmartRestaurant.Entities.Common;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Data;

/// <summary>
/// Seed dữ liệu mẫu cho các đơn vị đo lường phổ biến trong nhà hàng Việt Nam
/// </summary>
public class UnitDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<Unit, Guid> _unitRepository;

    public UnitDataSeedContributor(IRepository<Unit, Guid> unitRepository)
    {
        _unitRepository = unitRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        // Kiểm tra đã có dữ liệu chưa
        if (await _unitRepository.GetCountAsync() > 0)
        {
            return;
        }

        // Seed các đơn vị phổ biến theo thứ tự DisplayOrder
        var units = new[]
        {
            new Unit(Guid.NewGuid(), "kg", 10, true),
            new Unit(Guid.NewGuid(), "gram", 20, true), 
            new Unit(Guid.NewGuid(), "lít", 30, true),
            new Unit(Guid.NewGuid(), "ml", 40, true),
            new Unit(Guid.NewGuid(), "cái", 50, true),
            new Unit(Guid.NewGuid(), "hộp", 60, true),
            new Unit(Guid.NewGuid(), "gói", 70, true),
            new Unit(Guid.NewGuid(), "thùng", 80, true),
            new Unit(Guid.NewGuid(), "chai", 90, true),
            new Unit(Guid.NewGuid(), "lon", 100, true),
            new Unit(Guid.NewGuid(), "túi", 110, true),
            new Unit(Guid.NewGuid(), "bịch", 120, true),
            new Unit(Guid.NewGuid(), "miếng", 130, true),
            new Unit(Guid.NewGuid(), "lạng", 140, true),
            new Unit(Guid.NewGuid(), "tấn", 150, true)
        };

        await _unitRepository.InsertManyAsync(units, autoSave: true);
    }
}