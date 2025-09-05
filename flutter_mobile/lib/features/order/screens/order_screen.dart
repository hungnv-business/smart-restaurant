import 'package:flutter/material.dart';

/// Màn hình Gọi món
class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<String> _categories = [
    'Tất cả',
    'Khai vị',
    'Món chính',
    'Nước uống',
    'Tráng miệng',
  ];
  
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giỏ hàng đang phát triển')),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Giỏ hàng (3)'),
      ),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thêm ${food['name']} vào giỏ hàng')),
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
}