import 'package:equatable/equatable.dart';

/// The most recent completed workout, for the Home recap.
class LastWorkout extends Equatable {
  const LastWorkout({
    required this.sessionId,
    required this.planName,
    required this.completedAt,
    required this.durationSec,
    required this.volumeKg,
  });

  final String sessionId;
  final String planName;
  final DateTime completedAt;
  final int durationSec;
  final double volumeKg;

  @override
  List<Object> get props => [
    sessionId,
    planName,
    completedAt,
    durationSec,
    volumeKg,
  ];
}
