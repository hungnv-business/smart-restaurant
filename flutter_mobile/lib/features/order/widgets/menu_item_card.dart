import 'package:flutter/material.dart';
import '../../../core/models/menu/menu_models.dart';
import '../../../core/utils/price_formatter.dart';

/// Widget hiển thị món ăn theo template V0 design
class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onAddToCart;
  final int quantity; // Số lượng hiện tại trong giỏ hàng
  final VoidCallback? onIncreaseQuantity;
  final VoidCallback? onDecreaseQuantity;

  const MenuItemCard({
    Key? key,
    required this.menuItem,
    this.onAddToCart,
    this.quantity = 0,
    this.onIncreaseQuantity,
    this.onDecreaseQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  const Spacer(),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: 100, // Giảm từ 120 xuống 100 cho mobile
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: menuItem.imageUrl != null
                ? Image.network(
                    menuItem.imageUrl!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
          
          // Dark overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Popular badge (top-left) - hiển thị mức độ phổ biến
          if (menuItem.isPopular)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Phổ biến',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          
          // Unavailable overlay
          if (!menuItem.isAvailable)
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.black.withOpacity(0.6),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.not_interested,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hết món',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(
        Icons.restaurant_menu,
        size: 40, // Giảm icon size tương ứng
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                menuItem.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: menuItem.canOrder ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Hiển thị thông tin trạng thái - đã bán hoặc stock status
            if (menuItem.isOutOfStock || menuItem.hasLimitedStock)
              Flexible(
                child: _buildCompactStockStatus(context),
              )
            else if (menuItem.soldQuantity > 0)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4), // spacing
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${menuItem.soldQuantity} đã bán',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Không cần stock status riêng nữa vì đã hiển thị trong title row
      ],
    );
  }

  Widget _buildCompactStockStatus(BuildContext context) {
    final stockColor = _getStockStatusColor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: stockColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: stockColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            menuItem.stockStatusText,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: stockColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStockStatusColor() {
    if (menuItem.isOutOfStock) {
      return Colors.red[700]!;
    } else if (menuItem.hasLimitedStock) {
      return Colors.orange[700]!;
    } else {
      return Colors.green[700]!;
    }
  }

  Widget _buildCategoryInfo(BuildContext context) {
    if (menuItem.categoryName == null || menuItem.categoryName!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Text(
      menuItem.categoryName!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (menuItem.description == null || menuItem.description!.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị gì nếu không có description
    }
    
    return Text(
      menuItem.description!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: menuItem.isAvailable ? Colors.grey[600] : Colors.grey[400],
        fontSize: 12, // Tăng font size lên 12 để dễ đọc hơn
        height: 1.3, // Tăng line height để text không dính nhau
      ),
      maxLines: 3, // Hiển thị 3 dòng để hiện thị đầy đủ hơn
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price - sử dụng Expanded để tránh overflow
        Expanded(
          child: Text(
            PriceFormatter.format(menuItem.price),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: menuItem.isAvailable 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(width: 8), // Thêm spacing
        
        // Add button hoặc Quantity controls
        _buildActionButton(context),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // Nếu món không khả dụng (isAvailable = false), hiển thị button disabled
    // Nhưng cho phép thêm món hết stock - sẽ verify sau khi confirm order
    if (!menuItem.isAvailable) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Thêm',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Nếu chưa có trong giỏ hàng (quantity = 0), hiển thị nút "Thêm"
    if (quantity == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddToCart,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Thêm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Nếu đã có trong giỏ hàng (quantity > 0), hiển thị quantity controls
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDecreaseQuantity,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          
          // Quantity text
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Increase button - cho phép add dù hết stock
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIncreaseQuantity,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: _hasStockWarning() 
                      ? Colors.orange[700] 
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kiểm tra có warning về stock không (để đổi màu button)
  bool _hasStockWarning() {
    // Nếu hết hàng hoặc vượt quá stock available
    if (menuItem.isOutOfStock) return true;
    
    // Nếu không có giới hạn stock thì không warning
    if (menuItem.maximumQuantityAvailable == 2147483647) return false;
    
    // Warning khi quantity hiện tại >= stock available
    return quantity >= menuItem.maximumQuantityAvailable;
  }

  /// Kiểm tra có thể tăng quantity không (giữ lại method cũ để tương thích)
  bool _canIncreaseQuantity() {
    // Bây giờ luôn cho phép tăng - sẽ verify khi confirm order
    return true;
  }
}