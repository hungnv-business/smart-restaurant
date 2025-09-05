import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';

class OrderConfirmationWidget extends StatelessWidget {
  const OrderConfirmationWidget({super.key});

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
                'Xác nhận đơn hàng',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xác nhận cuối cùng trước khi gửi đơn hàng tới bếp',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Final confirmation UI placeholder
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order confirmation widget',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sẽ được triển khai trong FLUTTER-4',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Missing ingredients warning (if any)
                      if (notifier.state.missingIngredients.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cảnh báo thiếu nguyên liệu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...notifier.state.missingIngredients.map(
                                (ingredient) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    ingredient.displayText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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