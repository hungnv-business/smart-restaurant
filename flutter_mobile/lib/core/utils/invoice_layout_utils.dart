import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_mobile/core/utils/emvco_vietqr_builder.dart';
import '../models/order/order_details_models.dart';
import '../enums/restaurant_enums.dart';
import '../utils/price_formatter.dart';
import '../services/auth/auth_service.dart';
import 'thermal_printer_image_utils.dart';
import 'number_to_words_utils.dart';

/// Utilities cho layout hóa đơn máy in nhiệt
class InvoiceLayoutUtils {
  /// Tạo hình ảnh hóa đơn với tiếng Việt (80mm width = 576 pixels)
  static Future<Uint8List> createInvoiceImage(
    OrderDetailsDto orderDetails, {
    AuthService? authService,
  }) async {
    // Cấu hình cho máy in thermal với độ phân giải cao
    const int imageWidth = 576 * 2;
    const int maxHeight = 3000; // Đủ lớn để chứa mọi nội dung

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;

    // Background trắng với chiều cao lớn
    canvas.drawRect(
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), maxHeight.toDouble()),
      Paint()..color = Colors.white,
    );

    double currentY = 32;
    const double padding = 48;
    const double lineSpacing = 8;

    // Helper functions cho layout
    final layoutHelper = InvoiceLayoutHelper(
      canvas: canvas,
      paint: paint,
      imageWidth: imageWidth,
      padding: padding,
      lineSpacing: lineSpacing,
    );

    // === HEADER - THEO TEMPLATE ===
    currentY = layoutHelper.drawText(
      'CHỢ DỘC QUÁN',
      fontSize: 24,
      isBold: true,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    currentY = layoutHelper.drawText(
      'TDP Quang Biểu, Phường Nếnh',
      fontSize: 12,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    currentY = layoutHelper.drawText(
      'TP. Bắc Ninh',
      fontSize: 12,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    currentY = layoutHelper.drawText(
      'ĐT: 033 6953966',
      fontSize: 12,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    currentY += 8;

    // === TIÊU ĐỀ HÓA ĐƠN ===
    currentY = layoutHelper.drawText(
      'THÔNG TIN THANH TOÁN',
      fontSize: 16,
      isBold: true,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    // === THÔNG TIN BÀN VÀ CHI TIẾT ===
    currentY = layoutHelper.drawText(
      'Bàn ${orderDetails.tableNumber ?? orderDetails.orderNumber}',
      fontSize: 14,
      isBold: true,
      currentY: currentY,
    );

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Lấy thông tin thu ngân từ AuthService
    final cashierName = authService?.userInfo?.displayName ?? 'N/A';

    // Hàng thông tin song song
    currentY = layoutHelper.drawTwoColumnText(
      'Ngày: $dateStr',
      'Số: 021900003',
      currentY: currentY,
    );
    currentY = layoutHelper.drawTwoColumnText(
      'Thu ngân: $cashierName',
      'In lúc: $timeStr',
      currentY: currentY,
    );
    currentY = layoutHelper.drawTwoColumnText(
      'Giờ vào: $timeStr',
      'Giờ ra: $timeStr',
      currentY: currentY,
    );

    currentY += 8;

    // === TABLE 4 CỘT VỚI VIỀN - CHỈ HIỂN THỊ MÓN ĐÃ PHỤC VỤ ===
    final servedItems = orderDetails.orderItems
        .where((item) => item.status == OrderItemStatus.served)
        .toList();
    currentY = layoutHelper.drawOrderTable(servedItems, currentY);

    // === TỔNG TIỀN CHỈ CHO CÁC MÓN ĐÃ PHỤC VỤ ===
    final servedTotal = servedItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    if (servedTotal > 0) {
      final totalAmountStr = PriceFormatter.formatWithoutSymbol(
        servedTotal.toInt(),
      );
      final totalAmountInWords = NumberToWordsUtils.numberToWords(
        servedTotal.toInt(),
      );

      currentY += 12;
      currentY = layoutHelper.drawText(
        'Tổng: ${totalAmountStr.replaceAll(',', '.')}',
        fontSize: 16,
        isBold: true,
        textAlign: TextAlign.right,
        currentY: currentY,
      );

      currentY += 8;
      currentY = layoutHelper.drawText(
        'Bằng chữ: $totalAmountInWords',
        fontSize: 12,
        textAlign: TextAlign.left,
        currentY: currentY,
      );
    }

    currentY += 12;

    // === QR CODE THANH TOÁN ===
    currentY = await _addQRCodeSection(orderDetails, layoutHelper, currentY);

    // === FOOTER ===
    currentY = layoutHelper.drawText(
      'Cảm ơn Quý khách. Hẹn gặp lại !',
      fontSize: 12,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    currentY += 80; // Padding cuối

    // Render và crop image
    final finalHeight = (currentY + 50).round();
    final picture = recorder.endRecording();
    final fullImg = await picture.toImage(imageWidth, maxHeight);

    // Crop lại theo chiều cao thực tế
    final finalImg = await ThermalPrinterImageUtils.cropImage(
      originalImage: fullImg,
      targetSize: Size(imageWidth.toDouble(), finalHeight.toDouble()),
    );

    return await ThermalPrinterImageUtils.imageToBytes(finalImg);
  }

  /// Thêm section QR code thanh toán với thông tin Techcombank
  static Future<double> _addQRCodeSection(
    OrderDetailsDto orderDetails,
    InvoiceLayoutHelper helper,
    double currentY,
  ) async {
    currentY += 16;

    currentY = helper.drawText(
      'QR THANH TOÁN',
      fontSize: 14,
      isBold: true,
      textAlign: TextAlign.center,
      currentY: currentY,
    );

    try {
      // Tạo QR data EMVCo thủ công
      final qrData = EmvcoVietQrBuilder.buildPaymentQRData(orderDetails);

      // Tạo QR code từ data EMVCo (không cần API)
      final qrBytes = await ThermalPrinterImageUtils.generateQRFromData(qrData);

      if (qrBytes.isNotEmpty) {
        // Tính toán kích thước QR phù hợp với khổ giấy 80mm (576px)
        // Sử dụng 65% độ rộng canvas để QR vừa phải và rõ nét trên giấy nhiệt
        final qrWidth = (helper.imageWidth * 0.65)
            .toInt(); // ~374px cho canvas 576px

        // Prepare QR for printing - kích thước 65% width phù hợp giấy 80mm
        final preparedQR = await ThermalPrinterImageUtils.prepareQRForPrint(
          qrBytes,
          targetWidth: qrWidth,
        );

        if (preparedQR.isNotEmpty) {
          // Convert to UI Image
          final qrUIImage =
              await ThermalPrinterImageUtils.convertBytesToUIImage(preparedQR);

          // Vẽ QR code căn giữa với kích thước 65% width phù hợp giấy 80mm
          ThermalPrinterImageUtils.drawQRCentered(
            canvas: helper.canvas,
            qrImage: qrUIImage,
            canvasWidth: helper.imageWidth.toDouble(),
            currentY: currentY,
            qrSize: qrWidth.toDouble(), // 65% width phù hợp giấy 80mm
          );

          currentY += qrWidth.toDouble() + 20; // QR height + padding
        }
      }
    } catch (e) {
      // Continue without QR nếu có lỗi
    }

    // currentY = helper.drawText(
    //   'Quét mã để thanh toán',
    //   fontSize: 10,
    //   textAlign: TextAlign.center,
    //   currentY: currentY,
    // );

    // currentY = helper.drawText(
    //   'Techcombank - NGUYEN VAN HUNG',
    //   fontSize: 9,
    //   textAlign: TextAlign.center,
    //   currentY: currentY,
    // );

    currentY += 12;
    return currentY;
  }

  // In QR ESC/POS native (GS ( k) từ chuỗi EMVCo `data`
  // moduleSize: 3..16 (T80W 203dpi: 7–8 là đẹp); ec: 48=L,49=M,50=Q,51=H
  static Future<void> printQrEscPosNative({
    required Socket socket,
    required String data,
    int moduleSize = 8, // ~40 mm trên giấy 80mm (576 dots)
    int ec = 49, // 49 = M (khuyến nghị)
    bool center = true,
  }) async {
    List<int> bytes = [];
    void add(List<int> b) => bytes.addAll(b);

    if (center) add([0x1B, 0x61, 0x01]); // ESC a 1: center

    // Model 2
    add([0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
    // Module size
    add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, moduleSize]);
    // Error correction level
    add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, ec]);

    // Store data
    final dataBytes = ascii.encode(data);
    final len = dataBytes.length + 3; // 3 = 49, 80, 48
    final pL = len & 0xFF, pH = (len >> 8) & 0xFF;
    add([0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
    add(dataBytes);

    // Print the QR
    add([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);

    // Feed 3 lines
    add([0x1B, 0x64, 0x03]);

    socket.add(bytes);

    if (center) socket.add([0x1B, 0x61, 0x00]); // ESC a 0: left
  }
}

/// Helper class cho việc vẽ layout hóa đơn
class InvoiceLayoutHelper {
  final Canvas canvas;
  final Paint paint;
  final int imageWidth;
  final double padding;
  final double lineSpacing;

  InvoiceLayoutHelper({
    required this.canvas,
    required this.paint,
    required this.imageWidth,
    required this.padding,
    required this.lineSpacing,
  });

  /// Helper function để vẽ text với căn chỉnh
  double drawText(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
    bool isBold = false,
    required double currentY,
  }) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize * 4.0,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
      fontFamily: 'monospace',
      height: 1.4,
      letterSpacing: 0.5,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    textPainter.layout(maxWidth: imageWidth - (padding * 2));

    double xPosition;
    if (textAlign == TextAlign.center) {
      final contentWidth = imageWidth - (padding * 2);
      final remainingSpace = contentWidth - textPainter.width;
      xPosition = padding + (remainingSpace / 2);
    } else if (textAlign == TextAlign.right) {
      xPosition = imageWidth - padding - textPainter.width;
    } else {
      xPosition = padding;
    }

    textPainter.paint(canvas, Offset(xPosition, currentY));
    return currentY + textPainter.height + lineSpacing;
  }

  /// Helper function để vẽ text 2 cột (trái và phải)
  double drawTwoColumnText(
    String leftText,
    String rightText, {
    required double currentY,
  }) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12 * 4.0,
      height: 1.5,
      fontWeight: FontWeight.w700,
      fontFamily: 'monospace',
      letterSpacing: 0.4,
    );

    // Vẽ text trái
    final leftSpan = TextSpan(text: leftText, style: textStyle);
    final leftPainter = TextPainter(
      text: leftSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    leftPainter.layout();
    leftPainter.paint(canvas, Offset(padding, currentY));

    // Vẽ text phải
    final rightSpan = TextSpan(text: rightText, style: textStyle);
    final rightPainter = TextPainter(
      text: rightSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    rightPainter.layout();
    rightPainter.paint(
      canvas,
      Offset(imageWidth - padding - rightPainter.width, currentY),
    );

    return currentY + leftPainter.height + 6;
  }

  /// Helper function để vẽ table với viền
  double drawOrderTable(List<dynamic> orderItems, double currentY) {
    final tableWidth = imageWidth - (padding * 2);
    final tableX = padding;

    // Chiều rộng 4 cột
    final col1Width = tableWidth * 0.45; // Món ăn (45%)
    final col2Width = tableWidth * 0.1; // SL (10%)
    final col3Width = tableWidth * 0.225; // ĐG (22.5%)
    final col4Width = tableWidth * 0.225; // Thành tiền (22.5%)

    final rowHeight = 80.0;
    final borderPaint = Paint()..color = Colors.black;

    // Helper function để vẽ border cho cell
    void drawCellBorder(double x, double y, double width, double height) {
      const thickness = 2.0;

      // Top border
      canvas.drawRect(Rect.fromLTWH(x, y, width, thickness), borderPaint);
      // Bottom border
      canvas.drawRect(
        Rect.fromLTWH(x, y + height - thickness, width, thickness),
        borderPaint,
      );
      // Left border
      canvas.drawRect(Rect.fromLTWH(x, y, thickness, height), borderPaint);
      // Right border
      canvas.drawRect(
        Rect.fromLTWH(x + width - thickness, y, thickness, height),
        borderPaint,
      );
    }

    // === HEADER ===
    final headerY = currentY;

    // Vẽ khung header
    drawCellBorder(tableX, headerY, col1Width, rowHeight);
    drawCellBorder(tableX + col1Width, headerY, col2Width, rowHeight);
    drawCellBorder(
      tableX + col1Width + col2Width,
      headerY,
      col3Width,
      rowHeight,
    );
    drawCellBorder(
      tableX + col1Width + col2Width + col3Width,
      headerY,
      col4Width,
      rowHeight,
    );

    // Header text
    _drawTableCell(
      'Mặt hàng',
      tableX,
      col1Width,
      13,
      headerY,
      rowHeight,
      isBold: true,
      align: TextAlign.left,
    );
    _drawTableCell(
      'SL',
      tableX + col1Width,
      col2Width,
      13,
      headerY,
      rowHeight,
      isBold: true,
      align: TextAlign.center,
    );
    _drawTableCell(
      'ĐG',
      tableX + col1Width + col2Width,
      col3Width,
      13,
      headerY,
      rowHeight,
      isBold: true,
      align: TextAlign.center,
    );
    _drawTableCell(
      'T tiền',
      tableX + col1Width + col2Width + col3Width,
      col4Width,
      13,
      headerY,
      rowHeight,
      isBold: true,
      align: TextAlign.right,
    );

    currentY = headerY + rowHeight;

    // === DATA ROWS ===
    for (final item in orderItems) {
      final rowY = currentY;

      // Vẽ khung data row
      drawCellBorder(tableX, rowY, col1Width, rowHeight);
      drawCellBorder(tableX + col1Width, rowY, col2Width, rowHeight);
      drawCellBorder(
        tableX + col1Width + col2Width,
        rowY,
        col3Width,
        rowHeight,
      );
      drawCellBorder(
        tableX + col1Width + col2Width + col3Width,
        rowY,
        col4Width,
        rowHeight,
      );

      // Data
      final unitPriceStr = PriceFormatter.formatWithoutSymbol(
        item.unitPrice.toInt(),
      );
      final totalPriceStr = PriceFormatter.formatWithoutSymbol(
        item.totalPrice.toInt(),
      );

      _drawTableCell(
        item.menuItemName,
        tableX,
        col1Width,
        12,
        rowY,
        rowHeight,
        align: TextAlign.left,
      );
      _drawTableCell(
        '$item.quantity',
        tableX + col1Width,
        col2Width,
        12,
        rowY,
        rowHeight,
        align: TextAlign.center,
      );
      _drawTableCell(
        unitPriceStr.replaceAll(',', '.'),
        tableX + col1Width + col2Width,
        col3Width,
        12,
        rowY,
        rowHeight,
        align: TextAlign.right,
      );
      _drawTableCell(
        totalPriceStr.replaceAll(',', '.'),
        tableX + col1Width + col2Width + col3Width,
        col4Width,
        12,
        rowY,
        rowHeight,
        align: TextAlign.right,
      );

      currentY += rowHeight;
    }

    return currentY;
  }

  /// Helper function để vẽ cell trong table
  void _drawTableCell(
    String text,
    double x,
    double width,
    double fontSize,
    double cellY,
    double cellHeight, {
    bool isBold = false,
    TextAlign align = TextAlign.left,
  }) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize * 4.0,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
      height: 1.3,
      fontFamily: 'monospace',
      letterSpacing: 0.3,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: 1,
    );

    textPainter.layout(maxWidth: width - 6);

    double xPos = x + 3;
    if (align == TextAlign.center) {
      xPos = x + (width - textPainter.width) / 2;
    } else if (align == TextAlign.right) {
      xPos = x + width - textPainter.width - 3;
    }

    final textHeight = textPainter.height;
    final yPos = cellY + (cellHeight - textHeight) / 2;
    textPainter.paint(canvas, Offset(xPos, yPos));
  }
}
