import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';
import 'package:forge/features/home/presentation/widgets/week_strip.dart';
import 'package:forge/l10n/l10n.dart';

const _push = WeekPlanRef(planId: 'p1', planName: 'Push Day');
const _done = WeekSessionRef(sessionId: 's1', planName: 'Push Day', count: 2);

List<WeekDayStatus> _week() => [
  const WeekDayStatus(
    weekday: DateTime.monday,
    state: WeekDayState.completed,
    isToday: false,
    plan: _push,
    session: _done,
  ),
  const WeekDayStatus(
    weekday: DateTime.tuesday,
    state: WeekDayState.missed,
    isToday: false,
    plan: _push,
  ),
  const WeekDayStatus(
    weekday: DateTime.wednesday,
    state: WeekDayState.planned,
    isToday: true,
    plan: _push,
  ),
  for (var weekday = DateTime.thursday; weekday <= DateTime.sunday; weekday++)
    WeekDayStatus(weekday: weekday, state: WeekDayState.rest, isToday: false),
];

Widget _host({
  void Function(String, {required bool isToday})? onOpenPlan,
  void Function(String)? onOpenSession,
  VoidCallback? onOpenSchedule,
}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(
    body: WeekStrip(
      days: _week(),
      onOpenPlan: onOpenPlan ?? (_, {required isToday}) {},
      onOpenSession: onOpenSession ?? (_) {},
      onOpenSchedule: onOpenSchedule ?? () {},
    ),
  ),
);

void main() {
  testWidgets('shows progress and today\'s plan by default', (tester) async {
    await tester.pumpWidget(_host());

    expect(find.text('1 of 3 done'), findsOneWidget);
    expect(find.text('Wednesday · Push Day · planned'), findsOneWidget);
  });

  testWidgets('tapping a day describes it', (tester) async {
    await tester.pumpWidget(_host());

    await tester.tap(find.text('Tue'));
    await tester.pump();
    expect(find.text('Tuesday · Push Day · missed'), findsOneWidget);

    await tester.tap(find.text('Mon'));
    await tester.pump();
    expect(find.text('Monday · Push Day · 2 workouts done'), findsOneWidget);

    await tester.tap(find.text('Fri'));
    await tester.pump();
    expect(find.text('Friday · Rest day'), findsOneWidget);
  });

  testWidgets('a plan opened from a day other than today is not today', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(
      _host(onOpenPlan: (id, {required isToday}) => opened.add('$id:$isToday')),
    );

    await tester.tap(find.text('Tue'));
    await tester.pump();
    await tester.tap(find.text('Tuesday · Push Day · missed'));

    expect(opened, ['p1:false']);
  });

  testWidgets('the detail opens the workout, the plan, or the schedule', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(
      _host(
        onOpenPlan: (id, {required isToday}) =>
            opened.add('plan:$id:today=$isToday'),
        onOpenSession: (id) => opened.add('session:$id'),
        onOpenSchedule: () => opened.add('schedule'),
      ),
    );

    await tester.tap(find.text('Wednesday · Push Day · planned'));
    await tester.tap(find.text('Mon'));
    await tester.pump();
    await tester.tap(find.text('Monday · Push Day · 2 workouts done'));
    await tester.tap(find.text('Fri'));
    await tester.pump();
    await tester.tap(find.text('Friday · Rest day'));

    expect(opened, ['plan:p1:today=true', 'session:s1', 'schedule']);
  });
}
