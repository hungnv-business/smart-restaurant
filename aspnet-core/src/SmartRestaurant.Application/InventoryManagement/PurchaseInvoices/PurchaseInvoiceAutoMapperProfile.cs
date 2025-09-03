using AutoMapper;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using System;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    public class PurchaseInvoiceAutoMapperProfile : Profile
    {
        public PurchaseInvoiceAutoMapperProfile()
        {
            // Purchase Invoice mappings
            CreateMap<PurchaseInvoice, PurchaseInvoiceDto>()
                .ForMember(dest => dest.CanDelete, opt => opt.MapFrom(src => src.CanDelete()))
                .ForMember(dest => dest.CanEdit, opt => opt.MapFrom(src => src.CanEdit()))
                .ForMember(dest => dest.InvoiceDate, opt => opt.MapFrom(src => src.InvoiceDate.GetDateFormat()))
                .ForMember(dest => dest.InvoiceDateId, opt => opt.MapFrom(src => src.InvoiceDateId));

            CreateMap<PurchaseInvoiceItem, PurchaseInvoiceItemDto>()
                .ForMember(dest => dest.CategoryId, opt => opt.MapFrom(src => src.Ingredient.CategoryId));

            CreateMap<CreateUpdatePurchaseInvoiceDto, PurchaseInvoice>()
                .ForMember(dest => dest.Items, opt => opt.Ignore()) // Handle manually in AppService
                .ForMember(dest => dest.TotalAmount, opt => opt.Ignore()); // Calculated by domain method

            // Ingredient basic info mapping
            CreateMap<Ingredient, IngredientBasicInfoDto>();
        }
    }
}