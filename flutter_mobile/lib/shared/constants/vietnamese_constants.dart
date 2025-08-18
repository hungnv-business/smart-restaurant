// Vietnamese text constants for SmartRestaurant Mobile App
// All UI text is in Vietnamese as specified in requirements

class VietnameseConstants {
  // App Info
  static const String appName = 'SmartRestaurant';
  static const String appVersion = '1.0.0';

  // Main Navigation Labels
  static const String navOrders = 'Gọi món';
  static const String navReservations = 'Đặt bàn';
  static const String navTakeaway = 'Mang về';

  // Common Labels
  static const String loading = 'Đang tải...';
  static const String error = 'Lỗi';
  static const String success = 'Thành công';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Sửa';
  static const String add = 'Thêm';
  static const String search = 'Tìm kiếm';
  static const String filter = 'Lọc';

  // Authentication
  static const String login = 'Đăng nhập';
  static const String logout = 'Đăng xuất';
  static const String username = 'Tên đăng nhập';
  static const String password = 'Mật khẩu';
  static const String loginFailed = 'Đăng nhập thất bại';
  static const String loginSuccess = 'Đăng nhập thành công';

  // Orders Feature
  static const String orderTitle = 'Quản lý Đơn hàng';
  static const String newOrder = 'Đơn hàng mới';
  static const String orderNumber = 'Số đơn hàng';
  static const String orderTotal = 'Tổng cộng';
  static const String orderStatus = 'Trạng thái';
  static const String orderDate = 'Ngày đặt';
  static const String tableNumber = 'Số bàn';
  static const String customerName = 'Tên khách hàng';

  // Reservations Feature
  static const String reservationTitle = 'Quản lý Đặt bàn';
  static const String newReservation = 'Đặt bàn mới';
  static const String reservationDate = 'Ngày đặt';
  static const String reservationTime = 'Giờ đặt';
  static const String guestCount = 'Số khách';
  static const String phoneNumber = 'Số điện thoại';
  static const String notes = 'Ghi chú';

  // Takeaway Feature
  static const String takeawayTitle = 'Quản lý Mang về';
  static const String newTakeaway = 'Đơn mang về mới';
  static const String pickupTime = 'Giờ lấy hàng';
  static const String customerPhone = 'SĐT khách hàng';

  // Order Status
  static const String orderStatusPending = 'Đang chờ';
  static const String orderStatusConfirmed = 'Đã xác nhận';
  static const String orderStatusPreparing = 'Đang chuẩn bị';
  static const String orderStatusReady = 'Sẵn sàng';
  static const String orderStatusCompleted = 'Hoàn thành';
  static const String orderStatusCancelled = 'Đã hủy';

  // Error Messages
  static const String networkError = 'Lỗi mạng. Vui lòng thử lại.';
  static const String serverError = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String validationError = 'Thông tin không hợp lệ';
  static const String requiredField = 'Trường này bắt buộc';
  static const String invalidPhoneNumber = 'Số điện thoại không hợp lệ';
  static const String invalidEmail = 'Email không hợp lệ';

  // Date & Time
  static const String today = 'Hôm nay';
  static const String tomorrow = 'Ngày mai';
  static const String yesterday = 'Hôm qua';
  static const String thisWeek = 'Tuần này';
  static const String thisMonth = 'Tháng này';

  // Currency & Numbers
  static const String currencySymbol = 'đ';
  static const String thousandSeparator = '.';
  static const String decimalSeparator = ',';

  // Time Format Examples
  static const String dateFormatExample = 'dd/MM/yyyy (08/08/2025)';
  static const String timeFormatExample = 'HH:mm:ss (14:30:00)';
  static const String dateTimeFormatExample = 'dd/MM/yyyy HH:mm:ss (08/08/2025 14:30:00)';
}