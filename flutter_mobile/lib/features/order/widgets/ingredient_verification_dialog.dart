import 'package:flutter/material.dart';
import '../../../core/models/order/ingredient_verification_models.dart';

/// Dialog hiển thị thông tin thiếu nguyên liệu và cho phép người dùng xác nhận
class IngredientVerificationDialog extends StatelessWidget {
  final IngredientAvailabilityResultDto verificationResult;

  const IngredientVerificationDialog({
    Key? key,
    required this.verificationResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header cố định
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildHeader(context),
            ),
            
            // Content có thể scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummary(context),
                    const SizedBox(height: 20),
                    if (verificationResult.hasMissingIngredients) ...[
                      _buildMissingIngredientsList(context),
                      const SizedBox(height: 16),
                      _buildIngredientSummary(context),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            
            // Action buttons cố định ở dưới
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isAvailable = verificationResult.isAvailable;
    
    return Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.warning,
          color: isAvailable ? Colors.green : Colors.orange,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isAvailable ? 'Đặt món thành công' : 'Thiếu nguyên liệu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.green : Colors.orange[800],
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verificationResult.isAvailable 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verificationResult.isAvailable 
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verificationResult.shortSummary,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: verificationResult.isAvailable 
                  ? Colors.green[800] 
                  : Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verificationResult.summaryMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: verificationResult.isAvailable 
                  ? Colors.green[700] 
                  : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingIngredientsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết thiếu nguyên liệu:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Sử dụng Column thay vì ListView để tránh nested scroll
        ...verificationResult.missingIngredients.map((missing) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildMissingIngredientItem(context, missing),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingIngredientItem(BuildContext context, MissingIngredient missing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên món ăn
          Text(
            missing.menuItemName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 4),
          
          // Thông tin nguyên liệu thiếu
          Row(
            children: [
              Icon(
                Icons.remove_circle_outline,
                size: 16,
                color: Colors.red[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  missing.displayMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Chi tiết số lượng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Cần: ${missing.requiredQuantity} ${missing.unit} | Còn: ${missing.currentStock} ${missing.unit} | Thiếu: ${missing.shortageAmount} ${missing.unit}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSummary(BuildContext context) {
    // Tính tổng thiếu cho từng nguyên liệu
    final ingredientSummary = <String, _IngredientSummaryInfo>{};
    
    for (final missing in verificationResult.missingIngredients) {
      final key = '${missing.ingredientName}_${missing.unit}';
      
      if (ingredientSummary.containsKey(key)) {
        // Cộng dồn số lượng thiếu
        ingredientSummary[key]!.totalShortage += missing.shortageAmount;
      } else {
        // Tạo mới entry
        ingredientSummary[key] = _IngredientSummaryInfo(
          ingredientName: missing.ingredientName,
          unit: missing.unit,
          totalShortage: missing.shortageAmount,
        );
      }
    }

    if (ingredientSummary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tổng hợp nguyên liệu cần mua:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...ingredientSummary.values.map((summary) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${summary.ingredientName}: còn thiếu ${summary.totalShortage}${summary.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (verificationResult.isAvailable) {
      // Nếu đủ nguyên liệu, chỉ hiện nút OK
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Xác nhận đặt món',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Nếu thiếu nguyên liệu, hiện cả 2 nút
    return Column(
      children: [
        // Cảnh báo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bạn có muốn tiếp tục đặt món dù thiếu nguyên liệu?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Nút hành động
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Vẫn đặt món',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper class để tổng hợp thông tin nguyên liệu thiếu
class _IngredientSummaryInfo {
  final String ingredientName;
  final String unit;
  int totalShortage;

  _IngredientSummaryInfo({
    required this.ingredientName,
    required this.unit,
    required this.totalShortage,
  });
}