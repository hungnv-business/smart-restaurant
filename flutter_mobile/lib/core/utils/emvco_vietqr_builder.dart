import 'package:flutter_mobile/core/enums/restaurant_enums.dart';
import 'package:flutter_mobile/core/models/table_models.dart';

/// EMVCo / VietQR manual builder (TLV + CRC16-CCITT)
/// - Hỗ trợ VietQR QRIBFTTA (NAPAS Tag 38 – AID A000000727)
/// - Tạo payload EMVCo có CRC (Tag 63) đúng chuẩn
/// - Không phụ thuộc package ngoài

class EmvcoVietQrBuilder {
  /// Tạo EMVCo QR data cho thanh toán bàn (chỉ tính món đã phục vụ)
  static String buildPaymentQRData(TableDetailDto tableDetail) {
    // Chỉ tính tổng tiền các món đã phục vụ
    final servedItems = tableDetail.orderItems
        .where((item) => item.status == OrderItemStatus.served)
        .toList();
    final servedTotal = servedItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tableNumber = tableDetail.tableNumber;

    return buildVietQrIbftta(
      bankBin: '970407', // Techcombank
      accountNo: '19035669437012',
      accountName: 'NGUYEN VAN HUNG',
      amount: servedTotal.toString(), // (tuỳ chọn) cố định số tiền
      purpose: 'Thanh toan ban ' + tableNumber, // (tuỳ chọn) Tag 62-08
      // ref: 'INV-2025-0001',           // (tuỳ chọn) Tag 62-05
      dynamicQr: false, // '11' static; true => '12' dynamic
    );
  }

  /// Build VietQR (QRIBFTTA) payload (EMVCo) thủ công.
  ///
  /// [bankBin]    : BIN ngân hàng NAPAS (vd: Techcombank = '970407')
  /// [accountNo]  : Số tài khoản nhận
  /// [accountName]: Tên chủ tài khoản (không dấu/uppercase, <=25 ký tự)
  /// [amount]     : Tuỳ chọn, chuỗi số (vd '65000' hoặc '65000.00')
  /// [dynamicQr]  : false = static ('11'), true = dynamic ('12')
  /// [currency]   : ISO4217 (mặc định '704' = VND)
  /// [country]    : Mặc định 'VN'
  /// [purpose]    : Tuỳ chọn (sẽ gắn vào Tag 62-08 Purpose of Transaction)
  /// [ref]        : Tuỳ chọn (Tag 62-05 Reference Label)
  static String buildVietQrIbftta({
    required String bankBin,
    required String accountNo,
    required String accountName,
    String? amount,
    bool dynamicQr = false,
    String currency = '704',
    String country = 'VN',
    String? purpose,
    String? ref,
  }) {
    // 00: Payload Format Indicator
    final t00 = _tlv('00', '01');

    // 01: Point of Initiation Method
    final t01 = _tlv('01', dynamicQr ? '12' : '11');

    // 38: NAPAS (GUID + BIN + Account + Service=QRIBFTTA)
    final t38 = _template('38', [
      MapEntry('00', 'A000000727'), // AID
      MapEntry(
        '01',
        _tlv('00', bankBin) + _tlv('01', accountNo),
      ), // 00=BIN, 01=Account
      MapEntry('02', 'QRIBFTTA'), // Service
    ]);

    // 53: Currency (VND=704)
    final t53 = _tlv('53', currency);

    // 54: Amount (optional)
    final t54 = (amount != null && amount.isNotEmpty) ? _tlv('54', amount) : '';

    // 58: Country
    final t58 = _tlv('58', country);

    // 59: Merchant Name = tên chủ TK (ans, nên không dấu, <=25)
    final t59 = _tlv('59', _sanitizeName25(accountName));

    // 62: Additional Data Field Template (optional)
    final addl = <MapEntry<String, String>>[];
    if (ref != null && ref.isNotEmpty) {
      addl.add(MapEntry('05', _trimTo(ref, 50))); // Reference Label
    }
    if (purpose != null && purpose.isNotEmpty) {
      addl.add(MapEntry('08', _trimTo(purpose, 50))); // Purpose of Transaction
    }
    final t62 = addl.isEmpty ? '' : _template('62', addl);

    // Ghép payload (chưa có CRC): thêm '6304' làm placeholder
    final payloadNoCRC = t00 + t01 + t38 + t53 + t54 + t58 + t59 + t62 + '6304';

    // 63: CRC16-CCITT (poly 0x1021, init 0xFFFF) => 4 hex uppercase
    final crc = _crc16CcittHex(payloadNoCRC).toUpperCase();
    return payloadNoCRC + crc;
  }

  // ===================== TLV helpers =====================

  /// TLV đơn (ID = 2 ký tự số, LEN = 2 số, VAL = chuỗi)
  static String _tlv(String id, String value) {
    if (id.length != 2) {
      throw ArgumentError('EMV TLV id phải 2 ký tự số, ví dụ "59"');
    }
    final len = value.length;
    if (len > 99) {
      throw ArgumentError(
        'Giá trị TLV (ID $id) dài $len > 99. Hãy chia nhỏ bằng template lồng.',
      );
    }
    return '$id${len.toString().padLeft(2, '0')}$value';
  }

  /// Template (TLV lồng): value = concat các TLV con
  static String _template(String id, List<MapEntry<String, String>> subtags) {
    final value = subtags.map((e) => _tlv(e.key, e.value)).join();
    return _tlv(id, value);
  }

  // ===================== Utilities =====================

  /// CRC16-CCITT (0x1021, init 0xFFFF), tính trên ASCII bytes của chuỗi
  static String _crc16CcittHex(String input) {
    int crc = 0xFFFF;
    for (final ch in input.codeUnits) {
      crc ^= (ch & 0xFF) << 8;
      for (int i = 0; i < 8; i++) {
        final msb = (crc & 0x8000) != 0;
        crc = (crc << 1) & 0xFFFF;
        if (msb) crc ^= 0x1021;
      }
    }
    return crc.toRadixString(16).padLeft(4, '0');
  }

  /// Chuẩn hoá tên: bỏ dấu, uppercase, giữ A–Z 0–9 và ' _-.', cắt 25
  static String _sanitizeName25(String name) {
    final s = _removeDiacritics(
      name,
    ).toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 _\-\.]'), '');
    return s.substring(0, s.length > 25 ? 25 : s.length);
  }

  static String _trimTo(String s, int max) =>
      s.substring(0, s.length > max ? max : s.length);

  static String _removeDiacritics(String s) {
    const map = {
      'à': 'a',
      'á': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'è': 'e',
      'é': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'ì': 'i',
      'í': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'À': 'A',
      'Á': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ằ': 'A',
      'Ắ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ầ': 'A',
      'Ấ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'È': 'E',
      'É': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ề': 'E',
      'Ế': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ồ': 'O',
      'Ố': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ờ': 'O',
      'Ớ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ừ': 'U',
      'Ứ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ỳ': 'Y',
      'Ý': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    var out = s;
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out;
  }
}
