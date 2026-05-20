import 'package:intl/intl.dart';

class DateFormatter {
  // ── Full date: "Monday, 20 May 2026" ─────────────────────────
  static String fullDate(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy').format(date);

  // ── Short date: "20 May" ─────────────────────────────────────
  static String shortDate(DateTime date) =>
      DateFormat('d MMM').format(date);

  // ── Month-Year: "May 2026" ────────────────────────────────────
  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  // ── Time: "09:45 AM" ──────────────────────────────────────────
  static String time(DateTime date) =>
      DateFormat('hh:mm a').format(date);

  // ── Relative day label ────────────────────────────────────────
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff <= 7) return 'In $diff days';
    if (diff < -1 && diff >= -7) return '${diff.abs()} days ago';
    return shortDate(date);
  }

  // ── Note timestamp: "Today, 09:45 AM" ─────────────────────────
  static String noteTimestamp(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today, ${time(date)}';
    if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${time(date)}';
    }
    return '${shortDate(date)}, ${time(date)}';
  }

  // ── Day number: "20" ──────────────────────────────────────────
  static String dayNumber(DateTime date) =>
      DateFormat('d').format(date);

  // ── Day name short: "Mon" ─────────────────────────────────────
  static String dayNameShort(DateTime date) =>
      DateFormat('EEE').format(date);

  // ── Month short: "May" ────────────────────────────────────────
  static String monthShort(DateTime date) =>
      DateFormat('MMM').format(date);

  // ── ISO date key for storage: "2026-05-20" ────────────────────
  static String isoDateKey(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  // ── Is same day helper ────────────────────────────────────────
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Days in month ─────────────────────────────────────────────
  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  // ── Currency formatter: "₹1,234.56" ──────────────────────────
  static String currency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
          .format(amount);
}
