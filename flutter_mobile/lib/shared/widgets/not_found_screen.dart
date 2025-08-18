import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

class NotFoundScreen extends StatelessWidget {
  final Exception? error;

  const NotFoundScreen({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60.r,
                  color: Colors.red[600],
                ),
              ),

              SizedBox(height: 32.h),

              // Error Title
              Text(
                error != null ? 'Đã xảy ra lỗi' : 'Trang không tồn tại',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Error Message
              Text(
                error != null
                    ? 'Ứng dụng gặp sự cố không mong muốn. Vui lòng thử lại.'
                    : 'Trang bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (error != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              SizedBox(height: 48.h),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(RouteConstants.orders);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Về trang chủ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go(RouteConstants.orders);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Quay lại',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Help Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 16.r,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Cần hỗ trợ? Liên hệ quản trị viên',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}