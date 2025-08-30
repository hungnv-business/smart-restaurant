/**
 * DateTime Helper for handling DimDate conversions and Vietnamese date formatting
 */
export class DateTimeHelper {
  
  /**
   * Chuyển đổi Date thành DimDate ID (format YYYYMMDD)
   */
  static getDateId(date: Date): number {
    if (!date || isNaN(date.getTime())) return 0;
    
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return parseInt(`${year}${month}${day}`);
  }

  /**
   * Chuyển đổi DimDate ID thành Date object
   */
  static getDateFromId(dateId: number): Date | null {
    if (!dateId || dateId < 19000101 || dateId > 99991231) return null;
    
    const dateStr = dateId.toString();
    if (dateStr.length !== 8) return null;
    
    const year = parseInt(dateStr.substring(0, 4));
    const month = parseInt(dateStr.substring(4, 6)) - 1; // Month is 0-based
    const day = parseInt(dateStr.substring(6, 8));
    
    const date = new Date(year, month, day);
    
    // Validate the date
    if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) {
      return null;
    }
    
    return date;
  }

  /**
   * Format DimDate ID thành string dd/MM/yyyy
   */
  static formatDateId(dateId: number): string {
    const date = this.getDateFromId(dateId);
    return date ? this.formatDate(date) : 'N/A';
  }

  /**
   * Format Vietnamese date dd/MM/yyyy
   */
  static formatDate(date: Date | string | null, includeTime = false): string {
    if (!date) return 'N/A';

    const dateObj = typeof date === 'string' ? new Date(date) : date;
    if (isNaN(dateObj.getTime())) return 'N/A';

    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      timeZone: 'Asia/Ho_Chi_Minh',
    };

    if (includeTime) {
      options.hour = '2-digit';
      options.minute = '2-digit';
      options.hour12 = false;
    }

    return new Intl.DateTimeFormat('vi-VN', options).format(dateObj);
  }

  /**
   * Tạo khoảng ngày từ fromDateId và toDateId
   */
  static getDateRangeFromIds(fromDateId?: number, toDateId?: number): Date[] | null {
    if (!fromDateId && !toDateId) return null;
    
    const dates: Date[] = [];
    
    if (fromDateId) {
      const fromDate = this.getDateFromId(fromDateId);
      if (fromDate) dates.push(fromDate);
    }
    
    if (toDateId) {
      const toDate = this.getDateFromId(toDateId);
      if (toDate) dates.push(toDate);
    }
    
    return dates.length > 0 ? dates : null;
  }

  /**
   * Lấy DateId từ Date array (dùng cho PrimeNG range picker)
   */
  static getDateIdsFromRange(dateRange: Date[] | null): { fromDateId?: number; toDateId?: number } {
    if (!dateRange || dateRange.length === 0) {
      return {};
    }
    
    return {
      fromDateId: dateRange[0] ? this.getDateId(dateRange[0]) : undefined,
      toDateId: dateRange[1] ? this.getDateId(dateRange[1]) : undefined,
    };
  }

  /**
   * Check if date is today
   */
  static isToday(date: Date): boolean {
    if (!date || isNaN(date.getTime())) return false;
    
    const today = new Date();
    return date.getDate() === today.getDate() &&
           date.getMonth() === today.getMonth() &&
           date.getFullYear() === today.getFullYear();
  }

  /**
   * Get start of day
   */
  static getStartOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  /**
   * Get end of day
   */
  static getEndOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(23, 59, 59, 999);
    return result;
  }
}