import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

final class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();

  @override
  List<Object?> get props => [];
}
