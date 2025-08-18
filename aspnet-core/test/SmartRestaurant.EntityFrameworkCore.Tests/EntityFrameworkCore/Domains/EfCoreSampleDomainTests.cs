using SmartRestaurant.Samples;
using Xunit;

namespace SmartRestaurant.EntityFrameworkCore.Domains;

[Collection(SmartRestaurantTestConsts.CollectionDefinitionName)]
public class EfCoreSampleDomainTests : SampleDomainTests<SmartRestaurantEntityFrameworkCoreTestModule>
{

}
