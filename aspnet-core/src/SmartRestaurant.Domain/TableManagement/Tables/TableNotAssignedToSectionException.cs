using System;
using Volo.Abp;

namespace SmartRestaurant.TableManagement.Tables;

/// <summary>
/// Exception được ném khi bàn chưa được gán vào khu vực nào
/// </summary>
public class TableNotAssignedToSectionException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin bàn
    /// </summary>
    /// <param name="tableNumber">Tên bàn</param>
    public TableNotAssignedToSectionException(string tableNumber) 
        : base(SmartRestaurantDomainErrorCodes.Tables.NotAssignedToSection)
    {
        WithData("TableNumber", tableNumber);
    }
}