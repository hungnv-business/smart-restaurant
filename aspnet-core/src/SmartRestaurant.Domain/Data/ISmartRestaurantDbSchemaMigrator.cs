using System.Threading.Tasks;

namespace SmartRestaurant.Data;

public interface ISmartRestaurantDbSchemaMigrator
{
    Task MigrateAsync();
}
