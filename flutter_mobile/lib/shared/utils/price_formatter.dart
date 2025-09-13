/// Utility class for formatting prices in Vietnamese format
class PriceFormatter {
  /// Format price to Vietnamese currency format
  /// Example: 85000 -> "85.000 ₫"
  static String format(int price) {
    int priceInt;
    if (price is double) {
      priceInt = price.toInt();
    } else if (price is int) {
      priceInt = price;
    } else {
      priceInt = 0;
    }
    
    return '${priceInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )} ₫';
  }

  /// Parse price string back to int (remove formatting)
  /// Example: "85.000 ₫" -> 85000
  static int parse(String formattedPrice) {
    // Remove currency symbol and dots
    String cleanPrice = formattedPrice
        .replaceAll('₫', '')
        .replaceAll('.', '')
        .trim();
    
    return int.tryParse(cleanPrice) ?? 0;
  }
}