import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/get_dashboard_snapshot_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.getDashboardSnapshot}) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  final GetDashboardSnapshotUseCase getDashboardSnapshot;

  FutureOr<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoading) return;

    // A refresh keeps the current content instead of flashing a spinner.
    if (state is! HomePopulated) emit(const HomeLoading());

    final result = await getDashboardSnapshot();

    result.fold(
      (failure) => emit(const HomeError()),
      (snapshot) => emit(HomePopulated(snapshot)),
    );
  }
}
