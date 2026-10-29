import 'package:equatable/equatable.dart';

sealed class RemoveScheduleEntryState extends Equatable {
  const RemoveScheduleEntryState();
}

final class RemoveScheduleEntryConfirmation extends RemoveScheduleEntryState {
  const RemoveScheduleEntryConfirmation();

  @override
  List<Object?> get props => [];
}

final class RemoveScheduleEntryRemoving extends RemoveScheduleEntryState {
  const RemoveScheduleEntryRemoving();

  @override
  List<Object?> get props => [];
}

final class RemoveScheduleEntrySuccess extends RemoveScheduleEntryState {
  const RemoveScheduleEntrySuccess();

  @override
  List<Object?> get props => [];
}

final class RemoveScheduleEntryFailure extends RemoveScheduleEntryState {
  const RemoveScheduleEntryFailure();

  @override
  List<Object?> get props => [];
}
