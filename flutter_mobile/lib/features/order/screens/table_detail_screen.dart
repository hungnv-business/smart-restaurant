import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/network_thermal_printer_service.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../widgets/order_item_card.dart';
import '../widgets/edit_quantity_dialog.dart';
import '../../../core/utils/price_formatter.dart';
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
  TableDetailDto? _tableDetail;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadTableDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTableDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final orderService = Provider.of<OrderService>(context, listen: false);
      final tableDetail = await orderService.getTableDetails(widget.table.id);
      
      setState(() {
        _tableDetail = tableDetail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải chi tiết bàn: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Bàn ${widget.table.tableNumber}',
        actions: [
          IconButton(
            onPressed: _canPrintInvoice() ? _printInvoice : null,
            icon: Icon(
              Icons.print,
              color: _canPrintInvoice() ? null : Colors.grey,
            ),
            tooltip: _canPrintInvoice() 
                ? 'In hóa đơn' 
                : 'Không có món nào đã phục vụ',
          ),
          IconButton(
            onPressed: () => _loadTableDetails(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTableDetails,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_tableDetail == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return Column(
      children: [
        _buildTableHeader(),
        _buildOrderSummary(),
        Expanded(child: _buildOrderItemsList()),
      ],
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
    final summary = _tableDetail?.orderSummary;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Tổng quan đơn hàng',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          if (summary != null) ...[
            // Order stats cùng 1 hàng
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tổng số món',
                    '${summary.totalItemsCount} món',
                    Icons.list_alt,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    'Món chờ phục vụ',
                    '${summary.pendingServeCount} món',
                    Icons.schedule,
                    summary.pendingServeCount > 0 ? Colors.orange : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    'Tổng tiền',
                    PriceFormatter.format(summary.totalAmount.toInt()),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ] else ...[
            // No order data
            Center(
              child: Text(
                'Chưa có đơn hàng',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOrderItemsList() {
    final orderItems = _tableDetail?.orderItems ?? [];
    
    if (orderItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có món nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn "Thêm món" để bắt đầu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // Giảm padding top/bottom
      itemCount: orderItems.length,
      itemBuilder: (context, index) {
        final item = orderItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8), // Giảm khoảng cách giữa các item
          child: _buildOrderItemCard(item, index),
        );
      },
    );
  }

  Widget _buildOrderItemCard(TableOrderItemDto item, int index) {
    // Tạo displayMessage từ danh sách missingIngredients
    String? missingMessage;
    if (item.missingIngredients.isNotEmpty) {
      final messages = item.missingIngredients.map((ingredient) => ingredient.displayMessage).toList();
      missingMessage = messages.join(', ');
    }
    
    return OrderItemCard(
      itemName: item.menuItemName,
      quantity: item.quantity,
      unitPrice: item.unitPrice.toInt(),
      status: item.status,
      totalPrice: PriceFormatter.format(item.totalPrice.toInt()),
      specialRequest: item.specialRequest,
      hasMissingIngredients: item.hasMissingIngredients,
      missingIngredientsMessage: missingMessage,
      requiresCooking: item.requiresCooking,
      onEdit: item.canEdit ? () => _editOrderItem(index) : null,
      onRemove: item.canDelete ? () => _removeOrderItem(index) : null,
      onServe: item.status == OrderItemStatus.ready ? () => _markOrderItemServed(item.id) : null,
    );
  }


  Widget _buildBottomActions() {
    // Kiểm tra xem có thể thanh toán không
    bool canPayment = false;
    String? paymentDisabledReason;
    
    if (_tableDetail?.orderSummary != null && _tableDetail!.orderItems.isNotEmpty) {
      final orderItems = _tableDetail!.orderItems;
      
      // Kiểm tra các món chưa ở trạng thái "đã phục vụ" hoặc "cancel"
      final nonCompletedItems = orderItems.where((item) => 
        item.status != OrderItemStatus.served && 
        item.status != OrderItemStatus.canceled
      ).toList();
      
      if (nonCompletedItems.isEmpty) {
        canPayment = true;
      } else {
        paymentDisabledReason = '${nonCompletedItems.length} món chưa phục vụ';
      }
    }
    
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
          
          const SizedBox(width: 8),
          
          
          // Nút thanh toán (nếu có đơn hàng)
          if (_tableDetail?.orderSummary != null && _tableDetail!.orderItems.isNotEmpty)
            Expanded(
              child: OutlinedButton(
                onPressed: canPayment ? _showPaymentOptions : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  side: BorderSide(
                    color: canPayment 
                        ? Theme.of(context).colorScheme.outline
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canPayment ? Icons.credit_card : Icons.schedule,
                      size: 16,
                      color: canPayment ? null : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        canPayment ? 'Thanh toán' : paymentDisabledReason ?? 'Thanh toán',
                        style: TextStyle(
                          color: canPayment ? null : Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToMenu() async {
    // Kiểm tra bàn đã có order chưa
    final hasActiveOrder = _tableDetail?.orderSummary != null && _tableDetail!.orderItems.isNotEmpty;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          selectedTable: widget.table,
          hasActiveOrder: hasActiveOrder,
          currentOrderId: _tableDetail?.orderId, // Lấy orderId từ TableDetailDto
        ),
      ),
    );
    
    // Nếu có thay đổi (tạo đơn hàng hoặc thêm món), pop về OrderScreen
    if (result == true && mounted) {
      Navigator.of(context).pop(true); // Trả về result cho TableCard
    }
  }

  /// Kiểm tra xem có thể in hóa đơn không (có món đã phục vụ)
  bool _canPrintInvoice() {
    if (_tableDetail == null) return false;
    
    final servedItems = _tableDetail!.orderItems.where((item) => 
      item.status == OrderItemStatus.served
    ).toList();
    
    return servedItems.isNotEmpty;
  }

  void _printInvoice() async {
    if (_tableDetail == null) return;
    
    // Kiểm tra lại có món đã phục vụ không
    if (!_canPrintInvoice()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có món nào đã phục vụ để in hóa đơn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // In hóa đơn trực tiếp từ mobile
      await _printInvoiceLocally();

      // Đóng loading
      if (mounted) Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppTexts.printSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Đóng loading
      if (mounted) Navigator.of(context).pop();

      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi in hóa đơn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printInvoiceLocally() async {
    if (_tableDetail == null) return;

    try {
      final networkPrinter = NetworkThermalPrinterService();
      
      // Khởi tạo service
      await networkPrinter.initialize();
      
      // Kiểm tra kết nối hiện tại
      bool isConnected = await networkPrinter.checkConnection();
      
      if (!isConnected) {
        // Hiển thị dialog hỏi cấu hình máy in
        await _showPrinterConfigurationDialog();
        
        // Kiểm tra lại kết nối sau khi cấu hình
        isConnected = await networkPrinter.checkConnection();
        if (!isConnected) {
          throw Exception('Chưa cấu hình kết nối với máy in Xprinter T80W');
        }
      }
      
      // In hóa đơn
      await networkPrinter.printInvoice(_tableDetail!);
      
    } catch (e) {
      rethrow; // Để _printInvoice() xử lý error
    }
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
              leading: const Icon(Icons.qr_code, color: Colors.orange),
              title: Text(PaymentMethod.transfer.displayName),
              onTap: () {
                Navigator.pop(context);
                _showPaymentConfirmation(PaymentMethod.transfer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: Text(PaymentMethod.cash.displayName),
              onTap: () {
                Navigator.pop(context);
                _showPaymentConfirmation(PaymentMethod.cash);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_off, color: Colors.red),
              title: Text(PaymentMethod.debt.displayName),
              onTap: () {
                Navigator.pop(context);
                _showPaymentConfirmation(PaymentMethod.debt);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentConfirmation(PaymentMethod method) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final totalAmount = _tableDetail?.orderSummary?.totalAmount?.toInt() ?? 0;
    
    // Tự động điền số tiền cần thanh toán với format
    amountController.text = totalAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận thanh toán - ${method.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị tổng tiền cần thanh toán
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền cần thanh toán:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      PriceFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Ô nhập số tiền khách trả
              const Text(
                'Số tiền khách trả:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập số tiền...',
                  suffixText: '₫',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Ô nhập ghi chú
              const Text(
                'Ghi chú (không bắt buộc):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập ghi chú...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amountText = amountController.text.trim();
              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập số tiền'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              // Remove dots for parsing
              final cleanAmountText = amountText.replaceAll('.', '');
              final amount = int.tryParse(cleanAmountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Số tiền không hợp lệ'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              _processPayment(method, amount, noteController.text.trim());
            },
            child: const Text('Xác nhận thanh toán'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(PaymentMethod method, int paidAmount, String note) async {
    final orderId = _tableDetail?.orderId;
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.orderIdNotFound),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call API
      final orderService = Provider.of<OrderService>(context, listen: false);
      await orderService.processPayment(
        orderId: orderId,
        paymentMethod: method,
        customerMoney: paidAmount,
        notes: note.isNotEmpty ? note : null,
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success message with details
      final totalAmount = _tableDetail?.orderSummary?.totalAmount?.toInt() ?? 0;
      final changeAmount = paidAmount - totalAmount;
      
      String message = '✅ Thanh toán thành công!\n';
      message += 'Phương thức: ${method.displayName}\n';
      message += 'Số tiền: ${PriceFormatter.format(paidAmount)}';
      
      if (changeAmount > 0) {
        message += '\nTiền thừa: ${PriceFormatter.format(changeAmount)}';
      }
      
      if (note.isNotEmpty) {
        message += '\nGhi chú: $note';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Trở về màn hình order_screen.dart như khi đặt hàng thành công
        Navigator.of(context).pop(true); // Trả về result cho OrderScreen
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi thanh toán: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _processPayment(method, paidAmount, note),
            ),
          ),
        );
      }
    }
  }

  void _editOrderItem(int index) {
    if (_tableDetail == null || 
        _tableDetail!.orderItems.isEmpty || 
        index < 0 || 
        index >= _tableDetail!.orderItems.length) {
      return;
    }

    final orderItem = _tableDetail!.orderItems[index];
    _showEditQuantityDialog(orderItem, index);
  }

  /// Đánh dấu món đã phục vụ
  void _markOrderItemServed(String orderItemId) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final orderService = Provider.of<OrderService>(context, listen: false);
      await orderService.markOrderItemServed(orderItemId);

      // Đóng loading dialog
      if (mounted) Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã đánh dấu món phục vụ thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Reload dữ liệu
      await _loadTableDetails();
    } catch (e) {
      // Đóng loading dialog nếu vẫn mở
      if (mounted) Navigator.of(context).pop();

      // Hiển thị lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi đánh dấu phục vụ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Hiển thị dialog sửa số lượng món
  void _showEditQuantityDialog(TableOrderItemDto orderItem, int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditQuantityDialog(
        itemName: orderItem.menuItemName,
        currentQuantity: orderItem.quantity,
        unitPrice: orderItem.unitPrice.toInt(),
        currentNotes: orderItem.specialRequest,
      ),
    );

    if (result != null && mounted) {
      final newQuantity = result['quantity'] as int;
      final notes = result['notes'] as String?;
      
      if (newQuantity != orderItem.quantity) {
        _performUpdateOrderItemQuantity(orderItem, newQuantity, index, notes);
      }
    }
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
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performRemoveOrderItem(index);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Thực hiện cập nhật số lượng món
  Future<void> _performUpdateOrderItemQuantity(TableOrderItemDto orderItem, int newQuantity, int index, [String? notes]) async {
    final orderId = _tableDetail?.orderId;
    
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.orderInfoNotFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Gọi API cập nhật số lượng
      final orderService = Provider.of<OrderService>(context, listen: false);
      await orderService.updateOrderItemQuantity(orderId, orderItem.id, newQuantity, notes: notes);
      
      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Đã cập nhật số lượng ${orderItem.menuItemName} '
              'từ ${orderItem.quantity} thành $newQuantity',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reload dữ liệu để cập nhật giao diện
        await _loadTableDetails();
      }
    } catch (e) {
      // Hiển thị thông báo lỗi hoặc thông tin API chưa được implement
      if (mounted) {
        final isApiNotImplemented = e.toString().contains('API_NOT_IMPLEMENTED');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApiNotImplemented 
                ? '🚧 ${e.toString().split(': ').last}' 
                : '❌ Lỗi cập nhật số lượng: ${e.toString()}'
            ),
            backgroundColor: isApiNotImplemented ? Colors.orange : Colors.red,
            duration: Duration(seconds: isApiNotImplemented ? 4 : 3),
            action: !isApiNotImplemented ? SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _performUpdateOrderItemQuantity(orderItem, newQuantity, index),
            ) : null,
          ),
        );
      }
    }
  }

  /// Thực hiện xóa món khỏi order
  Future<void> _performRemoveOrderItem(int index) async {
    if (_tableDetail == null || 
        _tableDetail!.orderItems.isEmpty || 
        index < 0 || 
        index >= _tableDetail!.orderItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.orderItemNotFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final orderItem = _tableDetail!.orderItems[index];
    final orderId = _tableDetail!.orderId;
    
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.orderInfoNotFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Gọi API xóa món
      final orderService = Provider.of<OrderService>(context, listen: false);
      await orderService.removeOrderItem(orderId, orderItem.id);
      
      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã xóa ${orderItem.menuItemName} khỏi đơn hàng'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Reload dữ liệu để cập nhật giao diện
        await _loadTableDetails();
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi xóa món: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _performRemoveOrderItem(index),
            ),
          ),
        );
      }
    }
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
            _buildInfoRow('Có đơn hàng', (_tableDetail?.orderSummary != null && _tableDetail!.orderItems.isNotEmpty) ? 'Có' : 'Không'),
            _buildInfoRow('Món chờ phục vụ', '$_tableDetail?.orderSummary?.pendingServeCount ?? 0'),
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

  Future<void> _showPrinterConfigurationDialog() async {
    final shouldConfigure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cấu hình máy in'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chưa kết nối với máy in Xprinter T80W.'),
            SizedBox(height: 8),
            Text('Bạn có muốn cấu hình kết nối WiFi không?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cấu hình'),
          ),
        ],
      ),
    );
    
    if (shouldConfigure == true) {
      // Hiển thị thông báo tạm thời
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chức năng cấu hình máy in sẽ được thêm sau'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

/// Custom TextInputFormatter để thêm dấu chấm ngăn cách hàng nghìn
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all dots first
    String digits = newValue.text.replaceAll('.', '');
    
    // Add dots as thousands separators
    String formatted = '';
    for (int i = digits.length - 1; i >= 0; i--) {
      formatted = digits[i] + formatted;
      if ((digits.length - i) % 3 == 0 && i != 0) {
        formatted = '.$formatted';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}