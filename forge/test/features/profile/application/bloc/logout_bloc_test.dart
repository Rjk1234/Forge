import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/application/bloc/logout_bloc.dart';
import 'package:forge/features/profile/application/bloc/logout_event.dart';
import 'package:forge/features/profile/application/bloc/logout_state.dart';
import 'package:forge/features/profile/application/use_cases/clear_user_data_use_case.dart';
import 'package:forge/features/profile/domain/repositories/account_data_repository.dart';
import 'package:fpdart/fpdart.dart';

class _FakeRepository implements AccountDataRepository {
  _FakeRepository({this.fails = false});

  final bool fails;
  int calls = 0;

  @override
  Future<Either<AppException, void>> clearUserData() async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return fails ? Left(CacheException(message: 'boom')) : const Right(null);
  }
}

LogoutBloc _bloc(AccountDataRepository repository) =>
    LogoutBloc(clearUserData: ClearUserDataUseCase(repository: repository));

void main() {
  test('starts waiting for confirmation', () {
    expect(_bloc(_FakeRepository()).state, isA<LogoutConfirmation>());
  });

  blocTest<LogoutBloc, LogoutState>(
    'confirming clears the data and reports success',
    build: () => _bloc(_FakeRepository()),
    act: (bloc) => bloc.add(const LogoutConfirmed()),
    wait: const Duration(milliseconds: 50),
    expect: () => [isA<LogoutInProgress>(), isA<LogoutSuccess>()],
  );

  blocTest<LogoutBloc, LogoutState>(
    'a storage failure is reported so the user can retry',
    build: () => _bloc(_FakeRepository(fails: true)),
    act: (bloc) => bloc.add(const LogoutConfirmed()),
    wait: const Duration(milliseconds: 50),
    expect: () => [isA<LogoutInProgress>(), isA<LogoutFailure>()],
  );

  test('a second confirm while clearing does not wipe twice', () async {
    final repository = _FakeRepository();
    final bloc = _bloc(repository)
      ..add(const LogoutConfirmed())
      ..add(const LogoutConfirmed());
    await bloc.stream.firstWhere((state) => state is LogoutSuccess);
    await bloc.close();

    expect(repository.calls, 1);
  });

  test('retrying after a failure runs the wipe again', () async {
    final repository = _FakeRepository(fails: true);
    final bloc = _bloc(repository)..add(const LogoutConfirmed());
    await bloc.stream.firstWhere((state) => state is LogoutFailure);
    bloc.add(const LogoutConfirmed());
    await bloc.stream.firstWhere((state) => state is LogoutFailure);
    await bloc.close();

    expect(repository.calls, 2);
  });
}
