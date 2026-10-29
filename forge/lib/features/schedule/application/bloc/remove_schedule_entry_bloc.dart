import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_event.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_state.dart';
import 'package:forge/features/schedule/domain/usecases/remove_schedule_entry_usecase.dart';

class RemoveScheduleEntryBloc
    extends Bloc<RemoveScheduleEntryEvent, RemoveScheduleEntryState> {
  RemoveScheduleEntryBloc({required this.removeScheduleEntry})
    : super(const RemoveScheduleEntryConfirmation()) {
    on<RemoveScheduleEntryConfirmed>(_onConfirmed);
  }

  final RemoveScheduleEntryUseCase removeScheduleEntry;

  Future<void> _onConfirmed(
    RemoveScheduleEntryConfirmed event,
    Emitter<RemoveScheduleEntryState> emit,
  ) async {
    emit(const RemoveScheduleEntryRemoving());
    final result = await removeScheduleEntry(event.weekday);
    result.fold(
      (failure) => emit(const RemoveScheduleEntryFailure()),
      (_) => emit(const RemoveScheduleEntrySuccess()),
    );
  }
}
