import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_detail_footer.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_not_available_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_unavailable_state.dart';
import 'package:forge/l10n/l10n.dart';

import '../../../../helpers/l10n.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: child),
);

Color? _labelColor(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style.color;

void main() {
  final onPrimary = AppTheme.darkTheme.colorScheme.onPrimary;

  testWidgets('Start Workout label is dark on the green button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PlanDetailFooter(
          planId: 'p1',
          canStart: true,
          onStartWorkout: () {},
          onSchedule: () {},
        ),
      ),
    );

    expect(_labelColor(tester, l10n.planDetailStartWorkoutButton), onPrimary);
  });

  testWidgets('Back button label on the not-available card is dark', (
    tester,
  ) async {
    await tester.pumpWidget(_host(PlanNotAvailableCard(onBack: () {})));

    expect(_labelColor(tester, l10n.planNotAvailableButton), onPrimary);
  });

  testWidgets('Back to schedule label is dark on the green button', (
    tester,
  ) async {
    await tester.pumpWidget(_host(PreStartUnavailableState(onBack: () {})));

    expect(_labelColor(tester, l10n.preStartBackToScheduleButton), onPrimary);
  });
}
