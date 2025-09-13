using System;
using System.Threading.Tasks;
using SmartRestaurant.TableManagement.LayoutSections;
using SmartRestaurant.TableManagement.Tables;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace SmartRestaurant.Data.TableManagement;

/// <summary>
/// Seed dữ liệu mẫu cho các khu vực và bàn trong nhà hàng
/// Tạo 3 khu vực: Trái, Giữa, Phải - mỗi khu vực có 4 bàn (tổng 12 bàn)
/// </summary>
public class TableDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<LayoutSection, Guid> _layoutSectionRepository;
    private readonly IRepository<Table, Guid> _tableRepository;
    private readonly IGuidGenerator _guidGenerator;

    public TableDataSeedContributor(
        IRepository<LayoutSection, Guid> layoutSectionRepository,
        IRepository<Table, Guid> tableRepository,
        IGuidGenerator guidGenerator)
    {
        _layoutSectionRepository = layoutSectionRepository;
        _tableRepository = tableRepository;
        _guidGenerator = guidGenerator;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        // Kiểm tra đã có dữ liệu chưa
        if (await _layoutSectionRepository.GetCountAsync() > 0)
        {
            return;
        }

        // Tạo 3 khu vực: Trái, Giữa, Phải
        var leftSectionId = _guidGenerator.Create();
        var centerSectionId = _guidGenerator.Create();
        var rightSectionId = _guidGenerator.Create();

        var sections = new[]
        {
            new LayoutSection(leftSectionId, "Khu vực Trái", "Khu vực bên trái nhà hàng", 1, true),
            new LayoutSection(centerSectionId, "Khu vực Giữa", "Khu vực trung tâm nhà hàng", 2, true),
            new LayoutSection(rightSectionId, "Khu vực Phải", "Khu vực bên phải nhà hàng", 3, true)
        };

        await _layoutSectionRepository.InsertManyAsync(sections, autoSave: true);

        // Tạo 12 bàn - mỗi khu vực 4 bàn
        var tables = new[]
        {
            // Khu vực Trái - Bàn 1-4
            new Table(_guidGenerator.Create(), "B01", 1, TableStatus.Available, true, leftSectionId),
            new Table(_guidGenerator.Create(), "B02", 2, TableStatus.Available, true, leftSectionId),
            new Table(_guidGenerator.Create(), "B03", 3, TableStatus.Available, true, leftSectionId),
            new Table(_guidGenerator.Create(), "B04", 4, TableStatus.Available, true, leftSectionId),

            // Khu vực Giữa - Bàn 5-8
            new Table(_guidGenerator.Create(), "B05", 1, TableStatus.Available, true, centerSectionId),
            new Table(_guidGenerator.Create(), "B06", 2, TableStatus.Available, true, centerSectionId),
            new Table(_guidGenerator.Create(), "B07", 3, TableStatus.Available, true, centerSectionId),
            new Table(_guidGenerator.Create(), "B08", 4, TableStatus.Available, true, centerSectionId),

            // Khu vực Phải - Bàn 9-12
            new Table(_guidGenerator.Create(), "B09", 1, TableStatus.Available, true, rightSectionId),
            new Table(_guidGenerator.Create(), "B10", 2, TableStatus.Available, true, rightSectionId),
            new Table(_guidGenerator.Create(), "B11", 3, TableStatus.Available, true, rightSectionId),
            new Table(_guidGenerator.Create(), "B12", 4, TableStatus.Available, true, rightSectionId)
        };

        await _tableRepository.InsertManyAsync(tables, autoSave: true);
    }
}