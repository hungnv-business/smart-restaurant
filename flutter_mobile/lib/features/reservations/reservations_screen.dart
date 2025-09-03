import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/constants/vietnamese_constants.dart';

/// Screen quản lý đặt bàn trong ứng dụng nhà hàng mobile
/// 
/// Chức năng chính:
/// - Hiển thị danh sách đặt bàn với thông tin khách hàng và thời gian
/// - Tạo đặt bàn mới với lựa chọn bàn, thời gian, số người
/// - Chỉnh sửa thông tin đặt bàn (trước khi đến giờ)
/// - Xem chi tiết đặt bàn bao gồm yêu cầu đặc biệt
/// - Liên hệ trực tiếp với khách hàng qua điện thoại
/// - Tìm kiếm và lọc theo tên khách, ngày, trạng thái
/// 
/// Mode hoạt động:
/// - null: Hiển thị danh sách tất cả đặt bàn
/// - 'new': Form tạo đặt bàn mới
/// - 'edit': Form sửa đặt bàn đã tồn tại
/// - 'detail': Màn hình chi tiết đặt bàn
class ReservationsScreen extends StatefulWidget {
  /// Chế độ hoạt động của screen ('new', 'edit', 'detail', hoặc null cho list)
  final String? mode;
  
  /// ID của đặt bàn (cần thiết cho mode 'edit' và 'detail')
  final String? reservationId;

  /// Constructor với các tham số tùy chọn
  const ReservationsScreen({
    Key? key, 
    this.mode,
    this.reservationId,
  }) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
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
              if (widget.mode == null) // Only show add button on list view
                FloatingActionButton(
                  onPressed: () {
                    // TODO: Navigate to new reservation screen
                  },
                  backgroundColor: Colors.blue[600],
                  child: Icon(Icons.add, color: Colors.white, size: 24.r),
                ),
            ],
          ),
          
          SizedBox(height: 20.h),

          // Content based on mode
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case 'new':
        return VietnameseConstants.newReservation;
      case 'edit':
        return 'Sửa đặt bàn #${widget.reservationId}';
      case 'detail':
        return 'Chi tiết đặt bàn #${widget.reservationId}';
      default:
        return VietnameseConstants.reservationTitle;
    }
  }

  Widget _buildContent() {
    switch (widget.mode) {
      case 'new':
        return _buildNewReservationForm();
      case 'edit':
        return _buildEditReservationForm();
      case 'detail':
        return _buildReservationDetail();
      default:
        return _buildReservationsList();
    }
  }

  Widget _buildReservationsList() {
    return Column(
      children: [
        // Search and filter section
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
                    hintText: 'Tìm theo tên khách hàng',
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
                  // TODO: Implement date filter
                },
                icon: Icon(Icons.date_range, size: 24.r, color: Colors.blue[600]),
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

        // Reservations list
        Expanded(
          child: ListView.builder(
            itemCount: 4, // Mock data
            itemBuilder: (context, index) => _buildReservationCard(index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationCard(int reservationNumber) {
    final customerNames = ['Nguyễn Văn An', 'Trần Thị Bình', 'Lê Minh Cường', 'Phạm Thị Dung'];
    final times = ['19:00', '19:30', '20:00', '20:30'];
    
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
                customerNames[reservationNumber - 1],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Đã xác nhận',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Row(
            children: [
              Icon(Icons.event_seat, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                'Bàn ${reservationNumber + 10}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.people, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '${reservationNumber + 1} khách',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          
          SizedBox(height: 4.h),
          
          Row(
            children: [
              Icon(Icons.access_time, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '18/08/2025 - ${times[reservationNumber - 1]}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.phone, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                '0${900000000 + reservationNumber * 111111}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Call customer
                },
                icon: Icon(Icons.call, size: 16.r),
                label: Text('Gọi', style: TextStyle(fontSize: 12.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[600],
                  side: BorderSide(color: Colors.green[300]!),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to edit reservation
                },
                icon: Icon(Icons.edit, size: 16.r),
                label: Text('Sửa', style: TextStyle(fontSize: 12.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[600],
                  side: BorderSide(color: Colors.blue[300]!),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewReservationForm() {
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
              'Thông tin đặt bàn',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            // Form fields will be implemented here
            Text(
              'Form tạo đặt bàn mới sẽ được triển khai ở đây',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24.h),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save new reservation
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

  Widget _buildEditReservationForm() {
    return Center(
      child: Text(
        'Màn hình sửa đặt bàn #${widget.reservationId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildReservationDetail() {
    return Center(
      child: Text(
        'Chi tiết đặt bàn #${widget.reservationId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }
}