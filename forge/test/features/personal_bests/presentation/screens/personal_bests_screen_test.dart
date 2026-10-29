import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_bloc.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_state.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/personal_bests/presentation/screens/personal_bests_screen.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_card.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_empty_state.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

class _MockBloc extends MockBloc<PbEvent, PbState> implements PbBloc {}

final _records = [
  PersonalBestRecord(
    exerciseName: 'Barbell Bench Press',
    type: ExerciseType.weighted,
    bestDate: DateTime(2026, 8, 31),
    bestWeight: 65,
  ),
  PersonalBestRecord(
    exerciseName: 'Plank Hold',
    type: ExerciseType.timeBased,
    bestDate: DateTime(2026, 9, 7),
    bestDurationSec: 70,
  ),
  PersonalBestRecord(
    exerciseName: 'Push-Ups',
    type: ExerciseType.bodyweight,
    bestDate: DateTime(2026, 9, 1),
    bestReps: 18,
  ),
];

Widget _wrap(PbBloc bloc) => MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/pb'),
            child: const Text('Stats stub'),
          ),
        ),
      ),
      GoRoute(
        path: '/pb',
        builder: (_, _) => BlocProvider<PbBloc>.value(
          value: bloc,
          child: const PersonalBestsScreen(),
        ),
      ),
    ],
  ),
);

Future<void> _open(WidgetTester tester, PbBloc bloc) async {
  await tester.pumpWidget(_wrap(bloc));
  await tester.pump();
  await tester.tap(find.text('Stats stub'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

_MockBloc _blocIn(PbState state, {Stream<PbState>? stream}) {
  final bloc = _MockBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => stream ?? const Stream.empty());
  return bloc;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const PbLoadRequested());
  });

  testWidgets('Initial and Loading show the skeleton', (tester) async {
    await _open(tester, _blocIn(const PbLoading()));
    expect(find.byType(PbSkeleton), findsOneWidget);
    expect(find.text(l10n.pbScreenTitle), findsOneWidget);
  });

  testWidgets('Loaded shows a card per record with type-specific badges', (
    tester,
  ) async {
    await _open(tester, _blocIn(PbLoaded(records: _records)));

    expect(find.byType(PbCard), findsNWidgets(3));
    expect(find.text('65 kg'), findsOneWidget);
    expect(find.text('BEST WEIGHT'), findsOneWidget);
    expect(find.text('Set Aug 31, 2026'), findsOneWidget);
    expect(find.text('01:10'), findsOneWidget);
    expect(find.text('BEST TIME'), findsOneWidget);
    expect(find.text('18 reps'), findsOneWidget);
    expect(find.text('BEST REPS'), findsOneWidget);
  });

  testWidgets('cards are not tappable', (tester) async {
    await _open(tester, _blocIn(PbLoaded(records: _records)));

    expect(
      find.descendant(of: find.byType(PbCard), matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('Empty shows the prompt without a button', (tester) async {
    await _open(tester, _blocIn(const PbLoaded(records: [])));

    expect(find.byType(PbEmptyState), findsOneWidget);
    expect(find.text(l10n.pbEmptyTitle), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('Error shows copy and Retry; Retry dispatches once', (
    tester,
  ) async {
    final bloc = _blocIn(const PbError());
    await _open(tester, bloc);
    clearInteractions(bloc);

    expect(find.text(l10n.pbErrorTitle), findsOneWidget);
    expect(find.text(l10n.pbErrorBody), findsOneWidget);

    final retry = find.text(l10n.retryButton);
    await tester.tap(retry);
    await tester.pump();

    verify(() => bloc.add(any())).called(1);
  });

  testWidgets('Retry is usable again after a failed retry', (tester) async {
    final controller = StreamController<PbState>.broadcast();
    final bloc = _blocIn(const PbError(), stream: controller.stream);
    await _open(tester, bloc);
    clearInteractions(bloc);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();
    controller
      ..add(const PbLoading())
      ..add(const PbError());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text(l10n.retryButton));
    await tester.pump();

    verify(() => bloc.add(any())).called(2);

    await controller.close();
  });

  testWidgets('the back arrow returns to the previous screen', (tester) async {
    await _open(tester, _blocIn(PbLoaded(records: _records)));

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Stats stub'), findsOneWidget);
  });
}
