import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../services/offline_storage_service.dart';
import '../models/order_models.dart';
import '../../../shared/constants/app_colors.dart';

class OfflineModeWidget extends StatefulWidget {
  final Widget child;

  const OfflineModeWidget({
    super.key,
    required this.child,
  });

  @override
  State<OfflineModeWidget> createState() => _OfflineModeWidgetState();
}

class _OfflineModeWidgetState extends State<OfflineModeWidget> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _showOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final bool wasOnline = _isOnline;
    _isOnline = result.any((r) => r != ConnectivityResult.none);

    if (wasOnline && !_isOnline) {
      // Went offline
      _handleGoingOffline();
    } else if (!wasOnline && _isOnline) {
      // Came back online
      _handleComingOnline();
    }

    setState(() {
      _showOfflineBanner = !_isOnline;
    });
  }

  void _handleGoingOffline() {
    final offlineService = context.read<OfflineStorageService>();
    offlineService.enableOfflineMode();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã chuyển sang chế độ offline'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleComingOnline() {
    final offlineService = context.read<OfflineStorageService>();
    offlineService.syncPendingData().then((syncCount) {
      if (mounted && syncCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.white),
                const SizedBox(width: 8),
                Text('Đã đồng bộ $syncCount đơn hàng'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    setState(() {
      _showOfflineBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showOfflineBanner) _buildOfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Consumer<OfflineStorageService>(
      builder: (context, offlineService, child) {
        final pendingCount = offlineService.pendingOrdersCount;
        
        return Container(
          width: double.infinity,
          color: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Chế độ Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (pendingCount > 0)
                        Text(
                          '$pendingCount đơn hàng chờ đồng bộ',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (pendingCount > 0)
                  TextButton(
                    onPressed: () => _showPendingOrdersDialog(context, offlineService),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPendingOrdersDialog(BuildContext context, OfflineStorageService offlineService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đơn hàng chờ đồng bộ'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<Order>>(
            future: offlineService.getPendingOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final pendingOrders = snapshot.data ?? [];
              if (pendingOrders.isEmpty) {
                return const Center(
                  child: Text('Không có đơn hàng nào chờ đồng bộ'),
                );
              }

              return ListView.builder(
                itemCount: pendingOrders.length,
                itemBuilder: (context, index) {
                  final order = pendingOrders[index];
                  return ListTile(
                    leading: Icon(
                      Icons.schedule,
                      color: Colors.orange,
                    ),
                    title: Text(order.orderNumber),
                    subtitle: Text(
                      '${order.items.length} món - ${_formatCurrency(order.totalAmount)}',
                    ),
                    trailing: Text(
                      _formatTimeAgo(order.creationTime),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          if (_isOnline)
            ElevatedButton(
              onPressed: () async {
                await offlineService.syncPendingData();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Đồng bộ ngay'),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}₫';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

class NetworkStatusProvider extends ChangeNotifier {
  bool _isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool get isOnline => _isOnline;

  NetworkStatusProvider() {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);

    _subscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = result.any((r) => r != ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}