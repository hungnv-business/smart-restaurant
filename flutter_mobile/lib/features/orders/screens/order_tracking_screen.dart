import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/order_status_tracking_widget.dart';
import '../services/order_tracking_service.dart';
import '../widgets/connection_status_widget.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderTrackingService(),
      child: Scaffold(
        body: Column(
          children: [
            // Connection status indicator  
            const ConnectionStatusWidget(),
            
            // Order tracking content
            Expanded(
              child: OrderStatusTrackingWidget(
                orderId: orderId,
                onOrderCompleted: () => _handleOrderCompleted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrderCompleted(BuildContext context) {
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.celebration,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Hoàn thành đơn hàng!'),
        content: const Text(
          'Đơn hàng đã được phục vụ thành công.\n'
          'Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Return to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }
}