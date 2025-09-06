import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../shared/widgets/common_app_bar.dart';

/// Màn hình Menu món ăn cho bàn đã chọn
class MenuScreen extends StatefulWidget {
  final TableModel selectedTable;

  const MenuScreen({
    Key? key,
    required this.selectedTable,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<String> _categories = [
    'Tất cả',
    'Khai vị',
    'Món chính',
    'Nước uống',
    'Tráng miệng',
  ];
  
  int _selectedCategoryIndex = 0;
  int _cartItemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Menu - ${widget.selectedTable.name}',
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Color(widget.selectedTable.status.colorValue),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.selectedTable.status.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với tìm kiếm
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Thanh tìm kiếm
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quét QR code đang phát triển')),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Danh mục
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_categories[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Danh sách món ăn
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12, // Demo items
              itemBuilder: (context, index) {
                return _buildFoodItem(context, index);
              },
            ),
          ),
        ],
      ),
      
      // Floating action button để xem giỏ hàng
      floatingActionButton: _cartItemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                _showCartBottomSheet(context);
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text('Giỏ hàng ($_cartItemCount)'),
            )
          : null,
    );
  }

  Widget _buildFoodItem(BuildContext context, int index) {
    final foods = [
      {'name': 'Phở Bò Tái', 'price': '85.000₫', 'image': '🍜'},
      {'name': 'Cơm Tấm Sài Gòn', 'price': '65.000₫', 'image': '🍚'},
      {'name': 'Bánh Mì Thịt Nướng', 'price': '35.000₫', 'image': '🥖'},
      {'name': 'Gỏi Cuốn Tôm Thịt', 'price': '45.000₫', 'image': '🌯'},
      {'name': 'Bún Bò Huế', 'price': '75.000₫', 'image': '🍲'},
      {'name': 'Chả Cá Lã Vọng', 'price': '120.000₫', 'image': '🐟'},
      {'name': 'Cà Phê Sữa Đá', 'price': '25.000₫', 'image': '☕'},
      {'name': 'Nước Mía', 'price': '15.000₫', 'image': '🧃'},
      {'name': 'Chè Ba Màu', 'price': '30.000₫', 'image': '🍧'},
      {'name': 'Bánh Flan', 'price': '35.000₫', 'image': '🍮'},
      {'name': 'Nem Nướng Nha Trang', 'price': '55.000₫', 'image': '🍖'},
      {'name': 'Bánh Xèo', 'price': '65.000₫', 'image': '🥞'},
    ];

    final food = foods[index % foods.length];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh món ăn
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  food['image']!,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          
          // Thông tin món ăn
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name']!,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        food['price']!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _cartItemCount++;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã thêm ${food['name']} vào giỏ hàng cho ${widget.selectedTable.name}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Giỏ hàng - ${widget.selectedTable.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Cart items (Demo)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _cartItemCount,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Text('🍜', style: TextStyle(fontSize: 24)),
                    title: Text('Món ăn ${index + 1}'),
                    subtitle: const Text('85.000₫'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        const Text('1'),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom actions
              Container(
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
                          '${_cartItemCount * 85}.000₫',
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
                              setState(() {
                                _cartItemCount = 0;
                              });
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã gửi đơn hàng cho ${widget.selectedTable.name}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Gửi đơn'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}