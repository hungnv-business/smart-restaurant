import 'package:smart_restaurant/features/orders/models/order_models.dart';
import 'package:smart_restaurant/shared/models/menu_models.dart';
import 'package:smart_restaurant/shared/models/table_models.dart';

class MockData {
  static List<TableModel> get sampleTables => [
    TableModel(
      id: '1',
      tableNumber: 'B01',
      capacity: 4,
      status: TableStatus.available,
      layoutSectionId: 'section1',
    ),
    TableModel(
      id: '2',
      tableNumber: 'B02',
      capacity: 6,
      status: TableStatus.occupied,
      layoutSectionId: 'section1',
    ),
    TableModel(
      id: '3',
      tableNumber: 'B03',
      capacity: 2,
      status: TableStatus.reserved,
      layoutSectionId: 'section2',
    ),
    TableModel(
      id: '4',
      tableNumber: 'B04',
      capacity: 8,
      status: TableStatus.available,
      layoutSectionId: 'section2',
    ),
  ];

  static List<MenuCategoryModel> get sampleCategories => [
    MenuCategoryModel(
      id: '1',
      name: 'Phở',
      description: 'Các loại phở truyền thống Việt Nam',
      sortOrder: 1,
      isActive: true,
    ),
    MenuCategoryModel(
      id: '2',
      name: 'Cơm',
      description: 'Các món cơm đa dạng',
      sortOrder: 2,
      isActive: true,
    ),
    MenuCategoryModel(
      id: '3',
      name: 'Bún',
      description: 'Các loại bún nước và bún khô',
      sortOrder: 3,
      isActive: true,
    ),
    MenuCategoryModel(
      id: '4',
      name: 'Nước uống',
      description: 'Đồ uống và giải khát',
      sortOrder: 4,
      isActive: true,
    ),
    MenuCategoryModel(
      id: '5',
      name: 'Tráng miệng',
      description: 'Món tráng miệng và chè',
      sortOrder: 5,
      isActive: true,
    ),
  ];

  static List<MenuItemModel> get sampleMenuItems => [
    // Phở items
    MenuItemModel(
      id: '1',
      name: 'Phở Bò Tái',
      description: 'Phở bò tái thơm ngon, nước dùng đậm đà',
      price: 65000,
      categoryId: '1',
      isAvailable: true,
      imageUrl: '/assets/images/pho-bo-tai.jpg',
    ),
    MenuItemModel(
      id: '2',
      name: 'Phở Gà',
      description: 'Phở gà nước trong, thịt gà tươi ngon',
      price: 60000,
      categoryId: '1',
      isAvailable: true,
      imageUrl: '/assets/images/pho-ga.jpg',
    ),
    MenuItemModel(
      id: '3',
      name: 'Phở Đặc Biệt',
      description: 'Phở đầy đủ các loại thịt bò',
      price: 75000,
      categoryId: '1',
      isAvailable: false, // Out of ingredients
      imageUrl: '/assets/images/pho-dac-biet.jpg',
    ),

    // Cơm items
    MenuItemModel(
      id: '4',
      name: 'Cơm Tấm Sườn',
      description: 'Cơm tấm sườn nướng, trứng ốp la',
      price: 55000,
      categoryId: '2',
      isAvailable: true,
      imageUrl: '/assets/images/com-tam-suon.jpg',
    ),
    MenuItemModel(
      id: '5',
      name: 'Cơm Gà Xối Mỡ',
      description: 'Cơm gà xối mỡ truyền thống',
      price: 50000,
      categoryId: '2',
      isAvailable: true,
      imageUrl: '/assets/images/com-ga-xoi-mo.jpg',
    ),

    // Bún items
    MenuItemModel(
      id: '6',
      name: 'Bún Bò Huế',
      description: 'Bún bò Huế cay nồng đặc trưng',
      price: 70000,
      categoryId: '3',
      isAvailable: true,
      imageUrl: '/assets/images/bun-bo-hue.jpg',
    ),
    MenuItemModel(
      id: '7',
      name: 'Bún Chả',
      description: 'Bún chả Hà Nội thơm lừng',
      price: 65000,
      categoryId: '3',
      isAvailable: true,
      imageUrl: '/assets/images/bun-cha.jpg',
    ),

    // Nước uống items
    MenuItemModel(
      id: '8',
      name: 'Trà Đá',
      description: 'Trà đá truyền thống',
      price: 5000,
      categoryId: '4',
      isAvailable: true,
      imageUrl: null,
    ),
    MenuItemModel(
      id: '9',
      name: 'Nước Cam Tươi',
      description: 'Nước cam vắt tươi ngon',
      price: 25000,
      categoryId: '4',
      isAvailable: true,
      imageUrl: '/assets/images/nuoc-cam.jpg',
    ),

    // Tráng miệng items  
    MenuItemModel(
      id: '10',
      name: 'Chè Ba Màu',
      description: 'Chè ba màu mát lạnh',
      price: 20000,
      categoryId: '5',
      isAvailable: true,
      imageUrl: '/assets/images/che-ba-mau.jpg',
    ),
  ];

