import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/network_thermal_printer_service.dart';
import '../../../shared/widgets/common_app_bar.dart';

/// Màn hình cài đặt máy in nhiệt WiFi (Xprinter T80W)
class NetworkPrinterSettingsScreen extends StatefulWidget {
  const NetworkPrinterSettingsScreen({super.key});

  @override
  State<NetworkPrinterSettingsScreen> createState() => _NetworkPrinterSettingsScreenState();
}

class _NetworkPrinterSettingsScreenState extends State<NetworkPrinterSettingsScreen> {
  final NetworkThermalPrinterService _printerService = NetworkThermalPrinterService();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  
  List<String> _discoveredPrinters = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _currentIP;
  int _currentPort = 9100;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _initializePrinter() async {
    try {
      await _printerService.initialize();
      final printerInfo = _printerService.getPrinterInfo();
      
      setState(() {
        _currentIP = printerInfo['ip'];
        _currentPort = printerInfo['port'] ?? 9100;
        _isConnected = printerInfo['isConnected'] ?? false;
        
        if (_currentIP != null) {
          _ipController.text = _currentIP!;
        }
        _portController.text = _currentPort.toString();
      });

      // Kiểm tra kết nối hiện tại
      _checkCurrentConnection();
      
    } catch (e) {
    }
  }

  Future<void> _checkCurrentConnection() async {
    try {
      final isConnected = await _printerService.checkConnection();
      setState(() {
        _isConnected = isConnected;
      });
    } catch (e) {
    }
  }

  Future<void> _discoverPrinters() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final printers = await _printerService.discoverPrinters();
      setState(() {
        _discoveredPrinters = printers;
        _isScanning = false;
      });

      if (printers.isEmpty) {
        setState(() {
          _errorMessage = 'Không tìm thấy máy in Xprinter nào trong mạng';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isScanning = false;
      });
    }
  }

  Future<void> _configurePrinter() async {
    final ip = _ipController.text.trim();
    final portText = _portController.text.trim();

    if (ip.isEmpty) {
      _showError('Vui lòng nhập địa chỉ IP');
      return;
    }

    if (portText.isEmpty) {
      _showError('Vui lòng nhập port');
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      _showError('Port không hợp lệ (1-65535)');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      await _printerService.configurePrinter(ip, port: port);
      
      setState(() {
        _currentIP = ip;
        _currentPort = port;
        _isConnected = true;
        _isConnecting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã kết nối với máy in tại $ip:$port'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isConnecting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printTestPage() async {
    try {
      await _printerService.printTestPage();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã in trang thử thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi in trang thử: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn reset cài đặt máy in không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _printerService.resetPrinterSettings();
      setState(() {
        _currentIP = null;
        _currentPort = 9100;
        _isConnected = false;
        _ipController.clear();
        _portController.text = '9100';
        _discoveredPrinters.clear();
        _errorMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã reset cài đặt máy in'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _selectDiscoveredPrinter(String ip) {
    setState(() {
      _ipController.text = ip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Cài đặt máy in WiFi',
      ),
      body: RefreshIndicator(
        onRefresh: _discoverPrinters,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin máy in
              _buildPrinterInfo(),
              
              const SizedBox(height: 24),

              // Cấu hình thủ công
              _buildManualConfiguration(),

              const SizedBox(height: 24),

              // Tự động tìm máy in
              _buildAutoDiscovery(),

              const SizedBox(height: 24),

              // Nút test in và reset
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrinterInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Xprinter T80W (WiFi)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected 
                ? 'Đã kết nối: $_currentIP:$_currentPort'
                : 'Chưa kết nối máy in',
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualConfiguration() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cấu hình thủ công',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // IP Address field
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ IP máy in',
                hintText: 'Ví dụ: 192.168.1.100',
                prefixIcon: Icon(Icons.computer),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Port field
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '9100',
                prefixIcon: Icon(Icons.settings_ethernet),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Connect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnecting ? null : _configurePrinter,
                icon: _isConnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi),
                label: Text(_isConnecting ? 'Đang kết nối...' : 'Kết nối'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoDiscovery() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tự động tìm máy in',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _isScanning ? null : _discoverPrinters,
                  icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                ),
              ],
            ),

            if (_isScanning) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Đang quét mạng tìm máy in...'),
            ],

            if (_discoveredPrinters.isEmpty && !_isScanning) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa tìm thấy máy in',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhấn nút tìm kiếm để quét mạng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_discoveredPrinters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Máy in được tìm thấy:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _discoveredPrinters.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final ip = _discoveredPrinters[index];
                  final isSelected = _ipController.text == ip;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                        ? Border.all(color: Colors.blue)
                        : Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.print,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        ip,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: const Text('Xprinter T80W'),
                      trailing: isSelected 
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                      onTap: () => _selectDiscoveredPrinter(ip),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Test print button
        if (_isConnected)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printTestPage,
              icon: const Icon(Icons.print),
              label: const Text('In trang thử'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Reset button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset cài đặt'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}