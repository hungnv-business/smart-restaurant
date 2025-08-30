using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Volo.Abp.Domain.Entities;

namespace SmartRestaurant.Entities.Common;

/// <summary>
/// Dimension Date entity - Bảng chiều ngày cho báo cáo và phân tích
/// Chứa thông tin chi tiết về ngày tháng theo nhiều định dạng khác nhau
/// </summary>
public class DimDate : Entity<int>
{
    [Required]
    [Column("date")]
    public DateTime Date { get; set; }

    [Required]
    [MaxLength(10)]
    [Column("date_vn_format")]
    public string DateVnFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_vn_short_format")]
    public string DateVnShortFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_uk_format")]
    public string DateUkFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_uk_short_format")]
    public string DateUkShortFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_us_format")]
    public string DateUsFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_us_short_format")]
    public string DateUsShortFormat { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    [Column("date_iso_format")]
    public string DateIsoFormat { get; set; } = string.Empty;

    [Required]
    [Column("num_year")]
    public int NumYear { get; set; }

    [Required]
    [Column("num_quarter_in_year")]
    public int NumQuarterInYear { get; set; }

    [Required]
    [Column("num_month_in_year")]
    public int NumMonthInYear { get; set; }

    [Required]
    [Column("num_month_in_quarter")]
    public int NumMonthInQuarter { get; set; }

    [Required]
    [Column("num_week_in_year")]
    public int NumWeekInYear { get; set; }

    [Required]
    [Column("num_week_in_quarter")]
    public int NumWeekInQuarter { get; set; }

    [Required]
    [Column("num_week_in_month")]
    public int NumWeekInMonth { get; set; }

    [Required]
    [Column("num_day_in_year")]
    public int NumDayInYear { get; set; }

    [Required]
    [Column("num_day_in_quarter")]
    public int NumDayInQuarter { get; set; }

    [Required]
    [Column("num_day_in_month")]
    public int NumDayInMonth { get; set; }

    [Required]
    [Column("num_day_in_week")]
    public int NumDayInWeek { get; set; }

    [Required]
    [Column("is_holiday_us")]
    public bool IsHolidayUs { get; set; }

    [Required]
    [MaxLength(9)]
    [Column("name_month_en")]
    public string NameMonthEn { get; set; } = string.Empty;

    [Required]
    [MaxLength(3)]
    [Column("name_month_abbreviated_en")]
    public string NameMonthAbbreviatedEn { get; set; } = string.Empty;

    [Required]
    [MaxLength(9)]
    [Column("name_day_en")]
    public string NameDayEn { get; set; } = string.Empty;

    [Required]
    [MaxLength(3)]
    [Column("name_day_abbreviated_en")]
    public string NameDayAbbreviatedEn { get; set; } = string.Empty;

    public string GetDateFormat()
    {
        return DateVnFormat;
    }
}