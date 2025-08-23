using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using NSubstitute;
using Shouldly;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.Repositories;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.TableManagement.Tables.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Xunit;

namespace SmartRestaurant.TableManagement.Tables
{
    public class TableAppService_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
    {
        private readonly ITableAppService _tableAppService;
        private readonly ITableRepository _tableRepository;
        private readonly ILayoutSectionRepository _layoutSectionRepository;

        public TableAppService_Tests()
        {
            _tableAppService = GetRequiredService<ITableAppService>();
            _tableRepository = GetRequiredService<ITableRepository>();
            _layoutSectionRepository = GetRequiredService<ILayoutSectionRepository>();
        }

        [Fact]
        public async Task Should_Get_Tables_By_Section()
        {
            // Arrange
            var sectionId = Guid.NewGuid();
            var layoutSection = new LayoutSection(sectionId, "Test Section");
            await _layoutSectionRepository.InsertAsync(layoutSection);

            var table1 = new Table(Guid.NewGuid(), "B01", 1, TableStatus.Available, true, sectionId);
            var table2 = new Table(Guid.NewGuid(), "B02", 2, TableStatus.Occupied, true, sectionId);
            await _tableRepository.InsertAsync(table1);
            await _tableRepository.InsertAsync(table2);


            // Act
            var result = await _tableAppService.GetTablesBySectionAsync(sectionId);

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBe(2);
            result[0].TableNumber.ShouldBe("B01");
            result[0].DisplayOrder.ShouldBe(1);
            result[1].TableNumber.ShouldBe("B02");
            result[1].DisplayOrder.ShouldBe(2);
        }

        [Fact]
        public async Task Should_Assign_Table_To_Section()
        {
            // Arrange
            var originalSectionId = Guid.NewGuid();
            var targetSectionId = Guid.NewGuid();
            
            var originalSection = new LayoutSection(originalSectionId, "Original Section");
            var targetSection = new LayoutSection(targetSectionId, "Target Section");
            await _layoutSectionRepository.InsertAsync(originalSection);
            await _layoutSectionRepository.InsertAsync(targetSection);

            var table = new Table(Guid.NewGuid(), "B01", 1, TableStatus.Available, true, originalSectionId);
            await _tableRepository.InsertAsync(table);


            var assignDto = new AssignTableToSectionDto
            {
                LayoutSectionId = targetSectionId
            };

            // Act
            await _tableAppService.AssignToSectionAsync(table.Id, assignDto);

            // Assert
            var updatedTable = await _tableRepository.GetAsync(table.Id);
            updatedTable.LayoutSectionId.ShouldBe(targetSectionId);
        }

        [Fact]
        public async Task Should_Update_Table_Display_Order()
        {
            // Arrange
            var sectionId = Guid.NewGuid();
            var layoutSection = new LayoutSection(sectionId, "Test Section");
            await _layoutSectionRepository.InsertAsync(layoutSection);

            var table = new Table(Guid.NewGuid(), "B01", 1, TableStatus.Available, true, sectionId);
            await _tableRepository.InsertAsync(table);


            var updateDto = new UpdateTableDisplayOrderDto
            {
                DisplayOrder = 5
            };

            // Act
            await _tableAppService.UpdateDisplayOrderAsync(table.Id, updateDto);

            // Assert
            var updatedTable = await _tableRepository.GetAsync(table.Id);
            updatedTable.DisplayOrder.ShouldBe(5);
        }

        [Fact]
        public async Task Should_Get_All_Tables_Ordered()
        {
            // Arrange
            var section1Id = Guid.NewGuid();
            var section2Id = Guid.NewGuid();
            
            var section1 = new LayoutSection(section1Id, "Section 1", displayOrder: 1);
            var section2 = new LayoutSection(section2Id, "Section 2", displayOrder: 2);
            await _layoutSectionRepository.InsertAsync(section1);
            await _layoutSectionRepository.InsertAsync(section2);

            var table1 = new Table(Guid.NewGuid(), "B01", 2, TableStatus.Available, true, section1Id);
            var table2 = new Table(Guid.NewGuid(), "B02", 1, TableStatus.Available, true, section1Id);
            var table3 = new Table(Guid.NewGuid(), "B03", 1, TableStatus.Available, true, section2Id);
            
            await _tableRepository.InsertAsync(table1);
            await _tableRepository.InsertAsync(table2);
            await _tableRepository.InsertAsync(table3);


            // Act
            var result = await _tableAppService.GetAllTablesOrderedAsync();

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBe(3);
            
            // Should be ordered by section display order, then by table display order
            result[0].TableNumber.ShouldBe("B02"); // Section 1, Order 1
            result[1].TableNumber.ShouldBe("B01"); // Section 1, Order 2
            result[2].TableNumber.ShouldBe("B03"); // Section 2, Order 1
        }

        [Fact]
        public async Task Should_Update_Multiple_Table_Positions()
        {
            // Arrange
            var section1Id = Guid.NewGuid();
            var section2Id = Guid.NewGuid();
            
            var section1 = new LayoutSection(section1Id, "Section 1");
            var section2 = new LayoutSection(section2Id, "Section 2");
            await _layoutSectionRepository.InsertAsync(section1);
            await _layoutSectionRepository.InsertAsync(section2);

            var table1 = new Table(Guid.NewGuid(), "B01", 1, TableStatus.Available, true, section1Id);
            var table2 = new Table(Guid.NewGuid(), "B02", 2, TableStatus.Available, true, section1Id);
            
            await _tableRepository.InsertAsync(table1);
            await _tableRepository.InsertAsync(table2);


            var updates = new List<TablePositionUpdateDto>
            {
                new TablePositionUpdateDto { TableId = table1.Id, LayoutSectionId = section2Id, DisplayOrder = 1 },
                new TablePositionUpdateDto { TableId = table2.Id, LayoutSectionId = section1Id, DisplayOrder = 1 }
            };

            // Act
            await _tableAppService.UpdateMultipleTablePositionsAsync(updates);

            // Assert
            var updatedTable1 = await _tableRepository.GetAsync(table1.Id);
            var updatedTable2 = await _tableRepository.GetAsync(table2.Id);
            
            updatedTable1.LayoutSectionId.ShouldBe(section2Id);
            updatedTable1.DisplayOrder.ShouldBe(1);
            
            updatedTable2.LayoutSectionId.ShouldBe(section1Id);
            updatedTable2.DisplayOrder.ShouldBe(1);
        }
    }
}