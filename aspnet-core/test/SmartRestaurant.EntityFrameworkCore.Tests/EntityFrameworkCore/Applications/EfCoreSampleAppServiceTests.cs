using SmartRestaurant.Samples;
using Xunit;

namespace SmartRestaurant.EntityFrameworkCore.Applications;

[Collection(SmartRestaurantTestConsts.CollectionDefinitionName)]
public class EfCoreSampleAppServiceTests : SampleAppServiceTests<SmartRestaurantEntityFrameworkCoreTestModule>
{

}
