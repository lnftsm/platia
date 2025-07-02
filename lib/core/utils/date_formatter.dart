import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date, {String? locale}) {
    return DateFormat('dd MMMM yyyy', locale).format(date);
  }

  static String formatDateTime(DateTime dateTime, {String? locale}) {
    return DateFormat('dd MMMM yyyy HH:mm', locale).format(dateTime);
  }

  static String formatTime(DateTime time, {String? locale}) {
    return DateFormat('HH:mm', locale).format(time);
  }

  static String formatShortDate(DateTime date, {String? locale}) {
    return DateFormat('dd/MM/yyyy', locale).format(date);
  }

  static String formatMonthYear(DateTime date, {String? locale}) {
    return DateFormat('MMMM yyyy', locale).format(date);
  }

  static String formatDayMonth(DateTime date, {String? locale}) {
    return DateFormat('dd MMMM', locale).format(date);
  }

  static String formatWeekday(DateTime date, {String? locale}) {
    return DateFormat('EEEE', locale).format(date);
  }

  static String formatRelative(DateTime dateTime, {String? locale}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime, locale: locale);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${locale == 'tr' ? 'gün önce' : 'days ago'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${locale == 'tr' ? 'saat önce' : 'hours ago'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${locale == 'tr' ? 'dakika önce' : 'minutes ago'}';
    } else {
      return locale == 'tr' ? 'Şimdi' : 'Just now';
    }
  }

  static String formatDuration(Duration duration, {String? locale}) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours ${locale == 'tr' ? 'saat' : 'hour${hours > 1 ? 's' : ''}'} $minutes ${locale == 'tr' ? 'dakika' : 'minute${minutes > 1 ? 's' : ''}'}';
    } else {
      return '$minutes ${locale == 'tr' ? 'dakika' : 'minute${minutes > 1 ? 's' : ''}'}';
    }
  }
}
