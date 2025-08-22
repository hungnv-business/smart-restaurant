using AutoMapper;

namespace SmartRestaurant;

public class SmartRestaurantApplicationAutoMapperProfile : Profile
{
    public SmartRestaurantApplicationAutoMapperProfile()
    {
        // Add your object-to-object mapping configurations here
        // For users, we will use ABP's built-in IIdentityUserAppService
        
        // Table Management mappings are defined in separate profile files
        // Example: LayoutSectionAutoMapperProfile.cs
    }
}
