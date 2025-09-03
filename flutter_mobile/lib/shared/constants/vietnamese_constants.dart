/// Hằng số chứa tất cả văn bản tiếng Việt cho ứng dụng SmartRestaurant Mobile
/// 
/// Chức năng:
/// - Tập trung quản lý tất cả text hiển thị trong ứng dụng
/// - Đảm bảo tính nhất quán về ngôn ngữ và thuật ngữ
/// - Hỗ trợ dễ dàng thay đổi nội dung mà không cần sửa code
/// - Phục vụ cho localization trong tương lai nếu cần
/// 
/// Cấu trúc:
/// - App Info: Thông tin ứng dụng cơ bản
/// - Navigation: Các nhãn điều hướng chính
/// - Common: Các từ khóa dùng chung (Lưu, Hủy, Xác nhận...)
/// - Feature-specific: Nhãn riêng cho từng tính năng
/// - Status: Các trạng thái đơn hàng, đặt bàn
/// - Error Messages: Thông báo lỗi chuẩn
/// - Format: Định dạng ngày tháng, tiền tệ
class VietnameseConstants {
  /// Thông tin ứng dụng cơ bản
  static const String appName = 'SmartRestaurant';
  static const String appVersion = '1.0.0';

  /// Nhãn điều hướng chính - bottom navigation bar
  static const String navOrders = 'Gọi món';
  static const String navReservations = 'Đặt bàn';
  static const String navTakeaway = 'Mang về';

  /// Các nhãn dùng chung trong toàn ứng dụng
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

  /// Xác thực và đăng nhập nhân viên
  static const String login = 'Đăng nhập';
  static const String logout = 'Đăng xuất';
  static const String username = 'Tên đăng nhập';
  static const String password = 'Mật khẩu';
  static const String loginFailed = 'Đăng nhập thất bại';
  static const String loginSuccess = 'Đăng nhập thành công';

  /// Chức năng quản lý đơn hàng (gọi món tại bàn)
  static const String orderTitle = 'Quản lý Đơn hàng';
  static const String newOrder = 'Đơn hàng mới';
  static const String orderNumber = 'Số đơn hàng';
  static const String orderTotal = 'Tổng cộng';
  static const String orderStatus = 'Trạng thái';
  static const String orderDate = 'Ngày đặt';
  static const String tableNumber = 'Số bàn';
  static const String customerName = 'Tên khách hàng';

  /// Chức năng quản lý đặt bàn trước
  static const String reservationTitle = 'Quản lý Đặt bàn';
  static const String newReservation = 'Đặt bàn mới';
  static const String reservationDate = 'Ngày đặt';
  static const String reservationTime = 'Giờ đặt';
  static const String guestCount = 'Số khách';
  static const String phoneNumber = 'Số điện thoại';
  static const String notes = 'Ghi chú';

  /// Chức năng quản lý đơn mang về
  static const String takeawayTitle = 'Quản lý Mang về';
  static const String newTakeaway = 'Đơn mang về mới';
  static const String pickupTime = 'Giờ lấy hàng';
  static const String customerPhone = 'SĐT khách hàng';

  /// Các trạng thái của đơn hàng và đặt bàn
  static const String orderStatusPending = 'Đang chờ';
  static const String orderStatusConfirmed = 'Đã xác nhận';
  static const String orderStatusPreparing = 'Đang chuẩn bị';
  static const String orderStatusReady = 'Sẵn sàng';
  static const String orderStatusCompleted = 'Hoàn thành';
  static const String orderStatusCancelled = 'Đã hủy';

  /// Các thông báo lỗi chuẩn
  static const String networkError = 'Lỗi mạng. Vui lòng thử lại.';
  static const String serverError = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String validationError = 'Thông tin không hợp lệ';
  static const String requiredField = 'Trường này bắt buộc';
  static const String invalidPhoneNumber = 'Số điện thoại không hợp lệ';
  static const String invalidEmail = 'Email không hợp lệ';

  /// Các nhãn thời gian tương đối
  static const String today = 'Hôm nay';
  static const String tomorrow = 'Ngày mai';
  static const String yesterday = 'Hôm qua';
  static const String thisWeek = 'Tuần này';
  static const String thisMonth = 'Tháng này';

  /// Định dạng tiền tệ và số theo chuẩn Việt Nam
  static const String currencySymbol = 'đ';
  static const String thousandSeparator = '.';
  static const String decimalSeparator = ',';

  /// Các ví dụ định dạng thời gian cho developers tham khảo
  static const String dateFormatExample = 'dd/MM/yyyy (08/08/2025)';
  static const String timeFormatExample = 'HH:mm:ss (14:30:00)';
  static const String dateTimeFormatExample = 'dd/MM/yyyy HH:mm:ss (08/08/2025 14:30:00)';
}