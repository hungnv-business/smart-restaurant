using Xunit;

namespace SmartRestaurant.EntityFrameworkCore;

[CollectionDefinition(SmartRestaurantTestConsts.CollectionDefinitionName)]
public class SmartRestaurantEntityFrameworkCoreCollection : ICollectionFixture<SmartRestaurantEntityFrameworkCoreFixture>
{

}
