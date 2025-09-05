import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';

class OrderReviewWidget extends StatelessWidget {
  const OrderReviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderWorkflowNotifier>(
      builder: (context, notifier, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xem lại đơn hàng',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kiểm tra thông tin đơn hàng trước khi xác nhận',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Order summary placeholder
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order review widget',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sẽ được triển khai trong FLUTTER-4',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}