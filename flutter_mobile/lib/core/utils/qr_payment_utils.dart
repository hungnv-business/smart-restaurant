import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/table_models.dart';

/// Utilities cho tạo QR code thanh toán sử dụng VietQR API
class QRPaymentUtils {
  /// Tạo QR code thanh toán sử dụng VietQR API
  static Future<Uint8List> generatePaymentQRCode(
    TableDetailDto tableDetail,
  ) async {
    try {
      final totalAmount = tableDetail.orderSummary?.totalAmount ?? 0;
      final tableNumber = tableDetail.tableNumber;

      // Tạo URL VietQR với kích thước lớn hơn
      final qrUrl = generateVietQRUrl(
        bankBin: '970407', // Techcombank BIN
        accountNo: '19035669437012',
        accountName: 'NGUYEN VAN HUNG',
        amount: totalAmount.toInt(),
        addInfo: 'Thanh toan Ban $tableNumber - Cho Doc Quan',
        qrSize: 1024, // Tăng kích thước QR từ API để đủ chi tiết cho 80% width
      );

      // Tải ảnh QR từ VietQR API
      final response = await http.get(Uri.parse(qrUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Không thể tải QR code: ${response.statusCode}');
      }
    } catch (e) {
      // Log error nếu cần
      return Uint8List(0);
    }
  }

  /// Tạo VietQR URL theo mẫu bạn cung cấp
  static String generateVietQRUrl({
    required String bankBin, // Mã BIN của ngân hàng (VD: Techcombank = 970422)
    required String accountNo, // Số tài khoản
    required String accountName, // Tên chủ tài khoản
    int? amount, // Số tiền (có thể null nếu để khách nhập)
    String? addInfo, // Nội dung chuyển khoản
    int qrSize = 1024, // Kích thước QR code (default 1024px)
  }) {
    // Base URL của VietQR
    final baseUrl = "https://img.vietqr.io/image";

    // Encode tham số để tránh lỗi ký tự đặc biệt
    final encodedName = Uri.encodeComponent(accountName);
    final encodedInfo = addInfo != null ? Uri.encodeComponent(addInfo) : null;

    // Xây dựng URL với kích thước QR
    String url = "$baseUrl/$bankBin-$accountNo-compact2.png";

    List<String> params = [];
    if (amount != null) params.add("amount=$amount");
    if (encodedInfo != null) params.add("addInfo=$encodedInfo");
    params.add("accountName=$encodedName");
    params.add("width=$qrSize");
    params.add("height=$qrSize");

    if (params.isNotEmpty) {
      url += "?${params.join("&")}";
    }

    return url;
  }

  /// Tạo QR data EMVCo thủ công (không cần API)
  static String buildVietQRData({
    required String bankBin, // ví dụ "970407"
    required String accountNo, // ví dụ "19035669437012"
    int? amount, // số tiền
    String? addInfo, // nội dung CK
  }) {
    String payload = "000201"; // Phiên bản 01
    payload += "010211"; // QR tĩnh

    // Merchant Account Info (ID=38)
    String bankInfo = "0010A000000727"; // AID
    bankInfo += "01" + bankBin.length.toString().padLeft(2, '0') + bankBin;
    bankInfo += "02" + accountNo.length.toString().padLeft(2, '0') + accountNo;

    payload += "38" + bankInfo.length.toString().padLeft(2, '0') + bankInfo;

    // Số tiền (ID=54)
    if (amount != null) {
      final amt = amount.toString();
      payload += "54" + amt.length.toString().padLeft(2, '0') + amt;
    }

    // Nội dung (ID=62)
    if (addInfo != null && addInfo.isNotEmpty) {
      final info = addInfo;
      payload +=
          "62" +
          (info.length + 4).toString().padLeft(2, '0') +
          "01" +
          info.length.toString().padLeft(2, '0') +
          info;
    }

    // CRC16 (ID=63)
    payload += "6304";
    final crc = _crc16(payload);
    payload += crc;

    return payload;
  }

  /// Tạo EMVCo QR data cho thanh toán bàn
  static String buildPaymentQRData(TableDetailDto tableDetail) {
    final totalAmount = tableDetail.orderSummary?.totalAmount ?? 0;
    final tableNumber = tableDetail.tableNumber;

    return buildVietQRData(
      bankBin: '970407', // Techcombank BIN
      accountNo: '19035669437012',
      // accountName: 'NGUYEN VAN HUNG',
      amount: totalAmount.toInt(),
      addInfo: 'Thanh toan Ban $tableNumber - Cho Doc Quan',
    );
  }

  /// Hàm CRC16-CCITT
  static String _crc16(String payload) {
    int crc = 0xFFFF;
    final bytes = payload.codeUnits;
    for (final b in bytes) {
      crc ^= (b << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = (crc << 1) ^ 0x1021;
        } else {
          crc = (crc << 1);
        }
      }
    }
    crc &= 0xFFFF;
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
