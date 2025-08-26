# SmartRestaurant Mobile Template (Flutter 3.35.1)

## Cấu trúc Flutter Mobile

### 1. Feature Screen Template

```dart
// File: flutter_mobile/lib/features/{module}/{entity_name}_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/constants/vietnamese_constants.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/services/api/api_client.dart';
import '../../shared/models/{entity_name}_model.dart';
import '../widgets/{entity_name}_card.dart';
import '../widgets/{entity_name}_form.dart';

class {EntityName}Screen extends StatefulWidget {
  final String? mode; // 'new', 'edit', 'detail', or null for list
  final String? {entityName}Id;

  const {EntityName}Screen({
    Key? key,
    this.mode,
    this.{entityName}Id,
  }) : super(key: key);

  @override
  State<{EntityName}Screen> createState() => _{EntityName}ScreenState();
}

class _{EntityName}ScreenState extends State<{EntityName}Screen> {
  List<{EntityName}Model> {entityName}s = [];
  {EntityName}Model? current{EntityName};
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.mode == null) {
      _load{EntityName}s();
    } else if (widget.mode == 'edit' || widget.mode == 'detail') {
      _load{EntityName}(widget.{entityName}Id!);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: _getTitle(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case 'new':
        return VietnameseConstants.new{EntityName};
      case 'edit':
        return 'Sửa {entity-display-name} #${widget.{entityName}Id}';
      case 'detail':
        return 'Chi tiết {entity-display-name} #${widget.{entityName}Id}';
      default:
        return VietnameseConstants.{entityName}Title;
    }
  }

  Widget _buildHeader() {
    if (widget.mode != null) {
      return Container(); // No header for non-list modes
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getTitle(),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        FloatingActionButton(
          onPressed: () => _navigateToForm('new'),
          backgroundColor: Colors.blue[600],
          child: Icon(Icons.add, color: Colors.white, size: 24.r),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.blue[600],
        ),
      );
    }

    switch (widget.mode) {
      case 'new':
        return {EntityName}Form(
          onSave: _create{EntityName},
          onCancel: () => Navigator.pop(context),
        );
      case 'edit':
        return {EntityName}Form(
          initial{EntityName}: current{EntityName},
          onSave: _update{EntityName},
          onCancel: () => Navigator.pop(context),
        );
      case 'detail':
        return _build{EntityName}Detail();
      default:
        return _build{EntityName}List();
    }
  }

  Widget _build{EntityName}List() {
    List<{EntityName}Model> filtered{EntityName}s = {entityName}s.where((item) {
      return item.{propertyName}.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (item.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Column(
      children: [
        // Search Section
        _buildSearchSection(),
        SizedBox(height: 16.h),

        // List Section
        Expanded(
          child: filtered{EntityName}s.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filtered{EntityName}s.length,
                  itemBuilder: (context, index) => {EntityName}Card(
                    {entityName}: filtered{EntityName}s[index],
                    onEdit: () => _navigateToForm('edit', filtered{EntityName}s[index].id),
                    onDetail: () => _navigateToForm('detail', filtered{EntityName}s[index].id),
                    onDelete: () => _delete{EntityName}(filtered{EntityName}s[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: VietnameseConstants.search,
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.r),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(Icons.tune, size: 24.r, color: Colors.blue[600]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Không tìm thấy dữ liệu',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            searchQuery.isEmpty
                ? 'Chưa có {entity-display-name} nào'
                : 'Không có kết quả phù hợp với "$searchQuery"',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm('new'),
              icon: Icon(Icons.add, size: 20.r),
              label: Text('Thêm {entity-display-name} đầu tiên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _build{EntityName}Detail() {
    if (current{EntityName} == null) {
      return Center(
        child: Text(
          'Không tìm thấy thông tin {entity-display-name}',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('{Property Display Name}', current{EntityName}!.{propertyName}),
            if (current{EntityName}!.description != null && current{EntityName}!.description!.isNotEmpty)
              _buildDetailRow('Mô tả', current{EntityName}!.description!),
            _buildDetailRow('Thứ tự hiển thị', current{EntityName}!.displayOrder.toString()),
            _buildDetailRow(
              'Trạng thái',
              current{EntityName}!.isActive ? 'Hoạt động' : 'Không hoạt động',
              valueColor: current{EntityName}!.isActive ? Colors.green : Colors.red,
            ),
            _buildDetailRow(
              'Ngày tạo',
              _formatDateTime(current{EntityName}!.creationTime),
            ),
            if (current{EntityName}!.lastModificationTime != null)
              _buildDetailRow(
                'Ngày cập nhật',
                _formatDateTime(current{EntityName}!.lastModificationTime!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor ?? Colors.grey[800],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation and CRUD Operations
  void _navigateToForm(String mode, [String? {entityName}Id]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => {EntityName}Screen(
          mode: mode,
          {entityName}Id: {entityName}Id,
        ),
      ),
    ).then((_) {
      if (widget.mode == null) {
        _load{EntityName}s(); // Refresh list when returning
      }
    });
  }

  Future<void> _load{EntityName}s() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      setState(() {
        {entityName}s = _getMock{EntityName}s();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Không thể tải danh sách {entity-display-name}');
    }
  }

  Future<void> _load{EntityName}(String id) async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      setState(() {
        current{EntityName} = _getMock{EntityName}s().firstWhere((item) => item.id == id);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Không thể tải thông tin {entity-display-name}');
    }
  }

  Future<void> _create{EntityName}({EntityName}Model {entityName}) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      _showSuccessSnackBar('{Entity display name} đã được tạo thành công');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Không thể tạo {entity-display-name}');
    }
  }

  Future<void> _update{EntityName}({EntityName}Model {entityName}) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      _showSuccessSnackBar('{Entity display name} đã được cập nhật thành công');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Không thể cập nhật {entity-display-name}');
    }
  }

  Future<void> _delete{EntityName}({EntityName}Model {entityName}) async {
    final confirmed = await _showDeleteConfirmation({entityName}.{propertyName});
    if (!confirmed) return;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      setState(() {
        {entityName}s.removeWhere((item) => item.id == {entityName}.id);
      });
      _showSuccessSnackBar('{Entity display name} đã được xóa thành công');
    } catch (e) {
      _showErrorSnackBar('Không thể xóa {entity-display-name}');
    }
  }

  // Helper Methods
  List<{EntityName}Model> _getMock{EntityName}s() {
    return [
      {EntityName}Model(
        id: '1',
        {propertyName}: 'Mock {Entity Name} 1',
        description: 'Mô tả mẫu 1',
        displayOrder: 1,
        isActive: true,
        creationTime: DateTime.now().subtract(Duration(days: 7)),
        lastModificationTime: null,
      ),
      {EntityName}Model(
        id: '2',
        {propertyName}: 'Mock {Entity Name} 2',
        description: 'Mô tả mẫu 2',
        displayOrder: 2,
        isActive: false,
        creationTime: DateTime.now().subtract(Duration(days: 5)),
        lastModificationTime: DateTime.now().subtract(Duration(days: 1)),
      ),
      // Add more mock data as needed
    ];
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    _showInfoSnackBar('Chức năng lọc sẽ được triển khai sau');
  }

  Future<bool> _showDeleteConfirmation(String itemName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa "$itemName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

### 2. Model Template

```dart
// File: flutter_mobile/lib/shared/models/{entity_name}_model.dart
import 'package:json_annotation/json_annotation.dart';

