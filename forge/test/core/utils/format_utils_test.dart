import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/utils/format_utils.dart';

void main() {
  group('formatSessionDateTime', () {
    test('formats an evening time', () {
      expect(
        formatSessionDateTime(DateTime(2026, 9, 7, 18, 42)),
        'Mon, Sep 7 · 6:42 PM',
      );
    });

    test('includes the year when asked', () {
      expect(
        formatSessionDateTime(DateTime(2026, 9, 7, 18, 42), includeYear: true),
        'Mon, Sep 7, 2026 · 6:42 PM',
      );
    });

    test('midnight and noon use 12', () {
      expect(
        formatSessionDateTime(DateTime(2026, 9, 8, 0, 5)),
        'Tue, Sep 8 · 12:05 AM',
      );
      expect(
        formatSessionDateTime(DateTime(2026, 9, 9, 12)),
        'Wed, Sep 9 · 12:00 PM',
      );
    });
  });

  group('formatDurationCompact', () {
    test('minutes and hours', () {
      expect(formatDurationCompact(5), '0:05');
      expect(formatDurationCompact(90), '1:30');
      expect(formatDurationCompact(3725), '1:02:05');
    });
  });

  group('formatThousands', () {
    test('groups digits', () {
      expect(formatThousands(999), '999');
      expect(formatThousands(1820), '1,820');
      expect(formatThousands(1234567), '1,234,567');
      expect(formatThousands(-1820), '-1,820');
    });
  });

  test('formatWeightValue drops a trailing .0', () {
    expect(formatWeightValue(65), '65');
    expect(formatWeightValue(62.5), '62.5');
  });

  test('formatWeightValue hides floating-point noise', () {
    expect(formatWeightValue(72.5 - 70.2), '2.3');
    expect(formatWeightValue(65 - 62.5), '2.5');
  });

  group('formatVolume', () {
    test('groups digits and trims a trailing .0', () {
      expect(formatVolume(1100), '1,100');
      expect(formatVolume(1100.0), '1,100');
      expect(formatVolume(0), '0');
    });

    test('keeps one decimal', () {
      expect(formatVolume(20.8), '20.8');
      expect(formatVolume(792.5), '792.5');
      expect(formatVolume(20.8 + 0.00000001), '20.8');
    });
  });

  test('formatMonthDay is month abbreviation and day', () {
    expect(formatMonthDay(DateTime(2026, 9, 7)), 'Sep 7');
  });

  test('formatShortDate includes the year', () {
    expect(formatShortDate(DateTime(2026, 8, 31)), 'Aug 31, 2026');
  });
}
