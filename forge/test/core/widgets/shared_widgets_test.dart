import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/core/widgets/confirm_dialog.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/core/widgets/status_banner.dart';
import 'package:forge/l10n/l10n.dart';

import '../../helpers/l10n.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: child),
);

ConfirmDialog _dialog(ConfirmDialogStatus status, VoidCallback onConfirm) =>
    ConfirmDialog(
      icon: Icons.delete_outline,
      title: 'Title',
      message: 'Message',
      cancelLabel: 'Cancel',
      confirmLabel: 'Delete',
      busyLabel: 'Deleting…',
      retryLabel: 'Try again',
      errorMessage: 'It failed',
      status: status,
      onConfirm: onConfirm,
    );

void main() {
  group('AppCard', () {
    testWidgets('renders its child inside a bordered surface', (tester) async {
      await tester.pumpWidget(_host(const AppCard(child: Text('inside'))));

      expect(find.text('inside'), findsOneWidget);
      final box = tester.widget<Container>(find.byType(Container).first);
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, isNotNull);
    });
  });

  group('AppEmptyState', () {
    testWidgets('shows copy and fires the action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          AppEmptyState(
            icon: Icons.history,
            title: 'Nothing yet',
            subtitle: 'Do something',
            actionLabel: 'Go',
            onAction: () => taps++,
          ),
        ),
      );

      expect(find.text('Nothing yet'), findsOneWidget);
      expect(find.text('Do something'), findsOneWidget);
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('has no button without an action', (tester) async {
      await tester.pumpWidget(
        _host(
          const AppEmptyState(
            icon: Icons.history,
            title: 'Nothing yet',
            subtitle: 'Do something',
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('ErrorCard', () {
    testWidgets('uses the shared Retry label and fires onRetry', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpWidget(
        _host(ErrorCard(message: 'Broken', onRetry: () => retries++)),
      );

      await tester.tap(find.text(l10n.retryButton));
      expect(retries, 1);
    });

    testWidgets('shows the title and disables Retry while retrying', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ErrorCard(
            title: 'Oops',
            message: 'Broken',
            retryLabel: 'Again',
            isRetrying: true,
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Oops'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
      expect(find.text('Again'), findsOneWidget);
    });
  });

  group('StatusBanner', () {
    testWidgets('shows message and optional subtitle', (tester) async {
      await tester.pumpWidget(
        _host(const StatusBanner(message: 'Bad', subtitle: 'Because')),
      );

      expect(find.text('Bad'), findsOneWidget);
      expect(find.text('Because'), findsOneWidget);
    });
  });

  group('ConfirmDialog', () {
    testWidgets('idle shows Delete and fires onConfirm', (tester) async {
      var confirms = 0;
      await tester.pumpWidget(
        _host(_dialog(ConfirmDialogStatus.idle, () => confirms++)),
      );

      await tester.tap(find.text('Delete'));
      expect(confirms, 1);
      expect(find.text('It failed'), findsNothing);
    });

    testWidgets('busy shows the busy label and disables both buttons', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_dialog(ConfirmDialogStatus.busy, () {})));

      expect(find.text('Deleting…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final buttons = tester.widgetList<FilledButton>(
        find.byType(FilledButton),
      );
      expect(buttons.every((b) => b.onPressed == null), isTrue);
    });

    testWidgets('failed shows the error and a Retry confirm button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(_dialog(ConfirmDialogStatus.failed, () {})),
      );

      expect(find.text('It failed'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });
  });
}
