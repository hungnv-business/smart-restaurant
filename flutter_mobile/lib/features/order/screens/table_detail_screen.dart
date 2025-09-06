import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../widgets/order_item_card.dart';
import 'menu_screen.dart';

/// Màn hình chi tiết order của một bàn cụ thể
class TableDetailScreen extends StatefulWidget {
  final ActiveTableDto table;

  const TableDetailScreen({
    Key? key,
    required this.table,
  }) : super(key: key);

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Bàn ${widget.table.tableNumber}',
        actions: [
          IconButton(
            onPressed: _showTableInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin bàn',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTableHeader(),
          _buildOrderSummary(),
          Expanded(child: _buildOrderItemsList()),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Table icon và số bàn
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(widget.table.status.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(widget.table.status.colorValue),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.table_restaurant,
              size: 30,
              color: Color(widget.table.status.colorValue),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Thông tin bàn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bàn ${widget.table.tableNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.table.layoutSectionName != null)
                  Text(
                    'Khu vực: ${widget.table.layoutSectionName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                _buildStatusChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(widget.table.status.colorValue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.table.status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng quan đơn hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Order stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Trạng thái',
                  widget.table.hasActiveOrders ? 'Có đơn hàng' : 'Chưa có đơn hàng',
                  widget.table.hasActiveOrders ? Icons.restaurant_menu : Icons.add_circle_outline,
                  widget.table.hasActiveOrders ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Món chờ phục vụ',
                  '${widget.table.pendingServeOrdersCount} món',
                  Icons.schedule,
                  widget.table.pendingServeOrdersCount > 0 ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    // TODO: Implement actual order items from API
    // Hiện tại hiển thị placeholder
    if (!widget.table.hasActiveOrders) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có món nào được gọi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn "Thêm món" để bắt đầu gọi món',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Placeholder cho danh sách món đã gọi
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Placeholder items
      itemBuilder: (context, index) {
        return _buildOrderItemCard(index);
      },
    );
  }

  Widget _buildOrderItemCard(int index) {
    // Placeholder data
    final items = [
      {'name': 'Phở Bò Tái', 'quantity': 2, 'price': 45000, 'status': 'Đang chuẩn bị'},
      {'name': 'Cơm Tấm Sườn', 'quantity': 1, 'price': 35000, 'status': 'Đã phục vụ'},
      {'name': 'Trà Đá', 'quantity': 3, 'price': 5000, 'status': 'Chờ chuẩn bị'},
    ];

    final item = items[index];
    
    return OrderItemCard(
      itemName: item['name'] as String,
      quantity: item['quantity'] as int,
      unitPrice: item['price'] as int,
      status: item['status'] as String,
      onEdit: item['status'] == 'Chờ chuẩn bị' ? () => _editOrderItem(index) : null,
      onRemove: item['status'] == 'Chờ chuẩn bị' ? () => _removeOrderItem(index) : null,
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút thêm món
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _navigateToMenu,
              icon: const Icon(Icons.add),
              label: const Text('Thêm món'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Nút thanh toán (nếu có đơn hàng)
          if (widget.table.hasActiveOrders)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showPaymentOptions,
                icon: const Icon(Icons.payment),
                label: const Text('Thanh toán'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToMenu() {
    final tableModel = TableModel.fromActiveTable(widget.table);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(selectedTable: tableModel),
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thanh toán',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Tiền mặt'),
              onTap: () {
                Navigator.pop(context);
                _processPayment('cash');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Thẻ tín dụng'),
              onTap: () {
                Navigator.pop(context);
                _processPayment('card');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.orange),
              title: const Text('Chuyển khoản QR'),
              onTap: () {
                Navigator.pop(context);
                _processPayment('qr');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(String method) {
    // TODO: Implement payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang xử lý thanh toán bằng $method...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editOrderItem(int index) {
    // TODO: Implement edit order item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chỉnh sửa món thứ ${index + 1}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeOrderItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa món'),
        content: const Text('Bạn có chắc chắn muốn xóa món này khỏi đơn hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement remove order item
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa món thứ ${index + 1}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showTableInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông tin bàn ${widget.table.tableNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Số bàn', widget.table.tableNumber),
            _buildInfoRow('Khu vực', widget.table.layoutSectionName ?? 'Không có'),
            _buildInfoRow('Trạng thái', widget.table.status.displayName),
            _buildInfoRow('Có đơn hàng', widget.table.hasActiveOrders ? 'Có' : 'Không'),
            _buildInfoRow('Món chờ phục vụ', '${widget.table.pendingServeOrdersCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}