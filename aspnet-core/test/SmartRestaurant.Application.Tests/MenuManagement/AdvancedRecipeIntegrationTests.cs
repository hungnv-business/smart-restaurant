using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Shouldly;
using Xunit;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.Orders;
using SmartRestaurant.Application.Contracts.MenuManagement.MenuItems;
using SmartRestaurant.Application.Contracts.MenuManagement.MenuItems.Dto;
using SmartRestaurant.Application.Contracts.InventoryManagement.Ingredients;
using SmartRestaurant.Application.Contracts.InventoryManagement.Ingredients.Dto;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.TableManagement.Tables;
using SmartRestaurant.Application.Contracts.TableManagement.Tables.Dto;
using SmartRestaurant.Domain.Shared.Orders;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.BusinessException;

namespace SmartRestaurant.MenuManagement
{
    public class AdvancedRecipeIntegrationTests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
    {
        private readonly RecipeManager _recipeManager;
        private readonly IRepository<MenuItemIngredient, Guid> _menuItemIngredientRepository;
        private readonly IIngredientAppService _ingredientAppService;
        private readonly IMenuItemAppService _menuItemAppService;
        private readonly IOrderAppService _orderAppService;

        public AdvancedRecipeIntegrationTests()
        {
            _recipeManager = GetRequiredService<RecipeManager>();
            _menuItemIngredientRepository = GetRequiredService<IRepository<MenuItemIngredient, Guid>>();
            _ingredientAppService = GetRequiredService<IIngredientAppService>();
            _menuItemAppService = GetRequiredService<IMenuItemAppService>();
            _orderAppService = GetRequiredService<IOrderAppService>();
        }

        [Fact]
        public async Task Complex_Recipe_With_Multiple_Ingredients_Should_Calculate_Correctly()
        {
            // Arrange - Tạo recipe phức tạp cho "Bún Bò Huế Đặc Biệt"
            var ingredients = await CreateComplexRecipeIngredientsAsync();
            var bunBoHue = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bún Bò Huế Đặc Biệt",
                Description = "Bún bò Huế với đầy đủ topping",
                Price = 85000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Tạo recipe với nhiều ingredients
            var recipeIngredients = new[]
            {
                (ingredients["thit_bo"], 150, false),      // Thịt bò: 150g, bắt buộc
                (ingredients["cha_lua"], 50, false),       // Chả lụa: 50g, bắt buộc  
                (ingredients["bun_bo"], 1, false),         // Bún bò: 1 suất, bắt buộc
                (ingredients["hanh_la"], 20, true),        // Hành lá: 20g, tùy chọn
                (ingredients["rau_thom"], 15, true),       // Rau thơm: 15g, tùy chọn
                (ingredients["ot_tuong"], 30, true),       // Ớt tương: 30g, tùy chọn
                (ingredients["nuoc_mam"], 10, false),      // Nước mắm: 10ml, bắt buộc
            };

            foreach (var (ingredient, quantity, isOptional) in recipeIngredients)
            {
                await CreateMenuItemIngredientAsync(bunBoHue.Id, ingredient.Id, quantity, isOptional);
            }

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (bunBoHue.Id, 3) // 3 suất Bún Bò Huế
            };

            // Act - Kiểm tra ingredient availability (Mock implementation)
            var missingIngredients = await MockCheckIngredientAvailabilityAsync(orderItems, ingredients);

            // Assert - Phải tính toán đúng cho 3 suất
            // Thịt bò: cần 450g (150*3), có 400g => thiếu 50g
            // Chả lụa: cần 150g (50*3), có 200g => đủ
            // Nước mắm: cần 30ml (10*3), có 50ml => đủ
            // Ớt tương: cần 90g (30*3), có 0g => thiếu nhưng optional
            
            missingIngredients.Count(mi => !mi.IsOptional).ShouldBe(1); // Chỉ thịt bò thiếu (bắt buộc)
            
            var missingThitBo = missingIngredients.FirstOrDefault(mi => mi.IngredientName == "Thịt bò");
            missingThitBo.ShouldNotBeNull();
            missingThitBo.RequiredQuantity.ShouldBe(450);
            missingThitBo.CurrentStock.ShouldBe(400);
            missingThitBo.MissingQuantity.ShouldBe(50);
            missingThitBo.IsOptional.ShouldBe(false);
        }

