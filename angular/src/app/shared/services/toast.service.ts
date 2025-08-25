import { Injectable, inject } from '@angular/core';
import { MessageService } from 'primeng/api';

/**
 * Global Toast Service for Smart Restaurant
 * Centralized service for showing toast messages throughout the application
 */
@Injectable({
  providedIn: 'root',
})
export class ToastService {
  private messageService = inject(MessageService);

  /**
   * Show success message
   */
  showSuccess(summary: string, detail?: string): void {
    this.messageService.add({
      severity: 'success',
      summary,
      detail,
      life: 3000,
    });
  }

  /**
   * Show error message
   */
  showError(summary: string, detail?: string): void {
    this.messageService.add({
      severity: 'error',
      summary,
      detail,
      life: 5000,
    });
  }

  /**
   * Show warning message
   */
  showWarning(summary: string, detail?: string): void {
    this.messageService.add({
      severity: 'warn',
      summary,
      detail,
      life: 4000,
    });
  }

  /**
   * Show info message
   */
  showInfo(summary: string, detail?: string): void {
    this.messageService.add({
      severity: 'info',
      summary,
      detail,
      life: 3000,
    });
  }

  /**
   * Clear all messages
   */
  clear(): void {
    this.messageService.clear();
  }
}
