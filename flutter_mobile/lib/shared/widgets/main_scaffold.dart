import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../constants/vietnamese_constants.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _getCurrentIndex(String location) {
    if (location.startsWith(RouteConstants.orders)) return 0;
    if (location.startsWith(RouteConstants.reservations)) return 1;
    if (location.startsWith(RouteConstants.takeaway)) return 2;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(RouteConstants.orders);
        break;
      case 1:
        context.go(RouteConstants.reservations);
        break;
      case 2:
        context.go(RouteConstants.takeaway);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(currentRoute);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          VietnameseConstants.appName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Implement profile/logout menu
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant, size: 24.r),
            activeIcon: Icon(Icons.restaurant, size: 28.r),
            label: VietnameseConstants.navOrders,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat, size: 24.r),
            activeIcon: Icon(Icons.event_seat, size: 28.r),
            label: VietnameseConstants.navReservations,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.takeout_dining, size: 24.r),
            activeIcon: Icon(Icons.takeout_dining, size: 28.r),
            label: VietnameseConstants.navTakeaway,
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue[600]),
              title: Text(
                'Thông tin tài khoản',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue[600]),
              title: Text(
                'Cài đặt',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[600]),
              title: Text(
                VietnameseConstants.logout,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.red[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          VietnameseConstants.logout,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              VietnameseConstants.cancel,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              context.go(RouteConstants.login);
            },
            child: Text(
              VietnameseConstants.confirm,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}