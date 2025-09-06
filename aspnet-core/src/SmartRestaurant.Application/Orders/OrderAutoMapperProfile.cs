using AutoMapper;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Orders;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItems.Dto;

namespace SmartRestaurant.Application.Orders;

/// <summary>
/// AutoMapper profile cho Order domain
/// Mapping giữa Domain entities và DTOs
/// </summary>
public class OrderAutoMapperProfile : Profile
{
    public OrderAutoMapperProfile()
    {
        // Order mappings
        CreateMap<Order, OrderDto>()
            .ForMember(dest => dest.TableName, opt => opt.Ignore()) // Set manually in service
            .ForMember(dest => dest.StatusDisplay, opt => opt.Ignore()) // Set manually in service
            .ForMember(dest => dest.ItemCount, opt => opt.Ignore()) // Computed property
            .ForMember(dest => dest.ElapsedMinutes, opt => opt.Ignore()); // Computed property

        // OrderItem mappings
        CreateMap<OrderItem, OrderItemDto>()
            .ForMember(dest => dest.StatusDisplay, opt => opt.Ignore()) // Set manually in service
            .ForMember(dest => dest.TotalPrice, opt => opt.Ignore()) // Computed property
            .ForMember(dest => dest.PreparationDurationMinutes, opt => opt.Ignore()); // Computed property

        // Create mappings (DTOs to entities are handled in domain service)
        CreateMap<CreateOrderDto, Order>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.OrderNumber, opt => opt.Ignore()) // Generated in service
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => OrderStatus.Active))
            .ForMember(dest => dest.TotalAmount, opt => opt.MapFrom(src => 0))
            .ForMember(dest => dest.OrderItems, opt => opt.Ignore()) // Handled separately
            .ForMember(dest => dest.Table, opt => opt.Ignore())
            .ForMember(dest => dest.PaidTime, opt => opt.Ignore());

        CreateMap<CreateOrderItemDto, OrderItem>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.OrderId, opt => opt.Ignore()) // Set in service
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => OrderItemStatus.Pending))
            .ForMember(dest => dest.Order, opt => opt.Ignore())
            .ForMember(dest => dest.MenuItem, opt => opt.Ignore())
            .ForMember(dest => dest.PreparationStartTime, opt => opt.Ignore())
            .ForMember(dest => dest.PreparationCompleteTime, opt => opt.Ignore());

        // MenuItem mappings
        CreateMap<MenuItem, MenuItemDto>()
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => 
                src.Category != null ? src.Category.Name : null));
    }
}