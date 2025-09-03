using System;
using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Exception được ném khi đơn vị cơ sở có tỷ lệ quy đổi khác 1
/// </summary>
public class InvalidBaseUnitConversionException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin tỷ lệ quy đổi không hợp lệ
    /// </summary>
    /// <param name="conversionRatio">Tỷ lệ quy đổi không hợp lệ</param>
    public InvalidBaseUnitConversionException(int conversionRatio) 
        : base(SmartRestaurantDomainErrorCodes.Ingredients.InvalidBaseUnitConversion)
    {
        WithData("ConversionRatio", conversionRatio);
    }
}