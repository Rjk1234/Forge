import 'package:equatable/equatable.dart';

sealed class RestTimerState extends Equatable {
  const RestTimerState();
}

final class RestTimerInitial extends RestTimerState {
  const RestTimerInitial();

  @override
  List<Object?> get props => [];
}

final class RestTimerRunning extends RestTimerState {
  const RestTimerRunning({
    required this.totalSec,
    required this.remainingSec,
    this.navigateBack = false,
  });

  final int totalSec;
  final int remainingSec;
  final bool navigateBack;

  @override
  List<Object?> get props => [totalSec, remainingSec, navigateBack];

  RestTimerRunning copyWith({int? remainingSec, bool? navigateBack}) {
    return RestTimerRunning(
      totalSec: totalSec,
      remainingSec: remainingSec ?? this.remainingSec,
      navigateBack: navigateBack ?? this.navigateBack,
    );
  }
}
