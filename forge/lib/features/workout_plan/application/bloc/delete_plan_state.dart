import 'package:equatable/equatable.dart';

sealed class DeletePlanState extends Equatable {
  const DeletePlanState();
}

final class DeletePlanConfirmation extends DeletePlanState {
  const DeletePlanConfirmation();

  @override
  List<Object?> get props => [];
}

final class DeletePlanDeleting extends DeletePlanState {
  const DeletePlanDeleting();

  @override
  List<Object?> get props => [];
}

final class DeletePlanSuccess extends DeletePlanState {
  const DeletePlanSuccess();

  @override
  List<Object?> get props => [];
}

final class DeletePlanFailure extends DeletePlanState {
  const DeletePlanFailure();

  @override
  List<Object?> get props => [];
}
