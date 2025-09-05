import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

class AdvancedErrorHandler {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final List<AppError> _errorHistory = [];
  static Timer? _errorClearTimer;

  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
    
    // Handle errors in async operations
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleAsyncError(error, stack);
      return true;
    };
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.ui,
      message: details.exception.toString(),
      stackTrace: details.stack.toString(),
      timestamp: DateTime.now(),
      context: details.context?.toString(),
      severity: ErrorSeverity.high,
    );
    
    _addError(error);
    _showErrorDialog(error);
  }

  static void _handleAsyncError(Object error, StackTrace stack) {
    final appError = AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.async,
      message: error.toString(),
      stackTrace: stack.toString(),
      timestamp: DateTime.now(),
      severity: ErrorSeverity.medium,
    );
    
    _addError(appError);
  }

  static void handleNetworkError(dynamic error, {String? context}) {
    final appError = AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.network,
      message: _getNetworkErrorMessage(error),
      stackTrace: error is Error ? error.stackTrace?.toString() : null,
      timestamp: DateTime.now(),
      context: context,
      severity: ErrorSeverity.medium,
    );
    
    _addError(appError);
    _showErrorSnackbar(appError);
  }

  static void handleBusinessError(String message, {String? context}) {
    final appError = AppError(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.business,
      message: message,
      timestamp: DateTime.now(),
      context: context,
      severity: ErrorSeverity.low,
    );
    
    _addError(appError);
    _showErrorSnackbar(appError);
  }

  static String _getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('connection') || errorString.contains('timeout')) {
      return 'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Lỗi bảo mật kết nối. Vui lòng thử lại sau.';
    } else if (errorString.contains('401')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (errorString.contains('403')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    } else if (errorString.contains('404')) {
      return 'Không tìm thấy dữ liệu yêu cầu.';
    } else if (errorString.contains('500')) {
      return 'Lỗi server nội bộ. Vui lòng thử lại sau.';
    }
    
    return 'Có lỗi xảy ra khi kết nối. Vui lòng thử lại.';
  }

  static void _addError(AppError error) {
    _errorHistory.insert(0, error);
    if (_errorHistory.length > 50) {
      _errorHistory.removeRange(50, _errorHistory.length);
    }
    
    // Auto-clear old errors
    _errorClearTimer?.cancel();
    _errorClearTimer = Timer(const Duration(hours: 1), () {
      _errorHistory.removeWhere((e) => 
        DateTime.now().difference(e.timestamp).inHours > 1
      );
    });
  }

  static void _showErrorDialog(AppError error) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        title: Text(_getErrorTitle(error.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getErrorDescription(error)),
            if (error.context != null) ...[
              const SizedBox(height: 8),
              Text(
                'Chi tiết: ${error.context}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showErrorDetails(context, error);
            },
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackbar(AppError error) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getErrorDescription(error),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.severity),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: error.severity == ErrorSeverity.high ? 8 : 4),
        action: SnackBarAction(
          label: 'Chi tiết',
          textColor: Colors.white,
          onPressed: () => _showErrorDetails(context, error),
        ),
      ),
    );
  }

  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Lỗi kết nối';
      case ErrorType.business:
        return 'Thông báo';
      case ErrorType.ui:
        return 'Lỗi giao diện';
      case ErrorType.async:
        return 'Lỗi xử lý';
      case ErrorType.permission:
        return 'Lỗi quyền truy cập';
      case ErrorType.storage:
        return 'Lỗi lưu trữ';
    }
  }

  static String _getErrorDescription(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return error.message;
      case ErrorType.business:
        return error.message;
      case ErrorType.ui:
        return 'Có lỗi hiển thị giao diện. Ứng dụng sẽ tự động khôi phục.';
      case ErrorType.async:
        return 'Có lỗi trong quá trình xử lý. Vui lòng thử lại.';
      case ErrorType.permission:
        return 'Ứng dụng cần quyền truy cập để hoạt động bình thường.';
      case ErrorType.storage:
        return 'Không thể lưu trữ dữ liệu. Vui lòng kiểm tra dung lượng thiết bị.';
    }
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.business:
        return Icons.info_outline;
      case ErrorType.ui:
        return Icons.bug_report;
      case ErrorType.async:
        return Icons.error_outline;
      case ErrorType.permission:
        return Icons.security;
      case ErrorType.storage:
        return Icons.storage;
    }
  }

  static Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
    }
  }

  static void _showErrorDetails(BuildContext context, AppError error) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ErrorDetailsScreen(error: error),
      ),
    );
  }

  static List<AppError> getErrorHistory() => List.unmodifiable(_errorHistory);

  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  static void reportError(AppError error) {
    // In production, send error to crash reporting service
    debugPrint('Error reported: ${error.toJson()}');
  }
}

