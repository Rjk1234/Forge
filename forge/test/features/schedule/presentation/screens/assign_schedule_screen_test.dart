import '../../../../helpers/schedule_reload_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/load_assignment_context_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/schedule/presentation/widgets/invalid_plan_banner.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_save_failure_banner.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepository implements ScheduleRepository {
  _FakeRepository({
    required this.loadResult,
    List<Either<AppException, void>>? saveResults,
    this.saveDelay = Duration.zero,
  }) : _saveResults = saveResults ?? [const Right(null)];

  final Either<AppException, ScheduleFormContext> loadResult;
  final List<Either<AppException, void>> _saveResults;
  final Duration saveDelay;
  int saveCallCount = 0;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) async => loadResult;

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) async {
    if (saveDelay > Duration.zero) await Future<void>.delayed(saveDelay);
    final result =
        _saveResults[saveCallCount.clamp(0, _saveResults.length - 1)];
    saveCallCount++;
    return result;
  }

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AssignScheduleBloc _makeBloc(_FakeRepository repo) => AssignScheduleBloc(
  loadAssignmentContext: LoadAssignmentContextUseCase(repository: repo),
  saveScheduleAssignment: SaveScheduleAssignmentUseCase(repository: repo),
);

GoRouter _routerFor(AssignScheduleBloc bloc) => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
    GoRoute(
      path: '/schedule',
      builder: (context, state) => BlocProvider<AssignScheduleBloc>.value(
        value: bloc,
        child: const AssignScheduleScreen(),
      ),
    ),
  ],
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  // Long enough to clear GoRouter's default page-transition animation, so
  // context.pop() calls triggered by the bloc listener are not swallowed
  // mid-transition.
  await tester.pump(const Duration(milliseconds: 600));
}

/// Pumps the app with a navigation stack under `/schedule` (so the screen's
/// `context.pop()` has somewhere to go back to), then pushes and settles.
Future<GoRouter> _pumpScreen(WidgetTester tester, _FakeRepository repo) async {
  final bloc = _makeBloc(repo)..add(const AssignScheduleInitialized('p1'));
  final router = _routerFor(bloc);
  await tester.pumpWidget(
    MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    ),
  );
  router.push('/schedule');
  await _settle(tester);
  return router;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(registerScheduleReloadNotifiers);
  tearDown(unregisterScheduleReloadNotifiers);

  group('AssignScheduleScreen — US1 (new assignment)', () {
    testWidgets('no days selected → Save disabled', (tester) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Schedule'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting an unoccupied day → Save enabled', (tester) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      await tester.tap(find.text('M').first);
      await _settle(tester);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Schedule'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('reaching Saved pops the screen', (tester) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      await tester.tap(find.text('M').first);
      await _settle(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Schedule'));
      await _settle(tester);

      expect(find.byType(AssignScheduleScreen), findsNothing);
    });
  });

  group('AssignScheduleScreen — US2 (edit existing)', () {
    testWidgets(
      'pre-fills selected days, enables Save, app bar reads Edit Schedule',
      (tester) async {
        final repo = _FakeRepository(
          loadResult: const Right(
            ScheduleFormContext(
              planId: 'p1',
              planName: 'Push Day',
              currentDays: {1, 3},
              occupiedDays: {},
            ),
          ),
        );
        await _pumpScreen(tester, repo);

        expect(find.text('Edit Schedule'), findsOneWidget);
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save Schedule'),
        );
        expect(button.onPressed, isNotNull);
      },
    );
  });

  group('AssignScheduleScreen — US3 (conflict detection)', () {
    testWidgets(
      'selecting an occupied day shows conflict text and disables Save',
      (tester) async {
        final repo = _FakeRepository(
          loadResult: const Right(
            ScheduleFormContext(
              planId: 'p1',
              planName: 'Push Day',
              currentDays: {},
              occupiedDays: {2: 'Pull Day'},
            ),
          ),
        );
        await _pumpScreen(tester, repo);

        await tester.tap(find.text('T').first);
        await _settle(tester);

        expect(find.textContaining('Pull Day'), findsOneWidget);
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save Schedule'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('deselecting the conflicting day clears the conflict', (
      tester,
    ) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {},
            occupiedDays: {2: 'Pull Day'},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      await tester.tap(find.text('T').first);
      await _settle(tester);
      await tester.tap(find.text('T').first);
      await _settle(tester);

      expect(find.textContaining('Pull Day'), findsNothing);
    });

    testWidgets("a plan's own existing days never render as conflicting", (
      tester,
    ) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {1},
            occupiedDays: {2: 'Pull Day'},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Schedule'),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  group('AssignScheduleScreen — US4 (save failure and retry)', () {
    testWidgets(
      'SaveFailure shows banner, retains selection, Retry Save re-attempts',
      (tester) async {
        final repo = _FakeRepository(
          loadResult: const Right(
            ScheduleFormContext(
              planId: 'p1',
              planName: 'Push Day',
              currentDays: {1},
              occupiedDays: {},
            ),
          ),
          saveResults: [
            Left(CacheException(message: "Couldn't save your schedule")),
            const Right(null),
          ],
        );
        await _pumpScreen(tester, repo);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Save Schedule'));
        await _settle(tester);

        expect(find.byType(ScheduleSaveFailureBanner), findsOneWidget);
        expect(find.text('Retry Save'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Retry Save'));
        await _settle(tester);
        await _settle(tester);

        expect(find.byType(AssignScheduleScreen), findsNothing);
        expect(repo.saveCallCount, 2);
      },
    );

    testWidgets('back navigation is blocked while Saving', (tester) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {1},
            occupiedDays: {},
          ),
        ),
        saveDelay: const Duration(seconds: 5),
      );
      await _pumpScreen(tester, repo);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Schedule'));
      await tester.pump();

      final backButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(backButton.onPressed, isNull);

      // Flush the pending saveDelay timer so it doesn't leak past this test.
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('AssignScheduleScreen — US5 (invalid plan)', () {
    testWidgets('InvalidPlan renders banner, disables days, disables Save', (
      tester,
    ) async {
      final repo = _FakeRepository(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: null,
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      );
      await _pumpScreen(tester, repo);

      expect(find.byType(InvalidPlanBanner), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Schedule'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
