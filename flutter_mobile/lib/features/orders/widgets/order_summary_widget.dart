import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_models.dart';
import '../services/order_service.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/vietnamese_text.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../screens/order_tracking_screen.dart';
import '../widgets/missing_ingredients_widget.dart';
import '../services/ingredient_check_service.dart';

class OrderSummaryWidget extends StatefulWidget {
  const OrderSummaryWidget({super.key});

  @override
  State<OrderSummaryWidget> createState() => _OrderSummaryWidgetState();
}

class _OrderSummaryWidgetState extends State<OrderSummaryWidget> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final orderService = context.read<OrderService>();
    _noteController.text = orderService.customerNote;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        if (orderService.isLoading && !_isSubmitting) {
          return const LoadingWidget(message: 'Đang tải...');
        }

        if (orderService.error != null) {
          return CustomErrorWidget(
            message: orderService.error!,
            onRetry: () => orderService.validateOrderItems(),
          );
        }

        if (!orderService.hasItems) {
          return _buildEmptyOrderState();
        }

        return _buildOrderSummary(orderService);
      },
    );
  }

  Widget _buildEmptyOrderState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có món nào trong đơn hàng',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy quay lại chọn món để tiếp tục',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại chọn món'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderService orderService) {
    return Column(
      children: [
        _buildOrderHeader(orderService),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderTypeAndTable(orderService),
                const SizedBox(height: 24),
                _buildOrderItems(orderService),
                const SizedBox(height: 24),
                _buildCustomerNote(orderService),
                const SizedBox(height: 24),
                _buildOrderCalculation(orderService),
              ],
            ),
          ),
        ),
        _buildBottomActions(orderService),
      ],
    );
  }

  Widget _buildOrderHeader(OrderService orderService) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Xác nhận đơn hàng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${orderService.totalItemCount} món',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeAndTable(OrderService orderService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  orderService.orderType == OrderType.dineIn 
                      ? Icons.restaurant 
                      : Icons.takeout_dining,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  orderService.orderType.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (orderService.selectedTable != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bàn ${orderService.selectedTable!.tableNumber}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${orderService.selectedTable!.capacity} chỗ',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(OrderService orderService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderService.orderItems.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = orderService.orderItems[index];
                return _buildOrderItem(orderService, item, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderService orderService, OrderItem item, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.menuItemName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Ghi chú: ${item.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                VietnameseFormatter.formatCurrency(item.totalPrice),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildQuantityControls(orderService, index, item.quantity),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _showItemOptionsModal(orderService, index, item),
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildQuantityControls(OrderService orderService, int index, int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity > 1 ? () => orderService.updateItemQuantity(index, quantity - 1) : null,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                color: quantity > 1 ? AppColors.primary : Colors.grey[400],
                size: 20,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () => orderService.updateItemQuantity(index, quantity + 1),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerNote(OrderService orderService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi chú cho nhân viên',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Không cay, ít muối, phục vụ nhanh...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (value) => orderService.setCustomerNote(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCalculation(OrderService orderService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalculationRow('Tạm tính:', orderService.subtotal, false),
            const SizedBox(height: 8),
            _buildCalculationRow('VAT (10%):', orderService.vatAmount, false),
            const Divider(height: 24),
            _buildCalculationRow('Tổng cộng:', orderService.total, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          VietnameseFormatter.formatCurrency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(OrderService orderService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (orderService.error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        orderService.error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _confirmOrder(orderService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Xác nhận đặt hàng',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _confirmOrder(OrderService orderService) async {
    if (_isSubmitting) return;

    // First, check for missing ingredients
    final shouldProceed = await _checkIngredientsBeforeOrder(orderService);
    if (!shouldProceed) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await orderService.submitOrder();
      
      if (success && mounted) {
        _showOrderConfirmationDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _checkIngredientsBeforeOrder(OrderService orderService) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MissingIngredientsDialog(
        orderItems: orderService.orderItems,
      ),
    );
    
    return result ?? false;
  }

  void _showOrderConfirmationDialog() {
    final orderService = context.read<OrderService>();
    final orderId = DateTime.now().millisecondsSinceEpoch.toString(); // Would be from API response
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 48,
        ),
        title: const Text('Đặt hàng thành công!'),
        content: const Text(
          'Đơn hàng của bạn đã được gửi đến bếp.\n'
          'Bạn có thể theo dõi tình trạng đơn hàng trong màn hình tiếp theo.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OrderTrackingScreen(orderId: orderId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Theo dõi đơn hàng'),
          ),
        ],
      ),
    );
  }

  void _showItemOptionsModal(OrderService orderService, int index, OrderItem item) {
    final noteController = TextEditingController(text: item.notes);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.menuItemName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ghi chú cho món này:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Không cay, ít muối...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        orderService.removeItem(index);
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Xóa món'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        orderService.updateItemNotes(index, noteController.text);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cập nhật'),
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