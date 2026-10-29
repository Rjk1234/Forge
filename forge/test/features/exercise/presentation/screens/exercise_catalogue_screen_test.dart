import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_bloc.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/entities/picker_context.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/exercise/domain/usecases/get_exercises_usecase.dart';
import 'package:forge/features/exercise/presentation/screens/exercise_catalogue_screen.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forge/l10n/l10n.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo implements ExerciseRepository {
  final Either<AppException, List<Exercise>> result;
  _FakeRepo(this.result);

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() async => result;
}

class _ControlledRepo implements ExerciseRepository {
  final _completer = Completer<Either<AppException, List<Exercise>>>();

  void complete(Either<AppException, List<Exercise>> result) {
    if (!_completer.isCompleted) _completer.complete(result);
  }

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() =>
      _completer.future;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseCatalogueBloc _makeBloc(Either<AppException, List<Exercise>> result) =>
    ExerciseCatalogueBloc(
      getExercises: GetExercisesUseCase(repository: _FakeRepo(result)),
    );

Widget _pump(ExerciseCatalogueBloc bloc, {PickerContext? pickerContext}) {
  bloc.add(const ExerciseCatalogueLoadRequested());
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    home: BlocProvider<ExerciseCatalogueBloc>.value(
      value: bloc,
      child: ExerciseCatalogueScreen(pickerContext: pickerContext),
    ),
  );
}

final _benchPress = Exercise(
  id: 'ex_bench',
  name: 'Bench Press',
  type: ExerciseType.weighted,
);
final _plank = Exercise(
  id: 'ex_plank',
  name: 'Plank',
  type: ExerciseType.timeBased,
);
final _pushUp = Exercise(
  id: 'ex_pushup',
  name: 'Push-up',
  type: ExerciseType.bodyweight,
);

// ---------------------------------------------------------------------------
// US1 — View Exercise Catalogue
// ---------------------------------------------------------------------------