        [Fact]
        public async Task Recipe_Scaling_Should_Work_With_Different_Quantities()
        {
            // Arrange - Recipe cho "Phở Bò" cơ bản
            var thitBo = await CreateTestIngredientAsync("Thịt bò Phở", 1000); // 1kg
            var banhPho = await CreateTestIngredientAsync("Bánh phở", 20); // 20 suất
            var hanhLa = await CreateTestIngredientAsync("Hành lá", 500); // 500g

            var pho = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Chuẩn",
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe cho 1 suất
            await CreateMenuItemIngredientAsync(pho.Id, thitBo.Id, 120, false); // 120g thịt
            await CreateMenuItemIngredientAsync(pho.Id, banhPho.Id, 1, false);  // 1 suất bánh
            await CreateMenuItemIngredientAsync(pho.Id, hanhLa.Id, 10, true);   // 10g hành

            var testScenarios = new[]
            {
                (quantity: 1, expectedThitBo: 120, expectedBanhPho: 1, expectedHanhLa: 10),
                (quantity: 5, expectedThitBo: 600, expectedBanhPho: 5, expectedHanhLa: 50),
                (quantity: 8, expectedThitBo: 960, expectedBanhPho: 8, expectedHanhLa: 80), // Should exceed stock
            };

            foreach (var scenario in testScenarios)
            {
                // Act
                var orderItems = new List<(Guid menuItemId, int quantity)>
                {
                    (pho.Id, scenario.quantity)
                };

                // Mock recipe scaling implementation
                var scaledIngredients = MockScaleRecipeIngredients(pho.Id, scenario.quantity);

                // Assert - Ingredients should scale correctly
                scaledIngredients.First(i => i.IngredientName == "Thịt bò Phở")
                    .RequiredQuantity.ShouldBe(scenario.expectedThitBo);
                scaledIngredients.First(i => i.IngredientName == "Bánh phở")
                    .RequiredQuantity.ShouldBe(scenario.expectedBanhPho);
                scaledIngredients.First(i => i.IngredientName == "Hành lá")
                    .RequiredQuantity.ShouldBe(scenario.expectedHanhLa);
            }
        }

        [Fact]
        public async Task Negative_Stock_Should_Be_Handled_Gracefully()
        {
            // Arrange - Ingredient với stock rất thấp
            var criticalIngredient = await CreateTestIngredientAsync("Thịt bò cao cấp", 50); // Chỉ 50g
            
            var expensiveDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bò Úc Cao Cấp",
                Description = "Thịt bò Úc nhập khẩu",
                Price = 350000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(expensiveDish.Id, criticalIngredient.Id, 200, false); // Cần 200g

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (expensiveDish.Id, 1) // 1 suất cần 200g, chỉ có 50g
            };

            // Act - Kiểm tra availability
            var missingIngredients = await _recipeManager.CheckIngredientAvailabilityAsync(orderItems);

            // Assert - Should detect critical shortage
            missingIngredients.Count.ShouldBe(1);
            var missing = missingIngredients[0];
            missing.IngredientName.ShouldBe("Thịt bò cao cấp");
            missing.RequiredQuantity.ShouldBe(200);
            missing.CurrentStock.ShouldBe(50);
            missing.MissingQuantity.ShouldBe(150);
            missing.IsOptional.ShouldBe(false);

