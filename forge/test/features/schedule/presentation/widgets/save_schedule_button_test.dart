import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/schedule/presentation/widgets/save_schedule_button.dart';
import 'package:forge/l10n/l10n.dart';

import '../../../../helpers/l10n.dart';

Widget _host({required bool enabled}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(
    body: SaveScheduleButton(
      enabled: enabled,
      isSaving: false,
      isRetry: false,
      onPressed: () {},
    ),
  ),
);

Color? _labelColor(WidgetTester tester) => DefaultTextStyle.of(
  tester.element(find.text(l10n.saveScheduleButton)),
).style.color;

void main() {
  testWidgets('the enabled label is dark on the green button', (tester) async {
    await tester.pumpWidget(_host(enabled: true));

    expect(_labelColor(tester), AppTheme.darkTheme.colorScheme.onPrimary);
  });

  testWidgets('the disabled label stays muted on the grey button', (
    tester,
  ) async {
    await tester.pumpWidget(_host(enabled: false));

    expect(
      _labelColor(tester),
      isNot(AppTheme.darkTheme.colorScheme.onPrimary),
    );
  });
}
