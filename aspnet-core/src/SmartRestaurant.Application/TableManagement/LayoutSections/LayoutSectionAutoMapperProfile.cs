using System;
using AutoMapper;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.TableManagement.LayoutSections.Dto;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    public class LayoutSectionAutoMapperProfile : Profile
    {
        public LayoutSectionAutoMapperProfile()
        {
            CreateMap<LayoutSection, LayoutSectionDto>();
            CreateMap<CreateLayoutSectionDto, LayoutSection>();
            CreateMap<UpdateLayoutSectionDto, LayoutSection>();
        }
    }
}