            // Should not be able to fulfill order
            var (canFulfill, missingList) = await _recipeManager.CanFulfillOrderAsync(orderItems);
            canFulfill.ShouldBe(false);
            missingList.Count.ShouldBe(1);
        }

        [Fact]
        public async Task Stock_Reservation_Should_Prevent_Overselling()
        {
            // Arrange - Ingredient với stock giới hạn
            var limitedIngredient = await CreateTestIngredientAsync("Tôm hùm", 3); // Chỉ 3 con
            
            var lobsterDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Tôm Hùm Nướng",
                Price = 450000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(lobsterDish.Id, limitedIngredient.Id, 1, false); // 1 con/suất

            // Act - Tạo multiple orders cùng lúc (race condition test)
            var orderTasks = new List<Task<OrderDto>>();
            
            for (int i = 0; i < 5; i++)
            {
                var task = Task.Run(async () =>
                {
                    try
                    {
                        var table = await CreateTestTableAsync($"RACE-{i + 1}");
                        
                        var order = await _orderAppService.CreateAsync(new CreateOrderDto
                        {
                            TableId = table.Id,
                            OrderType = OrderType.DineIn,
                            Items = new[]
                            {
                                new CreateOrderItemDto
                                {
                                    MenuItemId = lobsterDish.Id,
                                    Quantity = 1
                                }
                            }
                        });

                        await _orderAppService.ConfirmOrderAsync(order.Id);
                        return order;
                    }
                    catch (BusinessException ex) when (ex.Code == OrderErrorCodes.InsufficientIngredients)
                    {
                        return null; // Expected for orders that can't be fulfilled
                    }
                });
                
                orderTasks.Add(task);
            }

            var results = await Task.WhenAll(orderTasks);
            var successfulOrders = results.Where(r => r != null).ToArray();

            // Assert - Chỉ 3 orders đầu tiên thành công (đúng với stock = 3)
            successfulOrders.Length.ShouldBeLessThanOrEqualTo(3);
            
            // Kiểm tra stock đã được reserve đúng
            var finalIngredient = await _ingredientAppService.GetAsync(limitedIngredient.Id);
            finalIngredient.CurrentStock.ShouldBe(3 - successfulOrders.Length);
        }

        [Fact]
        public async Task Recipe_Substitution_Should_Work_When_Available()
        {
            // Arrange - Recipe có thể thay thế ingredients
            var primaryIngredient = await CreateTestIngredientAsync("Thịt bò Úc", 0); // Hết hàng
            var substituteIngredient = await CreateTestIngredientAsync("Thịt bò Việt Nam", 500); // Có hàng
            
            var flexibleDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bò Lúc Lắc Linh Hoạt",
                Description = "Có thể dùng thịt bò thay thế",
                Price = 120000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe primary (preferred)
            await CreateMenuItemIngredientAsync(flexibleDish.Id, primaryIngredient.Id, 150, false);
            
            // Tạo ingredient substitution rule
            await CreateIngredientSubstitutionAsync(
                flexibleDish.Id, 
                primaryIngredient.Id, 
                substituteIngredient.Id,
                conversionRatio: 1.2m // Cần nhiều hơn 20% nếu dùng thay thế
            );

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (flexibleDish.Id, 2) // 2 suất
            };

            // Act - Check availability with substitution (Mock implementation)
            var availabilityResult = await MockCheckAvailabilityWithSubstitutionAsync(orderItems);

            // Assert - Should suggest substitution
            availabilityResult.CanFulfill.ShouldBe(true);
            availabilityResult.RequiresSubstitution.ShouldBe(true);
            
            var substitution = availabilityResult.Substitutions.First();
            substitution.OriginalIngredientName.ShouldBe("Thịt bò Úc");
            substitution.SubstituteIngredientName.ShouldBe("Thịt bò Việt Nam");
            substitution.RequiredQuantity.ShouldBe(360); // 150 * 2 * 1.2 = 360g
            substitution.PriceImpact.ShouldBeGreaterThan(0); // Should calculate price difference
        }

        [Fact]
        public async Task Batch_Order_Processing_Should_Optimize_Ingredient_Usage()
        {
            // Arrange - Multiple orders cùng ingredients
            var sharedIngredients = await CreateSharedIngredientsAsync();
            var menuItems = await CreateMenuItemsWithSharedIngredientsAsync(sharedIngredients);

            // Tạo 5 orders với different combinations
            var batchOrders = new List<(Guid menuItemId, int quantity)>
            {
                (menuItems["pho_bo"], 3),        // 3 Phở Bò
                (menuItems["pho_ga"], 2),        // 2 Phở Gà  
                (menuItems["bun_bo"], 2),        // 2 Bún Bò
                (menuItems["banh_mi"], 4),       // 4 Bánh Mì
                (menuItems["che_ba_mau"], 3),    // 3 Chè Ba Màu
            };

            // Act - Process as batch order (Mock implementation)
            var batchResult = await MockProcessBatchOrderAsync(batchOrders);

            // Assert - Should optimize ingredient usage
            batchResult.TotalIngredientUsage.Count.ShouldBeGreaterThan(0);
            batchResult.OptimizationSavings.ShouldBeGreaterThan(0); // Saved by batch processing
            batchResult.CanFulfillAll.ShouldBe(true);

            // Verify specific calculations
            var thitBoUsage = batchResult.TotalIngredientUsage
                .FirstOrDefault(u => u.IngredientName == "Thịt bò chung");
            thitBoUsage.ShouldNotBeNull();
            thitBoUsage.TotalRequired.ShouldBe(930); // Phở bò: 450g + Bún bò: 240g + Bánh mì: 240g

            var ricePaperUsage = batchResult.TotalIngredientUsage
                .FirstOrDefault(u => u.IngredientName == "Bánh tráng");
            ricePaperUsage.ShouldNotBeNull();
            ricePaperUsage.TotalRequired.ShouldBe(6); // Phở bò: 3 + Phở gà: 2 + Bún bò: 2 = 7, nhưng optimize xuống 6
        }

        [Fact]
        public async Task Recipe_Cost_Calculation_Should_Include_Labor_And_Overhead()
        {
            // Arrange - Recipe với detailed costing
            var expensiveIngredients = await CreateExpensiveIngredientsAsync();
            
            var premiumDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Kobe Premium",
                Description = "Phở bò Kobe Nhật Bản cao cấp",
                Price = 250000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe với ingredients đắt đỏ
            await CreateMenuItemIngredientAsync(premiumDish.Id, expensiveIngredients["kobe_beef"].Id, 200, false);
            await CreateMenuItemIngredientAsync(premiumDish.Id, expensiveIngredients["special_noodle"].Id, 1, false);
            await CreateMenuItemIngredientAsync(premiumDish.Id, expensiveIngredients["premium_broth"].Id, 500, false);

            // Act - Calculate detailed cost breakdown (Mock implementation)
            var costBreakdown = await MockCalculateRecipeCostAsync(premiumDish.Id, 1);

            // Assert - Should include all cost components
            costBreakdown.IngredientCost.ShouldBeGreaterThan(180000); // Major portion
            costBreakdown.LaborCost.ShouldBeGreaterThan(0); // Skilled preparation
            costBreakdown.OverheadCost.ShouldBeGreaterThan(0); // Kitchen overhead
            costBreakdown.TotalCost.ShouldBe(
                costBreakdown.IngredientCost + 
                costBreakdown.LaborCost + 
                costBreakdown.OverheadCost
            );
            
            // Profit margin should be reasonable
            var profitMargin = (250000m - costBreakdown.TotalCost) / 250000m;
            profitMargin.ShouldBeGreaterThan(0.15m); // At least 15% margin
            profitMargin.ShouldBeLessThan(0.80m); // Not excessive
        }

        [Fact]
        public async Task Seasonal_Ingredient_Availability_Should_Affect_Menu()
        {
            // Arrange - Seasonal ingredients
            var seasonalIngredients = await CreateSeasonalIngredientsAsync();
            
            var seasonalDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bánh Chưng Tết",
                Description = "Bánh chưng truyền thống dịp Tết",
                Price = 45000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe với seasonal ingredients
            await CreateMenuItemIngredientAsync(seasonalDish.Id, seasonalIngredients["la_dong"].Id, 2, false); // Lá dong
            await CreateMenuItemIngredientAsync(seasonalDish.Id, seasonalIngredients["gao_nep"].Id, 200, false); // Gạo nếp
            await CreateMenuItemIngredientAsync(seasonalDish.Id, seasonalIngredients["dau_xanh"].Id, 100, false); // Đậu xanh

            // Act - Check availability during off-season (Mock implementation)
            var (canFulfill, missingIngredients) = await MockCheckSeasonalAvailabilityAsync(
                new[] { (seasonalDish.Id, 10) }, // 10 bánh chưng
                "summer" // Off-season for Tết items
            );

            // Assert - Should be unavailable or very expensive
            canFulfill.ShouldBe(false);
            missingIngredients.ShouldContain(mi => mi.IngredientName == "Lá dong");

            // Check pricing impact (Mock implementation)
            var seasonalPricing = MockGetSeasonalPricing(seasonalDish.Id, "summer");
            seasonalPricing.PriceMultiplier.ShouldBeGreaterThan(1.5m); // At least 50% more expensive
        }

        [Fact]
        public async Task Cross_Contamination_Allergen_Checking()
        {
            // Arrange - Ingredients với allergen warnings
            var allergenicIngredients = await CreateAllergenicIngredientsAsync();
            
            var allergyDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món Ăn Dị Ứng Test",
                Price = 75000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe với potential allergens
            await CreateMenuItemIngredientAsync(allergyDish.Id, allergenicIngredients["tom_tuoi"].Id, 100, false); // Tôm (shellfish)
            await CreateMenuItemIngredientAsync(allergyDish.Id, allergenicIngredients["dau_phong"].Id, 20, true); // Đậu phộng (nuts)
            await CreateMenuItemIngredientAsync(allergyDish.Id, allergenicIngredients["sua_tuoi"].Id, 50, true); // Sữa (dairy)

            // Customer với allergies
            var customerAllergies = new[] { "shellfish", "nuts" };

            // Act - Check allergen compatibility (Mock implementation)
            var allergenCheck = await MockCheckAllergenCompatibilityAsync(
                allergyDish.Id, 
                customerAllergies
            );

            // Assert - Should detect allergen conflicts
            allergenCheck.HasConflicts.ShouldBe(true);
            allergenCheck.ConflictingIngredients.Count.ShouldBe(2);
            
            allergenCheck.ConflictingIngredients.ShouldContain(ing => 
                ing.IngredientName == "Tôm tươi" && ing.AllergenType == "shellfish");
            allergenCheck.ConflictingIngredients.ShouldContain(ing => 
                ing.IngredientName == "Đậu phộng" && ing.AllergenType == "nuts");

            // Should suggest modifications
            allergenCheck.SuggestedModifications.ShouldContain("Bỏ tôm tươi");
            allergenCheck.SuggestedModifications.ShouldContain("Bỏ đậu phộng");
            
            // Modified price should be calculated
            allergenCheck.ModifiedPrice.ShouldBeLessThan(75000m);
        }

        [Fact]
        public async Task Nutritional_Information_Should_Aggregate_From_Ingredients()
        {
            // Arrange - Ingredients với nutritional data
            var nutritionalIngredients = await CreateNutritionalIngredientsAsync();
            
            var healthyDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Salad Dinh Dưỡng",
                Description = "Salad rau củ với thịt bò",
                Price = 85000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe với detailed nutritional components
            await CreateMenuItemIngredientAsync(healthyDish.Id, nutritionalIngredients["lean_beef"].Id, 100, false);
            await CreateMenuItemIngredientAsync(healthyDish.Id, nutritionalIngredients["mixed_greens"].Id, 150, false);
            await CreateMenuItemIngredientAsync(healthyDish.Id, nutritionalIngredients["cherry_tomato"].Id, 50, false);
            await CreateMenuItemIngredientAsync(healthyDish.Id, nutritionalIngredients["olive_oil"].Id, 15, false);

            // Act - Calculate nutritional information (Mock implementation)
            var nutrition = await MockCalculateNutritionalInfoAsync(healthyDish.Id);

            // Assert - Should aggregate from all ingredients
            nutrition.TotalCalories.ShouldBeGreaterThan(250); // Realistic for this dish
            nutrition.TotalCalories.ShouldBeLessThan(400);
            
            nutrition.Protein.ShouldBeGreaterThan(20); // Good protein from beef
            nutrition.Carbohydrates.ShouldBeLessThan(15); // Low carb salad
            nutrition.Fat.ShouldBeGreaterThan(10); // From olive oil and beef
            nutrition.Fiber.ShouldBeGreaterThan(8); // From vegetables
            
            // Vitamin content from vegetables
            nutrition.VitaminC.ShouldBeGreaterThan(30); // From tomatoes and greens
            
            // Should include allergen warnings
            nutrition.AllergenWarnings.ShouldNotContain("shellfish");
            nutrition.AllergenWarnings.ShouldNotContain("nuts");
        }

        [Fact]
        public async Task Recipe_Modification_Should_Update_Costs_And_Nutrition()
        {
            // Arrange - Base recipe
            var ingredients = await CreateBaseRecipeIngredientsAsync();
            
            var modifiableDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Có Thể Tùy Chỉnh",
                Price = 70000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Base recipe
            await CreateMenuItemIngredientAsync(modifiableDish.Id, ingredients["base_beef"].Id, 120, false);
            await CreateMenuItemIngredientAsync(modifiableDish.Id, ingredients["base_noodle"].Id, 1, false);
            await CreateMenuItemIngredientAsync(modifiableDish.Id, ingredients["base_herbs"].Id, 20, true);

            // Customer modifications
            var modifications = new RecipeModification[]
            {
                new() { IngredientId = ingredients["base_beef"].Id, QuantityChange = +50 }, // Extra beef
                new() { IngredientId = ingredients["base_herbs"].Id, QuantityChange = -20 }, // No herbs
                new() { IngredientId = ingredients["premium_herbs"].Id, QuantityChange = +25 }, // Premium herbs instead
            };

            // Act - Apply modifications (Mock implementation)
            var modifiedRecipe = await MockApplyRecipeModificationsAsync(
                modifiableDish.Id, 
                modifications
            );

            // Assert - Should recalculate everything
            modifiedRecipe.TotalCost.ShouldBeGreaterThan(70000m); // Extra beef increases cost
            
            modifiedRecipe.ModifiedIngredients.Count.ShouldBe(3);
            
            var beefModification = modifiedRecipe.ModifiedIngredients
                .First(mi => mi.IngredientName == "Base beef");
            beefModification.FinalQuantity.ShouldBe(170); // 120 + 50
            
            var herbsModification = modifiedRecipe.ModifiedIngredients
                .FirstOrDefault(mi => mi.IngredientName == "Base herbs");
            herbsModification?.FinalQuantity.ShouldBe(0); // Removed

            // Nutrition should be recalculated
            modifiedRecipe.UpdatedNutrition.Protein.ShouldBeGreaterThan(25); // More protein from extra beef
        }

        [Fact]
        public async Task Recipe_Scaling_For_Large_Groups_Should_Maintain_Quality()
        {
            // Arrange - Recipe cho group orders
            var groupIngredients = await CreateGroupIngredientsAsync();
            
            var familyDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Lẩu Thái Gia Đình",
                Description = "Lẩu Thái cho 6-8 người",
                Price = 350000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipe cho 1 serving (assume 2 people)
            await CreateMenuItemIngredientAsync(familyDish.Id, groupIngredients["fish_stock"].Id, 1000, false); // 1L stock
            await CreateMenuItemIngredientAsync(familyDish.Id, groupIngredients["mixed_seafood"].Id, 300, false); // 300g seafood
            await CreateMenuItemIngredientAsync(familyDish.Id, groupIngredients["vegetables"].Id, 500, false); // 500g vegetables
            await CreateMenuItemIngredientAsync(familyDish.Id, groupIngredients["spices"].Id, 20, false); // 20g spices

            var groupSizes = new[] { 1, 2, 4, 6 }; // Different group sizes

            foreach (var groupSize in groupSizes)
            {
                // Act - Scale recipe for group size (Mock implementation)
                var scaledRecipe = await MockScaleRecipeForGroupAsync(
                    familyDish.Id, 
                    groupSize,
                    2 // 2 people per serving
                );

                // Assert - Should scale appropriately but maintain ratios
                var servings = Math.Ceiling(groupSize / 2.0); // Round up for group size
                
                scaledRecipe.ScaledIngredients.First(i => i.IngredientName == "Fish stock")
                    .ScaledQuantity.ShouldBe((int)(1000 * servings));
                    
                scaledRecipe.ScaledIngredients.First(i => i.IngredientName == "Mixed seafood")
                    .ScaledQuantity.ShouldBe((int)(300 * servings));

                // Quality maintenance factors
                scaledRecipe.QualityFactors.ShouldContain("cooking_time_adjusted");
                scaledRecipe.QualityFactors.ShouldContain("spice_ratio_optimized");
                
                // Large groups might need special preparation
                if (groupSize >= 6)
                {
                    scaledRecipe.SpecialInstructions.ShouldContain("Chuẩn bị trong nồi lớn");
                    scaledRecipe.EstimatedPrepTime.ShouldBeGreaterThan(TimeSpan.FromMinutes(45));
                }
            }
        }

        [Fact]
        public async Task Zero_Stock_Ingredients_Should_Block_Orders_Immediately()
        {
            // Arrange - Ingredients đã hết hoàn toàn
            var depletedIngredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Hải sản đặc biệt (hết hàng)",
                Unit = "portion", 
                CurrentStock = 0, // Completely out
                MinimumStock = 5,
                UnitCost = 180000m
            });

            var unavailableDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món Hải Sản Hết Hàng",
                Price = 280000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true // Menu shows available, but ingredients aren't
            });

            await CreateMenuItemIngredientAsync(unavailableDish.Id, depletedIngredient.Id, 1, false);

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (unavailableDish.Id, 1)
            };

            // Act - Try to check availability (Mock implementation)
            var (canFulfill, missingIngredients) = await MockCanFulfillOrderAsync(orderItems);

            // Assert - Should immediately block
            canFulfill.ShouldBe(false);
            missingIngredients.Count.ShouldBe(1);
            
            var depleted = missingIngredients[0];
            depleted.CurrentStock.ShouldBe(0);
            depleted.RequiredQuantity.ShouldBe(1);
            depleted.MissingQuantity.ShouldBe(1);
            depleted.IsOptional.ShouldBe(false);

            // Should also update menu item availability automatically
            var updatedMenuItem = await _menuItemAppService.GetAsync(unavailableDish.Id);
            updatedMenuItem.IsAvailable.ShouldBe(false); // Auto-updated due to missing ingredients
        }

        [Fact]
        public async Task Recipe_Inventory_Integration_Should_Prevent_Negative_Stock()
        {
            // Arrange - Ingredient với stock chính xác
            var preciseIngredient = await CreateTestIngredientAsync("Cua biển tươi", 8); // 8 con cua
            
            var crabDish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Cua Rang Me",
                Price = 180000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(crabDish.Id, preciseIngredient.Id, 2, false); // 2 con cua/suất

            // Act - Tạo orders sẽ vượt stock
            var orders = new[]
            {
                (crabDish.Id, 3), // 6 con cua - OK
                (crabDish.Id, 2), // 4 con cua - Total 10, exceeds stock of 8
            };

            // Process first order (Mock implementation)
            await MockReserveIngredientsAsync(new[] { orders[0] });
            
            var firstCheck = await _ingredientAppService.GetAsync(preciseIngredient.Id);
            firstCheck.CurrentStock.ShouldBe(2); // 8 - 6 = 2 (would be updated by reservation)

            // Try second order (Mock implementation)
            var (canFulfill, missing) = await MockCanFulfillOrderAsync(new[] { orders[1] });

            // Assert - Should prevent negative stock
            canFulfill.ShouldBe(false);
            missing.Count.ShouldBe(1);
            missing[0].MissingQuantity.ShouldBe(2); // Needs 4, only has 2

            // Stock should remain positive
            var finalCheck = await _ingredientAppService.GetAsync(preciseIngredient.Id);
            finalCheck.CurrentStock.ShouldBeGreaterThanOrEqualTo(0);
        }

        [Fact]
        public async Task Recipe_Optimization_Should_Minimize_Waste()
        {
            // Arrange - Ingredients có thể dùng chung
            var sharedIngredients = await CreateWasteOptimizationIngredientsAsync();
            
            var dishA = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món A - Tối Ưu Waste",
                Price = 60000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var dishB = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món B - Tối Ưu Waste", 
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Recipes use same base ingredients but different quantities
            await CreateMenuItemIngredientAsync(dishA.Id, sharedIngredients["shared_protein"].Id, 150, false);
            await CreateMenuItemIngredientAsync(dishA.Id, sharedIngredients["shared_vegetable"].Id, 100, false);
            
            await CreateMenuItemIngredientAsync(dishB.Id, sharedIngredients["shared_protein"].Id, 120, false);
            await CreateMenuItemIngredientAsync(dishB.Id, sharedIngredients["shared_vegetable"].Id, 80, false);
            await CreateMenuItemIngredientAsync(dishB.Id, sharedIngredients["exclusive_spice"].Id, 10, false);

            var mixedOrder = new[]
            {
                (dishA.Id, 3), // 3 món A
                (dishB.Id, 2), // 2 món B
            };

            // Act - Optimize ingredient usage to minimize waste (Mock implementation)
            var optimization = await MockOptimizeIngredientUsageAsync(mixedOrder);

            // Assert - Should find optimal preparation strategy
            optimization.WasteReduction.ShouldBeGreaterThan(0);
            optimization.OptimalPreparationOrder.Count.ShouldBe(2);
            
            // Should suggest preparing shared ingredients together
            optimization.SharedPreparationSteps.ShouldContain("Chuẩn bị shared_protein chung: 690g"); // (150*3) + (120*2)
            optimization.SharedPreparationSteps.ShouldContain("Chuẩn bị shared_vegetable chung: 460g"); // (100*3) + (80*2)
            
            // Should calculate exact portions needed
            optimization.ExactPortions.Count.ShouldBe(2); // 2 different dishes
        }

        // Helper methods
        private async Task<Dictionary<string, IngredientDto>> CreateComplexRecipeIngredientsAsync()
        {
            var ingredients = new Dictionary<string, IngredientDto>();
            
            ingredients["thit_bo"] = await CreateTestIngredientAsync("Thịt bò", 400); // 400g available, need 450g for 3 servings
            ingredients["cha_lua"] = await CreateTestIngredientAsync("Chả lụa", 200); // Enough
            ingredients["bun_bo"] = await CreateTestIngredientAsync("Bún bò", 10); // Enough  
            ingredients["hanh_la"] = await CreateTestIngredientAsync("Hành lá", 100); // Enough
            ingredients["rau_thom"] = await CreateTestIngredientAsync("Rau thơm", 80); // Enough
            ingredients["ot_tuong"] = await CreateTestIngredientAsync("Ớt tương", 0); // Out of stock but optional
            ingredients["nuoc_mam"] = await CreateTestIngredientAsync("Nước mắm", 100); // Enough

            return ingredients;
        }

        private async Task<Dictionary<string, IngredientDto>> CreateExpensiveIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["kobe_beef"] = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
                {
                    Name = "Thịt bò Kobe",
                    Unit = "g",
                    CurrentStock = 500,
                    MinimumStock = 100,
                    UnitCost = 800000m // 800k per kg
                }),
                ["special_noodle"] = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
                {
                    Name = "Bánh phở đặc biệt",
                    Unit = "suất",
                    CurrentStock = 20,
                    MinimumStock = 5,
                    UnitCost = 15000m
                }),
                ["premium_broth"] = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
                {
                    Name = "Nước dùng premium",
                    Unit = "ml", 
                    CurrentStock = 5000,
                    MinimumStock = 1000,
                    UnitCost = 200m // 200đ/ml
                })
            };
        }

        private async Task<IngredientDto> CreateTestIngredientAsync(string name, int currentStock)
        {
            return await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = name,
                Unit = "g",
                CurrentStock = currentStock,
                MinimumStock = Math.Max(currentStock / 10, 10),
                UnitCost = 50000m / Math.Max(currentStock, 1) // Variable cost based on scarcity
            });
        }

        private async Task CreateMenuItemIngredientAsync(Guid menuItemId, Guid ingredientId, int quantity, bool isOptional)
        {
            await _menuItemIngredientRepository.InsertAsync(new MenuItemIngredient
            {
                Id = Guid.NewGuid(),
                MenuItemId = menuItemId,
                IngredientId = ingredientId,
                RequiredQuantity = quantity,
                IsOptional = isOptional
            }, autoSave: true);
        }

        private async Task<TableDto> CreateTestTableAsync(string tableNumber)
        {
            var tableAppService = GetRequiredService<ITableAppService>();
            return await tableAppService.CreateAsync(new CreateTableDto
            {
                TableNumber = tableNumber,
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });
        }

        // Placeholder methods for advanced features - Implementations would be in actual RecipeManager
        private async Task CreateIngredientSubstitutionAsync(Guid menuItemId, Guid originalIngredientId, Guid substituteIngredientId, decimal conversionRatio)
        {
            // In real implementation, this would create substitution mapping
            // For now, we simulate the substitution logic in tests
            await Task.CompletedTask;
        }

        private async Task<Dictionary<string, IngredientDto>> CreateSeasonalIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["la_dong"] = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
                {
                    Name = "Lá dong",
                    Unit = "lá",
                    CurrentStock = 0, // Out of season
                    MinimumStock = 100,
                    UnitCost = 2000m
                }),
                ["gao_nep"] = await CreateTestIngredientAsync("Gạo nếp", 1000),
                ["dau_xanh"] = await CreateTestIngredientAsync("Đậu xanh", 2000),
            };
        }

        private async Task<Dictionary<string, IngredientDto>> CreateAllergenicIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["tom_tuoi"] = await CreateTestIngredientAsync("Tôm tươi", 300),
                ["dau_phong"] = await CreateTestIngredientAsync("Đậu phộng", 500),
                ["sua_tuoi"] = await CreateTestIngredientAsync("Sữa tươi", 1000),
            };
        }

        private async Task<Dictionary<string, IngredientDto>> CreateNutritionalIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["lean_beef"] = await CreateTestIngredientAsync("Thịt bò nạc", 800),
                ["mixed_greens"] = await CreateTestIngredientAsync("Rau xanh hỗn hợp", 1000),
                ["cherry_tomato"] = await CreateTestIngredientAsync("Cà chua cherry", 500),
                ["olive_oil"] = await CreateTestIngredientAsync("Dầu olive", 200),
            };
        }

        private async Task<Dictionary<string, IngredientDto>> CreateSharedIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["shared_beef"] = await CreateTestIngredientAsync("Thịt bò chung", 1000),
                ["rice_paper"] = await CreateTestIngredientAsync("Bánh tráng", 50),
                ["common_herbs"] = await CreateTestIngredientAsync("Rau thơm chung", 300),
            };
        }

        private async Task<Dictionary<string, MenuItemDto>> CreateMenuItemsWithSharedIngredientsAsync(Dictionary<string, IngredientDto> sharedIngredients)
        {
            var menuItems = new Dictionary<string, MenuItemDto>();

            menuItems["pho_bo"] = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Shared",
                Price = 70000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            menuItems["pho_ga"] = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Gà Shared", 
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            menuItems["bun_bo"] = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bún Bò Shared",
                Price = 75000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            menuItems["banh_mi"] = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bánh Mì Shared",
                Price = 25000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            menuItems["che_ba_mau"] = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Chè Ba Màu",
                Price = 15000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            return menuItems;
        }

        private async Task<Dictionary<string, IngredientDto>> CreateGroupIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["fish_stock"] = await CreateTestIngredientAsync("Nước dùng cá", 10000), // 10L
                ["mixed_seafood"] = await CreateTestIngredientAsync("Hải sản hỗn hợp", 2000), // 2kg
                ["vegetables"] = await CreateTestIngredientAsync("Rau củ lẩu", 3000), // 3kg
                ["spices"] = await CreateTestIngredientAsync("Gia vị lẩu Thái", 200), // 200g
            };
        }

        private async Task<Dictionary<string, IngredientDto>> CreateBaseRecipeIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["base_beef"] = await CreateTestIngredientAsync("Base beef", 1000),
                ["base_noodle"] = await CreateTestIngredientAsync("Base noodle", 20),
                ["base_herbs"] = await CreateTestIngredientAsync("Base herbs", 200),
                ["premium_herbs"] = await CreateTestIngredientAsync("Premium herbs", 100),
            };
        }

        private async Task<Dictionary<string, IngredientDto>> CreateWasteOptimizationIngredientsAsync()
        {
            return new Dictionary<string, IngredientDto>
            {
                ["shared_protein"] = await CreateTestIngredientAsync("Protein chung", 1000),
                ["shared_vegetable"] = await CreateTestIngredientAsync("Rau củ chung", 800),
                ["exclusive_spice"] = await CreateTestIngredientAsync("Gia vị riêng", 50),
            };
        }
    }

    // Supporting classes for advanced recipe features
    public class RecipeModification
    {
        public Guid IngredientId { get; set; }
        public int QuantityChange { get; set; }
    }

    public class ModifiedRecipe
    {
        public decimal TotalCost { get; set; }
        public List<ModifiedIngredient> ModifiedIngredients { get; set; } = new();
        public NutritionalInfo UpdatedNutrition { get; set; }
    }

    public class ModifiedIngredient
    {
        public string IngredientName { get; set; }
        public int OriginalQuantity { get; set; }
        public int QuantityChange { get; set; }
        public int FinalQuantity { get; set; }
    }

    public class NutritionalInfo
    {
        public decimal TotalCalories { get; set; }
        public decimal Protein { get; set; }
        public decimal Carbohydrates { get; set; }
        public decimal Fat { get; set; }
        public decimal Fiber { get; set; }
        public decimal VitaminC { get; set; }
        public List<string> AllergenWarnings { get; set; } = new();
    }

    public class AvailabilityResult
    {
        public bool CanFulfill { get; set; }
        public bool RequiresSubstitution { get; set; }
        public List<IngredientSubstitution> Substitutions { get; set; } = new();
    }

    public class IngredientSubstitution
    {
        public string OriginalIngredientName { get; set; }
        public string SubstituteIngredientName { get; set; }
        public int RequiredQuantity { get; set; }
        public decimal PriceImpact { get; set; }
    }

    public class BatchOrderResult
    {
        public List<IngredientUsage> TotalIngredientUsage { get; set; } = new();
        public decimal OptimizationSavings { get; set; }
        public bool CanFulfillAll { get; set; }
    }

    public class IngredientUsage
    {
        public string IngredientName { get; set; }
        public int TotalRequired { get; set; }
    }

    public class RecipeCostBreakdown
    {
        public decimal IngredientCost { get; set; }
        public decimal LaborCost { get; set; }
        public decimal OverheadCost { get; set; }
        public decimal TotalCost { get; set; }
    }

    public class SeasonalPricing
    {
        public decimal PriceMultiplier { get; set; }
        public List<string> UnavailableIngredients { get; set; } = new();
    }

    public class AllergenCheck
    {
        public bool HasConflicts { get; set; }
        public List<AllergenicIngredient> ConflictingIngredients { get; set; } = new();
        public List<string> SuggestedModifications { get; set; } = new();
        public decimal ModifiedPrice { get; set; }
    }

    public class AllergenicIngredient
    {
        public string IngredientName { get; set; }
        public string AllergenType { get; set; }
    }

    public class ScaledRecipe
    {
        public List<ScaledIngredient> ScaledIngredients { get; set; } = new();
        public List<string> QualityFactors { get; set; } = new();
        public List<string> SpecialInstructions { get; set; } = new();
        public TimeSpan EstimatedPrepTime { get; set; }
    }

    public class ScaledIngredient
    {
        public string IngredientName { get; set; }
        public int OriginalQuantity { get; set; }
        public int ScaledQuantity { get; set; }
    }

    public class WasteOptimization
    {
        public decimal WasteReduction { get; set; }
        public List<string> OptimalPreparationOrder { get; set; } = new();
        public List<string> SharedPreparationSteps { get; set; } = new();
        public List<ExactPortion> ExactPortions { get; set; } = new();
    }

    public class ExactPortion
    {
        public string DishName { get; set; }
        public int Quantity { get; set; }
        public Dictionary<string, int> IngredientPortions { get; set; } = new();
    }
}