using AutoMapper;
using SmartRestaurant.Kitchen.Dtos;

namespace SmartRestaurant.Kitchen
{
    /// <summary>
    /// AutoMapper profile for Kitchen domain mapping
    /// DTOs are now directly used from Application.Contracts, no mapping needed
    /// </summary>
    public class KitchenAutoMapperProfile : Profile
    {
        public KitchenAutoMapperProfile()
        {
            // No mappings needed - DTOs are directly used from Application.Contracts
        }
    }
}