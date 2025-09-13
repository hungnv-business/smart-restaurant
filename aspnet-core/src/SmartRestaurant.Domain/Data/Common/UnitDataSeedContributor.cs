using System;
using System.Threading.Tasks;
using SmartRestaurant.Common;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace SmartRestaurant.Data;

/// <summary>
/// Seed dữ liệu mẫu cho các đơn vị đo lường phổ biến trong nhà hàng Việt Nam
/// </summary>
public class UnitDataSeedContributor : ITransientDependency
{
    private readonly IRepository<Unit, Guid> _unitRepository;
    private readonly IGuidGenerator _guidGenerator;

    public UnitDataSeedContributor(IRepository<Unit, Guid> unitRepository, IGuidGenerator guidGenerator)
    {
        _unitRepository = unitRepository;
        _guidGenerator = guidGenerator;
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
            new Unit(_guidGenerator.Create(), "gram", 1, true),
            new Unit(_guidGenerator.Create(), "ml", 2, true),
            new Unit(_guidGenerator.Create(), "cốc", 3, true),
            new Unit(_guidGenerator.Create(), "ca", 4, true),
            new Unit(_guidGenerator.Create(), "lít", 5, true),
            new Unit(_guidGenerator.Create(), "bom", 6, true),
            new Unit(_guidGenerator.Create(), "con", 7, true),
            new Unit(_guidGenerator.Create(), "cái", 8, true),
            new Unit(_guidGenerator.Create(), "kg", 9, true),
            new Unit(_guidGenerator.Create(), "lon", 10, true),
            new Unit(_guidGenerator.Create(), "lốc", 11, true),
        };

        await _unitRepository.InsertManyAsync(units, autoSave: true);
    }
}