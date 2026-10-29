import 'package:equatable/equatable.dart';

sealed class RemoveScheduleEntryEvent extends Equatable {
  const RemoveScheduleEntryEvent();
}

final class RemoveScheduleEntryConfirmed extends RemoveScheduleEntryEvent {
  const RemoveScheduleEntryConfirmed({required this.weekday});

  final int weekday;

  @override
  List<Object?> get props => [weekday];
}
