import 'package:flutter/material.dart';
import 'package:flutter_mobile/core/models/order/takeaway_models.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/services/order/shared_order_service.dart';
import '../widgets/takeaway_order_dialog.dart';
import '../../order/screens/table_detail_screen.dart';

/// Màn hình Mang về
class TakeawayScreen extends StatefulWidget {
  const TakeawayScreen({Key? key}) : super(key: key);

  @override
  State<TakeawayScreen> createState() => _TakeawayScreenState();
}

class _TakeawayScreenState extends State<TakeawayScreen> {
  TakeawayStatus? _selectedStatus;
  final List<TakeawayStatus?> _statusFilters = [
    null, // Tất cả
    TakeawayStatus.preparing,
    TakeawayStatus.ready,
    TakeawayStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTakeawayOrders();
    });
  }

  Future<void> _loadTakeawayOrders() async {
    try {
      final sharedOrderService = Provider.of<SharedOrderService>(
        context,
        listen: false,
      );
      await sharedOrderService.loadTakeawayOrders(
        statusFilter: _selectedStatus,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải đơn mang về: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header với bộ lọc trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng mang về',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Bộ lọc trạng thái
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = status == _selectedStatus;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status?.displayName ?? 'Tất cả'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                            _loadTakeawayOrders();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Danh sách đơn hàng
          Expanded(
            child: Consumer<SharedOrderService>(
              builder: (context, sharedOrderService, child) {
                if (sharedOrderService.isLoadingTakeaway) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = sharedOrderService.getFilteredTakeawayOrders(
                  _selectedStatus,
                );
                if (orders.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng mang về'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(context, order);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Nút thêm đơn hàng mới
      floatingActionButton: FloatingActionButton(
        heroTag: "takeaway_add_order",
        onPressed: () {
          _showNewOrderDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Removed _getFilteredOrders - now using SharedOrderService.getFilteredTakeawayOrders

  IconData _getStatusIcon(TakeawayStatus status) {
    switch (status) {
      case TakeawayStatus.preparing:
        return Icons.restaurant;
      case TakeawayStatus.ready:
        return Icons.check_circle;
      case TakeawayStatus.delivered:
        return Icons.done_all;
    }
  }

  Widget _buildOrderCard(BuildContext context, TakeawayOrderDto order) {
    final Color statusColor = Color(order.status.colorValue);
    final IconData statusIcon = _getStatusIcon(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với mã đơn và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Thông tin khách hàng
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    order.customerName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    order.customerPhone,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Món ăn
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.restaurant_menu, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.items.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            // Ghi chú (nếu có)
            if (order.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sticky_note_2,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Thời gian và tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Thanh toán: ${order.formattedPaymentTime}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đặt: ${order.orderTime}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  order.formattedTotal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Actions
            if (order.status == TakeawayStatus.preparing ||
                order.status == TakeawayStatus.ready)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút chỉnh sửa (chỉ hiển thị khi đang chuẩn bị)
                    if (order.status == TakeawayStatus.preparing)
                      OutlinedButton.icon(
                        onPressed: () => _showEditOrderScreen(context, order),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Sửa đơn'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Nút trạng thái - chỉ hiển thị nút delivered cho status ready
                    Row(
                      children: [
                        if (order.status == TakeawayStatus.ready)
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final sharedOrderService =
                                    Provider.of<SharedOrderService>(
                                      context,
                                      listen: false,
                                    );
                                await sharedOrderService
                                    .updateTakeawayOrderStatus(
                                      orderId: order.id,
                                      newStatus: TakeawayStatus.delivered,
                                    );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã giao đơn ${order.orderNumber}',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.done_all),
                            label: Text(TakeawayStatus.delivered.displayName),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNewOrderDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const TakeawayOrderDialog(),
    );

    // Nếu tạo đơn thành công, refresh danh sách
    if (result == true) {
      _loadTakeawayOrders();
    }
  }

  void _showEditOrderScreen(
    BuildContext context,
    TakeawayOrderDto order,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TableDetailScreen(takeawayOrder: order, isForTakeaway: true),
      ),
    );

    // Nếu có thay đổi, refresh danh sách
    if (result == true && mounted) {
      _loadTakeawayOrders();
    }
  }
}
