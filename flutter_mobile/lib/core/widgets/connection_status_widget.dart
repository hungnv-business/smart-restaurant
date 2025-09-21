import 'package:flutter/material.dart';
import 'package:flutter_mobile/core/enums/restaurant_enums.dart';
import 'package:flutter_mobile/core/services/notification/signalr_service.dart';
import 'package:provider/provider.dart';

/// Widget hiển thị trạng thái kết nối SignalR
class ConnectionStatusWidget extends StatelessWidget {
  final bool showAsSnackBar;
  final bool showAsAppBar;

  const ConnectionStatusWidget({
    super.key,
    this.showAsSnackBar = false,
    this.showAsAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalRService>(
      builder: (context, signalRService, child) {
        final status = signalRService.connectionStatus;
        final error = signalRService.lastError;

        if (showAsSnackBar) {
          // Show as snackbar for important status changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (status == ConnectionStatus.error && error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi kết nối: $error'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () => signalRService.connect(),
                  ),
                ),
              );
            } else if (status == ConnectionStatus.connected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã kết nối với server'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
          return const SizedBox.shrink();
        }

        if (showAsAppBar) {
          // Show as app bar indicator
          return _buildAppBarIndicator(status, error, signalRService);
        }

        // Default inline indicator
        return _buildInlineIndicator(status, error, signalRService);
      },
    );
  }

  Widget _buildAppBarIndicator(
    ConnectionStatus status,
    String? error,
    SignalRService signalRService,
  ) {
    // Only show for non-connected states
    if (status == ConnectionStatus.connected) {
      return const SizedBox.shrink();
    }

    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status, error);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status == ConnectionStatus.error ||
              status == ConnectionStatus.disconnected)
            TextButton(
              onPressed: () {
                signalRService.connect();
              },
              child: const Text(
                'Kết nối',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInlineIndicator(
    ConnectionStatus status,
    String? error,
    SignalRService signalRService,
  ) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    final text = _getStatusText(status, error);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái kết nối',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (status == ConnectionStatus.error)
            ElevatedButton(
              onPressed: () => signalRService.connect(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Icons.wifi_outlined;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.error:
        return Icons.error_outline;
    }
  }

  String _getStatusText(ConnectionStatus status, String? error) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Đã kết nối';
      case ConnectionStatus.connecting:
        return 'Đang kết nối...';
      case ConnectionStatus.reconnecting:
        return 'Đang kết nối lại...';
      case ConnectionStatus.disconnected:
        return 'Ngắt kết nối';
      case ConnectionStatus.error:
        return error ?? 'Lỗi kết nối';
    }
  }
}
