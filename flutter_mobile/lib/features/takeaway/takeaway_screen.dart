import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/constants/vietnamese_constants.dart';

class TakeawayScreen extends StatefulWidget {
  final String? mode; // 'new', 'edit', 'detail', or null for list
  final String? orderId;

  const TakeawayScreen({
    Key? key, 
    this.mode,
    this.orderId,
  }) : super(key: key);

  @override
  State<TakeawayScreen> createState() => _TakeawayScreenState();
}

class _TakeawayScreenState extends State<TakeawayScreen> {
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
                    // TODO: Navigate to new takeaway screen
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
        return VietnameseConstants.newTakeaway;
      case 'edit':
        return 'Sửa đơn mang về #${widget.orderId}';
      case 'detail':
        return 'Chi tiết đơn mang về #${widget.orderId}';
      default:
        return VietnameseConstants.takeawayTitle;
    }
  }

  Widget _buildContent() {
    switch (widget.mode) {
      case 'new':
        return _buildNewTakeawayForm();
      case 'edit':
        return _buildEditTakeawayForm();
      case 'detail':
        return _buildTakeawayDetail();
      default:
        return _buildTakeawayList();
    }
  }

  Widget _buildTakeawayList() {
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
                    hintText: 'Tìm theo SĐT khách hàng',
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
                  // TODO: Implement status filter
                },
                icon: Icon(Icons.filter_list, size: 24.r, color: Colors.blue[600]),
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

        // Takeaway orders list
        Expanded(
          child: ListView.builder(
            itemCount: 6, // Mock data
            itemBuilder: (context, index) => _buildTakeawayCard(index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildTakeawayCard(int orderNumber) {
    final customerPhones = ['0901234567', '0902345678', '0903456789', '0904567890', '0905678901', '0906789012'];
    final pickupTimes = ['15:30', '16:00', '16:30', '17:00', '17:30', '18:00'];
    final statuses = ['Đang chuẩn bị', 'Sẵn sàng', 'Đang chuẩn bị', 'Sẵn sàng', 'Hoàn thành', 'Đang chuẩn bị'];
    final statusColors = [Colors.orange, Colors.green, Colors.orange, Colors.green, Colors.blue, Colors.orange];
    
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
                'Mang về #MW${orderNumber.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColors[orderNumber - 1][100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  statuses[orderNumber - 1],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: statusColors[orderNumber - 1][700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Row(
            children: [
              Icon(Icons.phone, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                customerPhones[orderNumber - 1],
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.schedule, size: 16.r, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                'Lấy lúc ${pickupTimes[orderNumber - 1]}',
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
                'Đặt lúc ${(14 + orderNumber).toString().padLeft(2, '0')}:${(10 + orderNumber * 5).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                'Tổng: ${(89000 + orderNumber * 15000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (statuses[orderNumber - 1] != 'Hoàn thành')
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
              if (statuses[orderNumber - 1] == 'Sẵn sàng')
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Mark as completed
                  },
                  icon: Icon(Icons.check, size: 16.r),
                  label: Text('Hoàn thành', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                )
              else if (statuses[orderNumber - 1] == 'Đang chuẩn bị')
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Mark as ready
                  },
                  icon: Icon(Icons.done, size: 16.r),
                  label: Text('Sẵn sàng', style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange[600],
                    side: BorderSide(color: Colors.orange[300]!),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              if (statuses[orderNumber - 1] != 'Hoàn thành') ...[
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit takeaway
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewTakeawayForm() {
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
              'Thông tin đơn mang về',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16.h),
            
            // Form fields will be implemented here
            Text(
              'Form tạo đơn mang về mới sẽ được triển khai ở đây',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            
            SizedBox(height: 24.h),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save new takeaway order
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

  Widget _buildEditTakeawayForm() {
    return Center(
      child: Text(
        'Màn hình sửa đơn mang về #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTakeawayDetail() {
    return Center(
      child: Text(
        'Chi tiết đơn mang về #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }
}