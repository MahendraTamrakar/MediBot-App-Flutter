import 'package:intl/intl.dart';

class DateFormatter {
  // Example: "Oct 24, 2025"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Example: "2:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Example: "Today, 2:30 PM" or "Oct 24, 2:30 PM"
  static String formatChatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today, ${formatTime(date)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${formatTime(date)}';
    } else {
      return '${formatDate(date)}, ${formatTime(date)}';
    }
  }
}