void main() {
  group('ExerciseCatalogueScreen — US1 (browse mode)', () {
    testWidgets('shows skeleton while loading', (tester) async {
      final controller = _ControlledRepo();
      final bloc = ExerciseCatalogueBloc(
        getExercises: GetExercisesUseCase(repository: controller),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump();

      expect(find.byType(ExerciseCatalogueScreen), findsOneWidget);
      expect(find.text('Exercise Catalogue'), findsOneWidget);
      // Skeleton is showing (no exercise names)
      expect(find.text('Bench Press'), findsNothing);

      controller.complete(Right([_benchPress]));
      bloc.close();
    });

    testWidgets('shows exercise list rows after load', (tester) async {
      final bloc = _makeBloc(Right([_benchPress, _plank, _pushUp]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Plank'), findsOneWidget);
      expect(find.text('Push-up'), findsOneWidget);
      // 'Weighted', 'Time-based', 'Bodyweight' each appear in both the list
      // item type label and the filter chip row.
      expect(find.text('Weighted'), findsWidgets);
      expect(find.text('Time-based'), findsWidgets);
      expect(find.text('Bodyweight'), findsWidgets);
      bloc.close();
    });

    testWidgets('browse-mode rows are non-interactive (FR-014)', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_benchPress]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      // Tapping a browse-mode row triggers no navigation (no InkWell response).
      // The row has no InkWell; tapping should produce no action.
      await tester.tap(find.text('Bench Press'));
      await tester.pump();

      // Screen is unchanged — still shows Exercise Catalogue title.
      expect(find.text('Exercise Catalogue'), findsOneWidget);
      bloc.close();
    });

    testWidgets(
      'ErrorCard renders on ExerciseCatalogueError with correct copy',
      (tester) async {
        final bloc = _makeBloc(
          Left(CacheException(message: "Couldn't load the exercise catalogue")),
        );

        await tester.pumpWidget(_pump(bloc));
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          find.text("Couldn't load the exercise catalogue"),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
        bloc.close();
      },
    );

    testWidgets('no picker banner in browse mode', (tester) async {
      final bloc = _makeBloc(Right([_benchPress]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Adding an exercise to'), findsNothing);
      bloc.close();
    });

    testWidgets('app bar always shows back icon', (tester) async {
      final bloc = _makeBloc(Right([_benchPress]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      bloc.close();
    });
  });

  // ---------------------------------------------------------------------------
  // US2 — Search and Filter
  // ---------------------------------------------------------------------------

  group('ExerciseCatalogueScreen — US2 (search and filter)', () {
    testWidgets('search field and filter chips visible when populated', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_benchPress, _plank]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Weighted'), findsWidgets);
      bloc.close();
    });

    testWidgets('typing dispatches SearchChanged and filters list', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_benchPress, _plank, _pushUp]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Plank'), findsNothing);
      bloc.close();
    });

    testWidgets('chip tap dispatches FilterChanged', (tester) async {
      final bloc = _makeBloc(Right([_benchPress, _plank, _pushUp]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap "Weighted" chip
      await tester.tap(find.text('Weighted').first);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Plank'), findsNothing);
      bloc.close();
    });

    testWidgets('empty state widget visible when ExerciseCatalogueEmpty', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_benchPress]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('No exercises match your search'), findsOneWidget);
      expect(
        find.text('Try a different name or clear the filter.'),
        findsOneWidget,
      );
      bloc.close();
    });

    testWidgets('search bar and filter chips hidden in error state (FR-010)', (
      tester,
    ) async {
      final bloc = _makeBloc(
        Left(CacheException(message: "Couldn't load the exercise catalogue")),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TextField), findsNothing);
      expect(find.text('All'), findsNothing);
      bloc.close();
    });
  });

  // ---------------------------------------------------------------------------
  // US3 — Picker Mode
  // ---------------------------------------------------------------------------

  group('ExerciseCatalogueScreen — US3 (picker mode)', () {
    const pickerContext = PickerContext(planName: 'Push Day');

    testWidgets('picker banner visible with plan name', (tester) async {
      final bloc = _makeBloc(Right([_benchPress]));

      await tester.pumpWidget(_pump(bloc, pickerContext: pickerContext));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Adding an exercise to'), findsOneWidget);
      // 'Push Day' is a TextSpan inside Text.rich — use textContaining.
      expect(find.textContaining('Push Day'), findsOneWidget);
      bloc.close();
    });

    testWidgets('+ button visible per row in picker mode', (tester) async {
      final bloc = _makeBloc(Right([_benchPress, _plank]));

      await tester.pumpWidget(_pump(bloc, pickerContext: pickerContext));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.add), findsNWidgets(2));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      bloc.close();
    });

    testWidgets('no + buttons and chevrons shown in browse mode', (
      tester,
    ) async {
      final bloc = _makeBloc(Right([_benchPress, _plank]));

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
      bloc.close();
    });

    testWidgets('search and filter still work in picker mode', (tester) async {
      final bloc = _makeBloc(Right([_benchPress, _plank, _pushUp]));

      await tester.pumpWidget(_pump(bloc, pickerContext: pickerContext));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Plank'), findsNothing);
      bloc.close();
    });
  });

  // ---------------------------------------------------------------------------
  // US4 — Error Recovery
  // ---------------------------------------------------------------------------

  group('ExerciseCatalogueScreen — US4 (error recovery)', () {
    testWidgets('Retry button tap dispatches LoadRequested', (tester) async {
      var callCount = 0;
      final repo = _FakeRepo(
        Left(CacheException(message: "Couldn't load the exercise catalogue")),
      );
      // Wrap in a bloc that counts calls
      final bloc = ExerciseCatalogueBloc(
        getExercises: GetExercisesUseCase(
          repository: _CountingRepo(repo, () => callCount++),
        ),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(callCount, greaterThan(1));
      bloc.close();
    });

    testWidgets('back icon visible from error state', (tester) async {
      final bloc = _makeBloc(
        Left(CacheException(message: "Couldn't load the exercise catalogue")),
      );

      await tester.pumpWidget(_pump(bloc));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      bloc.close();
    });
  });
} // end main()

// ---------------------------------------------------------------------------
// Helper: counting repo wrapper
// ---------------------------------------------------------------------------

class _CountingRepo implements ExerciseRepository {
  _CountingRepo(this._inner, this._onCall);

  final ExerciseRepository _inner;
  final VoidCallback _onCall;

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() {
    _onCall();
    return _inner.getExercises();
  }
}
