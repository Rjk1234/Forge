import 'package:flutter/services.dart';

/// Blocks any digit typed after the first decimal place.
/// Allows: empty, integers, trailing dot, and exactly one decimal digit.
/// Regex: ^\d*\.?\d{0,1}$
class DecimalOneDigitInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*\.?\d{0,1}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
