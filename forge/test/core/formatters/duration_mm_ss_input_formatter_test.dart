import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/formatters/duration_mm_ss_input_formatter.dart';

TextEditingValue _val(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

String _format(String oldText, String newText) {
  final formatter = DurationMmSsInputFormatter();
  return formatter.formatEditUpdate(_val(oldText), _val(newText)).text;
}

void main() {
  group('DurationMmSsInputFormatter', () {
    group('formatEditUpdate', () {
      test('starts at 00:00 for empty input', () {
        expect(_format('00:00', ''), '00:00');
      });

      test('typing 0 produces 00:00', () {
        expect(_format('00:00', '00:000'), '00:00');
      });

      test('typing 1 produces 00:01', () {
        expect(_format('00:00', '00:001'), '00:01');
      });

      test('typing 3 then 0 accumulates to 00:30', () {
        final after3 = _format('00:00', '00:003');
        final after30 = _format(after3, '${after3}0');
        expect(after30, '00:30');
      });

      test('typing 0,1,3,0 produces 01:30', () {
        var v = '00:00';
        v = _format(v, '${v}0');
        v = _format(v, '${v}1');
        v = _format(v, '${v}3');
        v = _format(v, '${v}0');
        expect(v, '01:30');
      });

      test('capped at 4 significant digits — 5th digit shifts left', () {
        // After 0,1,3,0,5 → last 4 digits are 1,3,0,5 → 13:05
        var v = '00:00';
        v = _format(v, '${v}0');
        v = _format(v, '${v}1');
        v = _format(v, '${v}3');
        v = _format(v, '${v}0');
        v = _format(v, '${v}5');
        expect(v, '13:05');
      });

      test('always returns exactly mm:ss format (5 chars with colon)', () {
        final result = _format('00:00', '00:001');
        expect(result.length, 5);
        expect(result[2], ':');
      });

      test('ignores non-digit characters in input', () {
        expect(_format('00:00', 'ab:cd'), '00:00');
      });

      test('cursor is always at end of formatted string', () {
        final formatter = DurationMmSsInputFormatter();
        final result = formatter.formatEditUpdate(
          _val('00:00'),
          _val('00:001'),
        );
        expect(result.selection.baseOffset, result.text.length);
      });
    });

    group('parseToSeconds', () {
      test('parses 00:00 as 0 seconds', () {
        expect(DurationMmSsInputFormatter.parseToSeconds('00:00'), 0);
      });

      test('parses 01:30 as 90 seconds', () {
        expect(DurationMmSsInputFormatter.parseToSeconds('01:30'), 90);
      });

      test('parses 10:00 as 600 seconds', () {
        expect(DurationMmSsInputFormatter.parseToSeconds('10:00'), 600);
      });

      test('parses 59:59 as 3599 seconds', () {
        expect(DurationMmSsInputFormatter.parseToSeconds('59:59'), 3599);
      });

      test('returns 0 for malformed input', () {
        expect(DurationMmSsInputFormatter.parseToSeconds('bad'), 0);
      });
    });

    group('formatFromSeconds', () {
      test('formats 0 as 00:00', () {
        expect(DurationMmSsInputFormatter.formatFromSeconds(0), '00:00');
      });

      test('formats 90 as 01:30', () {
        expect(DurationMmSsInputFormatter.formatFromSeconds(90), '01:30');
      });

      test('formats 600 as 10:00', () {
        expect(DurationMmSsInputFormatter.formatFromSeconds(600), '10:00');
      });

      test('formats 3599 as 59:59', () {
        expect(DurationMmSsInputFormatter.formatFromSeconds(3599), '59:59');
      });

      test('roundtrip: parse then format returns original value', () {
        const original = '03:45';
        final seconds = DurationMmSsInputFormatter.parseToSeconds(original);
        expect(DurationMmSsInputFormatter.formatFromSeconds(seconds), original);
      });
    });
  });
}
