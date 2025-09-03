using System;
using Volo.Abp;

namespace SmartRestaurant.Common;

/// <summary>
/// Exception được ném khi không thể xóa sau thời gian quy định
/// </summary>
public class CannotDeleteAfterTimeException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin thời gian
    /// </summary>
    /// <param name="creationTime">Thời gian tạo</param>
    /// <param name="timeLimit">Giới hạn thời gian (giờ)</param>
    public CannotDeleteAfterTimeException(DateTime creationTime, int timeLimit) 
        : base(SmartRestaurantDomainErrorCodes.PurchaseInvoices.CannotDeleteAfterSixHours)
    {
        WithData("CreationTime", creationTime.ToString("dd/MM/yyyy HH:mm"));
        WithData("TimeLimit", timeLimit);
        WithData("Deadline", creationTime.AddHours(timeLimit).ToString("dd/MM/yyyy HH:mm"));
    }
}