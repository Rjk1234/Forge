import 'package:equatable/equatable.dart';

sealed class PbEvent extends Equatable {
  const PbEvent();
}

/// Initial load and Retry.
final class PbLoadRequested extends PbEvent {
  const PbLoadRequested();

  @override
  List<Object?> get props => [];
}
