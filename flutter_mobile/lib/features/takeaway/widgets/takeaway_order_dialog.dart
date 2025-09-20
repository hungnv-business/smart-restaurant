import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/order_request_models.dart';
import '../../../core/services/shared_order_service.dart';
import '../../order/screens/menu_screen.dart';

/// Dialog để tạo đơn hàng takeaway với form nhập thông tin khách hàng
class TakeawayOrderDialog extends StatefulWidget {
  const TakeawayOrderDialog({super.key});

  @override
  State<TakeawayOrderDialog> createState() => _TakeawayOrderDialogState();
}

class _TakeawayOrderDialogState extends State<TakeawayOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<CreateOrderItemDto> _selectedItems = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectMenuItems() async {
    final result = await Navigator.of(context).push<List<CreateOrderItemDto>>(
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          // Không có tableId cho takeaway
          tableId: null,
          isForTakeaway: true,
          initialSelectedItems: _selectedItems,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedItems = result;
      });
    }
  }

  Future<void> _createTakeawayOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một món')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sharedOrderService = Provider.of<SharedOrderService>(context, listen: false);
      
      await sharedOrderService.createOrder(
        orderType: OrderType.takeaway,
        tableId: null, // Không có tableId cho takeaway
        orderItems: _selectedItems,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
      );

      if (mounted) {
        // Refresh takeaway orders list
        await sharedOrderService.loadTakeawayOrders();
        
        Navigator.of(context).pop(true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo đơn mang về thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo đơn hàng: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}₫';
  }

  int get _totalAmount {
    return _selectedItems.fold<int>(
      0, 
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tạo đơn mang về',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form thông tin khách hàng
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin khách hàng
                    Text(
                      'Thông tin khách hàng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tên khách hàng
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên khách hàng *',
                        hintText: 'Nhập tên khách hàng',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên khách hàng';
                        }
                        if (value.trim().length < 2) {
                          return 'Tên khách hàng phải có ít nhất 2 ký tự';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Số điện thoại
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại *',
                        hintText: 'Nhập số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        final phoneRegex = RegExp(r'^(0|84)[3|5|7|8|9][0-9]{8}$');
                        if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Món ăn đã chọn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Món ăn đã chọn (${_selectedItems.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectMenuItems,
                          icon: const Icon(Icons.add),
                          label: const Text('Chọn món'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Danh sách món đã chọn
                    Expanded(
                      child: _selectedItems.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Chưa chọn món nào\nBấm "Chọn món" để thêm',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.separated(
                                itemCount: _selectedItems.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = _selectedItems[index];
                                  return ListTile(
                                    title: Text(item.menuItemName),
                                    subtitle: Text(_formatCurrency(item.unitPrice)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'x${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatCurrency(item.unitPrice * item.quantity),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ghi chú
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (tùy chọn)',
                        hintText: 'Nhập ghi chú cho đơn hàng',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tổng tiền và nút tạo đơn
                    if (_selectedItems.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _formatCurrency(_totalAmount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Nút tạo đơn
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createTakeawayOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Tạo đơn mang về',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}