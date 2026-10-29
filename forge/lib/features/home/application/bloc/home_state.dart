import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_snapshot.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

final class HomePopulated extends HomeState {
  const HomePopulated(this.snapshot);

  /// snapshot.todayWorkout == null → rest day; non-null → scheduled workout.
  final DashboardSnapshot snapshot;

  @override
  List<Object?> get props => [snapshot];
}

final class HomeError extends HomeState {
  const HomeError();

  @override
  List<Object?> get props => [];
}
