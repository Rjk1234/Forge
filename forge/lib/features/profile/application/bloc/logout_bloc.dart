import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/profile/application/bloc/logout_event.dart';
import 'package:forge/features/profile/application/bloc/logout_state.dart';
import 'package:forge/features/profile/application/use_cases/clear_user_data_use_case.dart';

/// Deletes the user's data on logout. Locking the app and navigating to the
/// login screen is left to the presentation layer once this reports success.
class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc({required this.clearUserData})
    : super(const LogoutConfirmation()) {
    on<LogoutConfirmed>(_onConfirmed);
  }

  final ClearUserDataUseCase clearUserData;

  Future<void> _onConfirmed(
    LogoutConfirmed event,
    Emitter<LogoutState> emit,
  ) async {
    if (state is LogoutInProgress) return;
    emit(const LogoutInProgress());
    final result = await clearUserData();
    result.fold(
      (failure) => emit(const LogoutFailure()),
      (_) => emit(const LogoutSuccess()),
    );
  }
}
