import 'package:equatable/equatable.dart';

sealed class DeletePlanEvent extends Equatable {
  const DeletePlanEvent();
}

final class DeletePlanConfirmed extends DeletePlanEvent {
  const DeletePlanConfirmed({required this.planId});

  final String planId;

  @override
  List<Object?> get props => [planId];
}
