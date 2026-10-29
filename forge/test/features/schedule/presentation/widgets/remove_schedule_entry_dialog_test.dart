import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_event.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_state.dart';
import 'package:forge/features/schedule/presentation/widgets/remove_schedule_entry_dialog.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class MockRemoveScheduleEntryBloc
    extends MockBloc<RemoveScheduleEntryEvent, RemoveScheduleEntryState>
    implements RemoveScheduleEntryBloc {}

Widget _wrap(RemoveScheduleEntryBloc bloc) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: BlocProvider<RemoveScheduleEntryBloc>.value(
    value: bloc,
    child: const Material(
      child: RemoveScheduleEntryDialog(
        weekday: 3,
        planName: 'Push Day',
        dayName: 'Wednesday',
      ),
    ),
  ),
);

void main() {
  setUpAll(() {
    registerFallbackValue(const RemoveScheduleEntryConfirmed(weekday: 0));
  });

  group('RemoveScheduleEntryDialog — Confirmation state (US1)', () {
    late MockRemoveScheduleEntryBloc bloc;

    setUp(() {
      bloc = MockRemoveScheduleEntryBloc();
      when(
        () => bloc.state,
      ).thenReturn(const RemoveScheduleEntryConfirmation());
      whenListen(
        bloc,
        Stream<RemoveScheduleEntryState>.fromIterable([
          const RemoveScheduleEntryConfirmation(),
        ]),
        initialState: const RemoveScheduleEntryConfirmation(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows title and plan/day names in subtitle', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.removeScheduleTitle), findsOneWidget);
      expect(find.textContaining('Push Day'), findsOneWidget);
      expect(find.textContaining('Wednesday'), findsOneWidget);
    });

    testWidgets('shows Cancel and Remove buttons', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.removeScheduleCancelButton), findsOneWidget);
      expect(find.text(l10n.removeScheduleConfirmButton), findsOneWidget);
    });

    testWidgets('Remove tap dispatches RemoveScheduleEntryConfirmed', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc));

      await tester.tap(find.text(l10n.removeScheduleConfirmButton));
      await tester.pump();

      verify(
        () => bloc.add(const RemoveScheduleEntryConfirmed(weekday: 3)),
      ).called(1);
    });

    testWidgets('Remove button uses lime background', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final buttonFinder = find.widgetWithText(
        FilledButton,
        l10n.removeScheduleConfirmButton,
      );
      final button = tester.widget<FilledButton>(buttonFinder);
      final bg = button.style?.backgroundColor?.resolve({});
      expect(bg, AppTheme.darkTheme.colorScheme.primary);
    });
  });

  group('RemoveScheduleEntryDialog — Cancel (US2)', () {
    late MockRemoveScheduleEntryBloc bloc;

    setUp(() {
      bloc = MockRemoveScheduleEntryBloc();
      when(
        () => bloc.state,
      ).thenReturn(const RemoveScheduleEntryConfirmation());
      whenListen(
        bloc,
        Stream<RemoveScheduleEntryState>.fromIterable([
          const RemoveScheduleEntryConfirmation(),
        ]),
        initialState: const RemoveScheduleEntryConfirmation(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('Cancel tap pops with false', (tester) async {
      bool? poppedWith;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          home: BlocProvider<RemoveScheduleEntryBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  poppedWith = await showDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider<RemoveScheduleEntryBloc>.value(
                      value: bloc,
                      child: const RemoveScheduleEntryDialog(
                        weekday: 3,
                        planName: 'Push Day',
                        dayName: 'Wednesday',
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
      await tester.tap(find.text(l10n.removeScheduleCancelButton));
      await tester.pumpAndSettle();

      expect(poppedWith, isFalse);
    });
  });

  group('RemoveScheduleEntryDialog — Removing state', () {
    late MockRemoveScheduleEntryBloc bloc;

    setUp(() {
      bloc = MockRemoveScheduleEntryBloc();
      when(() => bloc.state).thenReturn(const RemoveScheduleEntryRemoving());
      whenListen(
        bloc,
        Stream<RemoveScheduleEntryState>.fromIterable([
          const RemoveScheduleEntryRemoving(),
        ]),
        initialState: const RemoveScheduleEntryRemoving(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows Removing label', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.removeScheduleRemovingLabel), findsOneWidget);
    });

    testWidgets('Cancel button is disabled', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final cancelFinder = find.widgetWithText(
        FilledButton,
        l10n.removeScheduleCancelButton,
      );
      final button = tester.widget<FilledButton>(cancelFinder);
      expect(button.onPressed, isNull);
    });
  });

  group('RemoveScheduleEntryDialog — Success state (listener)', () {
    testWidgets('pops dialog with true on Success', (tester) async {
      final bloc = MockRemoveScheduleEntryBloc();
      when(
        () => bloc.state,
      ).thenReturn(const RemoveScheduleEntryConfirmation());
      whenListen(
        bloc,
        Stream<RemoveScheduleEntryState>.fromIterable([
          const RemoveScheduleEntryConfirmation(),
          const RemoveScheduleEntryRemoving(),
          const RemoveScheduleEntrySuccess(),
        ]),
        initialState: const RemoveScheduleEntryConfirmation(),
      );

      bool? poppedWith;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme,
          home: BlocProvider<RemoveScheduleEntryBloc>.value(
            value: bloc,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  poppedWith = await showDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider<RemoveScheduleEntryBloc>.value(
                      value: bloc,
                      child: const RemoveScheduleEntryDialog(
                        weekday: 3,
                        planName: 'Push Day',
                        dayName: 'Wednesday',
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

  group('RemoveScheduleEntryDialog — Failure state (US3)', () {
    late MockRemoveScheduleEntryBloc bloc;

    setUp(() {
      bloc = MockRemoveScheduleEntryBloc();
      when(() => bloc.state).thenReturn(const RemoveScheduleEntryFailure());
      whenListen(
        bloc,
        Stream<RemoveScheduleEntryState>.fromIterable([
          const RemoveScheduleEntryFailure(),
        ]),
        initialState: const RemoveScheduleEntryFailure(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('shows inline error message', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.textContaining("Couldn't remove"), findsOneWidget);
    });

    testWidgets('shows Retry button', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      expect(find.text(l10n.removeScheduleRetryButton), findsOneWidget);
    });

    testWidgets('Retry tap dispatches RemoveScheduleEntryConfirmed', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(bloc));

      await tester.tap(find.text(l10n.removeScheduleRetryButton));
      await tester.pump();

      verify(
        () => bloc.add(const RemoveScheduleEntryConfirmed(weekday: 3)),
      ).called(1);
    });

    testWidgets('Cancel button is enabled on failure', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final cancelFinder = find.widgetWithText(
        FilledButton,
        l10n.removeScheduleCancelButton,
      );
      final button = tester.widget<FilledButton>(cancelFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Retry button uses lime background', (tester) async {
      await tester.pumpWidget(_wrap(bloc));

      final retryFinder = find.widgetWithText(
        FilledButton,
        l10n.removeScheduleRetryButton,
      );
      final button = tester.widget<FilledButton>(retryFinder);
      final bg = button.style?.backgroundColor?.resolve({});
      expect(bg, AppTheme.darkTheme.colorScheme.primary);
    });
  });
}
