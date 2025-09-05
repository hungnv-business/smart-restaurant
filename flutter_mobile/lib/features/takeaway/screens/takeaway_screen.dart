import 'package:flutter/material.dart';

/// Màn hình Mang về
class TakeawayScreen extends StatefulWidget {
  const TakeawayScreen({Key? key}) : super(key: key);

  @override
  State<TakeawayScreen> createState() => _TakeawayScreenState();
}

class _TakeawayScreenState extends State<TakeawayScreen> {
  final List<Map<String, dynamic>> _takeawayOrders = [
    {
      'id': 'TW001',
      'customerName': 'Nguyễn Văn A',
      'phone': '0901234567',
      'items': ['Phở Bò Tái', 'Cà phê sữa đá'],
      'total': '110.000₫',
      'pickupTime': '14:30',
      'status': 'Đang chuẩn bị',
      'orderTime': '13:45',
    },
    {
      'id': 'TW002',
      'customerName': 'Trần Thị B',
      'phone': '0987654321',
      'items': ['Cơm tấm', 'Nước mía'],
      'total': '80.000₫',
      'pickupTime': '15:00',
      'status': 'Sẵn sàng',
      'orderTime': '14:15',
    },
    {
      'id': 'TW003',
      'customerName': 'Lê Văn C',
      'phone': '0912345678',
      'items': ['Bánh mì thịt nướng', 'Bánh flan'],
      'total': '70.000₫',
      'pickupTime': '15:15',
      'status': 'Đã giao',
      'orderTime': '14:30',
    },
  ];

  String _selectedStatus = 'Tất cả';
  final List<String> _statusFilters = [
    'Tất cả',
    'Đang chuẩn bị',
    'Sẵn sàng',
    'Đã giao',
  ];

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
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getFilteredOrders().length,
              itemBuilder: (context, index) {
                final order = _getFilteredOrders()[index];
                return _buildOrderCard(context, order);
              },
            ),
          ),
        ],
      ),
      
      // Nút thêm đơn hàng mới
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewOrderDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredOrders() {
    if (_selectedStatus == 'Tất cả') {
      return _takeawayOrders;
    }
    return _takeawayOrders.where((order) => order['status'] == _selectedStatus).toList();
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    Color statusColor;
    IconData statusIcon;
    
    switch (order['status']) {
      case 'Đang chuẩn bị':
        statusColor = Colors.orange;
        statusIcon = Icons.restaurant;
        break;
      case 'Sẵn sàng':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Đã giao':
        statusColor = Colors.grey;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
    }

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
                Text(
                  order['id'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        order['status'],
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
                Text(order['customerName']),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(order['phone']),
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
                    order['items'].join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            
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
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Nhận: ${order['pickupTime']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Đặt: ${order['orderTime']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  order['total'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Actions
            if (order['status'] == 'Đang chuẩn bị' || order['status'] == 'Sẵn sàng')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order['status'] == 'Đang chuẩn bị')
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            order['status'] = 'Sẵn sàng';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đơn ${order['id']} đã sẵn sàng')),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Hoàn thành'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (order['status'] == 'Sẵn sàng')
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            order['status'] = 'Đã giao';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã giao đơn ${order['id']}')),
                          );
                        },
                        icon: const Icon(Icons.done_all),
                        label: const Text('Đã giao'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNewOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm đơn mang về'),
        content: const Text('Chức năng thêm đơn hàng mang về đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}