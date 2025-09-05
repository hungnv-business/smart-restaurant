import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderWorkflowNotifier>(
      builder: (context, notifier, child) {
        if (notifier.state.isConnected) {
          return const SizedBox.shrink(); // Hide when connected
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Theme.of(context).colorScheme.errorContainer,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                size: 16,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mất kết nối mạng. Một số tính năng có thể không hoạt động.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _retryConnection(context, notifier),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _retryConnection(BuildContext context, OrderWorkflowNotifier notifier) {
    // Simulate connection retry
    notifier.setConnectionStatus(true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã kết nối lại thành công'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}