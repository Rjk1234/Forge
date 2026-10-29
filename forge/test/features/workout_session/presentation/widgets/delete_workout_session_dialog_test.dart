import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/delete_workout_session_dialog.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/l10n.dart';

class _MockBloc
    extends MockBloc<DeleteWorkoutSessionEvent, DeleteWorkoutSessionState>
    implements DeleteWorkoutSessionBloc {}

Future<bool?> _open(
  WidgetTester tester,
  _MockBloc bloc, {
  Stream<DeleteWorkoutSessionState>? stream,
}) async {
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<bool>(
              context: context,
              builder: (_) => BlocProvider<DeleteWorkoutSessionBloc>.value(
                value: bloc,
                child: const DeleteWorkoutSessionDialog(sessionId: 's1'),
              ),
            );
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump(const Duration(milliseconds: 400));
  return result;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const DeleteWorkoutSessionConfirmed(sessionId: 's1'));
  });

  testWidgets('shows the confirmation copy and buttons', (tester) async {
    final bloc = _MockBloc();
    when(() => bloc.state).thenReturn(const DeleteWorkoutSessionConfirmation());
    await _open(tester, bloc);

    expect(find.text(l10n.deleteSessionDialogTitle), findsOneWidget);
    expect(find.text(l10n.deleteSessionDialogMessage), findsOneWidget);
    expect(find.text(l10n.deleteSessionCancelButton), findsOneWidget);
    expect(find.text(l10n.deleteSessionDeleteButton), findsOneWidget);
  });

  testWidgets('Delete dispatches the confirmation event', (tester) async {
    final bloc = _MockBloc();
    when(() => bloc.state).thenReturn(const DeleteWorkoutSessionConfirmation());
    await _open(tester, bloc);

    await tester.tap(find.text(l10n.deleteSessionDeleteButton));

    verify(
      () => bloc.add(const DeleteWorkoutSessionConfirmed(sessionId: 's1')),
    ).called(1);
  });

  testWidgets('Cancel closes the dialog without deleting', (tester) async {
    final bloc = _MockBloc();
    when(() => bloc.state).thenReturn(const DeleteWorkoutSessionConfirmation());
    await _open(tester, bloc);

    await tester.tap(find.text(l10n.deleteSessionCancelButton));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteWorkoutSessionDialog), findsNothing);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('Deleting disables both buttons and shows the label', (
    tester,
  ) async {
    final bloc = _MockBloc();
    when(() => bloc.state).thenReturn(const DeleteWorkoutSessionDeleting());
    await _open(tester, bloc);

    expect(find.text(l10n.deleteSessionDeletingLabel), findsOneWidget);
    final buttons = tester.widgetList<FilledButton>(find.byType(FilledButton));
    expect(buttons.every((button) => button.onPressed == null), isTrue);
  });

  testWidgets('failure shows the error and a Retry that re-dispatches', (
    tester,
  ) async {
    final bloc = _MockBloc();
    when(() => bloc.state).thenReturn(const DeleteWorkoutSessionFailure());
    await _open(tester, bloc);

    expect(find.text(l10n.deleteSessionError), findsOneWidget);
    await tester.tap(find.text(l10n.deleteSessionRetryButton));

    verify(
      () => bloc.add(const DeleteWorkoutSessionConfirmed(sessionId: 's1')),
    ).called(1);
  });

  testWidgets('success closes the dialog', (tester) async {
    final bloc = _MockBloc();
    whenListen(
      bloc,
      Stream.value(const DeleteWorkoutSessionSuccess()),
      initialState: const DeleteWorkoutSessionConfirmation(),
    );
    await _open(tester, bloc, stream: bloc.stream);
    await tester.pumpAndSettle();

    expect(find.byType(DeleteWorkoutSessionDialog), findsNothing);
  });
}
