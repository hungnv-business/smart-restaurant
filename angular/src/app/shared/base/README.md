# ComponentBase - Base Class cho tất cả Components

## Mục đích
ComponentBase cung cấp các functionality chung mà tất cả components trong Smart Restaurant có thể tái sử dụng.

## Các tính năng có sẵn

### 🔧 Form Utilities
- `isFieldInvalid(form, fieldName)` - Kiểm tra field có lỗi không
- `getFormControl(form, fieldName)` - Lấy FormControl với type safety
- `markFormGroupTouched(form)` - Mark tất cả fields touched để hiện validation
- `validateForm(form, errorMessage)` - Validate form và hiện error message
- `resetForm(form)` - Reset form và clear errors
- `clearFormErrors(form)` - Clear tất cả validation errors

### 📢 Message Utilities
- `showSuccess(summary, detail?)` - Hiện thông báo thành công
- `showError(summary, detail?)` - Hiện thông báo lỗi
- `showWarning(summary, detail?)` - Hiện thông báo cảnh báo
- `showInfo(summary, detail?)` - Hiện thông báo thông tin

### 🌐 API Error Handling
- `handleApiError(error, defaultMessage?)` - Xử lý lỗi API với message tiếng Việt

### 🛡️ Memory Management
- `destroyed$` - Observable để unsubscribe khi component destroy
- Auto cleanup OnDestroy

### 🇻🇳 Vietnamese Helpers
- `formatCurrency(amount)` - Format tiền VND
- `formatDate(date, format?)` - Format ngày theo kiểu Việt Nam
- `getFieldErrorMessage(form, fieldName, displayName)` - Error message tiếng Việt cho field

### 🔧 Utility Functions
- `safeGet(obj, path, defaultValue)` - Safe navigation cho objects

## Cách sử dụng

### 1. Import ComponentBase
```typescript
import { ComponentBase } from '../../../shared/components';
```

### 2. Extend từ ComponentBase
```typescript
export class MyComponent extends ComponentBase implements OnInit {
  myForm: FormGroup;

  constructor(private fb: FormBuilder) {
    super(); // Quan trọng: gọi super()
    this.myForm = this.createForm();
  }

  // Component code...
}
```

### 3. Sử dụng các utilities

#### Form Validation
```typescript
onSubmit() {
  // Validate form với message tùy chỉnh
  if (!this.validateForm(this.myForm, 'Vui lòng điền đầy đủ thông tin')) {
    return;
  }

  // Process form...
}

// Lấy FormControl với type safety
get emailControl(): FormControl {
  return this.getFormControl(this.myForm, 'email');
}
```

#### Message Handling
```typescript
saveData() {
  this.dataService.save(data).subscribe({
    next: () => {
      this.showSuccess('Lưu thành công', 'Dữ liệu đã được lưu vào hệ thống');
    },
    error: (error) => {
      this.handleApiError(error, 'Không thể lưu dữ liệu');
    }
  });
}
```

#### Memory Management
```typescript
ngOnInit() {
  // Sử dụng destroyed$ để auto unsubscribe
  this.dataService.getData()
    .pipe(takeUntil(this.destroyed$))
    .subscribe(data => {
      // Handle data
    });
}
```

#### Vietnamese Formatting
```typescript
displayPrice(amount: number): string {
  return this.formatCurrency(amount); // "50.000 ₫"
}

displayDate(date: Date): string {
  return this.formatDate(date, 'long'); // "Thứ Hai, 19 tháng 8, 2025"
}
```

### 4. Template Usage

#### Với ValidationErrorComponent
```html
<div class="flex flex-col gap-2">
  <label for="email">Email *</label>
  <input 
    pInputText 
    id="email" 
    formControlName="email"
    [class.p-invalid]="emailControl.invalid && (emailControl.dirty || emailControl.touched)" />
  
  <app-validation-error 
    [control]="emailControl" 
    fieldName="Email">
  </app-validation-error>
</div>
```

## Lợi ích

✅ **DRY Principle** - Không lặp lại code\n✅ **Consistency** - Consistent error handling và messaging\n✅ **Vietnamese Support** - Built-in tiếng Việt\n✅ **Type Safety** - TypeScript support đầy đủ\n✅ **Memory Safe** - Auto cleanup subscriptions\n✅ **Maintainable** - Centralized common functionality

## Best Practices

1. **Luôn gọi super()** trong constructor
2. **Sử dụng destroyed$** cho tất cả subscriptions
3. **Sử dụng validateForm()** thay vì validate manually
4. **Sử dụng handleApiError()** cho tất cả API errors
5. **Sử dụng show* methods** thay vì MessageService trực tiếp

## Ví dụ Component hoàn chỉnh

```typescript
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { takeUntil } from 'rxjs/operators';
import { ComponentBase } from '../../../shared/components';

@Component({
  selector: 'app-user-form',
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
      <div class="flex flex-col gap-2">
        <label for="name">Tên *</label>
        <input pInputText formControlName="name" 
               [class.p-invalid]="nameControl.invalid && (nameControl.dirty || nameControl.touched)" />
        <app-validation-error [control]="nameControl" fieldName="Tên"></app-validation-error>
      </div>
      
      <p-button type="submit" [loading]="isLoading">Lưu</p-button>
    </form>
    <p-toast></p-toast>
  `
})
export class UserFormComponent extends ComponentBase implements OnInit {
  userForm: FormGroup;
  isLoading = false;

  constructor(
    private fb: FormBuilder,
    private userService: UserService
  ) {
    super();
    this.userForm = this.fb.group({
      name: ['', [Validators.required]],
      email: ['', [Validators.required, Validators.email]]
    });
  }

  get nameControl() {
    return this.getFormControl(this.userForm, 'name');
  }

  onSubmit() {
    if (!this.validateForm(this.userForm)) return;

    this.isLoading = true;
    this.userService.create(this.userForm.value)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: () => {
          this.isLoading = false;
          this.showSuccess('Tạo người dùng thành công');
          this.resetForm(this.userForm);
        },
        error: (error) => {
          this.isLoading = false;
          this.handleApiError(error);
        }
      });
  }
}
```