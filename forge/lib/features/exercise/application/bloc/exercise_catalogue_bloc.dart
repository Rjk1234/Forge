import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_event.dart';
import 'package:forge/features/exercise/application/bloc/exercise_catalogue_state.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/usecases/get_exercises_usecase.dart';

class ExerciseCatalogueBloc
    extends Bloc<ExerciseCatalogueEvent, ExerciseCatalogueState> {
  ExerciseCatalogueBloc({required this.getExercises})
    : super(const ExerciseCatalogueInitial()) {
    on<ExerciseCatalogueLoadRequested>(_onLoadRequested);
    on<ExerciseCatalogueSearchChanged>(_onSearchChanged);
    on<ExerciseCatalogueFilterChanged>(_onFilterChanged);
  }

  final GetExercisesUseCase getExercises;

  List<Exercise> _allExercises = [];
  String _activeQuery = '';
  ExerciseType? _activeFilter;

  FutureOr<void> _onLoadRequested(
    ExerciseCatalogueLoadRequested event,
    Emitter<ExerciseCatalogueState> emit,
  ) async {
    if (state is ExerciseCatalogueLoading) return;

    emit(const ExerciseCatalogueLoading());

    final result = await getExercises();

    result.fold((failure) => emit(const ExerciseCatalogueError()), (exercises) {
      _allExercises = exercises;
      _activeQuery = '';
      _activeFilter = null;
      _applyFilter(emit, query: '', activeFilter: null);
    });
  }

  void _onSearchChanged(
    ExerciseCatalogueSearchChanged event,
    Emitter<ExerciseCatalogueState> emit,
  ) {
    _activeQuery = event.query;
    _applyFilter(emit, query: _activeQuery, activeFilter: _activeFilter);
  }

  FutureOr<void> _onFilterChanged(
    ExerciseCatalogueFilterChanged event,
    Emitter<ExerciseCatalogueState> emit,
  ) {
    _activeFilter = event.type;
    _applyFilter(emit, query: _activeQuery, activeFilter: _activeFilter);
  }

  void _applyFilter(
    Emitter<ExerciseCatalogueState> emit, {
    required String query,
    required ExerciseType? activeFilter,
  }) {
    var filtered = _allExercises;

    if (activeFilter != null) {
      filtered = filtered.where((e) => e.type == activeFilter).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (filtered.isEmpty) {
      emit(ExerciseCatalogueEmpty(query: query, activeFilter: activeFilter));
    } else {
      emit(
        ExerciseCataloguePopulated(
          displayedExercises: filtered,
          query: query,
          activeFilter: activeFilter,
        ),
      );
    }
  }
}
