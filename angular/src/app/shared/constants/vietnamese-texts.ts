// Vietnamese text constants for SmartRestaurant
// Use this file for commonly used Vietnamese texts across the application

export const VIETNAMESE_TEXTS = {
  // Common UI
  COMMON: {
    ADD: 'Thêm',
    EDIT: 'Chỉnh sửa', 
    DELETE: 'Xóa',
    SAVE: 'Lưu',
    CANCEL: 'Hủy',
    BACK: 'Quay lại',
    SEARCH: 'Tìm kiếm',
    FILTER: 'Lọc',
    LOADING: 'Đang tải...',
    NO_DATA: 'Không có dữ liệu',
    SUCCESS: 'Thành công',
    ERROR: 'Lỗi',
    CONFIRM: 'Xác nhận',
    STATUS: 'Trạng thái',
    ACTIONS: 'Thao tác',
    ACTIVE: 'Hoạt động',
    INACTIVE: 'Tạm khóa',
    CREATED_DATE: 'Ngày tạo'
  },

  // User Management
  USER: {
    TITLE: 'Quản lý Nhân viên',
    LIST_TITLE: 'Danh sách Nhân viên',
    ADD_USER: 'Thêm Nhân viên',
    EDIT_USER: 'Chỉnh sửa Nhân viên',
    USER_DETAILS: 'Thông tin Nhân viên',
    
    // Fields
    EMPLOYEE_ID: 'Mã Nhân viên',
    USERNAME: 'Tên đăng nhập',
    EMAIL: 'Email',
    FULL_NAME: 'Họ tên',
    FIRST_NAME: 'Họ',
    LAST_NAME: 'Tên',
    PHONE: 'Số điện thoại',
    PASSWORD: 'Mật khẩu',
    ROLES: 'Vai trò',
    ADDRESS: 'Địa chỉ',
    EMERGENCY_CONTACT: 'Người liên hệ khẩn cấp',
    EMERGENCY_PHONE: 'SĐT người liên hệ',
    EMERGENCY_RELATION: 'Mối quan hệ',
    WORK_START_TIME: 'Giờ làm việc từ',
    WORK_END_TIME: 'Giờ làm việc đến',
    
    // Messages
    USER_CREATED: 'Đã tạo nhân viên mới thành công',
    USER_UPDATED: 'Đã cập nhật thông tin nhân viên',
    USER_DELETED: 'Đã xóa nhân viên',
    ROLES_UPDATED: 'Đã cập nhật quyền cho nhân viên',
    DELETE_CONFIRM: 'Bạn có chắc chắn muốn xóa nhân viên này?',
    
    // Validation
    USERNAME_REQUIRED: 'Tên đăng nhập là bắt buộc',
    EMAIL_REQUIRED: 'Email là bắt buộc',
    EMAIL_INVALID: 'Email không hợp lệ',
    PASSWORD_REQUIRED: 'Mật khẩu là bắt buộc',
    PASSWORD_MIN_LENGTH: 'Mật khẩu tối thiểu 6 ký tự',
    ROLES_REQUIRED: 'Phải chọn ít nhất một vai trò'
  },

  // Restaurant Roles
  ROLES: {
    OWNER: 'Chủ nhà hàng',
    MANAGER: 'Quản lý', 
    CASHIER: 'Thu ngân',
    KITCHEN_STAFF: 'Nhân viên bếp',
    WAITSTAFF: 'Nhân viên phục vụ',
    
    // Descriptions
    OWNER_DESC: 'Toàn quyền quản lý nhà hàng, báo cáo và nhân viên',
    MANAGER_DESC: 'Quản lý đơn hàng, menu, bàn và báo cáo cơ bản', 
    CASHIER_DESC: 'Xử lý đơn hàng, thanh toán và trạng thái bàn',
    KITCHEN_STAFF_DESC: 'Xem màn hình bếp và cập nhật trạng thái món ăn',
    WAITSTAFF_DESC: 'Nhận đơn hàng, quản lý bàn và hỗ trợ khách hàng'
  },

  // Restaurant Business
  RESTAURANT: {
    DASHBOARD: 'Bảng điều khiển',
    ORDERS: 'Đơn hàng', 
    MENU: 'Thực đơn',
    TABLES: 'Bàn ăn',
    KITCHEN: 'Bếp',
    REPORTS: 'Báo cáo',
    SETTINGS: 'Cài đặt',
    
    // Order Status
    ORDER_NEW: 'Đơn mới',
    ORDER_CONFIRMED: 'Đã xác nhận',
    ORDER_PREPARING: 'Đang chuẩn bị',
    ORDER_READY: 'Sẵn sàng',
    ORDER_SERVED: 'Đã phục vụ',
    ORDER_COMPLETED: 'Hoàn thành',
    ORDER_CANCELLED: 'Đã hủy',
    
    // Table Status  
    TABLE_AVAILABLE: 'Trống',
    TABLE_OCCUPIED: 'Có khách',
    TABLE_RESERVED: 'Đã đặt',
    TABLE_CLEANING: 'Đang dọn dẹp'
  },

  // Time & Date
  TIME: {
    TODAY: 'Hôm nay',
    YESTERDAY: 'Hôm qua', 
    THIS_WEEK: 'Tuần này',
    THIS_MONTH: 'Tháng này',
    FORMAT_DATE: 'dd/MM/yyyy',
    FORMAT_TIME: 'HH:mm',
    FORMAT_DATETIME: 'dd/MM/yyyy HH:mm'
  },

  // Currency
  CURRENCY: {
    VND: '₫',
    THOUSAND_SEPARATOR: '.',
    DECIMAL_SEPARATOR: ','
  }
} as const;

// Role mapping utility
export const ROLE_MAPPING = {
  'Owner': VIETNAMESE_TEXTS.ROLES.OWNER,
  'Manager': VIETNAMESE_TEXTS.ROLES.MANAGER,
  'Cashier': VIETNAMESE_TEXTS.ROLES.CASHIER,
  'KitchenStaff': VIETNAMESE_TEXTS.ROLES.KITCHEN_STAFF,
  'Waitstaff': VIETNAMESE_TEXTS.ROLES.WAITSTAFF
} as const;

export const ROLE_DESCRIPTIONS = {
  'Owner': VIETNAMESE_TEXTS.ROLES.OWNER_DESC,
  'Manager': VIETNAMESE_TEXTS.ROLES.MANAGER_DESC, 
  'Cashier': VIETNAMESE_TEXTS.ROLES.CASHIER_DESC,
  'KitchenStaff': VIETNAMESE_TEXTS.ROLES.KITCHEN_STAFF_DESC,
  'Waitstaff': VIETNAMESE_TEXTS.ROLES.WAITSTAFF_DESC
} as const;

// Type safety
export type RoleKey = keyof typeof ROLE_MAPPING;
export type VietnameseTextKey = keyof typeof VIETNAMESE_TEXTS;