class AppError {
  final String id;
  final ErrorType type;
  final String message;
  final String? stackTrace;
  final DateTime timestamp;
  final String? context;
  final ErrorSeverity severity;

  const AppError({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    this.context,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'message': message,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'severity': severity.toString(),
    };
  }

  factory AppError.fromJson(Map<String, dynamic> json) {
    return AppError(
      id: json['id'] as String,
      type: ErrorType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String?,
      severity: ErrorSeverity.values.firstWhere(
        (s) => s.toString() == json['severity'],
      ),
    );
  }
}

enum ErrorType {
  network,
  business,
  ui,
  async,
  permission,
  storage;

  String get displayName {
    switch (this) {
      case ErrorType.network:
        return 'Lỗi mạng';
      case ErrorType.business:
        return 'Lỗi nghiệp vụ';
      case ErrorType.ui:
        return 'Lỗi giao diện';
      case ErrorType.async:
        return 'Lỗi xử lý';
      case ErrorType.permission:
        return 'Lỗi quyền truy cập';
      case ErrorType.storage:
        return 'Lỗi lưu trữ';
    }
  }
}

enum ErrorSeverity {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'Thấp';
      case ErrorSeverity.medium:
        return 'Trung bình';
      case ErrorSeverity.high:
        return 'Cao';
    }
  }
}

class ErrorDetailsScreen extends StatelessWidget {
  final AppError error;

  const ErrorDetailsScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lỗi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _copyErrorDetails(),
            icon: const Icon(Icons.copy),
            tooltip: 'Sao chép thông tin lỗi',
          ),
          IconButton(
            onPressed: () => _reportError(),
            icon: const Icon(Icons.send),
            tooltip: 'Báo cáo lỗi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildErrorSummary(context),
            const SizedBox(height: 24),
            _buildErrorDetails(context),
            const SizedBox(height: 24),
            if (error.stackTrace != null) ...[
              _buildStackTrace(context),
              const SizedBox(height: 24),
            ],
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSummary(BuildContext context) {
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
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  error.type.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(error.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error.severity.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin chi tiết',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Mã lỗi:', error.id),
            _buildDetailRow('Thời gian:', _formatDateTime(error.timestamp)),
            if (error.context != null)
              _buildDetailRow('Ngữ cảnh:', error.context!),
          ],
        ),
      ),
    );
  }

  Widget _buildStackTrace(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stack Trace',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                error.stackTrace!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hành động',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyErrorDetails,
                    icon: const Icon(Icons.copy),
                    label: const Text('Sao chép'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _reportError,
                    icon: const Icon(Icons.send),
                    label: const Text('Báo cáo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _copyErrorDetails() {
    final errorDetails = '''
Mã lỗi: ${error.id}
Loại lỗi: ${error.type.displayName}
Mức độ: ${error.severity.displayName}
Thời gian: ${_formatDateTime(error.timestamp)}
Thông điệp: ${error.message}
${error.context != null ? 'Ngữ cảnh: ${error.context}\n' : ''}
${error.stackTrace != null ? 'Stack Trace:\n${error.stackTrace}\n' : ''}
    '''.trim();

    Clipboard.setData(ClipboardData(text: errorDetails));
    
    // Show confirmation
    final context = AdvancedErrorHandler.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép thông tin lỗi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _reportError() {
    AdvancedErrorHandler.reportError(error);
    
    final context = AdvancedErrorHandler.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi báo cáo lỗi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}