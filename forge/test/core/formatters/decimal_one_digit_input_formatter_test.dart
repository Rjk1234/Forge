import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/formatters/decimal_one_digit_input_formatter.dart';

TextEditingValue _val(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

String _format(String oldText, String newText) {
  final formatter = DecimalOneDigitInputFormatter();
  return formatter.formatEditUpdate(_val(oldText), _val(newText)).text;
}

void main() {
  group('DecimalOneDigitInputFormatter', () {
    test('allows empty string', () {
      expect(_format('1', ''), '');
    });

    test('allows integer input', () {
      expect(_format('', '60'), '60');
    });

    test('allows trailing dot', () {
      expect(_format('60', '60.'), '60.');
    });

    test('allows one decimal place', () {
      expect(_format('60.', '60.5'), '60.5');
    });

    test('blocks second decimal digit', () {
      // Attempting to type 60.55 — second digit after dot is rejected.
      expect(_format('60.5', '60.55'), '60.5');
    });

    test('blocks multiple decimal points', () {
      expect(_format('60.5', '60.5.'), '60.5');
    });

    test('allows zero', () {
      expect(_format('', '0'), '0');
    });

    test('allows single digit before dot', () {
      expect(_format('', '5.'), '5.');
    });

    test('blocks non-numeric characters', () {
      expect(_format('10', '10a'), '10');
    });
  });
}
