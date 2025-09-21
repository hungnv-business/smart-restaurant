import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_utils/esc_pos_utils.dart' as pos;
import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

/// EMVCo builder (rút gọn)
class EmvcoVietQr {
  static String build({
    required String bankBin,
    required String accountNo,
    required String accountName,
  }) {
    String tlv(String id, String v) =>
        '$id${v.length.toString().padLeft(2, '0')}$v';
    String tpl(String id, List<String> vs) => tlv(id, vs.join());

    final t00 = tlv('00', '01');
    final t01 = tlv('01', '11'); // static QR
    final t38 = tpl('38', [
      tlv('00', 'A000000727'),
      tlv('01', tlv('00', bankBin) + tlv('01', accountNo)),
      tlv('02', 'QRIBFTTA'),
    ]);
    final t53 = tlv('53', '704');
    final t58 = tlv('58', 'VN');
    final t59 = tlv('59', accountName);

    final noCrc = '$t00$t01$t38$t53$t58$t59' '6304';
    final crc = _crc16(noCrc).toUpperCase();
    return noCrc + crc;
  }

  static String _crc16(String s) {
    int crc = 0xFFFF;
    for (final ch in s.codeUnits) {
      crc ^= (ch & 0xFF) << 8;
      for (int i = 0; i < 8; i++) {
        final msb = (crc & 0x8000) != 0;
        crc = ((crc << 1) & 0xFFFF) ^ (msb ? 0x1021 : 0);
      }
    }
    return crc.toRadixString(16).padLeft(4, '0');
  }
}

/// Tạo ảnh QR fallback đúng 576 px
img.Image buildQrImage576(String data) {
  final qr = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.Q,
  );
  
  final qrImage = QrImage(qr);
  final mc = qr.moduleCount;
  final quiet = 4;
  final total = mc + quiet * 2;
  final module = 576 ~/ total;
  final size = module * total;

  final im = img.Image(size, size);
  img.fill(im, 0xFFFFFFFF); // white background

  for (int y = 0; y < mc; y++) {
    for (int x = 0; x < mc; x++) {
      if (qrImage.isDark(y, x)) {
        final l = (x + quiet) * module;
        final t = (y + quiet) * module;
        img.fillRect(
          im,
          l, // x1
          t, // y1
          l + module - 1, // x2
          t + module - 1, // y2
          0xFF000000, // black color
        );
      }
    }
  }
  return im;
}

/// Tiền xử lý ảnh chữ Việt để in raster
img.Image prepareVietnameseText(Uint8List pngBytes) {
  img.Image? im = img.decodeImage(pngBytes);
  if (im == null) throw ArgumentError('PNG decode failed');
  im = img.grayscale(im);
  if (im.width != 576) {
    im = img.copyResize(
      im,
      width: 576,
      interpolation: img.Interpolation.nearest,
    );
  }
  for (int y = 0; y < im.height; y++) {
    for (int x = 0; x < im.width; x++) {
      final l = img.getLuminance(im.getPixel(x, y));
      final black = l < 170;
      im.setPixelRgba(x, y, black ? 0 : 255, black ? 0 : 255, black ? 0 : 255);
    }
  }
  return im;
}

/// In qua Wi-Fi RAW (9100)
Future<void> printInvoiceT80W({
  required String printerIp,
  required Uint8List vietnameseTextPng,
}) async {
  final profile = await pos.CapabilityProfile.load();
  final gen = pos.Generator(pos.PaperSize.mm80, profile);

  final payload = EmvcoVietQr.build(
    bankBin: '970407',
    accountNo: '19035669437012',
    accountName: 'NGUYEN VAN HUNG',
  );

  final bytes = <int>[];

  // Reset + chỉnh nhiệt (ESC 7)
  bytes.addAll([0x1B, 0x40]);
  bytes.addAll([0x1B, 0x37, 180, 3, 15]);

  // In chữ Việt (ảnh raster)
  final txt = prepareVietnameseText(vietnameseTextPng);
  bytes.addAll(gen.imageRaster(txt, align: pos.PosAlign.center));
  bytes.addAll(gen.feed(1));

  // In QR (native nếu có, fallback ảnh 576 px)
  final qrNative = gen.qrcode(
    payload,
    align: pos.PosAlign.center,
    size: pos.QRSize.Size2,
    cor: pos.QRCorrection.Q,
  );
  if (qrNative.isNotEmpty) {
    bytes.addAll(qrNative);
  } else {
    final qrImg = buildQrImage576(payload);
    bytes.addAll(gen.imageRaster(qrImg, align: pos.PosAlign.center));
  }

  bytes.addAll(gen.feed(2));
  bytes.addAll(gen.cut());

  Socket? s;
  try {
    s = await Socket.connect(
      printerIp,
      9100,
      timeout: const Duration(seconds: 5),
    );
    s.add(bytes);
    await s.flush();
  } finally {
    await s?.close();
  }
}
