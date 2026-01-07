import 'package:intl/intl.dart';

class AppDateUtils {
  // Format date to readable string
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date to localized string
  static String formatDateLocalized(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Parse release date string from TMDB
  static DateTime? parseReleaseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get year from date string
  static int? getYear(String? dateString) {
    final date = parseReleaseDate(dateString);
    return date?.year;
  }

  // Format runtime (e.g., "2h 30m")
  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes == 0) return '';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  // Check if date is in the future
  static bool isFuture(String? dateString) {
    final date = parseReleaseDate(dateString);
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  // Check if date is in the past
  static bool isPast(String? dateString) {
    final date = parseReleaseDate(dateString);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }
}
