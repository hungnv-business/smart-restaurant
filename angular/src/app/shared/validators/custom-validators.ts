import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * Custom validators for SmartRestaurant application
 */
export class CustomValidators {
  /**
   * URL validator - allows empty, validates http/https when present
   */
  static url(): ValidatorFn {
    const urlRegex = /^https?:\/\/[^\s]+$/i;
    return (control: AbstractControl): ValidationErrors | null => {
      const value = (control.value ?? '').toString().trim();
      if (!value) return null;
      return urlRegex.test(value) ? null : { url: true };
    };
  }

  /**
   * Vietnamese phone number validator
   * Format: 0xxx-xxx-xxx (10-11 digits starting with 0)
   */
  static vietnamesePhone(): ValidatorFn {
    const phoneRegex = /^(0[3-9]\d{8,9})$/;
    return (control: AbstractControl): ValidationErrors | null => {
      const value = (control.value ?? '').toString().trim();
      if (!value) return null;
      return phoneRegex.test(value) ? null : { vietnamesePhone: true };
    };
  }

  /**
   * Display order validator with configurable min/max
   */
  static displayOrder(min: number = 1, max: number = 999): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;
      if (value === null || value === undefined || value === '') {
        return null;
      }

      const numValue = Number(value);
      if (isNaN(numValue)) {
        return { displayOrder: { invalidNumber: true } };
      }

      if (numValue < min) {
        return { displayOrder: { min: min, actual: numValue } };
      }

      if (numValue > max) {
        return { displayOrder: { max: max, actual: numValue } };
      }

      return null;
    };
  }

  /**
   * Vietnamese text validator - allows Vietnamese characters and spaces
   */
  static vietnameseText(): ValidatorFn {
    const vietnameseRegex = /^[a-zA-ZÀ-ỹ\s]+$/;
    return (control: AbstractControl): ValidationErrors | null => {
      const value = (control.value ?? '').toString().trim();
      if (!value) return null;
      return vietnameseRegex.test(value) ? null : { vietnameseText: true };
    };
  }

  /**
   * Strong password validator
   * Requirements: At least 8 characters, uppercase, lowercase, number, special character
   */
  static strongPassword(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;
      if (!value) return null;

      const hasUpperCase = /[A-Z]/.test(value);
      const hasLowerCase = /[a-z]/.test(value);
      const hasNumeric = /[0-9]/.test(value);
      const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(value);
      const isValidLength = value.length >= 8;

      const passwordValid =
        hasUpperCase && hasLowerCase && hasNumeric && hasSpecialChar && isValidLength;

      if (!passwordValid) {
        return {
          strongPassword: {
            hasUpperCase,
            hasLowerCase,
            hasNumeric,
            hasSpecialChar,
            isValidLength,
          },
        };
      }

      return null;
    };
  }

  /**
   * Positive integer validator
   */
  static positiveInteger(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;
      if (value === null || value === undefined || value === '') {
        return null;
      }

      const numValue = Number(value);
      if (isNaN(numValue) || numValue <= 0 || !Number.isInteger(numValue)) {
        return { positiveInteger: true };
      }

      return null;
    };
  }

  /**
   * Vietnamese national ID validator (CCCD - 12 digits)
   */
  static vietnameseNationalId(): ValidatorFn {
    const cccdRegex = /^\d{12}$/;
    return (control: AbstractControl): ValidationErrors | null => {
      const value = (control.value ?? '').toString().trim();
      if (!value) return null;
      return cccdRegex.test(value) ? null : { vietnameseNationalId: true };
    };
  }

  /**
   * Price validator - positive number with up to 2 decimal places
   */
  static price(): ValidatorFn {
    const priceRegex = /^\d+(\.\d{1,2})?$/;
    return (control: AbstractControl): ValidationErrors | null => {
      const value = (control.value ?? '').toString().trim();
      if (!value) return null;

      const numValue = Number(value);
      if (isNaN(numValue) || numValue < 0) {
        return { price: { invalidNumber: true } };
      }

      if (!priceRegex.test(value)) {
        return { price: { invalidFormat: true } };
      }

      return null;
    };
  }
}
