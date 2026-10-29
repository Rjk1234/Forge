import 'package:intl/intl.dart';

/// Formats [seconds] as "MM:SS". Example: 90 → "01:30".
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Formats [seconds] as "m:ss", or "h:mm:ss" from one hour. Example: 90 → "1:30".
String formatDurationCompact(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = (seconds % 60).toString().padLeft(2, '0');
  if (hours == 0) return '$minutes:$secs';
  return '$hours:${minutes.toString().padLeft(2, '0')}:$secs';
}

/// Formats [value] with locale digit grouping. Example: 1820 → "1,820".
String formatThousands(num value) =>
    NumberFormat.decimalPattern().format(value.round());

/// Formats a volume with grouping and up to one decimal, trimming ".0".
/// Examples: 1100 → "1,100", 20.8 → "20.8".
String formatVolume(num value) =>
    NumberFormat('#,##0.#').format((value * 10).round() / 10);

/// Rounds to one decimal and drops a trailing ".0".
/// Examples: 65.0 → "65", 62.5 → "62.5", 2.3000000000000114 → "2.3".
String formatWeightValue(double weight) {
  final rounded = (weight * 10).round() / 10;
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// Formats [dateTime] as "September 2026".
String formatMonthYear(DateTime dateTime) =>
    DateFormat('MMMM y').format(dateTime);

/// Three-letter weekday, e.g. "Mon".
String formatWeekdayAbbreviation(DateTime dateTime) =>
    DateFormat('EEE').format(dateTime);

/// Formats [dateTime] as "Mon, Sep 7 · 6:42 PM", or with the year
/// ("Mon, Sep 7, 2026 · 6:42 PM") when [includeYear] is true.
String formatSessionDateTime(DateTime dateTime, {bool includeYear = false}) {
  final pattern = includeYear
      ? "EEE, MMM d, y '·' h:mm a"
      : "EEE, MMM d '·' h:mm a";
  return DateFormat(pattern).format(dateTime);
}

/// Formats [dateTime] as "Sep 7".
String formatMonthDay(DateTime dateTime) =>
    DateFormat('MMM d').format(dateTime);

/// Formats [dateTime] as "Thursday, Oct 24".
String formatWeekdayMonthDay(DateTime dateTime) =>
    DateFormat('EEEE, MMM d').format(dateTime);

/// Formats [dateTime] as "Aug 31, 2026".
String formatShortDate(DateTime dateTime) =>
    DateFormat('MMM d, y').format(dateTime);
