import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/profile/application/bloc/logout_bloc.dart';
import 'package:forge/features/profile/application/use_cases/clear_user_data_use_case.dart';
import 'package:forge/features/profile/domain/repositories/account_data_repository.dart';
import 'package:forge/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:fpdart/fpdart.dart';

class _FakeRepository implements AccountDataRepository {
  _FakeRepository({required this.fails});

  bool fails;

  @override
  Future<Either<AppException, void>> clearUserData() async =>
      fails ? Left(CacheException(message: 'boom')) : const Right(null);
}

Widget _host(_FakeRepository repository, ValueChanged<bool?> onResult) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => onResult(
              await showDialog<bool>(
                context: context,
                builder: (_) => BlocProvider(
                  create: (_) => LogoutBloc(
                    clearUserData: ClearUserDataUseCase(repository: repository),
                  ),
                  child: const LogoutDialog(),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('warns that the data is deleted for good', (tester) async {
    await tester.pumpWidget(_host(_FakeRepository(fails: false), (_) {}));
    await _open(tester);

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.textContaining('permanently deletes'), findsOneWidget);
    expect(find.textContaining('workout history'), findsOneWidget);
  });

  testWidgets('Cancel closes it with false and clears nothing', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _host(_FakeRepository(fails: false), (value) => result = value),
    );
    await _open(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('Log out clears the data and closes with true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _host(_FakeRepository(fails: false), (value) => result = value),
    );
    await _open(tester);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('a failure keeps the dialog open with an error and Retry', (
    tester,
  ) async {
    bool? result;
    final repository = _FakeRepository(fails: true);
    await tester.pumpWidget(_host(repository, (value) => result = value));
    await _open(tester);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't clear your data. Please try again."), findsOne);
    expect(find.text('Retry'), findsOneWidget);
    expect(result, isNull);

    repository.fails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
