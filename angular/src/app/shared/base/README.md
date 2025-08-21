# ComponentBase - Base Class for Angular Components

## Mô tả
`ComponentBase` là một abstract class cung cấp các utility methods và functionality chung cho tất cả components trong SmartRestaurant application.

## Tính năng chính

### 🔧 **Dependency Injection**
- `ToastService` - Hiển thị thông báo toast
- `PermissionService` - Kiểm tra quyền hạn người dùng

### 📋 **Pagination Support**
- `pageSize: 10` - Kích thước trang mặc định
- `rowsPerPageOptions: [10, 20, 30, 50, 100]` - Các tùy chọn số dòng

### 🎭 **Role Labels**
Hỗ trợ nhãn vai trò tiếng Việt:
- Admin → 'Quản trị viên'
- Owner → 'Chủ nhà hàng'  
- Waiter → 'Nhân viên phục vụ'
- Kitchen → 'Nhân viên bếp'
- Cashier → 'Thu ngân'
- Customer → 'Khách hàng'

## API Methods

### 📝 **Form Utilities**
```typescript
// Kiểm tra field có lỗi không
protected isFieldInvalid(form: FormGroup, fieldName: string): boolean

// Lấy FormControl với type safety
protected getFormControl(form: FormGroup, fieldName: string): FormControl

// Đánh dấu tất cả fields touched để hiển thị validation
protected markFormGroupTouched(form: FormGroup): void

// Reset form và xóa validation errors
protected resetForm(form: FormGroup): void

// Xóa validation errors
protected clearFormErrors(form: FormGroup): void

// Validate form và hiển thị lỗi nếu invalid
protected validateForm(form: FormGroup, errorMessage?: string): boolean

// Lấy error message cho field cụ thể
protected getFieldErrorMessage(form: FormGroup, fieldName: string, displayName: string): string
```

### 🔔 **Toast Messages**
```typescript
protected showSuccess(summary: string, detail?: string): void
protected showError(summary: string, detail?: string): void  
protected showWarning(summary: string, detail?: string): void
protected showInfo(summary: string, detail?: string): void
```

### 🚨 **Error Handling**
```typescript
// Xử lý API errors với thông báo tiếng Việt user-friendly
protected handleApiError(error: any, defaultMessage?: string): void
```

**Supported HTTP Status Codes:**
- `400` → "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại."
- `401` → "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
- `403` → "Bạn không có quyền thực hiện thao tác này."
- `404` → "Không tìm thấy dữ liệu yêu cầu."
- `500` → "Lỗi máy chủ. Vui lòng liên hệ quản trị viên."
- `0` → "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng."

### 🔐 **Permission Checking**
```typescript
// Kiểm tra quyền cụ thể
protected hasPermission(permission: string): boolean

// Kiểm tra có ít nhất một quyền trong danh sách
protected hasAnyPermission(permissions: string[]): boolean

// Kiểm tra có tất cả quyền trong danh sách
protected hasAllPermissions(permissions: string[]): boolean
```

### 🏷️ **Label Utilities**
```typescript
// Lấy nhãn vai trò tiếng Việt
protected getRoleLabel(role: string): string

// Tạo tên đầy đủ từ name và surname
protected getFullName(name?: string, surname?: string): string
```

### 🔄 **Lifecycle Management**
```typescript
// Observable để handle component destruction và unsubscribe
protected get destroyed$(): Observable<void>

// Tự động cleanup khi component destroy
ngOnDestroy(): void
```

## Cách sử dụng

### 1. **Kế thừa ComponentBase**
```typescript
import { ComponentBase } from '../../shared/base/component-base';

@Component({...})
export class MyComponent extends ComponentBase implements OnInit {
  constructor() {
    super();
  }
}
```

### 2. **Sử dụng Form Utilities**
```typescript
onSubmit() {
  if (!this.validateForm(this.myForm, 'Vui lòng điền đầy đủ thông tin')) {
    return;
  }
  // Process form...
}

get emailControl() {
  return this.getFormControl(this.myForm, 'email');
}
```

