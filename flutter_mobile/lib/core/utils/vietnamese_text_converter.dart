/// Utility để chuyển đổi text tiếng Việt cho máy in nhiệt
class VietnameseTextConverter {
  /// Map ký tự tiếng Việt sang ASCII
  static const Map<String, String> _vietnameseToAscii = {
    // Chữ a
    'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
    'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
    'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
    'À': 'A', 'Á': 'A', 'Ạ': 'A', 'Ả': 'A', 'Ã': 'A',
    'Â': 'A', 'Ầ': 'A', 'Ấ': 'A', 'Ậ': 'A', 'Ẩ': 'A', 'Ẫ': 'A',
    'Ă': 'A', 'Ằ': 'A', 'Ắ': 'A', 'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
    
    // Chữ e
    'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
    'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
    'È': 'E', 'É': 'E', 'Ẹ': 'E', 'Ẻ': 'E', 'Ẽ': 'E',
    'Ê': 'E', 'Ề': 'E', 'Ế': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
    
    // Chữ i
    'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
    'Ì': 'I', 'Í': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
    
    // Chữ o
    'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
    'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
    'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
    'Ò': 'O', 'Ó': 'O', 'Ọ': 'O', 'Ỏ': 'O', 'Õ': 'O',
    'Ô': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ộ': 'O', 'Ổ': 'O', 'Ỗ': 'O',
    'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O', 'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
    
    // Chữ u
    'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
    'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
    'Ù': 'U', 'Ú': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U',
    'Ư': 'U', 'Ừ': 'U', 'Ứ': 'U', 'Ự': 'U', 'Ử': 'U', 'Ữ': 'U',
    
    // Chữ y
    'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
    'Ỳ': 'Y', 'Ý': 'Y', 'Ỵ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y',
    
    // Chữ d
    'đ': 'd', 'Đ': 'D',
  };

  /// Chuyển đổi text tiếng Việt thành ASCII cho máy in
  static String toAscii(String text) {
    String result = text;
    
    for (final entry in _vietnameseToAscii.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    
    return result;
  }

  /// Chuyển đổi và giới hạn độ dài dòng cho máy in 80mm
  static String toAsciiWithLineBreak(String text, {int maxLineLength = 42}) {
    final asciiText = toAscii(text);
    
    if (asciiText.length <= maxLineLength) {
      return asciiText;
    }
    
    // Chia thành nhiều dòng
    final words = asciiText.split(' ');
    final lines = <String>[];
    String currentLine = '';
    
    for (final word in words) {
      if ('$currentLine $word'.trim().length <= maxLineLength) {
        currentLine = '$currentLine $word'.trim();
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }
    
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    
    return lines.join('\n');
  }

  /// Test xem text có chứa ký tự tiếng Việt không
  static bool containsVietnamese(String text) {
    for (final key in _vietnameseToAscii.keys) {
      if (text.contains(key)) {
        return true;
      }
    }
    return false;
  }

  /// Chuyển đổi text với thông báo debug
  static String convertWithDebug(String text) {
    if (containsVietnamese(text)) {
      final converted = toAscii(text);
      print('🔄 Vietnamese text converted: "$text" -> "$converted"');
      return converted;
    }
    return text;
  }

  /// Chuyển đổi text an toàn cho màn hình và log
  static String safeConvert(String text) {
    try {
      return toAscii(text);
    } catch (e) {
      print('❌ Error converting Vietnamese text: $e');
      // Fallback: chỉ giữ lại ASCII characters
      return text.replaceAll(RegExp(r'[^\x00-\x7F]'), '?');
    }
  }
}