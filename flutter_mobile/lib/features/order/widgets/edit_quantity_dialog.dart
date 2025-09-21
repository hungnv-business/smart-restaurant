import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog để chỉnh sửa số lượng món ăn trong order
class EditQuantityDialog extends StatefulWidget {
  final String itemName;
  final int currentQuantity;
  final int unitPrice;
  final String? currentNotes;

  const EditQuantityDialog({
    super.key,
    required this.itemName,
    required this.currentQuantity,
    required this.unitPrice,
    this.currentNotes,
  });

  @override
  State<EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<EditQuantityDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late int _quantity;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _quantity = widget.currentQuantity;
    _quantityController = TextEditingController(text: _quantity.toString());
    _notesController = TextEditingController(text: widget.currentNotes ?? '');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    setState(() {
      final newQuantity = _quantity + delta;
      if (newQuantity > 0) {
        _quantity = newQuantity;
        _quantityController.text = _quantity.toString();
        _isValid = true;
      } else {
        _isValid = false;
      }
    });
  }

  void _onQuantityChanged(String value) {
    final quantity = int.tryParse(value);
    setState(() {
      if (quantity != null && quantity > 0) {
        _quantity = quantity;
        _isValid = true;
      } else {
        _isValid = false;
      }
    });
  }

  void _onSave() {
    if (_isValid && _quantity > 0) {
      Navigator.of(context).pop({
        'quantity': _quantity,
        'notes': _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.unitPrice * _quantity;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chỉnh sửa món',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tên món ăn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.itemName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Chỉnh sửa số lượng
            Text(
              'Số lượng',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                // Nút giảm
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _quantity > 1 ? () => _updateQuantity(-1) : null,
                    icon: const Icon(Icons.remove),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Input số lượng
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onQuantityChanged,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      errorText: _isValid ? null : 'Số lượng phải > 0',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Nút tăng
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _updateQuantity(1),
                    icon: const Icon(Icons.add),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Hiển thị tổng tiền
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tổng tiền',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} ₫',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ghi chú
            Text(
              'Ghi chú (tùy chọn)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ghi chú đặc biệt cho món này...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValid ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}