  static List<OrderItemModel> get sampleOrderItems => [
    OrderItemModel(
      id: '1',
      menuItemId: '1',
      menuItemName: 'Phở Bò Tái',
      unitPrice: 65000,
      quantity: 2,
      notes: 'Ít muối',
      status: OrderItemStatus.pending,
    ),
    OrderItemModel(
      id: '2',
      menuItemId: '4',
      menuItemName: 'Cơm Tấm Sườn',
      unitPrice: 55000,
      quantity: 1,
      notes: 'Không cần rau',
      status: OrderItemStatus.pending,
    ),
  ];

  static OrderModel get sampleOrder => OrderModel(
    id: 'order-123',
    orderNumber: 'ORD-001',
    tableId: 'table-1',
    status: OrderStatus.pending,
    items: sampleOrderItems,
    totalAmount: 185000, // (65000 * 2) + 55000
    createdAt: DateTime.now(),
    customerInfo: CustomerInfo(
      name: 'Nguyễn Văn Test',
      phone: '0901234567',
      notes: 'Khách hàng VIP',
    ),
    specialRequests: SpecialRequestsModel(
      kitchenNotes: 'Làm nhanh',
      allergyWarnings: ['Không tôm'],
      servingPreferences: 'Món nóng trước',
      priority: OrderPriority.normal,
    ),
  );

  static List<MissingIngredientModel> get sampleMissingIngredients => [
    MissingIngredientModel(
      ingredientName: 'Thịt bò',
      requiredQuantity: 300,
      currentStock: 150,
      missingQuantity: 150,
      isOptional: false,
    ),
    MissingIngredientModel(
      ingredientName: 'Rau thơm',
      requiredQuantity: 50,
      currentStock: 0,
      missingQuantity: 50,
      isOptional: true,
    ),
  ];

  static OrderStatusUpdate get sampleStatusUpdate => OrderStatusUpdate(
    orderId: 'order-123',
    status: OrderStatus.preparing,
    updatedAt: DateTime.now().toIso8601String(),
    estimatedReadyTime: DateTime.now().add(const Duration(minutes: 25)).toIso8601String(),
    notes: 'Đã bắt đầu nấu món',
  );

  static KitchenNotification get sampleKitchenNotification => KitchenNotification(
    orderId: 'order-456',
    message: 'Bàn 5: Phở Bò Tái x2 - Ít muối',
    priority: NotificationPriority.normal,
    kitchenArea: 'pho_station',
    timestamp: DateTime.now(),
  );

  static PaymentResult get samplePaymentResult => PaymentResult(
    success: true,
    transactionId: 'txn-789',
    paymentMethod: PaymentMethod.cash,
    amount: 185000,
    timestamp: DateTime.now(),
  );

  // Test scenarios for edge cases
  static List<MenuItemModel> get largeMenuItems => List.generate(100, (index) =>
    MenuItemModel(
      id: 'large_$index',
      name: 'Món số ${index + 1}',
      description: 'Mô tả cho món số ${index + 1}',
      price: 50000 + (index * 1000),
      categoryId: '${(index % 5) + 1}',
      isAvailable: index % 7 != 0, // Some items unavailable
      imageUrl: null,
    ),
  );

