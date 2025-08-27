import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'vndCurrency',
  standalone: true
})
export class VndCurrencyPipe implements PipeTransform {
  
  transform(value: number | null | undefined, showSymbol: boolean = true): string {
    // Handle null/undefined/0 cases
    if (value === null || value === undefined) {
      return 'Chưa có giá';
    }
    
    if (value === 0) {
      return showSymbol ? '0 ₫' : '0';
    }

    // Format number with Vietnamese locale
    const formatter = new Intl.NumberFormat('vi-VN', {
      style: 'decimal',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    });
    
    const formattedNumber = formatter.format(value);
    
    return showSymbol ? `${formattedNumber} ₫` : formattedNumber;
  }
}