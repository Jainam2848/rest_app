import 'package:intl/intl.dart';

class FormatUtils {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Format number with commas
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Format percentage
  static String formatPercentage(double value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove all non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Format based on length
    if (cleaned.startsWith('+')) {
      return cleaned;
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return cleaned;
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Format distance
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // Format rating
  static String formatRating(double? rating) {
    if (rating == null) return 'N/A';
    return rating.toStringAsFixed(1);
  }

  // Get discount display text
  static String getDiscountText({
    required String discountType,
    required double? discountValue,
  }) {
    if (discountValue == null) return '';
    
    switch (discountType) {
      case 'percentage':
        return '${discountValue.toStringAsFixed(0)}% OFF';
      case 'fixed_amount':
        return '${formatCurrency(discountValue)} OFF';
      case 'buy_one_get_one':
        return 'BOGO';
      default:
        return '';
    }
  }

  // Calculate discount amount
  static double calculateDiscount({
    required String discountType,
    required double discountValue,
    required double originalAmount,
    double? maxDiscount,
  }) {
    double discount = 0;
    
    switch (discountType) {
      case 'percentage':
        discount = originalAmount * (discountValue / 100);
        break;
      case 'fixed_amount':
        discount = discountValue;
        break;
      case 'buy_one_get_one':
        discount = originalAmount / 2;
        break;
    }
    
    // Apply max discount cap if specified
    if (maxDiscount != null && discount > maxDiscount) {
      discount = maxDiscount;
    }
    
    return discount;
  }

  // Calculate final amount after discount
  static double calculateFinalAmount({
    required double originalAmount,
    required double discountAmount,
  }) {
    final finalAmount = originalAmount - discountAmount;
    return finalAmount < 0 ? 0 : finalAmount;
  }
}