### 3. **Sử dụng Permission Checking**
```typescript
ngOnInit() {
  if (this.hasPermission('Users.Create')) {
    // Show create button
  }
  
  if (this.hasAnyPermission(['Users.Update', 'Users.Delete'])) {
    // Show action buttons
  }
}
```

### 4. **Error Handling**
```typescript
try {
  await this.apiCall();
  this.showSuccess('Thành công', 'Dữ liệu đã được lưu');
} catch (error) {
  this.handleApiError(error, 'Không thể lưu dữ liệu');
}
```

### 5. **Memory Management**
```typescript
ngOnInit() {
  // ✅ ABP Services - KHÔNG CẦN destroyed$ (tự động complete)
  this.identityUserService.getList(input).subscribe({
    next: (result) => {
      this.users.set(result.items || []);
    },
    error: (error) => {
      this.handleApiError(error);
    }
  });

  // ❌ Long-running Observables - CẦN destroyed$
  this.signalRService.connectionState$
    .pipe(takeUntil(this.destroyed$))
    .subscribe(state => {
      // Handle real-time updates
    });
}
```

## Template Usage

### Với ValidationErrorComponent
```html
<div class="flex flex-col gap-2">
  <label for="email" class="required">Email</label>
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

## Complete Component Example

```typescript
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { takeUntil } from 'rxjs/operators';
import { ComponentBase } from '../../../shared/base/component-base';

@Component({
  selector: 'app-user-form',
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
      <div class="flex flex-col gap-2">
        <label for="name" class="required">Tên</label>
        <input pInputText formControlName="name" 
               [class.p-invalid]="nameControl.invalid && (nameControl.dirty || nameControl.touched)" />
        <app-validation-error [control]="nameControl" fieldName="Tên"></app-validation-error>
      </div>
      
      <p-button type="submit" [loading]="isLoading">Lưu</p-button>
    </form>
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

## Memory Management Rules

### ✅ **KHÔNG CẦN `destroyed$` (auto-complete):**
```typescript
// ABP Proxy Services
this.identityUserService.getList(input).subscribe(...)
this.permissionsService.get('R', roleName).subscribe(...)

// HTTP Calls
this.httpClient.get('/api/data').subscribe(...)
this.httpClient.post('/api/create', data).subscribe(...)

// Promises & async/await
await firstValueFrom(this.service.getData())
```

### ❌ **CẦN `destroyed$` (không auto-complete):**
```typescript
// EventEmitter & Subject
this.dataChanged$.pipe(takeUntil(this.destroyed$)).subscribe(...)

// Timer & Interval
interval(1000).pipe(takeUntil(this.destroyed$)).subscribe(...)

// SignalR & WebSocket
this.hubConnection.stream$.pipe(takeUntil(this.destroyed$)).subscribe(...)

// Custom observables
this.customService.longRunningStream$.pipe(takeUntil(this.destroyed$)).subscribe(...)
```

## Best Practices

1. **Luôn gọi super()** trong constructor
2. **Sử dụng destroyed$** chỉ cho long-running observables (không phải ABP services)  
3. **Sử dụng validateForm()** thay vì validate manually
4. **Sử dụng handleApiError()** cho tất cả API errors
5. **Sử dụng show* methods** thay vì ToastService trực tiếp
6. **Sử dụng hasPermission()** để kiểm tra quyền hạn
7. **Sử dụng label.required class** với global CSS trong styles.scss
8. **ABP Services tự complete** - không cần takeUntil cho API calls

## Lợi ích

✅ **DRY Principle** - Không lặp lại code  
✅ **Consistency** - Consistent error handling và messaging  
✅ **Vietnamese Support** - Built-in tiếng Việt  
✅ **Type Safety** - TypeScript support đầy đủ  
✅ **Memory Safe** - Auto cleanup subscriptions  
✅ **Permission Ready** - Built-in permission checking  
✅ **Maintainable** - Centralized common functionality