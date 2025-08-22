using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Shouldly;
using Volo.Abp;
using Volo.Abp.Authorization;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Modularity;
using Xunit;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.TableManagement.LayoutSections.Dto;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    public class LayoutSectionAppService_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
    {
        private readonly ILayoutSectionAppService _layoutSectionAppService;
        private readonly IRepository<LayoutSection, Guid> _layoutSectionRepository;

        public LayoutSectionAppService_Tests()
        {
            _layoutSectionAppService = GetRequiredService<ILayoutSectionAppService>();
            _layoutSectionRepository = GetRequiredService<IRepository<LayoutSection, Guid>>();
        }



        [Fact]
        public async Task Should_Get_List_Of_Layout_Sections()
        {
            // Act
            var result = await _layoutSectionAppService.GetListAsync();

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBeGreaterThanOrEqualTo(0);
        }

        [Fact]
        public async Task Should_Create_A_Valid_Layout_Section()
        {
            // Arrange
            var createDto = new CreateLayoutSectionDto
            {
                SectionName = "Dãy 1",
                Description = "Khu vực dãy 1 với 10 bàn",
                DisplayOrder = 1,
                IsActive = true
            };

            // Act
            var result = await _layoutSectionAppService.CreateAsync(createDto);

            // Assert
            result.ShouldNotBeNull();
            result.SectionName.ShouldBe("Dãy 1");
            result.Description.ShouldBe("Khu vực dãy 1 với 10 bàn");
            result.DisplayOrder.ShouldBe(1);
            result.IsActive.ShouldBe(true);
            result.Id.ShouldNotBe(Guid.Empty);
        }

        [Fact]
        public async Task Should_Create_Layout_Section_With_Null_Description()
        {
            // Arrange
            var createDto = new CreateLayoutSectionDto
            {
                SectionName = "Khu VIP",
                Description = null,
                DisplayOrder = 2,
                IsActive = true
            };

            // Act
            var result = await _layoutSectionAppService.CreateAsync(createDto);

            // Assert
            result.ShouldNotBeNull();
            result.SectionName.ShouldBe("Khu VIP");
            result.Description.ShouldBeNull();
            result.DisplayOrder.ShouldBe(2);
            result.IsActive.ShouldBe(true);
        }

        [Fact]
        public async Task Should_Get_Layout_Section_By_Id()
        {
            // Arrange
            var section = new LayoutSection(
                Guid.NewGuid(),
                "Sân vườn",
                "Khu vực ngoài trời",
                3,
                true
            );
            await _layoutSectionRepository.InsertAsync(section);

            // Act
            var result = await _layoutSectionAppService.GetAsync(section.Id);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(section.Id);
            result.SectionName.ShouldBe("Sân vườn");
            result.Description.ShouldBe("Khu vực ngoài trời");
            result.DisplayOrder.ShouldBe(3);
            result.IsActive.ShouldBe(true);
        }

        [Fact]
        public async Task Should_Update_Layout_Section()
        {
            // Arrange
            var section = new LayoutSection(
                Guid.NewGuid(),
                "Phòng riêng A",
                "Phòng riêng cho nhóm nhỏ",
                4,
                true
            );
            await _layoutSectionRepository.InsertAsync(section);

            var updateDto = new UpdateLayoutSectionDto
            {
                SectionName = "Phòng riêng VIP",
                Description = "Phòng riêng VIP cao cấp",
                DisplayOrder = 5,
                IsActive = false
            };

            // Act
            var result = await _layoutSectionAppService.UpdateAsync(section.Id, updateDto);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(section.Id);
            result.SectionName.ShouldBe("Phòng riêng VIP");
            result.Description.ShouldBe("Phòng riêng VIP cao cấp");
            result.DisplayOrder.ShouldBe(5);
            result.IsActive.ShouldBe(false);
        }

        [Fact]
        public async Task Should_Delete_Layout_Section()
        {
            // Arrange
            var section = new LayoutSection(
                Guid.NewGuid(),
                "Tầng 2",
                "Khu vực tầng 2",
                6,
                true
            );
            await _layoutSectionRepository.InsertAsync(section);

            // Act
            await _layoutSectionAppService.DeleteAsync(section.Id);

            // Assert
            var deletedSection = await _layoutSectionRepository.FindAsync(section.Id);
            deletedSection.ShouldBeNull();
        }

        [Fact]
        public async Task Should_Get_Next_Display_Order()
        {
            // Arrange - Create some sections with different display orders
            var section1 = new LayoutSection(Guid.NewGuid(), "Test 1", null, 5, true);
            var section2 = new LayoutSection(Guid.NewGuid(), "Test 2", null, 10, true);
            var section3 = new LayoutSection(Guid.NewGuid(), "Test 3", null, 3, true);

            await _layoutSectionRepository.InsertAsync(section1);
            await _layoutSectionRepository.InsertAsync(section2);
            await _layoutSectionRepository.InsertAsync(section3);

            // Act
            var nextOrder = await _layoutSectionAppService.GetNextDisplayOrderAsync();

            // Assert
            nextOrder.ShouldBe(11); // Max is 10, so next should be 11
        }

        [Fact]
        public async Task Should_Get_Next_Display_Order_When_No_Sections_Exist()
        {
            // Act
            var nextOrder = await _layoutSectionAppService.GetNextDisplayOrderAsync();

            // Assert
            nextOrder.ShouldBe(1); // Should return 1 when no sections exist
        }

        [Fact]
        public async Task Should_Order_Sections_By_DisplayOrder_And_SectionName()
        {
            // Arrange
            var section1 = new LayoutSection(Guid.NewGuid(), "Z Section", null, 2, true);
            var section2 = new LayoutSection(Guid.NewGuid(), "A Section", null, 1, true);
            var section3 = new LayoutSection(Guid.NewGuid(), "B Section", null, 1, true);

            await _layoutSectionRepository.InsertAsync(section1);
            await _layoutSectionRepository.InsertAsync(section2);
            await _layoutSectionRepository.InsertAsync(section3);

            // Act
            var result = await _layoutSectionAppService.GetListAsync();

            // Assert
            result.Count.ShouldBeGreaterThanOrEqualTo(3);
            
            // Find our test sections in the result
            var orderedSections = result.Where(s => new[] { "A Section", "B Section", "Z Section" }.Contains(s.SectionName))
                                        .ToList();

            orderedSections.Count.ShouldBe(3);
            orderedSections[0].SectionName.ShouldBe("A Section"); // DisplayOrder 1, name A
            orderedSections[1].SectionName.ShouldBe("B Section"); // DisplayOrder 1, name B  
            orderedSections[2].SectionName.ShouldBe("Z Section"); // DisplayOrder 2, name Z
        }
    }
}