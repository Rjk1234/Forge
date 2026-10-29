import '../../../../helpers/schedule_reload_notifiers.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/domain/entities/schedule_day.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/get_weekly_schedule_usecase.dart';
import 'package:forge/features/schedule/presentation/screens/weekly_schedule_screen.dart';
import 'package:forge/features/schedule/presentation/widgets/day_row.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_empty_state.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_error_card.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_skeleton_list.dart';
import 'package:forge/features/schedule/presentation/widgets/week_schedule_list.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/l10n/l10n.dart';
import '../../../../helpers/l10n.dart';

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _FakeRepository implements ScheduleRepository {
  _FakeRepository(this.response);

  final Either<AppException, WeeklySchedule> Function() response;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() async =>
      response();

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

class _HangingRepository implements ScheduleRepository {
  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() =>
      Completer<Either<AppException, WeeklySchedule>>().future;

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WeeklySchedule _scheduleWithPlan() {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  return WeeklySchedule(
    days: List.generate(
      7,
      (i) => ScheduleDay(
        weekday: i + 1,
        date: monday.add(Duration(days: i)),
        isToday: (i + 1) == now.weekday,
        assignedPlan: i == 0
            ? const ScheduledPlanRef(
                planId: 'p1',
                planName: 'Push Day',
                recurrenceLabel: 'Weekly',
              )
            : null,
      ),
    ),
  );
}

WeeklySchedule _allRestSchedule() {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  return WeeklySchedule(
    days: List.generate(
      7,
      (i) => ScheduleDay(
        weekday: i + 1,
        date: monday.add(Duration(days: i)),
        isToday: (i + 1) == now.weekday,
      ),
    ),
  );
}

WeekScheduleBloc _makeBloc(Either<AppException, WeeklySchedule> result) =>
    WeekScheduleBloc(
      getWeeklySchedule: GetWeeklyScheduleUseCase(
        repository: _FakeRepository(() => result),
      ),
    );

WeekScheduleBloc _makeLoadingBloc() => WeekScheduleBloc(
  getWeeklySchedule: GetWeeklyScheduleUseCase(repository: _HangingRepository()),
);

Widget _pump(WeekScheduleBloc bloc) {
  bloc.add(const WeekScheduleRequested());
  final router = GoRouter(
    initialLocation: '/schedule',
    routes: [
      GoRoute(
        path: '/schedule',
        builder: (context, state) => BlocProvider<WeekScheduleBloc>.value(
          value: bloc,
          child: const WeeklyScheduleScreen(),
        ),
      ),
    ],
  );
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: router,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(registerScheduleReloadNotifiers);
  tearDown(unregisterScheduleReloadNotifiers);

  group('WeeklyScheduleScreen — reload signal', () {
    testWidgets('reloads when the schedule reload notifier fires', (
      tester,
    ) async {
      var schedule = _allRestSchedule();
      final bloc = WeekScheduleBloc(
        getWeeklySchedule: GetWeeklyScheduleUseCase(
          repository: _FakeRepository(() => Right(schedule)),
        ),
      );
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ScheduleEmptyState), findsOneWidget);

      schedule = _scheduleWithPlan();
      getIt<ScheduleReloadNotifier>().notify();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WeekScheduleList), findsOneWidget);
      expect(find.byType(ScheduleEmptyState), findsNothing);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US1 — Loading skeleton and populated week
  // -------------------------------------------------------------------------

  group('WeeklyScheduleScreen — US1 (see the week at a glance)', () {
    testWidgets('shows app bar title "Schedule"', (tester) async {
      final bloc = _makeBloc(Right(_scheduleWithPlan()));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Schedule'), findsOneWidget);
      bloc.close();
    });

    testWidgets('shows skeleton while loading', (tester) async {
      final bloc = _makeLoadingBloc();
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();

      expect(find.byType(ScheduleSkeletonList), findsOneWidget);
      expect(find.byType(WeekScheduleList), findsNothing);
      bloc.close();
    });

    testWidgets('shows WeekScheduleList when data loads', (tester) async {
      final bloc = _makeBloc(Right(_scheduleWithPlan()));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WeekScheduleList), findsOneWidget);
      expect(find.byType(ScheduleSkeletonList), findsNothing);
      bloc.close();
    });

    testWidgets('renders plan name in the populated list', (tester) async {
      final bloc = _makeBloc(Right(_scheduleWithPlan()));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Push Day'), findsOneWidget);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US2 — Today highlighted + Start action
  // -------------------------------------------------------------------------

  group('WeeklyScheduleScreen — US2 (start today\'s workout)', () {
    testWidgets("today's row with plan shows Start button", (tester) async {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final schedule = WeeklySchedule(
        days: List.generate(
          7,
          (i) => ScheduleDay(
            weekday: i + 1,
            date: monday.add(Duration(days: i)),
            isToday: (i + 1) == now.weekday,
            assignedPlan: (i + 1) == now.weekday
                ? const ScheduledPlanRef(
                    planId: 'p1',
                    planName: 'Leg Day',
                    recurrenceLabel: 'Weekly',
                  )
                : null,
          ),
        ),
      );

      final bloc = _makeBloc(Right(schedule));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Start'), findsOneWidget);
      bloc.close();
    });

    testWidgets("today unscheduled shows edit icon, not Start", (tester) async {
      final bloc = _makeBloc(Right(_allRestSchedule()));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Start'), findsNothing);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US3 — Empty state
  // -------------------------------------------------------------------------

  group('WeeklyScheduleScreen — US3 (empty state)', () {
    testWidgets('shows ScheduleEmptyState when all days are rest', (
      tester,
    ) async {
      final bloc = _makeBloc(Right(_allRestSchedule()));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ScheduleEmptyState), findsOneWidget);
      expect(find.text('No workouts scheduled'), findsOneWidget);
      expect(find.text('Schedule a plan'), findsOneWidget);
      bloc.close();
    });
  });

  // -------------------------------------------------------------------------
  // US4 — Error state + Retry
  // -------------------------------------------------------------------------

  group('WeeklyScheduleScreen — US4 (error and retry)', () {
    testWidgets('shows ScheduleErrorCard on load failure', (tester) async {
      final bloc = _makeBloc(Left(CacheException(message: "Couldn't load")));
      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ScheduleErrorCard), findsOneWidget);
      expect(find.text("Couldn't load your schedule"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      bloc.close();
    });

    testWidgets('tapping Retry dispatches WeekScheduleRetried', (tester) async {
      var callCount = 0;
      final bloc = WeekScheduleBloc(
        getWeeklySchedule: GetWeeklyScheduleUseCase(
          repository: _FakeRepository(() {
            callCount++;
            if (callCount == 1) {
              return Left(CacheException(message: 'fail'));
            }
            return Right(_scheduleWithPlan());
          }),
        ),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(ScheduleErrorCard), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WeekScheduleList), findsOneWidget);
      expect(callCount, 2);
      bloc.close();
    });
  });

  group('WeeklyScheduleScreen — navigation', () {
    Widget pumpWithRoutes(WeekScheduleBloc bloc) {
      bloc.add(const WeekScheduleRequested());
      return MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        routerConfig: GoRouter(
          initialLocation: '/schedule',
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (_, _) => BlocProvider<WeekScheduleBloc>.value(
                value: bloc,
                child: const WeeklyScheduleScreen(),
              ),
            ),
            GoRoute(
              path: WorkoutPlansScreen.routePath,
              builder: (_, _) => const Text('Plans stub'),
            ),
            GoRoute(
              path: '/assign/:${PlanDetailScreen.planIdParam}',
              name: AssignScheduleScreen.routeName,
              builder: (_, state) => Text(
                'Assign ${state.pathParameters[PlanDetailScreen.planIdParam]}',
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('editing a scheduled day opens that plan\'s schedule', (
      tester,
    ) async {
      final now = DateTime.now();
      final otherDay = now.weekday % 7 + 1;
      final schedule = WeeklySchedule(
        days: [
          for (var weekday = 1; weekday <= 7; weekday++)
            ScheduleDay(
              weekday: weekday,
              date: now.add(Duration(days: weekday - now.weekday)),
              isToday: weekday == now.weekday,
              assignedPlan: weekday == otherDay
                  ? const ScheduledPlanRef(
                      planId: 'p1',
                      planName: 'Push Day',
                      recurrenceLabel: 'Weekly',
                    )
                  : null,
            ),
        ],
      );
      final bloc = _makeBloc(Right(schedule));
      await tester.pumpWidget(pumpWithRoutes(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final row = find.ancestor(
        of: find.text('Push Day'),
        matching: find.byType(DayRow),
      );
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byTooltip(l10n.scheduleRowMenuTooltip),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.scheduleChangeDaysAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Assign p1'), findsOneWidget);
      unawaited(bloc.close());
    });

    testWidgets('the empty-state button goes to the Plans tab', (tester) async {
      final bloc = _makeBloc(Right(_allRestSchedule()));
      await tester.pumpWidget(pumpWithRoutes(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text(l10n.scheduleEmptyCta));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Plans stub'), findsOneWidget);
      unawaited(bloc.close());
    });
  });
}