part '{entity_name}_model.g.dart';

@JsonSerializable()
class {EntityName}Model {
  final String id;
  final String {propertyName};
  final String? description;
  final int displayOrder;
  final bool isActive;
  final DateTime creationTime;
  final DateTime? lastModificationTime;

  {EntityName}Model({
    required this.id,
    required this.{propertyName},
    this.description,
    required this.displayOrder,
    required this.isActive,
    required this.creationTime,
    this.lastModificationTime,
  });

  factory {EntityName}Model.fromJson(Map<String, dynamic> json) => _${EntityName}ModelFromJson(json);

  Map<String, dynamic> toJson() => _${EntityName}ModelToJson(this);

  {EntityName}Model copyWith({
    String? id,
    String? {propertyName},
    String? description,
    int? displayOrder,
    bool? isActive,
    DateTime? creationTime,
    DateTime? lastModificationTime,
  }) {
    return {EntityName}Model(
      id: id ?? this.id,
      {propertyName}: {propertyName} ?? this.{propertyName},
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      creationTime: creationTime ?? this.creationTime,
      lastModificationTime: lastModificationTime ?? this.lastModificationTime,
    );
  }

  @override
  String toString() {
    return '{EntityName}Model(id: $id, {propertyName}: ${propertyName}, description: $description, '
        'displayOrder: $displayOrder, isActive: $isActive, '
        'creationTime: $creationTime, lastModificationTime: $lastModificationTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is {EntityName}Model &&
        other.id == id &&
        other.{propertyName} == {propertyName} &&
        other.description == description &&
        other.displayOrder == displayOrder &&
        other.isActive == isActive &&
        other.creationTime == creationTime &&
        other.lastModificationTime == lastModificationTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      {propertyName},
      description,
      displayOrder,
      isActive,
      creationTime,
      lastModificationTime,
    );
  }
}

