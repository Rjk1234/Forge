import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/delete_plan_dialog.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class MockDeletePlanBloc extends MockBloc<DeletePlanEvent, DeletePlanState>
    implements DeletePlanBloc {}

Widget _wrap(DeletePlanBloc bloc) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: BlocProvider<DeletePlanBloc>.value(
    value: bloc,
    child: const Material(
      child: DeletePlanDialog(planId: 'p1', planName: 'Push Day'),
    ),
  ),
);

void main() {
  setUpAll(() {
    registerFallbackValue(const DeletePlanConfirmed(planId: ''));
  });

  group('DeletePlanDialog — Confirmation state', () {
    late MockDeletePlanBloc bloc;

    setUp(() {
      bloc = MockDeletePlanBloc();
      when(() => bloc.state).thenReturn(const DeletePlanConfirmation());
      whenListen(
        bloc,
        Stream<DeletePlanState>.fromIterable([const DeletePlanConfirmation()]),
        initialState: const DeletePlanConfirmation(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows title and plan name in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.deletePlanDialogTitle), findsOneWidget);
      expect(find.textContaining('Push Day'), findsOneWidget);
    });

    testWidgets('shows Cancel and Delete buttons', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.deletePlanCancelButton), findsOneWidget);
      expect(find.text(l10n.deletePlanDeleteButton), findsOneWidget);
    });

    testWidgets('Delete tap dispatches DeletePlanConfirmed', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      await tester.tap(find.text(l10n.deletePlanDeleteButton));
      await tester.pump();

      verify(() => bloc.add(const DeletePlanConfirmed(planId: 'p1'))).called(1);
    });

    testWidgets('Cancel tap pops with false', (tester) async {
      bool? poppedWith;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          home: BlocProvider<DeletePlanBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  poppedWith = await showDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider<DeletePlanBloc>.value(
                      value: bloc,
                      child: const DeletePlanDialog(
                        planId: 'p1',
                        planName: 'Push Day',
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.deletePlanCancelButton));
      await tester.pumpAndSettle();

      expect(poppedWith, isFalse);
    });
  });

  group('DeletePlanDialog — Deleting state', () {
    late MockDeletePlanBloc bloc;

    setUp(() {
      bloc = MockDeletePlanBloc();
      when(() => bloc.state).thenReturn(const DeletePlanDeleting());
      whenListen(
        bloc,
        Stream<DeletePlanState>.fromIterable([const DeletePlanDeleting()]),
        initialState: const DeletePlanDeleting(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows Deleting label', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.deletePlanDeletingLabel), findsOneWidget);
    });

    testWidgets('Cancel button is disabled', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final cancelFinder = find.widgetWithText(
        FilledButton,
        l10n.deletePlanCancelButton,
      );
      final button = tester.widget<FilledButton>(cancelFinder);
      expect(button.onPressed, isNull);
    });
  });

  group('DeletePlanDialog — Success state (listener)', () {
    late MockDeletePlanBloc bloc;

    testWidgets('pops dialog with true on Success', (tester) async {
      bloc = MockDeletePlanBloc();
      when(() => bloc.state).thenReturn(const DeletePlanConfirmation());
      whenListen(
        bloc,
        Stream<DeletePlanState>.fromIterable([
          const DeletePlanConfirmation(),
          const DeletePlanDeleting(),
          const DeletePlanSuccess(),
        ]),
        initialState: const DeletePlanConfirmation(),
      );

      bool? poppedWith;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          home: BlocProvider<DeletePlanBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  poppedWith = await showDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider<DeletePlanBloc>.value(
                      value: bloc,
                      child: const DeletePlanDialog(
                        planId: 'p1',
                        planName: 'Push Day',
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(poppedWith, isTrue);
      bloc.close();
    });
  });

  group('DeletePlanDialog — Failure state', () {
    late MockDeletePlanBloc bloc;

    setUp(() {
      bloc = MockDeletePlanBloc();
      when(() => bloc.state).thenReturn(const DeletePlanFailure());
      whenListen(
        bloc,
        Stream<DeletePlanState>.fromIterable([const DeletePlanFailure()]),
        initialState: const DeletePlanFailure(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.textContaining("Couldn't delete the plan"), findsOneWidget);
    });

    testWidgets('shows Retry button with lime colour', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.deletePlanRetryButton), findsOneWidget);
    });

    testWidgets('Retry tap dispatches DeletePlanConfirmed', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      await tester.tap(find.text(l10n.deletePlanRetryButton));
      await tester.pump();

      verify(() => bloc.add(const DeletePlanConfirmed(planId: 'p1'))).called(1);
    });

    testWidgets('Cancel button is enabled', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final cancelFinder = find.widgetWithText(
        FilledButton,
        l10n.deletePlanCancelButton,
      );
      final button = tester.widget<FilledButton>(cancelFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('lime button uses the primary color background', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc));

      final retryFinder = find.widgetWithText(
        FilledButton,
        l10n.deletePlanRetryButton,
      );
      final button = tester.widget<FilledButton>(retryFinder);
      final bg = button.style?.backgroundColor?.resolve({});
      expect(bg, AppTheme.darkTheme.colorScheme.primary);
    });
  });
}
