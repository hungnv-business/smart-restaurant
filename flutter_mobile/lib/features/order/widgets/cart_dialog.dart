import 'package:flutter/material.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/table_models.dart';
import '../../../shared/utils/price_formatter.dart';

/// Widget dialog hiển thị giỏ hàng
class CartDialog extends StatefulWidget {
  final ActiveTableDto selectedTable;
  final List<MenuItem> cartItems;
  final List<int> cartItemQuantities;
  final Function(int index) onIncreaseQuantity;
  final Function(int index) onDecreaseQuantity;
  final VoidCallback onClearCart;
  final VoidCallback onSubmitOrder;

  const CartDialog({
    Key? key,
    required this.selectedTable,
    required this.cartItems,
    required this.cartItemQuantities,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onClearCart,
    required this.onSubmitOrder,
  }) : super(key: key);

  @override
  State<CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<CartDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giỏ hàng - ${widget.selectedTable.tableNumber}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Cart items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) => _buildCartItem(context, index),
              ),
            ),
            
            // Bottom actions
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        widget.cartItems[index].name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        PriceFormatter.format(widget.cartItems[index].price),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                widget.onDecreaseQuantity(index);
                setState(() {}); // Rebuild dialog để cập nhật UI
              },
              icon: const Icon(Icons.remove),
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${index < widget.cartItemQuantities.length ? widget.cartItemQuantities[index] : 0}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.onIncreaseQuantity(index);
                setState(() {}); // Rebuild dialog để cập nhật UI
              },
              icon: const Icon(Icons.add),
              iconSize: 20,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                PriceFormatter.format(_calculateTotal()),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClearCart();
                    Navigator.pop(context);
                  },
                  child: const Text('Xóa tất cả'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSubmitOrder();
                  },
                  child: const Text('Gửi đơn'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateTotal() {
    int total = 0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      total += widget.cartItems[i].price * widget.cartItemQuantities[i];
    }
    return total;
  }

}