import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/constants/vietnamese_constants.dart';

/// Screen quản lý đơn hàng gọi món trong ứng dụng nhà hàng
/// 
/// Chức năng chính:
/// - Hiển thị danh sách đơn hàng với trạng thái và thông tin chi tiết
/// - Tạo đơn hàng mới với lựa chọn món ăn từ thực đơn
/// - Chỉnh sửa đơn hàng đã tồn tại (nếu chưa xác nhận)
/// - Xem chi tiết đơn hàng bao gồm món ăn, giá cả, trạng thái
/// - Tìm kiếm và lọc đơn hàng theo nhiều tiêu chí
/// 
/// Mode hoạt động:
/// - null: Hiển thị danh sách tất cả đơn hàng
/// - 'new': Form tạo đơn hàng mới
/// - 'edit': Form sửa đơn hàng existante
/// - 'detail': Màn hình chi tiết đơn hàng read-only
class OrdersScreen extends StatefulWidget {
  /// Chế độ hoạt động của screen ('new', 'edit', 'detail', hoặc null cho list)
  final String? mode;
  
  /// ID của đơn hàng (cần thiết cho mode 'edit' và 'detail')
  final String? orderId;

  /// Constructor với các tham số tùy chọn
  const OrdersScreen({
    Key? key, 
    this.mode,
    this.orderId,
  }) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

/// State class cho OrdersScreen với logic quản lý giao diện
class _OrdersScreenState extends State<OrdersScreen> {
  /// Xây dựng giao diện chính của screen
  /// 
  /// Bao gồm header với title và nút thêm mới (chỉ ở list view)
  /// Nội dung chính thay đổi theo mode hiện tại
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần header với tiêu đề và nút thêm mới
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTitle(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (widget.mode == null) // Chỉ hiện nút thêm ở chế độ danh sách
                FloatingActionButton(
                  onPressed: () {
                    // TODO: Điều hướng đến màn hình tạo đơn hàng mới
                  },
                  backgroundColor: Colors.blue[600],
                  child: Icon(Icons.add, color: Colors.white, size: 24.r),
                ),
            ],
          ),
          
          SizedBox(height: 20.h),

          // Nội dung chính thay đổi theo mode
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Lấy tiêu đề phù hợp dựa trên mode hiện tại
  /// 
  /// Returns: Chuỗi tiêu đề hiển thị trên header
  String _getTitle() {
    switch (widget.mode) {
      case 'new':
        return VietnameseConstants.newOrder;
      case 'edit':
        return 'Sửa đơn hàng #${widget.orderId}';
      case 'detail':
        return 'Chi tiết đơn hàng #${widget.orderId}';
      default:
        return VietnameseConstants.orderTitle;
    }
  }

  /// Xây dựng nội dung chính dựa trên mode hiện tại
  /// 
  /// Returns: Widget phù hợp với từng chế độ hoạt động
  Widget _buildContent() {
    switch (widget.mode) {
      case 'new':
        return _buildNewOrderForm();
      case 'edit':
        return _buildEditOrderForm();
      case 'detail':
        return _buildOrderDetail();
      default:
        return _buildOrdersList();
    }
  }

  /// Xây dựng danh sách tất cả đơn hàng với tính năng tìm kiếm và lọc
  /// 
  /// Bao gồm:
  /// - Thanh tìm kiếm theo mã đơn hàng, bàn, thời gian
  /// - Nút lọc theo trạng thái, khoảng thời gian
  /// - Danh sách đơn hàng dạng card với thông tin tóm tắt
  Widget _buildOrdersList() {
    return Column(
      children: [
        // Phần tìm kiếm và lọc đơn hàng
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: VietnameseConstants.search,
                    hintStyle: TextStyle(fontSize: 14.sp),
                    prefixIcon: Icon(Icons.search, size: 20.r),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                onPressed: () {
                  // TODO: Mở dialog lọc theo trạng thái, thời gian, bàn
                },
                icon: Icon(Icons.tune, size: 24.r, color: Colors.blue[600]),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Danh sách các đơn hàng
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Dữ liệu mock tạm thời
            itemBuilder: (context, index) => _buildOrderCard(index + 1),
          ),
        ),
      ],
    );
  }

  /// Xây dựng card hiển thị thông tin tóm tắt một đơn hàng
  /// 
  /// [orderNumber]: Số thứ tự đơn hàng để tạo dữ liệu mock
  /// 
  /// Hiển thị:
  /// - Mã đơn hàng và trạng thái (đã xác nhận, đang chế biến, hoàn thành)
  /// - Thông tin bàn và thời gian đặt
  /// - Tổng giá trị đơn hàng được format theo VND
  /// - Nút sửa và xem chi tiết
  Widget _buildOrderCard(int orderNumber) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng #$orderNumber',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              // Badge trạng thái đơn hàng với màu sắc phân biệt
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  VietnameseConstants.orderStatusConfirmed,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Thông tin bàn và thời gian
          Row(
            children: [
              Icon(Icons.table_restaurant, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                'Bàn ${orderNumber + 5}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '${14 + orderNumber}:${30 + orderNumber}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Tổng tiền và các nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng: ${(123456 * orderNumber).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
              Row(
                children: [
                  // Nút sửa đơn hàng (chỉ khi chưa xác nhận)
                  IconButton(
                    onPressed: () {
                      // TODO: Điều hướng đến màn hình sửa đơn hàng
                    },
                    icon: Icon(Icons.edit, size: 20.r, color: Colors.blue[600]),
                  ),
                  // Nút xem chi tiết đơn hàng
                  IconButton(
                    onPressed: () {
                      // TODO: Điều hướng đến màn hình chi tiết đơn hàng
                    },
                    icon: Icon(Icons.visibility, size: 20.r, color: Colors.green[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng form tạo đơn hàng mới
  /// 
  /// Bao gồm:
  /// - Chọn bàn hoặc khách hàng (cho mang về)
  /// - Thêm món ăn từ thực đơn với số lượng
  /// - Ghi chú đặc biệt cho từng món
  /// - Tính toán tổng tiền tự động
  /// - Nút lưu và hủy
  Widget _buildNewOrderForm() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đơn hàng',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            // Các trường form sẽ được implement ở đây
            // Bao gồm: chọn bàn, chọn món, số lượng, ghi chú
            Text(
              'Form tạo đơn hàng mới sẽ được triển khai ở đây',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24.h),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Lưu đơn hàng mới và gửi đến bếp
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      VietnameseConstants.save,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Quay lại màn hình trước đó
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      VietnameseConstants.cancel,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng form chỉnh sửa đơn hàng đã tồn tại
  /// 
  /// Chỉ cho phép sửa những đơn hàng chưa được xác nhận
  /// Hiển thị thông tin hiện tại và cho phép thay đổi
  Widget _buildEditOrderForm() {
    return Center(
      child: Text(
        'Màn hình sửa đơn hàng #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }

  /// Xây dựng màn hình chi tiết đơn hàng (chỉ đọc)
  /// 
  /// Hiển thị:
  /// - Thông tin khách hàng và bàn
  /// - Danh sách món ăn đã order với giá và số lượng
  /// - Trạng thái từng món (chờ chế biến, đang làm, hoàn thành)
  /// - Tổng tiền và phương thức thanh toán
  /// - Thời gian tạo và cập nhật cuối
  Widget _buildOrderDetail() {
    return Center(
      child: Text(
        'Chi tiết đơn hàng #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }
}