  static List<OrderModel> get multipleOrders => [
    OrderModel(
      id: 'order-001',
      orderNumber: 'ORD-001',
      tableId: 'table-1',
      status: OrderStatus.pending,
      items: [sampleOrderItems[0]],
      totalAmount: 130000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    OrderModel(
      id: 'order-002',
      orderNumber: 'ORD-002', 
      tableId: 'table-2',
      status: OrderStatus.preparing,
      items: [sampleOrderItems[1]],
      totalAmount: 55000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    OrderModel(
      id: 'order-003',
      orderNumber: 'ORD-003',
      tableId: 'table-3',
      status: OrderStatus.ready,
      items: sampleOrderItems,
      totalAmount: 185000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  // Vietnamese specific test data
  static Map<String, String> get vietnameseTestStrings => {
    'search_terms': 'phở bò tái nạm chín',
    'search_no_diacritics': 'pho bo tai nam chin',
    'special_requests': 'Ít muối, không cay, thêm rau thơm',
    'customer_names': 'Nguyễn Văn Anh, Trần Thị Bình, Lê Hoàng Cường',
    'phone_numbers': '0901234567, +84909876543, 0123456789',
    'kitchen_notes': 'Làm nhanh, khách vội, món nóng, extra nước mắm',
    'allergy_warnings': 'Không tôm, không đậu phộng, không sữa',
  };

  static Map<String, dynamic> get testConfiguration => {
    'api_base_url': 'http://localhost:44346',
    'websocket_url': 'ws://localhost:8080/orders',
    'test_timeout': 30000,
    'retry_attempts': 3,
    'heartbeat_interval': 5000,
    'offline_storage_max_items': 50,
  };

  static List<String> get vietnameseSearchQueries => [
    'phở', 'pho', // Test diacritics
    'cơm tấm', 'com tam',
    'bún bò', 'bun bo',
    'nước cam', 'nuoc cam',
    'chè đậu', 'che dau',
    'sườn nướng', 'suon nuong',
    'gà xối mỡ', 'ga xoi mo',
  ];

  static List<Map<String, dynamic>> get orderWorkflowSteps => [
    {
      'step': 1,
      'name': 'Chọn bàn',
      'description': 'Nhân viên chọn bàn cho khách',
      'expected_elements': ['table_grid', 'table_status_indicators'],
    },
    {
      'step': 2,
      'name': 'Duyệt menu',
      'description': 'Khách hàng chọn món ăn',
      'expected_elements': ['category_tabs', 'menu_items_grid', 'search_bar'],
    },
    {
      'step': 3,
      'name': 'Tùy chỉnh món',
      'description': 'Thêm ghi chú và điều chỉnh số lượng',
      'expected_elements': ['quantity_selector', 'notes_field', 'add_button'],
    },
    {
      'step': 4,
      'name': 'Xem lại order',
      'description': 'Kiểm tra thông tin đơn hàng',
      'expected_elements': ['order_summary', 'total_amount', 'customer_info'],
    },
    {
      'step': 5,
      'name': 'Xác nhận',
      'description': 'Xác nhận và gửi đến bếp',
      'expected_elements': ['confirm_dialog', 'ingredient_check', 'success_message'],
    },
  ];

  static List<Map<String, dynamic>> get errorScenarios => [
    {
      'name': 'Mất kết nối mạng',
      'description': 'Test offline mode và sync khi online lại',
      'trigger': 'network_disconnect',
      'expected_behavior': 'queue_orders_offline',
    },
    {
      'name': 'Thiếu nguyên liệu',
      'description': 'Test warning khi thiếu nguyên liệu bắt buộc',
      'trigger': 'insufficient_ingredients',
      'expected_behavior': 'prevent_order_or_warn',
    },
    {
      'name': 'Bàn đã có người',
      'description': 'Test khi bàn được chọn đồng thời',
      'trigger': 'table_already_occupied',
      'expected_behavior': 'show_error_select_different_table',
    },
    {
      'name': 'Server quá tải',
      'description': 'Test khi API response chậm',
      'trigger': 'slow_api_response',
      'expected_behavior': 'show_loading_allow_retry',
    },
    {
      'name': 'Validation lỗi',
      'description': 'Test input validation',
      'trigger': 'invalid_input_data',
      'expected_behavior': 'show_validation_messages',
    },
  ];

  static Map<String, dynamic> get performanceThresholds => {
    'app_startup_time_ms': 3000,
    'menu_load_time_ms': 2000,
    'order_creation_time_ms': 1500,
    'search_response_time_ms': 500,
    'status_update_time_ms': 100,
    'max_frame_build_time_ms': 16, // 60fps
    'max_memory_usage_mb': 150,
  };

  static List<Map<String, dynamic>> get accessibilityTestCases => [
    {
      'feature': 'Table Selection',
      'semantic_labels': ['Bàn số B01, 4 chỗ ngồi, trống', 'Bàn số B02, 6 chỗ ngồi, có khách'],
      'actions': ['tap', 'long_press'],
    },
    {
      'feature': 'Menu Items',
      'semantic_labels': ['Phở Bò Tái, giá 65,000 đồng', 'Cơm Tấm Sườn, giá 55,000 đồng'],
      'actions': ['tap', 'double_tap', 'add_to_cart'],
    },
    {
      'feature': 'Order Summary', 
      'semantic_labels': ['Tổng tiền 185,000 đồng', 'Xác nhận đơn hàng'],
      'actions': ['scroll', 'edit_quantity', 'confirm'],
    },
  ];

  static Map<String, List<String>> get vietnameseUITexts => {
    'navigation': [
      'Đặt món', 'Theo dõi', 'Bếp', 'Cài đặt', 'Thống kê'
    ],
    'order_status': [
      'Chờ xác nhận', 'Đã xác nhận', 'Đang chuẩn bị', 'Sẵn sàng', 'Đã phục vụ'
    ],
    'table_status': [
      'Trống', 'Có khách', 'Đã đặt', 'Đang dọn'
    ],
    'payment_methods': [
      'Tiền mặt', 'Thẻ ngân hàng', 'Chuyển khoản', 'Chia tách'
    ],
    'common_actions': [
      'Thêm', 'Xóa', 'Sửa', 'Lưu', 'Hủy', 'Xác nhận', 'Thử lại'
    ],
    'error_messages': [
      'Có lỗi xảy ra', 'Không có kết nối', 'Thiếu nguyên liệu', 
      'Dữ liệu không hợp lệ', 'Đơn hàng trống'
    ],
  };

  // Helper methods for test setup
  static MenuItemModel createTestMenuItem({
    String? id,
    String? name,
    int? price,
    String? categoryId,
    bool? isAvailable,
  }) {
    return MenuItemModel(
      id: id ?? 'test-item',
      name: name ?? 'Test Món',
      description: 'Món test cho unit test',
      price: price ?? 50000,
      categoryId: categoryId ?? '1',
      isAvailable: isAvailable ?? true,
      imageUrl: null,
    );
  }

  static OrderItemModel createTestOrderItem({
    String? id,
    String? menuItemName,
    int? quantity,
    int? unitPrice,
    String? notes,
  }) {
    return OrderItemModel(
      id: id ?? 'test-order-item',
      menuItemId: 'menu-item-1',
      menuItemName: menuItemName ?? 'Test Món',
      unitPrice: unitPrice ?? 50000,
      quantity: quantity ?? 1,
      notes: notes ?? '',
      status: OrderItemStatus.pending,
    );
  }

  static TableModel createTestTable({
    String? id,
    String? tableNumber,
    int? capacity,
    TableStatus? status,
  }) {
    return TableModel(
      id: id ?? 'test-table',
      tableNumber: tableNumber ?? 'TEST-01',
      capacity: capacity ?? 4,
      status: status ?? TableStatus.available,
      layoutSectionId: 'test-section',
    );
  }
}