# Real-time Notification & Auto-refresh System

## Tổng quan

Hệ thống notification và auto-refresh cho phép mobile app nhận thông báo real-time từ bếp và tự động cập nhật dữ liệu khi có thay đổi.

## Kiến trúc

```
Backend (C#)                    Mobile App (Flutter)
┌─────────────────┐            ┌─────────────────┐
│   KitchenHub    │◄───SignalR──►│ SignalRService │
│   (SignalR)     │            │                 │
└─────────────────┘            └─────────────────┘
         │                               │
         ▼                               ▼
┌─────────────────┐            ┌─────────────────┐
│OrderNotification│            │NotificationService│
│    Service      │            │                 │
└─────────────────┘            └─────────────────┘
                                        │
                                        ▼
                               ┌─────────────────┐
                               │   OrderService  │
                               │  (Auto-refresh) │
                               └─────────────────┘
```

## Các thành phần

### 1. SignalRService (`signalr_service.dart`)

**Chức năng:**
- Kết nối với KitchenHub backend qua SignalR
- Auto-reconnect khi mất kết nối
- Nhận và parse các loại notification từ bếp
- Emit events để các service khác xử lý

**Các event nhận được:**
- `NewOrderReceived` - Đơn hàng mới từ mobile
- `OrderItemServed` - Món đã được phục vụ
- `OrderItemQuantityUpdated` - Cập nhật số lượng món
- `OrderItemsAdded` - Thêm món mới vào order
- `OrderItemRemoved` - Xóa món khỏi order

**Connection States:**
- `disconnected` - Chưa kết nối
- `connecting` - Đang kết nối
- `connected` - Đã kết nối thành công
- `reconnecting` - Đang kết nối lại
- `error` - Lỗi kết nối

### 2. NotificationService (`notification_service.dart`)

**Chức năng:**
- Hiển thị local notifications trên device
- Quản lý danh sách notifications trong app
- Đánh dấu đã đọc/chưa đọc
- Badge count cho unread notifications

**Features:**
- System notifications (using `flutter_local_notifications`)
- In-app notification list
- Notification history
- Badge với số lượng chưa đọc

### 3. OrderService Integration

**Auto-refresh logic:**
```dart
void _handleNotificationForAutoRefresh(BaseNotification notification) {
  switch (notification.type) {
    case NotificationType.newOrder:
    case NotificationType.orderItemServed:
    case NotificationType.orderItemQuantityUpdated:
    case NotificationType.orderItemsAdded:
    case NotificationType.orderItemRemoved:
      _refreshTablesAsync(); // Tự động refresh danh sách bàn
      break;
  }
}
```

**Benefits:**
- Data luôn up-to-date mà không cần user refresh
- Delay 500ms để tránh refresh quá nhiều
- Có thể enable/disable auto-refresh

### 4. UI Components

#### ConnectionStatusWidget
- Hiển thị trạng thái kết nối SignalR
- App bar indicator cho disconnected states
- Floating indicator ở góc màn hình
- Snackbar cho important events

#### NotificationListWidget
- Danh sách notifications
- Swipe để xóa
- Badge với unread count
- Bottom sheet hiển thị full list

#### NotificationBadge
- Badge hiển thị số notifications chưa đọc
- Tự động ẩn khi count = 0
- Wrap bất kỳ widget nào

## Cách sử dụng

### 1. Setup trong main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => NotificationService()),
    ChangeNotifierProxyProvider<AuthService, SignalRService>(
      create: (context) => SignalRService(authService: context.read<AuthService>()),
      update: (_, auth, previous) => previous ?? SignalRService(authService: auth),
    ),
    ChangeNotifierProxyProvider3<AuthService, SignalRService, NotificationService, OrderService>(
      create: (context) => OrderService(
        accessToken: context.read<AuthService>().accessToken,
        signalRService: context.read<SignalRService>(),
        notificationService: context.read<NotificationService>(),
      ),
      update: (_, auth, signalR, notification, previous) => OrderService(
        accessToken: auth.accessToken,
        signalRService: signalR,
        notificationService: notification,
      ),
    ),
  ],
  child: const QuanBiaApp(),
)
```

### 2. Hiển thị connection status

```dart
// App bar indicator
const ConnectionStatusWidget(showAsAppBar: true)

// Inline indicator
const ConnectionStatusWidget(showAsAppBar: false)
```

### 3. Notification button với badge

```dart
NotificationBadge(
  child: IconButton(
    icon: const Icon(Icons.notifications_outlined),
    onPressed: () {
      NotificationBottomSheet.show(context);
    },
  ),
)
```

### 4. Listen for notifications

```dart
Consumer<NotificationService>(
  builder: (context, notificationService, child) {
    return Text('Unread: ${notificationService.unreadCount}');
  },
)
```

## Cấu hình

### Backend URL
```dart
// lib/core/constants/app_constants.dart
static const String baseUrl = 'https://localhost:44346';
```

### SignalR Hub URL
```dart
// Tự động tạo từ baseUrl
final hubUrl = '${AppConstants.baseUrl}/kitchenhub';
```

### Auto-refresh settings
```dart
// Enable/disable auto-refresh
orderService.setAutoRefreshEnabled(true);

// Check if auto-refresh is enabled
bool isEnabled = orderService.autoRefreshEnabled;
```

## Error Handling

### Connection Errors
- Auto-reconnect với backoff (max 5 attempts)
- Display error messages to user
- Fallback polling nếu SignalR fail completely

### Notification Errors
- Silent failures cho non-critical notifications
- Log errors để debugging
- Graceful degradation

### Network Issues
- Handle offline/online states
- Queue notifications khi offline
- Sync khi back online

## Performance

### Connection Management
- Auto-disconnect khi user logout
- Reuse connection cho multiple subscriptions
- Efficient event parsing

### Memory Management
- Limit notifications list (max 50 items)
- Dispose streams properly
- Clean up resources

### UI Performance
- Delay auto-refresh để avoid excessive calls
- Use IndexedStack để maintain state
- Efficient notification widgets

## Testing

### Unit Tests
```bash
flutter test test/unit/signalr_service_test.dart
flutter test test/unit/notification_service_test.dart
```

### Integration Tests
```bash
flutter test test/integration/realtime_notification_test.dart
```

### Manual Testing
1. Start backend server
2. Login to mobile app
3. Make changes từ kitchen dashboard
4. Verify notifications appear
5. Verify data auto-refreshes

## Troubleshooting

### Connection Issues
```dart
// Check connection status
final status = signalRService.connectionStatus;
final error = signalRService.lastError;
```

### Missing Notifications
1. Verify SignalR connection
2. Check KitchenHub group membership
3. Verify backend is sending events
4. Check notification permissions

### Performance Issues
1. Disable auto-refresh temporarily
2. Check notification list size
3. Monitor connection stability
4. Review error logs

## Future Enhancements

1. **Push Notifications** - FCM integration khi app ở background
2. **Offline Support** - Cache notifications khi offline
3. **Custom Sounds** - Different sounds cho different notification types
4. **Rich Notifications** - Images, actions trong notifications
5. **Analytics** - Track notification engagement
6. **Filtering** - Filter notifications by type/priority