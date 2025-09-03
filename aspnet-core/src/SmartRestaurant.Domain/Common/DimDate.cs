using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Volo.Abp.Domain.Entities;

namespace SmartRestaurant.Common;

/// <summary>
/// Dimension Date entity - Bảng chiều ngày cho báo cáo và phân tích
/// Chứa thông tin chi tiết về ngày tháng theo nhiều định dạng khác nhau
/// </summary>
public class DimDate : Entity<int>
{
    /// <summary>
    /// Ngày thực tế (DateTime)
    /// </summary>
    [Required]
    [Column("date")]
    public DateTime Date { get; set; }

    /// <summary>
    /// Định dạng ngày Việt Nam (dd/MM/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_vn_format")]
    public string DateVnFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày Việt Nam rút gọn (d/M/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_vn_short_format")]
    public string DateVnShortFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày Anh (dd/MM/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_uk_format")]
    public string DateUkFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày Anh rút gọn (d/M/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_uk_short_format")]
    public string DateUkShortFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày Mỹ (MM/dd/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_us_format")]
    public string DateUsFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày Mỹ rút gọn (M/d/yyyy)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_us_short_format")]
    public string DateUsShortFormat { get; set; } = string.Empty;

    /// <summary>
    /// Định dạng ngày ISO (yyyy-MM-dd)
    /// </summary>
    [Required]
    [MaxLength(10)]
    [Column("date_iso_format")]
    public string DateIsoFormat { get; set; } = string.Empty;

    /// <summary>
    /// Số năm (ví dụ: 2024)
    /// </summary>
    [Required]
    [Column("num_year")]
    public int NumYear { get; set; }

    /// <summary>
    /// Số quý trong năm (1-4)
    /// </summary>
    [Required]
    [Column("num_quarter_in_year")]
    public int NumQuarterInYear { get; set; }

    /// <summary>
    /// Số tháng trong năm (1-12)
    /// </summary>
    [Required]
    [Column("num_month_in_year")]
    public int NumMonthInYear { get; set; }

    /// <summary>
    /// Số tháng trong quý (1-3)
    /// </summary>
    [Required]
    [Column("num_month_in_quarter")]
    public int NumMonthInQuarter { get; set; }

    /// <summary>
    /// Số tuần trong năm (1-53)
    /// </summary>
    [Required]
    [Column("num_week_in_year")]
    public int NumWeekInYear { get; set; }

    /// <summary>
    /// Số tuần trong quý (1-14)
    /// </summary>
    [Required]
    [Column("num_week_in_quarter")]
    public int NumWeekInQuarter { get; set; }

    /// <summary>
    /// Số tuần trong tháng (1-6)
    /// </summary>
    [Required]
    [Column("num_week_in_month")]
    public int NumWeekInMonth { get; set; }

    /// <summary>
    /// Số ngày trong năm (1-366)
    /// </summary>
    [Required]
    [Column("num_day_in_year")]
    public int NumDayInYear { get; set; }

    /// <summary>
    /// Số ngày trong quý (1-92)
    /// </summary>
    [Required]
    [Column("num_day_in_quarter")]
    public int NumDayInQuarter { get; set; }

    /// <summary>
    /// Số ngày trong tháng (1-31)
    /// </summary>
    [Required]
    [Column("num_day_in_month")]
    public int NumDayInMonth { get; set; }

    /// <summary>
    /// Số ngày trong tuần (1-7, Chủ nhật = 1)
    /// </summary>
    [Required]
    [Column("num_day_in_week")]
    public int NumDayInWeek { get; set; }

    /// <summary>
    /// Có phải là ngày lễ Mỹ hay không
    /// </summary>
    [Required]
    [Column("is_holiday_us")]
    public bool IsHolidayUs { get; set; }

    /// <summary>
    /// Tên tháng tiếng Anh đầy đủ (January, February...)
    /// </summary>
    [Required]
    [MaxLength(9)]
    [Column("name_month_en")]
    public string NameMonthEn { get; set; } = string.Empty;

    /// <summary>
    /// Tên tháng tiếng Anh rút gọn (Jan, Feb...)
    /// </summary>
    [Required]
    [MaxLength(3)]
    [Column("name_month_abbreviated_en")]
    public string NameMonthAbbreviatedEn { get; set; } = string.Empty;

    /// <summary>
    /// Tên ngày tiếng Anh đầy đủ (Monday, Tuesday...)
    /// </summary>
    [Required]
    [MaxLength(9)]
    [Column("name_day_en")]
    public string NameDayEn { get; set; } = string.Empty;

    /// <summary>
    /// Tên ngày tiếng Anh rút gọn (Mon, Tue...)
    /// </summary>
    [Required]
    [MaxLength(3)]
    [Column("name_day_abbreviated_en")]
    public string NameDayAbbreviatedEn { get; set; } = string.Empty;

    /// <summary>
    /// Lấy định dạng ngày mặc định (Việt Nam)
    /// </summary>
    /// <returns>Chuỗi ngày định dạng Việt Nam</returns>
    public string GetDateFormat()
    {
        return DateVnFormat;
    }
}