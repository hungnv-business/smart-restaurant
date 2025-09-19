import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/connection_status_widget.dart';
import '../../../core/widgets/notification_list_widget.dart';
import '../../auth/screens/login_screen.dart';
import '../../order/screens/order_screen.dart';
import '../../takeaway/screens/takeaway_screen.dart';
import '../../payment/screens/payment_screen.dart';
import '../../settings/screens/network_printer_settings_screen.dart';

/// Màn hình chính với bottom navigation cho 3 tab
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OrderScreen(),
    TakeawayScreen(),
    PaymentScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      activeIcon: Icon(Icons.restaurant_menu),
      label: AppConstants.orderTabTitle,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_bag_outlined),
      activeIcon: Icon(Icons.shopping_bag),
      label: AppConstants.takeawayTabTitle,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.payment_outlined),
      activeIcon: Icon(Icons.payment),
      label: AppConstants.paymentTabTitle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Cài đặt máy in',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NetworkPrinterSettingsScreen(),
                ),
              );
            },
          ),
          // Notification button with badge
          NotificationBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                NotificationBottomSheet.show(context);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Xử lý profile
              _showProfileBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status indicator
          const ConnectionStatusWidget(showAsAppBar: true),
          // Main content
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return AppConstants.orderTabTitle;
      case 1:
        return AppConstants.takeawayTabTitle;
      case 2:
        return AppConstants.paymentTabTitle;
      default:
        return AppConstants.appName;
    }
  }

  void _showProfileBottomSheet(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userInfo = authService.userInfo;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(height: 16),
            Text(
              userInfo?.displayName ?? userInfo?.username ?? 'Nhân viên',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getUserRoleDisplay(userInfo?.roles ?? []),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cài đặt đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Hỗ trợ'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hỗ trợ đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getUserRoleDisplay(List<String> roles) {
    if (roles.isEmpty) return 'Nhân viên';

    // Map roles to Vietnamese display names
    final roleMap = {
      'admin': 'Quản lý',
      'manager': 'Quản lý',
      'staff': 'Nhân viên',
      'waiter': 'Phục vụ bàn',
      'cashier': 'Thu ngân',
      'kitchen': 'Bếp',
      'cook': 'Đầu bếp',
    };

    final displayRoles = roles
        .map((role) => roleMap[role.toLowerCase()] ?? role)
        .toList();

    return displayRoles.join(', ');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.logout();

              // Quay về màn hình login
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
