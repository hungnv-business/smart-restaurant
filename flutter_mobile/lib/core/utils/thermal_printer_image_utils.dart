import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';

/// Utilities cho xử lý hình ảnh máy in nhiệt
class ThermalPrinterImageUtils {
  /// Xử lý image cho thermal printer với chất lượng cao
  static img.Image processImageForThermalPrinter(img.Image originalImage) {
    // Bước 1: Scale xuống về kích thước thực tế (576 width)
    final scaledImage = img.copyResize(
      originalImage,
      width: 576,
      interpolation: img.Interpolation.linear,
    );

    // Bước 2: Convert sang grayscale đơn giản
    final grayscaleImage = img.grayscale(scaledImage);

    // Bước 3: Áp dụng contrast nhẹ
    final contrastedImage = img.adjustColor(
      grayscaleImage,
      contrast: 1.5,
      brightness: 1.05,
    );

    // Bước 4: Convert sang monochrome với threshold an toàn
    final monochromeImage = img.Image(
      contrastedImage.width,
      contrastedImage.height,
    );

    // Fill background trắng trước
    final whitePixel = img.getColor(255, 255, 255);
    for (int y = 0; y < monochromeImage.height; y++) {
      for (int x = 0; x < monochromeImage.width; x++) {
        monochromeImage.setPixel(x, y, whitePixel);
      }
    }

    int blackPixels = 0;
    int whitePixels = 0;

    for (int y = 0; y < contrastedImage.height; y++) {
      for (int x = 0; x < contrastedImage.width; x++) {
        final pixel = contrastedImage.getPixel(x, y);
        final gray = img.getRed(pixel);

        // Threshold an toàn: < 128 = black, >= 128 = white
        if (gray < 128) {
          monochromeImage.setPixel(x, y, img.getColor(0, 0, 0));
          blackPixels++;
        } else {
          monochromeImage.setPixel(x, y, img.getColor(255, 255, 255));
          whitePixels++;
        }
      }
    }

    return monochromeImage;
  }

  /// Convert QR code bytes thành Flutter UI Image
  static Future<ui.Image> convertBytesToUIImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Resize và encode QR image cho thermal printer với quality cao
  static Future<Uint8List> prepareQRForPrint(
    Uint8List qrBytes, {
    int targetWidth = 920,
  }) async {
    final qrImg = img.decodeImage(qrBytes);
    if (qrImg == null) return Uint8List(0);

    // Giữ nguyên kích thước QR nếu đã đủ lớn, chỉ resize nếu cần thiết
    final finalImg = qrImg.width >= targetWidth 
        ? qrImg 
        : img.copyResize(
            qrImg, 
            width: targetWidth,
            height: targetWidth,
            interpolation: img.Interpolation.nearest, // Giữ nét cho QR code
          );
    
    // Enhance contrast cho QR code
    final enhancedQr = img.adjustColor(
      finalImg,
      contrast: 1.8,
      brightness: 1.0,
    );
    
    // Encode lại thành PNG với quality cao
    return Uint8List.fromList(img.encodePng(enhancedQr, level: 0));
  }

  /// Tạo background trắng cho QR code
  static void drawQRBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
  }

  /// Vẽ QR code căn giữa trên canvas
  static void drawQRCentered({
    required Canvas canvas,
    required ui.Image qrImage,
    required double canvasWidth,
    required double currentY,
    required double qrSize,
  }) {
    final qrX = (canvasWidth - qrSize) / 2;
    canvas.drawImageRect(
      qrImage,
      Rect.fromLTWH(
        0,
        0,
        qrImage.width.toDouble(),
        qrImage.height.toDouble(),
      ),
      Rect.fromLTWH(qrX, currentY, qrSize, qrSize),
      Paint(),
    );
  }

  /// Tính toán kích thước image cần thiết
  static Size calculateImageSize({
    required double contentHeight,
    double width = 576.0,
    double padding = 50.0,
  }) {
    return Size(width, contentHeight + padding);
  }

  /// Crop image theo kích thước thực tế cần thiết
  static Future<ui.Image> cropImage({
    required ui.Image originalImage,
    required Size targetSize,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Vẽ phần cần thiết từ originalImage
    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, targetSize.width, targetSize.height),
      Rect.fromLTWH(0, 0, targetSize.width, targetSize.height),
      Paint(),
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
      targetSize.width.toInt(),
      targetSize.height.toInt(),
    );
  }

  /// Convert UI Image thành bytes
  static Future<Uint8List> imageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Tạo QR code từ EMVCo data string
  static Future<Uint8List> generateQRFromData(String qrData, {int size = 800}) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

      if (qrValidationResult.status == QrValidationStatus.error) {
        return Uint8List(0);
      }

      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
        gapless: true,
      );

      final picture = painter.toPicture(size.toDouble());
      final qrImage = await picture.toImage(size, size);
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List() ?? Uint8List(0);
    } catch (e) {
      return Uint8List(0);
    }
  }
}