// Create DTO
@JsonSerializable()
class Create{EntityName}Request {
  final String {propertyName};
  final String? description;
  final int displayOrder;
  final bool isActive;

  Create{EntityName}Request({
    required this.{propertyName},
    this.description,
    required this.displayOrder,
    this.isActive = true,
  });

  factory Create{EntityName}Request.fromJson(Map<String, dynamic> json) => 
      _$Create{EntityName}RequestFromJson(json);

  Map<String, dynamic> toJson() => _$Create{EntityName}RequestToJson(this);
}

// Update DTO
@JsonSerializable()
class Update{EntityName}Request {
  final String {propertyName};
  final String? description;
  final int displayOrder;
  final bool isActive;

  Update{EntityName}Request({
    required this.{propertyName},
    this.description,
    required this.displayOrder,
    required this.isActive,
  });

  factory Update{EntityName}Request.fromJson(Map<String, dynamic> json) => 
      _$Update{EntityName}RequestFromJson(json);

  Map<String, dynamic> toJson() => _$Update{EntityName}RequestToJson(this);
}
```

### 3. Card Widget Template

```dart
// File: flutter_mobile/lib/features/{module}/widgets/{entity_name}_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/{entity_name}_model.dart';

class {EntityName}Card extends StatelessWidget {
  final {EntityName}Model {entityName};
  final VoidCallback? onEdit;
  final VoidCallback? onDetail;
  final VoidCallback? onDelete;

