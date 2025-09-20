import 'package:flutter/material.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/table_models.dart';
import '../../../core/utils/price_formatter.dart';

/// Widget dialog hiển thị giỏ hàng
class CartDialog extends StatefulWidget {
  final ActiveTableDto? selectedTable;
  final List<MenuItem> cartItems;
  final List<int> cartItemQuantities;
  final Function(int index) onIncreaseQuantity;
  final Function(int index) onDecreaseQuantity;
  final VoidCallback onClearCart;
  final VoidCallback onSubmitOrder;
  final Function(int index, String note)? onUpdateNote;
  final bool hasActiveOrder;
  final bool isForTakeaway;

  const CartDialog({
    Key? key,
    this.selectedTable,
    required this.cartItems,
    required this.cartItemQuantities,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onClearCart,
    required this.onSubmitOrder,
    this.onUpdateNote,
    this.hasActiveOrder = false,
    this.isForTakeaway = false,
  }) : super(key: key);

  @override
  State<CartDialog> createState() => _CartDialogState();
}

class _CartDialogState extends State<CartDialog> {
  late List<String> itemNotes;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách ghi chú cho từng món
    itemNotes = List.generate(
      widget.cartItems.length.clamp(0, widget.cartItems.length), 
      (index) => ''
    );
  }

  @override
  void didUpdateWidget(CartDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật itemNotes khi widget thay đổi
    if (widget.cartItems.length != itemNotes.length) {
      final newLength = widget.cartItems.length;
      if (newLength > itemNotes.length) {
        // Thêm notes mới
        itemNotes.addAll(List.generate(newLength - itemNotes.length, (_) => ''));
      } else if (newLength < itemNotes.length) {
        // Cắt bớt notes thừa
        itemNotes = itemNotes.take(newLength).toList();
      }
    }
  }

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
                    widget.isForTakeaway 
                        ? 'Giỏ hàng - Mang về'
                        : 'Giỏ hàng - ${widget.selectedTable?.tableNumber ?? ""}',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tên món và điều chỉnh số lượng
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cartItems[index].name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PriceFormatter.format(widget.cartItems[index].price),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Container(
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
                        if (index >= 0 && index < widget.cartItems.length) {
                          widget.onDecreaseQuantity(index);
                        }
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
                        '${widget.cartItemQuantities.isNotEmpty && index < widget.cartItemQuantities.length ? widget.cartItemQuantities[index] : 0}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (index >= 0 && index < widget.cartItems.length) {
                          widget.onIncreaseQuantity(index);
                        }
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
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Ghi chú
          Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ghi chú cho món này...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  onChanged: (value) {
                    if (index < itemNotes.length) {
                      setState(() {
                        itemNotes[index] = value;
                      });
                      widget.onUpdateNote?.call(index, value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
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
                  child: Text(widget.hasActiveOrder ? 'Thêm món' : 'Gửi đơn'),
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