import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import '../models/table_models.dart';
import '../utils/thermal_printer_image_utils.dart';
import '../utils/invoice_layout_utils.dart';
import 'auth_service.dart';

/// Service xử lý in hóa đơn qua máy in nhiệt WiFi (Xprinter T80W) - Đã refactor
class NetworkThermalPrinterService {
  static final NetworkThermalPrinterService _instance =
      NetworkThermalPrinterService._internal();
  factory NetworkThermalPrinterService() => _instance;
  NetworkThermalPrinterService._internal();

  static const String _printerIPKey = 'printer_ip';
  static const String _printerPortKey = 'printer_port';
  static const int defaultPort = 9100; // ESC/POS standard port

  String? _printerIP;
  int _printerPort = defaultPort;
  bool _isConnected = false;

  final List<String> _discoveredPrinters = [];

  /// Khởi tạo và load cài đặt đã lưu
  Future<void> initialize() async {
    await _loadSavedSettings();
  }

  /// Load cài đặt máy in đã lưu
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _printerIP = prefs.getString(_printerIPKey);
      _printerPort = prefs.getInt(_printerPortKey) ?? defaultPort;
    } catch (e) {
      // Log error
    }
  }

  /// Lưu cài đặt máy in
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_printerIP != null) {
        await prefs.setString(_printerIPKey, _printerIP!);
      }
      await prefs.setInt(_printerPortKey, _printerPort);
    } catch (e) {
      // Log error
    }
  }

  /// Quét tìm máy in trong mạng local
  Future<List<String>> discoverPrinters() async {
    try {
      // Lấy thông tin mạng hiện tại
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();

      if (wifiIP == null) {
        throw NetworkPrinterException('Không thể lấy địa chỉ IP của thiết bị');
      }

      // Parse network từ IP của thiết bị
      final parts = wifiIP.split('.');
      if (parts.length != 4) {
        throw NetworkPrinterException('Địa chỉ IP không hợp lệ: $wifiIP');
      }

      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
      _discoveredPrinters.clear();

      // Quét từ 100-254 trong subnet (bỏ qua range thấp để nhanh hơn)
      final futures = <Future<void>>[];
      for (int i = 100; i <= 254; i++) {
        final ip = '$subnet.$i';
        futures.add(_checkPrinterAtIP(ip));
      }

      // Chạy song song với timeout
      await Future.wait(futures).timeout(const Duration(seconds: 30));

      return _discoveredPrinters;
    } catch (e) {
      throw NetworkPrinterException('Lỗi quét tìm máy in: $e');
    }
  }

  /// Kiểm tra máy in tại IP cụ thể
  Future<void> _checkPrinterAtIP(String ip) async {
    try {
      if (await _isXprinter(ip)) {
        _discoveredPrinters.add(ip);
      }
    } catch (e) {
      // Ignore individual IP check errors
    }
  }

  /// Kiểm tra xem IP có phải máy in Xprinter không
  Future<bool> _isXprinter(String ip) async {
    try {
      // Thử kết nối đến port ESC/POS
      final socket = await Socket.connect(
        ip,
        defaultPort,
        timeout: const Duration(seconds: 2),
      );

      // Gửi lệnh status query
      final statusCommand = Uint8List.fromList([
        0x10,
        0x04,
        0x01,
      ]); // ESC/POS status query
      socket.add(statusCommand);

      // Đợi response
      final response = await socket.first.timeout(const Duration(seconds: 1));
      await socket.close();

      // Nếu có response, có thể là máy in ESC/POS
      return response.isNotEmpty;
    } catch (e) {
      // Không thể kết nối hoặc không phải máy in
      return false;
    }
  }

  /// Cài đặt địa chỉ IP máy in
  Future<void> configurePrinter(String ip, {int port = defaultPort}) async {
    try {
      // Kiểm tra kết nối
      final isReachable = await _testConnection(ip, port);
      if (!isReachable) {
        throw NetworkPrinterException(
          'Không thể kết nối đến máy in tại $ip:$port',
        );
      }

      _printerIP = ip;
      _printerPort = port;
      _isConnected = true;

      await _saveSettings();
    } catch (e) {
      rethrow;
    }
  }

  /// Kiểm tra kết nối đến máy in
  Future<bool> _testConnection(String ip, int port) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 3),
      );
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra trạng thái kết nối hiện tại
  Future<bool> checkConnection() async {
    if (_printerIP == null) {
      _isConnected = false;
      return false;
    }

    _isConnected = await _testConnection(_printerIP!, _printerPort);
    return _isConnected;
  }

  /// In hóa đơn cho bàn (sử dụng InvoiceLayoutUtils)
  Future<void> printInvoice(
    TableDetailDto tableDetail, {
    AuthService? authService,
  }) async {
    if (_printerIP == null) {
      throw NetworkPrinterException('Chưa cấu hình địa chỉ IP máy in');
    }

    try {
      // Tạo hình ảnh hóa đơn với QR code
      final imageBytes = await InvoiceLayoutUtils.createInvoiceImage(
        tableDetail,
        authService: authService,
      );

      // Convert image thành ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      // Decode và xử lý image cho thermal printer
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw NetworkPrinterException('Lỗi khi xử lý hình ảnh hóa đơn');
      }

      // Convert thành monochrome cho thermal printer
      final processedImage =
          ThermalPrinterImageUtils.processImageForThermalPrinter(image);

      // Tạo ESC/POS commands cho image
      List<int> bytes = [];

      // In hình ảnh hóa đơn với cài đặt tối ưu cho thermal printer
      bytes += generator.imageRaster(processedImage, align: PosAlign.center);

      // Cắt giấy
      bytes += generator.cut();

      // Gửi dữ liệu đến máy in qua WiFi
      await _sendToPrinter(bytes);
    } catch (e) {
      throw NetworkPrinterException('Lỗi khi in hóa đơn: $e');
    }
  }

  /// In test page để kiểm tra máy in
  Future<void> printTestPage() async {
    if (_printerIP == null) {
      throw NetworkPrinterException('Chưa cấu hình địa chỉ IP máy in');
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text(
        'TEST PAGE',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        'Xprinter T80W WiFi',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'Smart Restaurant System',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'May in hoat dong binh thuong',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'IP: $_printerIP:$_printerPort',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        DateTime.now().toString(),
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.cut();

      await _sendToPrinter(bytes);
    } catch (e) {
      throw NetworkPrinterException('Lỗi khi in trang thử: $e');
    }
  }

  /// Gửi dữ liệu in đến máy in qua WiFi với retry mechanism
  Future<void> _sendToPrinter(List<int> bytes) async {
    const int maxRetries = 3;
    const int chunkSize = 1024; // Gửi theo từng chunk nhỏ

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      Socket? socket;
      try {
        // Kết nối đến máy in với timeout dài hơn
        socket = await Socket.connect(
          _printerIP!,
          _printerPort,
          timeout: const Duration(seconds: 10),
        );

        // Kiểm tra trạng thái máy in trước khi gửi
        await _checkPrinterStatus(socket);

        // Gửi dữ liệu theo chunks để tránh buffer overflow
        for (int i = 0; i < bytes.length; i += chunkSize) {
          final end = (i + chunkSize < bytes.length)
              ? i + chunkSize
              : bytes.length;
          final chunk = bytes.sublist(i, end);

          socket.add(chunk);
          await socket.flush();

          // Đợi một chút giữa các chunks
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Đợi máy in xử lý hoàn toàn
        await Future.delayed(const Duration(seconds: 2));

        // Verify data was sent successfully
        await _verifyPrintCompletion(socket);

        return; // Success, exit retry loop
      } catch (e) {
        if (attempt == maxRetries) {
          throw NetworkPrinterException(
            'Lỗi gửi dữ liệu sau $maxRetries lần thử: $e',
          );
        }

        // Đợi trước khi thử lại
        await Future.delayed(Duration(seconds: attempt));
      } finally {
        try {
          await socket?.close();
        } catch (e) {
          // Log error
        }
      }
    }
  }

  /// Kiểm tra trạng thái máy in
  Future<void> _checkPrinterStatus(Socket socket) async {
    try {
      // Gửi lệnh kiểm tra trạng thái ESC/POS
      final statusCommand = [0x10, 0x04, 0x01]; // DLE EOT n=1 (printer status)
      socket.add(statusCommand);
      await socket.flush();

      // Đợi response (với timeout ngắn)
      final response = await socket.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('Printer status timeout'),
      );

      // Kiểm tra status byte
      if (response.isNotEmpty) {
        final status = response[0];
        if ((status & 0x08) != 0) {
          // Paper out
          throw NetworkPrinterException('Máy in hết giấy');
        }
        if ((status & 0x20) != 0) {
          // Cover open
          throw NetworkPrinterException('Nắp máy in đang mở');
        }
        if ((status & 0x40) != 0) {
          // Feed button
          throw NetworkPrinterException('Máy in đang bận');
        }
      }
    } catch (e) {
      // Không throw error nếu chỉ là timeout status check
    }
  }

  /// Verify print completion
  Future<void> _verifyPrintCompletion(Socket socket) async {
    try {
      // Gửi lệnh kiểm tra buffer trống
      final bufferCommand = [0x10, 0x04, 0x02]; // DLE EOT n=2 (buffer status)
      socket.add(bufferCommand);
      await socket.flush();

      // Đợi buffer được xử lý
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Log error
    }
  }

  /// Lấy thông tin máy in hiện tại
  Map<String, dynamic> getPrinterInfo() {
    return {
      'ip': _printerIP,
      'port': _printerPort,
      'isConnected': _isConnected,
      'printerModel': 'Xprinter T80W',
    };
  }

  /// Reset cài đặt máy in
  Future<void> resetPrinterSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_printerIPKey);
      await prefs.remove(_printerPortKey);

      _printerIP = null;
      _printerPort = defaultPort;
      _isConnected = false;
      _discoveredPrinters.clear();
    } catch (e) {
      // Log error
    }
  }

  /// Cleanup resources
  void dispose() {
    _isConnected = false;
  }
}

/// Exception class cho Network Thermal Printer Service
class NetworkPrinterException implements Exception {
  final String message;
  final String? errorCode;

  const NetworkPrinterException(this.message, {this.errorCode});

  @override
  String toString() {
    return 'NetworkPrinterException: $message';
  }
}
