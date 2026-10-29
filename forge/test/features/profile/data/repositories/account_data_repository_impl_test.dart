import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/profile/data/datasources/account_data_local_data_source.dart';
import 'package:forge/features/profile/data/repositories/account_data_repository_impl.dart';

class _FakeDataSource implements AccountDataLocalDataSource {
  _FakeDataSource({this.shouldThrow = false});

  final bool shouldThrow;
  int calls = 0;

  @override
  Future<void> clearUserData() async {
    calls++;
    if (shouldThrow) throw Exception('disk full');
  }
}

void main() {
  test('returns Right and clears once on success', () async {
    final source = _FakeDataSource();

    final result = await AccountDataRepositoryImpl(
      dataSource: source,
    ).clearUserData();

    expect(result.isRight(), isTrue);
    expect(source.calls, 1);
  });

  test('maps a storage failure to a CacheException', () async {
    final result = await AccountDataRepositoryImpl(
      dataSource: _FakeDataSource(shouldThrow: true),
    ).clearUserData();

    result.fold(
      (failure) => expect(failure, isA<CacheException>()),
      (_) => fail('Expected Left'),
    );
  });
}
