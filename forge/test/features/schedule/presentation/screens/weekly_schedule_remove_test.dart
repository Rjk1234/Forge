import '../../../../helpers/schedule_reload_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_event.dart';
import 'package:forge/features/schedule/domain/entities/schedule_day.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/get_weekly_schedule_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/remove_schedule_entry_usecase.dart';
import 'package:forge/features/schedule/presentation/screens/weekly_schedule_screen.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';

import '../../../../helpers/l10n.dart';

/// Schedule with one plan on [plannedWeekday]; removing it empties the week
/// unless [failRemoval] is set.
class _MutableRepository implements ScheduleRepository {
  _MutableRepository(this.plannedWeekday);

  int? plannedWeekday;
  bool failRemoval = false;
  int removeCalls = 0;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() async {
    final now = DateTime.now();
    return Right(
      WeeklySchedule(
        days: [
          for (var weekday = 1; weekday <= 7; weekday++)
            ScheduleDay(
              weekday: weekday,
              date: now.add(Duration(days: weekday - now.weekday)),
              isToday: weekday == now.weekday,
              assignedPlan: weekday == plannedWeekday
                  ? const ScheduledPlanRef(
                      planId: 'p1',
                      planName: 'Push Day',
                      recurrenceLabel: 'Weekly',
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) async {
    removeCalls++;
    if (failRemoval) return Left(CacheException(message: 'disk full'));
    plannedWeekday = null;
    return const Right(null);
  }

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
}

Widget _host(WeekScheduleBloc bloc) {
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
        GoRoute(path: '/', builder: (_, _) => const Text('Home')),
      ],
    ),
  );
}

void main() {
  late _MutableRepository repository;
  WeekScheduleBloc makeBloc() => WeekScheduleBloc(
    getWeeklySchedule: GetWeeklyScheduleUseCase(repository: repository),
  );

  setUp(() {
    registerScheduleReloadNotifiers();
    // A day that is not today, so the row shows the menu without Start.
    final otherDay = DateTime.now().weekday % 7 + 1;
    repository = _MutableRepository(otherDay);
    if (getIt.isRegistered<RemoveScheduleEntryBloc>()) {
      getIt.unregister<RemoveScheduleEntryBloc>();
    }
    getIt.registerFactory<RemoveScheduleEntryBloc>(
      () => RemoveScheduleEntryBloc(
        removeScheduleEntry: RemoveScheduleEntryUseCase(repository: repository),
      ),
    );
  });

  tearDown(() {
    getIt.unregister<RemoveScheduleEntryBloc>();
    unregisterScheduleReloadNotifiers();
  });

  Future<void> openRemoveDialog(WidgetTester tester) async {
    await tester.pumpWidget(_host(makeBloc()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byTooltip(l10n.scheduleRowMenuTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.scheduleRemoveAction));
    await tester.pumpAndSettle();
  }

  testWidgets('the menu offers Change days and Remove', (tester) async {
    await tester.pumpWidget(_host(makeBloc()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byTooltip(l10n.scheduleRowMenuTooltip));
    await tester.pumpAndSettle();

    expect(find.text(l10n.scheduleChangeDaysAction), findsOneWidget);
    expect(find.text(l10n.scheduleRemoveAction), findsOneWidget);
  });

  testWidgets('confirming removes the plan and refreshes the week', (
    tester,
  ) async {
    await openRemoveDialog(tester);
    expect(find.text(l10n.removeScheduleTitle), findsOneWidget);

    await tester.tap(find.text(l10n.removeScheduleConfirmButton));
    await tester.pumpAndSettle();

    expect(repository.removeCalls, 1);
    expect(find.text(l10n.removeScheduleTitle), findsNothing);
    expect(find.text('Push Day'), findsNothing);
  });

  testWidgets('cancelling keeps the plan', (tester) async {
    await openRemoveDialog(tester);

    await tester.tap(find.text(l10n.removeScheduleCancelButton));
    await tester.pumpAndSettle();

    expect(repository.removeCalls, 0);
    expect(find.text('Push Day'), findsOneWidget);
  });

  testWidgets('a failed removal shows the error and offers Retry', (
    tester,
  ) async {
    repository.failRemoval = true;
    await openRemoveDialog(tester);

    await tester.tap(find.text(l10n.removeScheduleConfirmButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.scheduleRemoveError), findsOneWidget);
    expect(find.text(l10n.removeScheduleRetryButton), findsOneWidget);
    expect(find.text('Push Day'), findsOneWidget);
  });
}
