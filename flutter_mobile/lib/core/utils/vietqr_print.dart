import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' as pos;

/// =======================
/// 1) EMVCo / VietQR utils
/// =======================

String buildVietQRData({
  required String bankBin, // ví dụ "970407" (Techcombank)
  required String accountNo, // ví dụ "19035669437012"
  int? amount, // số tiền VND (optional)
  String? addInfo, // nội dung chuyển khoản (optional, không dấu càng tốt)
}) {
  // 00-01 header
  String payload = "000201"; // 00 02 "01"
  payload += "010211"; // 01 02 "11" (QR static with tip/amount allowed)

  // 38 - Merchant Account Information (VietQR AID + BIN + AccountNo)
  String mai = "0010A000000727"; // 00 10 A000000727 (AID VietQR)
  // 01 <len> <BIN>
  mai += "01${bankBin.length.toString().padLeft(2, '0')}$bankBin";
  // 02 <len> <AccountNo>
  mai += "02${accountNo.length.toString().padLeft(2, '0')}$accountNo";

  payload += "38${mai.length.toString().padLeft(2, '0')}$mai";

  // 54 - Amount (optional)
  if (amount != null) {
    final amt = amount.toString();
    payload += "54${amt.length.toString().padLeft(2, '0')}$amt";
  }

  // 62 - Additional Data (only addInfo here)
  if (addInfo != null && addInfo.isNotEmpty) {
    final info = addInfo;
    final infoLen = info.length.toString().padLeft(2, '0');
    // 62 <len total> 01 <len info> <info>
    final totalLen =
        (2 +
        info.length); // "01" + infoLen(2) + info(n)  -> nhưng theo EMV là 2 + n (ID+LEN không tính trong total của sub? => 01 + LL + V, vậy cộng 2 + n)
    payload += "62${(totalLen).toString().padLeft(2, '0')}01$infoLen$info";
  }

  // 63 - CRC
  payload += "6304";
  final crc = _crc16Ccitt(payload);
  payload += crc;
  return payload;
}

/// CRC16-CCITT (polynomial 0x1021, init 0xFFFF)
String _crc16Ccitt(String data) {
  int crc = 0xFFFF;
  final bytes = data.codeUnits;
  for (final b in bytes) {
    crc ^= (b << 8);
    for (int i = 0; i < 8; i++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc <<= 1;
      }
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}

/// =======================================
/// 2) Native ESC/POS QR (nét nhất) cho T80W
/// =======================================

Future<void> _printQrEscPosNative({
  required Socket socket,
  required String emvString,
  int moduleSize = 8, // 7~8 đẹp cho 203dpi/576dots (~36–42mm)
  int ec = 49, // 48=L, 49=M, 50=Q, 51=H
  bool center = true,
}) async {
  final List<int> bytes = [];
  void add(List<int> b) => bytes.addAll(b);

  if (center) add([0x1B, 0x61, 0x01]); // ESC a 1 (center)

  // Model 2
  add([0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
  // Module size
  add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, moduleSize]);
  // Error correction level
  add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, ec]);

  // Store data
  final dataBytes = ascii.encode(emvString);
  final len = dataBytes.length + 3; // 3 = 0x31,0x50,0x30
  final pL = len & 0xFF;
  final pH = (len >> 8) & 0xFF;
  add([0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
  add(dataBytes);

  // Print
  add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);

  // Feed
  add([0x1B, 0x64, 0x03]);

  socket.add(bytes);

  if (center) socket.add([0x1B, 0x61, 0x00]); // ESC a 0 (left)
}

/// =======================================================
/// 3) Fallback: render QR ảnh raster rồi in (mọi máy đều chạy)
/// =======================================================

Future<Uint8List> _buildQrPng({
  required String emvString,
  int modulePx = 8, // px/ô QR; 8px rất nét trên 203dpi
  int quietModules = 4, // lề trắng theo chuẩn
}) async {
  final result = QrValidator.validate(
    data: emvString,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );
  if (result.status != QrValidationStatus.valid || result.qrCode == null) {
    throw Exception("EMV string không hợp lệ để tạo QR");
  }
  final qr = result.qrCode!;
  final modules = qr.moduleCount;
  final sizePx = (modules + quietModules * 2) * modulePx;

  final rec = ui.PictureRecorder();
  final canvas = ui.Canvas(rec);
  final white = ui.Paint()..color = const ui.Color(0xFFFFFFFF);

  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, sizePx.toDouble(), sizePx.toDouble()),
    white,
  );

  // Sử dụng QrPainter để render thay vì truy cập trực tiếp modules
  final painter = QrPainter.withQr(
    qr: qr,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: ui.Color(0xFF000000),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: ui.Color(0xFF000000),
    ),
    gapless: true,
  );

  painter.paint(canvas, ui.Size(sizePx.toDouble(), sizePx.toDouble()));

  final img = await rec.endRecording().toImage(sizePx, sizePx);
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  return png!.buffer.asUint8List();
}

Future<void> _printQrAsRaster({
  required Socket socket,
  required String emvString,
}) async {
  final profile = await pos.CapabilityProfile.load();
  final gen = pos.Generator(pos.PaperSize.mm80, profile);

  final png = await _buildQrPng(
    emvString: emvString,
    modulePx: 8, // 8px/module → QR ~40–50mm (tùy ma trận)
    quietModules: 4,
  );

  final img = decodeImage(png)!;

  socket.add(
    gen.imageRaster(
      img,
      align: pos.PosAlign.center,
      highDensityHorizontal: true,
      highDensityVertical: true,
    ),
  );
  socket.add(gen.feed(3));
}

/// ======================================
/// 4) API duy nhất bạn cần gọi từ app
/// ======================================
/// - Thử in native ESC/POS trước (nét và chuẩn nhất)
/// - Nếu có exception → fallback sang raster
/// Lưu ý: ESC/POS qua socket thường không trả ACK, nên
///        exception không phải lúc nào cũng ném ra nếu firmware bỏ qua.
///        T80W thường hỗ trợ tốt GS(k), nên ưu tiên native.
Future<void> printVietQR({
  required String printerIp,
  int port = 9100,
  required String emvString,
  bool fallbackToRasterOnError = true,
  int moduleSizeNative = 8,
  int ecLevelNative = 49, // 49 = 'M'
}) async {
  Socket? socket;
  try {
    socket = await Socket.connect(
      printerIp,
      port,
      timeout: const Duration(seconds: 5),
    );

    // Cách 1: Native ESC/POS
    await _printQrEscPosNative(
      socket: socket,
      emvString: emvString,
      moduleSize: moduleSizeNative,
      ec: ecLevelNative,
    );
  } catch (e) {
    // Có lỗi kết nối/ghi hoặc lỗi lệnh
    if (fallbackToRasterOnError && socket != null) {
      try {
        await _printQrAsRaster(socket: socket, emvString: emvString);
      } catch (_) {
        rethrow;
      }
    } else {
      rethrow;
    }
  } finally {
    await socket?.flush();
    await socket?.close();
  }
}
