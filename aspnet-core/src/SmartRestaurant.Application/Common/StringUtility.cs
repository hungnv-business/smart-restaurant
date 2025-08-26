using System;
using System.Text.RegularExpressions;

namespace SmartRestaurant.Common;

/// <summary>
/// Tiện ích xử lý chuỗi dùng chung cho toàn hệ thống
/// </summary>
public static class StringUtility
{
    /// <summary>
    /// Chuẩn hóa chuỗi: loại bỏ khoảng trắng thừa ở đầu/cuối và giữa các từ
    /// Chuyển null thành empty string
    /// </summary>
    /// <param name="input">Chuỗi đầu vào</param>
    /// <returns>Chuỗi đã được chuẩn hóa</returns>
    public static string NormalizeString(string? input)
    {
        if (string.IsNullOrEmpty(input))
        {
            return string.Empty;
        }

        // Loại bỏ khoảng trắng thừa ở đầu/cuối và giữa các từ
        return Regex.Replace(input.Trim(), @"\s+", " ");
    }

    /// <summary>
    /// Chuẩn hóa chuỗi và giữ nguyên null nếu input là null
    /// </summary>
    /// <param name="input">Chuỗi đầu vào</param>
    /// <returns>Chuỗi đã được chuẩn hóa hoặc null</returns>
    public static string? NormalizeStringNullable(string? input)
    {
        if (input == null)
        {
            return null;
        }

        var normalized = NormalizeString(input);
        return string.IsNullOrEmpty(normalized) ? null : normalized;
    }

    /// <summary>
    /// Kiểm tra hai chuỗi có trùng nhau sau khi chuẩn hóa (không phân biệt hoa/thường)
    /// </summary>
    /// <param name="str1">Chuỗi thứ nhất</param>
    /// <param name="str2">Chuỗi thứ hai</param>
    /// <returns>True nếu hai chuỗi trùng nhau sau khi chuẩn hóa</returns>
    public static bool AreNormalizedEqual(string? str1, string? str2)
    {
        var normalized1 = NormalizeString(str1);
        var normalized2 = NormalizeString(str2);
        
        return string.Equals(normalized1, normalized2, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng sau khi chuẩn hóa
    /// </summary>
    /// <param name="input">Chuỗi đầu vào</param>
    /// <returns>True nếu chuỗi rỗng hoặc chỉ chứa khoảng trắng</returns>
    public static bool IsNullOrWhiteSpaceNormalized(string? input)
    {
        var normalized = NormalizeString(input);
        return string.IsNullOrEmpty(normalized);
    }
}