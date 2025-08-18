import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/constants/vietnamese_constants.dart';

class OrdersScreen extends StatefulWidget {
  final String? mode; // 'new', 'edit', 'detail', or null for list
  final String? orderId;

  const OrdersScreen({
    Key? key, 
    this.mode,
    this.orderId,
  }) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
                    // TODO: Navigate to new order screen
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
        return VietnameseConstants.newOrder;
      case 'edit':
        return 'Sửa đơn hàng #${widget.orderId}';
      case 'detail':
        return 'Chi tiết đơn hàng #${widget.orderId}';
      default:
        return VietnameseConstants.orderTitle;
    }
  }

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

  Widget _buildOrdersList() {
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
                  // TODO: Implement filter functionality
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

        // Orders list
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Mock data
            itemBuilder: (context, index) => _buildOrderCard(index + 1),
          ),
        ),
      ],
    );
  }

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
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to edit order
                    },
                    icon: Icon(Icons.edit, size: 20.r, color: Colors.blue[600]),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to order detail
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
            
            // Form fields will be implemented here
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
                      // TODO: Save new order
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

  Widget _buildEditOrderForm() {
    return Center(
      child: Text(
        'Màn hình sửa đơn hàng #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildOrderDetail() {
    return Center(
      child: Text(
        'Chi tiết đơn hàng #${widget.orderId}',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
      ),
    );
  }
}