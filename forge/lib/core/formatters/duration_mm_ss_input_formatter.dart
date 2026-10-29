import 'package:flutter/services.dart';

/// Formats a numeric-keyboard text field as mm:ss.
/// Accumulates typed digits from right: typing 0,1,3,0 produces 01:30.
/// Backspace removes from the right. Field always shows exactly mm:ss.
class DurationMmSsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digit characters from the new text.
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Keep last 4 digits (new digit is appended at the end by Flutter).
    final limited = digits.length > 4
        ? digits.substring(digits.length - 4)
        : digits;

    // Left-pad with zeros to ensure exactly 4 digit positions.
    final padded = limited.padLeft(4, '0');

    // Format as mm:ss.
    final formatted = '${padded.substring(0, 2)}:${padded.substring(2, 4)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Parses a mm:ss string into total seconds.
  static int parseToSeconds(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return minutes * 60 + seconds;
  }

  /// Converts total seconds into a mm:ss display string.
  static String formatFromSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
