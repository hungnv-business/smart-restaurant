import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_models.dart';
import '../services/ingredient_check_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/formatters.dart';

class MissingIngredientsWidget extends StatefulWidget {
  final List<OrderItem> orderItems;
  final VoidCallback? onIngredientsChecked;
  final bool autoCheck;

  const MissingIngredientsWidget({
    super.key,
    required this.orderItems,
    this.onIngredientsChecked,
    this.autoCheck = true,
  });

  @override
  State<MissingIngredientsWidget> createState() => _MissingIngredientsWidgetState();
}

class _MissingIngredientsWidgetState extends State<MissingIngredientsWidget> {
  late IngredientCheckService _ingredientService;
  List<MissingIngredient> _missingIngredients = [];
  bool _isChecking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ingredientService = context.read<IngredientCheckService>();
    
    if (widget.autoCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIngredients();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildCheckingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_missingIngredients.isEmpty) {
      return _buildAllAvailableState();
    }

    return _buildMissingIngredientsState();
  }

  Widget _buildCheckingState() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Đang kiểm tra nguyên liệu...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vui lòng chờ trong giây lát',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Không thể kiểm tra nguyên liệu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _checkIngredients,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAvailableState() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nguyên liệu đầy đủ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tất cả món ăn có thể chuẩn bị bình thường',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _checkIngredients,
              child: const Text('Kiểm tra lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingIngredientsState() {
    final criticalMissing = _missingIngredients.where((m) => !m.isOptional).toList();
    final optionalMissing = _missingIngredients.where((m) => m.isOptional).toList();

    return Column(
      children: [
        if (criticalMissing.isNotEmpty) _buildCriticalMissingCard(criticalMissing),
        if (optionalMissing.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildOptionalMissingCard(optionalMissing),
        ],
        const SizedBox(height: 16),
        _buildActionsRow(),
      ],
    );
  }

  Widget _buildCriticalMissingCard(List<MissingIngredient> missing) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nguyên liệu thiếu hụt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Các món sau không thể chuẩn bị do thiếu nguyên liệu:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ...missing.map((ingredient) => _buildMissingIngredientItem(ingredient, true)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalMissingCard(List<MissingIngredient> missing) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nguyên liệu tùy chọn thiếu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Các nguyên liệu sau có thể không có:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ...missing.map((ingredient) => _buildMissingIngredientItem(ingredient, false)),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingIngredientItem(MissingIngredient ingredient, bool isCritical) {
    final color = isCritical ? Colors.red : Colors.orange.shade700;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.close : Icons.remove,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.displayText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Tồn kho: ${ingredient.stockDisplayText}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    final hasCriticalMissing = _missingIngredients.any((m) => !m.isOptional);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _checkIngredients,
            icon: const Icon(Icons.refresh),
            label: const Text('Kiểm tra lại'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: hasCriticalMissing ? null : _proceedWithOrder,
            icon: Icon(hasCriticalMissing ? Icons.block : Icons.check),
            label: Text(hasCriticalMissing ? 'Không thể đặt hàng' : 'Tiếp tục đặt hàng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasCriticalMissing 
                  ? Colors.grey 
                  : AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkIngredients() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      final missing = await _ingredientService.checkMissingIngredients(widget.orderItems);
      
      setState(() {
        _missingIngredients = missing;
      });
      
      widget.onIngredientsChecked?.call();
      
    } catch (e) {
      setState(() {
        _error = 'Không thể kiểm tra nguyên liệu: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _proceedWithOrder() {
    final hasOptionalMissing = _missingIngredients.any((m) => m.isOptional);
    
    if (hasOptionalMissing) {
      _showOptionalMissingConfirmation();
    } else {
      Navigator.of(context).pop(true); // Proceed with order
    }
  }

  void _showOptionalMissingConfirmation() {
    final optionalMissing = _missingIngredients.where((m) => m.isOptional).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Một số nguyên liệu tùy chọn có thể không có sẵn:',
            ),
            const SizedBox(height: 8),
            ...optionalMissing.map((ingredient) => 
              Text(
                '• ${ingredient.ingredientName}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn có muốn tiếp tục đặt hàng không?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Proceed with order
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tiếp tục đặt hàng'),
          ),
        ],
      ),
    );
  }
}

class MissingIngredientsDialog extends StatelessWidget {
  final List<OrderItem> orderItems;

  const MissingIngredientsDialog({
    super.key,
    required this.orderItems,
  });

  static Future<bool?> show(BuildContext context, List<OrderItem> orderItems) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MissingIngredientsDialog(orderItems: orderItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Text('Kiểm tra nguyên liệu'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: MissingIngredientsWidget(
          orderItems: orderItems,
          autoCheck: true,
          onIngredientsChecked: () {
            // Optional callback when check completes
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy đặt hàng'),
        ),
      ],
    );
  }
}

class IngredientWarningBanner extends StatelessWidget {
  final List<MissingIngredient> missingIngredients;
  final VoidCallback? onDismissed;

  const IngredientWarningBanner({
    super.key,
    required this.missingIngredients,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    if (missingIngredients.isEmpty) return const SizedBox.shrink();

    final criticalCount = missingIngredients.where((m) => !m.isOptional).length;
    final optionalCount = missingIngredients.where((m) => m.isOptional).length;

    Color backgroundColor;
    IconData icon;
    String message;

    if (criticalCount > 0) {
      backgroundColor = Colors.red;
      icon = Icons.warning;
      message = '$criticalCount nguyên liệu quan trọng thiếu';
    } else {
      backgroundColor = Colors.orange;
      icon = Icons.info;
      message = '$optionalCount nguyên liệu tùy chọn thiếu';
    }

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showDetailDialog(context),
              child: const Text(
                'Chi tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onDismissed != null)
              IconButton(
                onPressed: onDismissed,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết nguyên liệu thiếu'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.separated(
            itemCount: missingIngredients.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final ingredient = missingIngredients[index];
              return ListTile(
                leading: Icon(
                  ingredient.isOptional ? Icons.info_outline : Icons.warning,
                  color: ingredient.isOptional ? Colors.orange : Colors.red,
                ),
                title: Text(ingredient.ingredientName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Món: ${ingredient.menuItemName}'),
                    Text('Cần: ${ingredient.requiredQuantity}${ingredient.unit}'),
                    Text('Còn: ${ingredient.currentStock}${ingredient.unit}'),
                    Text('Thiếu: ${ingredient.missingQuantity}${ingredient.unit}'),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ingredient.isOptional 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ingredient.isOptional ? 'Tùy chọn' : 'Bắt buộc',
                    style: TextStyle(
                      color: ingredient.isOptional ? Colors.orange : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}