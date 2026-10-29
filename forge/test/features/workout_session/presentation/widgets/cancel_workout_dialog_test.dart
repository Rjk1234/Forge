import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_session/presentation/widgets/cancel_workout_dialog.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

Widget _wrap({
  bool isDiscarding = false,
  VoidCallback? onKeepGoing,
  VoidCallback? onDiscard,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: CancelWorkoutDialog(
        planName: 'Leg Day',
        isDiscarding: isDiscarding,
        onKeepGoing: onKeepGoing ?? () {},
        onDiscard: onDiscard ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('buttons invoke their callbacks', (tester) async {
    var keepGoing = 0;
    var discard = 0;
    await tester.pumpWidget(
      _wrap(onKeepGoing: () => keepGoing++, onDiscard: () => discard++),
    );

    await tester.tap(find.text(l10n.cancelWorkoutKeepGoingButton));
    await tester.tap(find.text(l10n.cancelWorkoutDiscardButton));

    expect(keepGoing, 1);
    expect(discard, 1);
  });

  testWidgets('Discard is disabled while discarding, Keep Going stays live', (
    tester,
  ) async {
    var keepGoing = 0;
    var discard = 0;
    await tester.pumpWidget(
      _wrap(
        isDiscarding: true,
        onKeepGoing: () => keepGoing++,
        onDiscard: () => discard++,
      ),
    );

    await tester.tap(
      find.text(l10n.cancelWorkoutDiscardButton),
      warnIfMissed: false,
    );
    await tester.tap(find.text(l10n.cancelWorkoutKeepGoingButton));

    expect(discard, 0);
    expect(keepGoing, 1);
  });
}