  const {EntityName}Card({
    Key? key,
    required this.{entityName},
    this.onEdit,
    this.onDetail,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 8.h),
          _buildContent(),
          SizedBox(height: 12.h),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            {entityName}.{propertyName},
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: {entityName}.isActive ? Colors.green[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            {entityName}.isActive ? 'Hoạt động' : 'Không hoạt động',
            style: TextStyle(
              fontSize: 12.sp,
              color: {entityName}.isActive ? Colors.green[700] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ({entityName}.description != null && {entityName}.description!.isNotEmpty) ...[
          Text(
            {entityName}.description!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
        ],
        Row(
          children: [
            Icon(Icons.sort, size: 16.r, color: Colors.grey[500]),
            SizedBox(width: 4.w),
            Text(
              'Thứ tự: ${entityName}.displayOrder',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(width: 16.w),
            Icon(Icons.access_time, size: 16.r, color: Colors.grey[500]),
            SizedBox(width: 4.w),
            Text(
              _formatDate({entityName}.creationTime),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onDetail != null)
          IconButton(
            onPressed: onDetail,
            icon: Icon(Icons.visibility, size: 20.r, color: Colors.blue[600]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        if (onEdit != null) ...[
          SizedBox(width: 8.w),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, size: 20.r, color: Colors.orange[600]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
        if (onDelete != null) ...[
          SizedBox(width: 8.w),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete, size: 20.r, color: Colors.red[600]),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
```

### 4. Form Widget Template

```dart
// File: flutter_mobile/lib/features/{module}/widgets/{entity_name}_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/{entity_name}_model.dart';
import '../../../shared/constants/vietnamese_constants.dart';
import '../../../shared/widgets/vietnamese_input_widgets.dart';

class {EntityName}Form extends StatefulWidget {
  final {EntityName}Model? initial{EntityName};
  final Function({EntityName}Model) onSave;
  final VoidCallback onCancel;

  const {EntityName}Form({
    Key? key,
    this.initial{EntityName},
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<{EntityName}Form> createState() => _{EntityName}FormState();
}

class _{EntityName}FormState extends State<{EntityName}Form> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _{propertyName}Controller;
  late TextEditingController _descriptionController;
  late int _displayOrder;
  late bool _isActive;

  bool _isLoading = false;

  // Vietnamese suggestions
  final List<String> _{propertyName}Suggestions = [
    // Add Vietnamese suggestions here based on entity type
  ];

  @override
  void initState() {
    super.initState();
    _{propertyName}Controller = TextEditingController(
      text: widget.initial{EntityName}?.{propertyName} ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initial{EntityName}?.description ?? '',
    );
    _displayOrder = widget.initial{EntityName}?.displayOrder ?? 1;
    _isActive = widget.initial{EntityName}?.isActive ?? true;
  }

  @override
  void dispose() {
    _{propertyName}Controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              SizedBox(height: 20.h),
              _build{PropertyName}Field(),
              SizedBox(height: 16.h),
              _buildDescriptionField(),
              SizedBox(height: 16.h),
              _buildDisplayOrderField(),
              SizedBox(height: 16.h),
              _buildActiveStatusField(),
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.initial{EntityName} == null
          ? 'Tạo mới {Entity Display Name}'
          : 'Chỉnh sửa {Entity Display Name}',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _build{PropertyName}Field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '{Property Display Name}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        VietnameseTextFormField(
          controller: _{propertyName}Controller,
          hintText: 'Nhập {property-display-name}...',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '{Property Display Name} không được để trống';
            }
            if (value.trim().length > 128) {
              return '{Property Display Name} không được quá 128 ký tự';
            }
            return null;
          },
          suggestions: _{propertyName}Suggestions,
          onSuggestionSelected: (suggestion) {
            _{propertyName}Controller.text = suggestion;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập mô tả (tùy chọn)...',
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          validator: (value) {
            if (value != null && value.length > 512) {
              return 'Mô tả không được quá 512 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDisplayOrderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Thứ tự hiển thị',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _displayOrder > 1 ? () => setState(() => _displayOrder--) : null,
              icon: Icon(Icons.remove, size: 20.r),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: _displayOrder > 1 ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _displayOrder.toString(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            IconButton(
              onPressed: _displayOrder < 999 ? () => setState(() => _displayOrder++) : null,
              icon: Icon(Icons.add, size: 20.r),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: _displayOrder < 999 ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveStatusField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trạng thái hoạt động',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          activeColor: Colors.green[600],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.initial{EntityName} == null 
                        ? VietnameseConstants.create 
                        : VietnameseConstants.update,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              VietnameseConstants.cancel,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final {entityName} = {EntityName}Model(
      id: widget.initial{EntityName}?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      {propertyName}: _{propertyName}Controller.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      displayOrder: _displayOrder,
      isActive: _isActive,
      creationTime: widget.initial{EntityName}?.creationTime ?? DateTime.now(),
      lastModificationTime: widget.initial{EntityName} != null ? DateTime.now() : null,
    );

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => _isLoading = false);
      widget.onSave({entityName});
    });
  }
}
```

### 5. API Service Template

```dart
// File: flutter_mobile/lib/shared/services/api/{entity_name}_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/{entity_name}_model.dart';
import 'api_client.dart';

class {EntityName}ApiService {
  final ApiClient _apiClient;

  {EntityName}ApiService(this._apiClient);

  Future<List<{EntityName}Model>> get{EntityName}s() async {
    try {
      final response = await _apiClient.get('/api/{module}/{entity-name}s');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => {EntityName}Model.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load {entity-name}s: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading {entity-name}s: $e');
    }
  }

  Future<{EntityName}Model> get{EntityName}(String id) async {
    try {
      final response = await _apiClient.get('/api/{module}/{entity-name}s/$id');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return {EntityName}Model.fromJson(json);
      } else {
        throw Exception('Failed to load {entity-name}: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading {entity-name}: $e');
    }
  }

  Future<{EntityName}Model> create{EntityName}(Create{EntityName}Request request) async {
    try {
      final response = await _apiClient.post(
        '/api/{module}/{entity-name}s',
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return {EntityName}Model.fromJson(json);
      } else {
        throw Exception('Failed to create {entity-name}: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating {entity-name}: $e');
    }
  }

  Future<{EntityName}Model> update{EntityName}(String id, Update{EntityName}Request request) async {
    try {
      final response = await _apiClient.put(
        '/api/{module}/{entity-name}s/$id',
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return {EntityName}Model.fromJson(json);
      } else {
        throw Exception('Failed to update {entity-name}: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating {entity-name}: $e');
    }
  }

  Future<void> delete{EntityName}(String id) async {
    try {
      final response = await _apiClient.delete('/api/{module}/{entity-name}s/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete {entity-name}: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting {entity-name}: $e');
    }
  }

  Future<int> getNextDisplayOrder() async {
    try {
      final response = await _apiClient.get('/api/{module}/{entity-name}s/next-display-order');
      
      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('Failed to get next display order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting next display order: $e');
    }
  }
}
```

### 6. Test Template

```dart
// File: flutter_mobile/test/features/{module}/{entity_name}_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_restaurant_mobile/features/{module}/{entity_name}_screen.dart';
import 'package:smart_restaurant_mobile/shared/models/{entity_name}_model.dart';

void main() {
  late {EntityName}Model test{EntityName};

  setUpAll(() async {
    await ScreenUtil.ensureScreenSize();
  });

  setUp(() {
    test{EntityName} = {EntityName}Model(
      id: '1',
      {propertyName}: 'Test {Entity Name}',
      description: 'Test description',
      displayOrder: 1,
      isActive: true,
      creationTime: DateTime.now(),
      lastModificationTime: null,
    );
  });

  group('{EntityName}Screen Widget Tests', () {
    testWidgets('should display title for list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      expect(find.text('{Entity Display Name}'), findsOneWidget);
    });

    testWidgets('should display add button in list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display new form title in new mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      expect(find.text('Tạo mới {Entity Display Name}'), findsOneWidget);
    });

    testWidgets('should display edit form title in edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'edit', {entityName}Id: '1'),
        ),
      );

      expect(find.text('Sửa {entity-display-name} #1'), findsOneWidget);
    });

    testWidgets('should display search field in list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('{EntityName}Model Tests', () {
    test('should create {EntityName}Model from json', () {
      final json = {
        'id': '1',
        '{propertyName}': 'Test {Entity Name}',
        'description': 'Test description',
        'displayOrder': 1,
        'isActive': true,
        'creationTime': DateTime.now().toIso8601String(),
        'lastModificationTime': null,
      };

      final {entityName} = {EntityName}Model.fromJson(json);

      expect({entityName}.id, '1');
      expect({entityName}.{propertyName}, 'Test {Entity Name}');
      expect({entityName}.description, 'Test description');
      expect({entityName}.displayOrder, 1);
      expect({entityName}.isActive, true);
    });

    test('should convert {EntityName}Model to json', () {
      final json = test{EntityName}.toJson();

      expect(json['id'], '1');
      expect(json['{propertyName}'], 'Test {Entity Name}');
      expect(json['description'], 'Test description');
      expect(json['displayOrder'], 1);
      expect(json['isActive'], true);
    });

    test('should create copy with modified values', () {
      final copied = test{EntityName}.copyWith(
        {propertyName}: 'Modified Name',
        isActive: false,
      );

      expect(copied.id, test{EntityName}.id);
      expect(copied.{propertyName}, 'Modified Name');
      expect(copied.description, test{EntityName}.description);
      expect(copied.displayOrder, test{EntityName}.displayOrder);
      expect(copied.isActive, false);
      expect(copied.creationTime, test{EntityName}.creationTime);
    });

    test('should compare equality correctly', () {
      final another{EntityName} = {EntityName}Model(
        id: '1',
        {propertyName}: 'Test {Entity Name}',
        description: 'Test description',
        displayOrder: 1,
        isActive: true,
        creationTime: test{EntityName}.creationTime,
        lastModificationTime: null,
      );

      expect(test{EntityName}, another{EntityName});
      expect(test{EntityName}.hashCode, another{EntityName}.hashCode);
    });
  });
}
```

## Quy tắc đặt tên

### Flutter/Dart
- **Classes**: `PascalCase` (VD: `LayoutSectionScreen`, `LayoutSectionModel`)
- **Files**: `snake_case` (VD: `layout_section_screen.dart`, `layout_section_model.dart`)
- **Variables/Methods**: `camelCase` (VD: `sectionName`, `loadSections`)
- **Constants**: `lowerCamelCase` (VD: `vietnameseConstants`)
- **Private members**: `_camelCase` (VD: `_sectionName`, `_loadSections`)

### Directories
- **Features**: `snake_case` (VD: `table_management/`, `orders/`)
- **Widgets**: `snake_case` (VD: `vietnamese_input_widgets.dart`)

## Notes quan trọng

1. **Vietnamese UI**: Tất cả text hiển thị phải bằng tiếng Việt
2. **Responsive**: Sử dụng `flutter_screenutil` cho responsive design
3. **State Management**: Sử dụng StatefulWidget với proper lifecycle management
4. **Error Handling**: Implement try-catch với user-friendly error messages
5. **Navigation**: Sử dụng named routes hoặc MaterialPageRoute
6. **API Integration**: Centralize API calls trong services
7. **Validation**: Client-side validation với Vietnamese error messages
8. **Testing**: Unit tests cho models và widget tests cho UI components