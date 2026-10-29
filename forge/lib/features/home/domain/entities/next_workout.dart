import 'package:equatable/equatable.dart';

/// The next scheduled workout after today.
class NextWorkout extends Equatable {
  const NextWorkout({required this.weekday, required this.planName});

  /// 1 = Monday … 7 = Sunday.
  final int weekday;
  final String planName;

  @override
  List<Object> get props => [weekday, planName];
}
