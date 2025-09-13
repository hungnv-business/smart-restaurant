import 'package:flutter/material.dart';

/// Màn hình Thanh toán
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final List<Map<String, dynamic>> _pendingPayments = [
    {
      'tableNumber': 'Bàn 5',
      'orderId': 'DH001',
      'items': [
        {'name': 'Phở Bò Tái', 'quantity': 2, 'price': 85000},
        {'name': 'Cà phê sữa đá', 'quantity': 2, 'price': 25000},
        {'name': 'Chè ba màu', 'quantity': 1, 'price': 30000},
      ],
      'subtotal': 250000,
      'tax': 25000,
      'total': 275000,
      'orderTime': '14:30',
      'paymentMethod': null,
    },
    {
      'tableNumber': 'Bàn 12',
      'orderId': 'DH002',
      'items': [
        {'name': 'Cơm tấm sườn', 'quantity': 1, 'price': 65000},
        {'name': 'Nước mía', 'quantity': 1, 'price': 15000},
      ],
      'subtotal': 80000,
      'tax': 8000,
      'total': 88000,
      'orderTime': '15:15',
      'paymentMethod': null,
    },
    {
      'tableNumber': 'Bàn 7',
      'orderId': 'DH003',
      'items': [
        {'name': 'Bánh mì thịt nướng', 'quantity': 3, 'price': 35000},
        {'name': 'Bánh flan', 'quantity': 2, 'price': 35000},
      ],
      'subtotal': 175000,
      'tax': 17500,
      'total': 192500,
      'orderTime': '13:45',
      'paymentMethod': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header với thống kê
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanh toán',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Thống kê nhanh
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Chờ thanh toán',
                        '${_pendingPayments.length}',
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tổng tiền',
                        _formatCurrency(_getTotalAmount()),
                        Icons.payments,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Danh sách hóa đơn chờ thanh toán
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingPayments.length,
              itemBuilder: (context, index) {
                final payment = _pendingPayments[index];
                return _buildPaymentCard(context, payment, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> payment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['tableNumber'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mã: ${payment['orderId']} • ${payment['orderTime']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(payment['total']),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Chi tiết món ăn
            ...payment['items'].map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name']} x${item['quantity']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      _formatCurrency(item['price'] * item['quantity']),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const Divider(height: 24),
            
            // Tổng kết
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính:'),
                    Text(_formatCurrency(payment['subtotal'])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thuế (10%):'),
                    Text(_formatCurrency(payment['tax'])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCurrency(payment['total']),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Nút thanh toán
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPaymentMethodDialog(context, payment),
                    icon: const Icon(Icons.payment),
                    label: const Text('Thanh toán'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBillPreview(context, payment),
                    icon: const Icon(Icons.receipt),
                    label: const Text('Xem hóa đơn'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn hình thức thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Chuyển khoản QR'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, payment, 'Chuyển khoản QR');
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Tiền mặt'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, payment, 'Tiền mặt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_off),
              title: const Text('Nợ'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, payment, 'Nợ');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, Map<String, dynamic> payment, String method) {
    // Mô phỏng xử lý thanh toán
    setState(() {
      _pendingPayments.remove(payment);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thanh toán ${payment['tableNumber']} bằng $method'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showBillPreview(BuildContext context, Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hóa đơn ${payment['tableNumber']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn: ${payment['orderId']}'),
              Text('Thời gian: ${payment['orderTime']}'),
              const Divider(),
              ...payment['items'].map<Widget>((item) {
                return Text('${item['name']} x${item['quantity']} = ${_formatCurrency(item['price'] * item['quantity'])}');
              }).toList(),
              const Divider(),
              Text('Tổng: ${_formatCurrency(payment['total'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã in hóa đơn')),
              );
            },
            child: const Text('In hóa đơn'),
          ),
        ],
      ),
    );
  }

  int _getTotalAmount() {
    return _pendingPayments.fold(0, (sum, payment) => sum + payment['total'] as int);
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫';
  }
}