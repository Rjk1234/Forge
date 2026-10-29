import 'package:equatable/equatable.dart';
import 'package:forge/features/home/domain/entities/last_workout.dart';
import 'package:forge/features/home/domain/entities/next_workout.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/domain/entities/week_day_status.dart';

class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.hasPlans,
    this.todayWorkout,
    this.weekDays = const [],
    this.nextWorkout,
    this.hasSchedule = false,
    this.lastWorkout,
  });

  /// Whether at least one workout plan exists. When false, Home offers to
  /// create one in place of today's workout.
  final bool hasPlans;

  /// The plan assigned to today's weekday, or null when nothing is planned.
  final TodayWorkout? todayWorkout;

  /// The current week, Monday first.
  final List<WeekDayStatus> weekDays;

  /// The next scheduled workout after today, if any.
  final NextWorkout? nextWorkout;

  /// Whether any weekday has a plan assigned.
  final bool hasSchedule;

  /// The most recent completed workout, if any.
  final LastWorkout? lastWorkout;

  @override
  List<Object?> get props => [
    hasPlans,
    todayWorkout,
    weekDays,
    nextWorkout,
    hasSchedule,
    lastWorkout,
  ];
}
