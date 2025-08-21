import { Injectable } from '@angular/core';
@Injectable({
  providedIn: 'root'
})
export class VietnameseFormatterService {

  /**
   * Format Vietnamese currency (VND)
   */
  formatCurrency(amount: number): string {
    if (amount == null || isNaN(amount)) return '0₫';
    
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  }

  /**
   * Format Vietnamese number with thousand separators
   */
  formatNumber(num: number): string {
    if (num == null || isNaN(num)) return '0';
    
    return new Intl.NumberFormat('vi-VN').format(num);
  }

  /**
   * Format Vietnamese date
   */
  formatDate(date: Date | string | null, includeTime = false): string {
    if (!date) return 'N/A';
    
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    if (isNaN(dateObj.getTime())) return 'N/A';

    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      timeZone: 'Asia/Ho_Chi_Minh'
    };

    if (includeTime) {
      options.hour = '2-digit';
      options.minute = '2-digit';
      options.hour12 = false;
    }

    return new Intl.DateTimeFormat('vi-VN', options).format(dateObj);
  }

  /**
   * Format Vietnamese time only
   */
  formatTime(date: Date | string | null): string {
    if (!date) return 'N/A';
    
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    if (isNaN(dateObj.getTime())) return 'N/A';

    return new Intl.DateTimeFormat('vi-VN', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Asia/Ho_Chi_Minh'
    }).format(dateObj);
  }

  /**
   * Format Vietnamese phone number
   */
  formatPhoneNumber(phone: string | null): string {
    if (!phone) return 'N/A';
    
    // Remove all non-digits
    const cleaned = phone.replace(/\D/g, '');
    
    // Vietnamese phone number patterns
    if (cleaned.startsWith('84')) {
      // International format +84
      const withoutCountryCode = cleaned.substring(2);
      if (withoutCountryCode.length === 9) {
        return `+84 ${withoutCountryCode.substring(0, 3)} ${withoutCountryCode.substring(3, 6)} ${withoutCountryCode.substring(6)}`;
      }
    } else if (cleaned.startsWith('0') && cleaned.length === 10) {
      // Domestic format 0xxx xxx xxx
      return `${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}`;
    }
    
    return phone; // Return original if can't format
  }

  /**
   * Validate Vietnamese phone number
   */
  isValidVietnamesePhone(phone: string): boolean {
    if (!phone) return false;
    
    const cleaned = phone.replace(/\D/g, '');
    
    // Vietnamese mobile patterns
    const mobilePatterns = [
      /^(84|0)(3[2-9]|5[689]|7[06-9]|8[1-689]|9[0-46-9])\d{7}$/,
      // Viettel: 032-039, 086, 096-098
      // VinaPhone: 056, 058, 059, 091-094, 0123-0125, 0127-0129
      // MobiFone: 070, 076-079, 089, 090, 093
      // And other networks...
    ];
    
    return mobilePatterns.some(pattern => pattern.test(cleaned));
  }

  /**
   * Format Employee ID with proper padding
   */
  formatEmployeeId(id: string | number): string {
    if (!id) return '';
    
    const numStr = id.toString();
    if (numStr.startsWith('NV')) {
      return numStr;
    }
    
    // Ensure 3-digit padding: NV001, NV002, etc.
    const num = parseInt(numStr, 10);
    if (!isNaN(num)) {
      return `NV${num.toString().padStart(3, '0')}`;
    }
    
    return numStr;
  }

  /**
   * Generate next Employee ID
   */
  generateNextEmployeeId(existingIds: string[]): string {
    const numbers = existingIds
      .filter(id => id && id.startsWith('NV'))
      .map(id => {
        const numPart = id.substring(2);
        return parseInt(numPart, 10);
      })
      .filter(num => !isNaN(num));
    
    const maxNumber = numbers.length > 0 ? Math.max(...numbers) : 0;
    return this.formatEmployeeId(maxNumber + 1);
  }

  /**
   * Format relative time in Vietnamese
   */
  formatRelativeTime(date: Date | string | null): string {
    if (!date) return 'N/A';
    
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    if (isNaN(dateObj.getTime())) return 'N/A';

    const now = new Date();
    const diffMs = now.getTime() - dateObj.getTime();
    const diffMinutes = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMinutes / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffMinutes < 1) return 'Vừa xong';
    if (diffMinutes < 60) return `${diffMinutes} phút trước`;
    if (diffHours < 24) return `${diffHours} giờ trước`;
    if (diffDays < 7) return `${diffDays} ngày trước`;
    
    return this.formatDate(dateObj);
  }

  /**
   * Capitalize Vietnamese text properly
   */
  capitalizeVietnamese(text: string): string {
    if (!text) return '';
    
    return text
      .toLowerCase()
      .split(' ')
      .map(word => {
        if (word.length === 0) return word;
        return word.charAt(0).toUpperCase() + word.slice(1);
      })
      .join(' ');
  }
}