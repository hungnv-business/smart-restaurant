using Volo.Abp;

namespace SmartRestaurant.Exceptions;

/// <summary>
/// Exception được ném khi tên đơn vị đã tồn tại trong hệ thống
/// </summary>
public class UnitNameAlreadyExistsException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tên đơn vị bị trùng
    /// </summary>
    /// <param name="unitName">Tên đơn vị bị trùng</param>
    public UnitNameAlreadyExistsException(string unitName) 
        : base(SmartRestaurantDomainErrorCodes.Units.NameAlreadyExists)
    {
        WithData("UnitName", unitName);
    }
}