import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_models.dart';
import '../services/order_tracking_service.dart';
import '../widgets/kitchen_integration_widget.dart';
import '../screens/order_tracking_screen.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/constants/app_colors.dart';

class WaitstaffDashboardWidget extends StatefulWidget {
  const WaitstaffDashboardWidget({super.key});

  @override
  State<WaitstaffDashboardWidget> createState() => _WaitstaffDashboardWidgetState();
}

class _WaitstaffDashboardWidgetState extends State<WaitstaffDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Order> _activeOrders = [];
  final List<Order> _readyOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    // Mock active orders
    _activeOrders.addAll([
      Order(
        id: 'order-1',
        orderNumber: 'DH040915001',
        orderType: OrderType.dineIn,
        tableId: 'T03',
        status: OrderStatus.preparing,
        totalAmount: 195000,
        notes: 'Phục vụ nhanh',
        items: [
          OrderItem(
            id: '1',
            orderId: 'order-1',
            menuItemId: 'pho-bo-tai',
            menuItemName: 'Phở Bò Tái',
            unitPrice: 65000,
            quantity: 2,
            notes: 'Ít hành',
            status: OrderItemStatus.preparing,
          ),
          OrderItem(
            id: '2',
            orderId: 'order-1',
            menuItemId: 'com-tam',
            menuItemName: 'Cơm Tấm',
            unitPrice: 55000,
            quantity: 1,
            notes: null,
            status: OrderItemStatus.preparing,
          ),
        ],
        creationTime: now.subtract(const Duration(minutes: 15)),
      ),
      Order(
        id: 'order-2',
        orderNumber: 'DH040915002',
        orderType: OrderType.takeaway,
        status: OrderStatus.confirmed,
        totalAmount: 125000,
        items: [
          OrderItem(
            id: '3',
            orderId: 'order-2',
            menuItemId: 'bun-bo-hue',
            menuItemName: 'Bún Bò Huế',
            unitPrice: 70000,
            quantity: 1,
            status: OrderItemStatus.pending,
          ),
          OrderItem(
            id: '4',
            orderId: 'order-2',
            menuItemId: 'ca-phe-sua',
            menuItemName: 'Cà Phê Sữa',
            unitPrice: 30000,
            quantity: 1,
            status: OrderItemStatus.pending,
          ),
        ],
        creationTime: now.subtract(const Duration(minutes: 5)),
      ),
    ]);
    
    // Mock ready orders
    _readyOrders.addAll([
      Order(
        id: 'order-3',
        orderNumber: 'DH040915000',
        orderType: OrderType.dineIn,
        tableId: 'T01',
        status: OrderStatus.ready,
        totalAmount: 165000,
        items: [
          OrderItem(
            id: '5',
            orderId: 'order-3',
            menuItemId: 'com-ga-nuong',
            menuItemName: 'Cơm Gà Nướng',
            unitPrice: 65000,
            quantity: 1,
            status: OrderItemStatus.ready,
          ),
          OrderItem(
            id: '6',
            orderId: 'order-3',
            menuItemId: 'ca-phe-den',
            menuItemName: 'Cà Phê Đen',
            unitPrice: 25000,
            quantity: 2,
            status: OrderItemStatus.ready,
          ),
        ],
        creationTime: now.subtract(const Duration(minutes: 25)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển nhân viên'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Đang xử lý',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Sẵn sàng',
            ),
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Thông báo',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrdersTab(),
          _buildReadyOrdersTab(),
          const KitchenIntegrationWidget(),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    if (_activeOrders.isEmpty) {
      return _buildEmptyState(
        Icons.schedule,
        'Không có đơn hàng đang xử lý',
        'Các đơn hàng mới sẽ xuất hiện ở đây',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeOrders.length,
      itemBuilder: (context, index) {
        final order = _activeOrders[index];
        return _buildOrderCard(order, false);
      },
    );
  }

  Widget _buildReadyOrdersTab() {
    if (_readyOrders.isEmpty) {
      return _buildEmptyState(
        Icons.restaurant_menu,
        'Không có món nào sẵn sàng',
        'Món ăn sẵn sàng để phục vụ sẽ xuất hiện ở đây',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readyOrders.length,
      itemBuilder: (context, index) {
        final order = _readyOrders[index];
        return _buildOrderCard(order, true);
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isReady) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isReady ? 4 : 2,
      color: isReady ? Colors.green.shade50 : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToOrderTracking(order.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              order.orderType == OrderType.dineIn 
                                  ? Icons.restaurant 
                                  : Icons.takeout_dining,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.orderType.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (order.tableId != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.table_restaurant,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bàn ${order.tableId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(order.status, isReady),
                      const SizedBox(height: 4),
                      Text(
                        VietnameseFormatter.formatCurrency(order.totalAmount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Order items preview
              Text(
                'Món ăn (${order.items.length} món):',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.items.map((item) => '${item.quantity}x ${item.menuItemName}').join(', '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    VietnameseFormatter.formatTimeAgo(order.creationTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (isReady)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'CẦN PHỤC VỤ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
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

  Widget _buildStatusChip(OrderStatus status, bool isReady) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (isReady) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle;
    } else {
      switch (status) {
        case OrderStatus.pending:
          backgroundColor = Colors.orange.shade100;
          textColor = Colors.orange.shade700;
          icon = Icons.schedule;
          break;
        case OrderStatus.confirmed:
          backgroundColor = Colors.blue.shade100;
          textColor = Colors.blue.shade700;
          icon = Icons.check_circle_outline;
          break;
        case OrderStatus.preparing:
          backgroundColor = Colors.amber.shade100;
          textColor = Colors.amber.shade700;
          icon = Icons.restaurant;
          break;
        default:
          backgroundColor = Colors.grey.shade100;
          textColor = Colors.grey.shade700;
          icon = Icons.help_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderTracking(String orderId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: orderId),
      ),
    );
  }
}