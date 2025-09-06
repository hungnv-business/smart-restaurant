import 'package:flutter/material.dart';
import '../../../core/models/menu_models.dart';

/// Widget hiển thị món ăn theo template V0 design
class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    Key? key,
    required this.menuItem,
    this.onAddToCart,
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
                  const SizedBox(height: 4),
                  _buildDescription(context),
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
      height: 120,
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
                    height: 120,
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
      height: 120,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            menuItem.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: menuItem.isAvailable ? Colors.black87 : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Sold quantity
        if (menuItem.soldQuantity > 0)
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 12,
                color: Colors.green[600],
              ),
              const SizedBox(width: 2),
              Text(
                '${menuItem.soldQuantity} đã bán',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
      ],
    );
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
        // Price
        Text(
          _formatPrice(menuItem.price),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: menuItem.isAvailable 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        
        // Add button
        Container(
          decoration: BoxDecoration(
            color: menuItem.isAvailable 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            boxShadow: menuItem.isAvailable ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: menuItem.isAvailable ? onAddToCart : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 16,
                      color: menuItem.isAvailable ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Thêm',
                      style: TextStyle(
                        color: menuItem.isAvailable ? Colors.white : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )} ₫';
  }
}