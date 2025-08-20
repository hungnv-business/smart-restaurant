# Global Toast Service Usage

## Overview
Toast messages are now centrally managed through the layout component. You no longer need to add `<p-toast></p-toast>` to each component.

## Using Toast Messages

### In Components extending ComponentBase
Components that extend `ComponentBase` can use these protected methods:

```typescript
// Success message
this.showSuccess('Đăng nhập thành công', 'Chào mừng bạn!');

// Error message  
this.showError('Đăng nhập thất bại', 'Tên đăng nhập hoặc mật khẩu không đúng');

// Warning message
this.showWarning('Cảnh báo', 'Dữ liệu chưa được lưu');

// Info message
this.showInfo('Thông báo', 'Hệ thống sẽ bảo trì vào 2h sáng');
```

### In Standalone Components
For components that don't extend ComponentBase, inject the ToastService directly:

```typescript
import { ToastService } from '../shared/services/toast.service';

export class MyComponent {
  private toastService = inject(ToastService);

  showMessage() {
    this.toastService.showSuccess('Thành công!');
  }
}
```

## Configuration
- Success messages: 3 seconds duration
- Error messages: 5 seconds duration  
- Warning messages: 4 seconds duration
- Info messages: 3 seconds duration

## Global Setup
The toast component is already added to `RestaurantLayoutComponent` so it appears on all pages that use the layout.