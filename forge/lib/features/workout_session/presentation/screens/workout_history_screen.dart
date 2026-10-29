import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_state.dart';
import 'package:forge/features/workout_session/application/models/history_month_group.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_card.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_empty_view.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_month_label.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  static const String routePath = '/history';
  static const String routeName = 'history';

  const WorkoutHistoryScreen({super.key});

  static const double _listHorizontalPadding = AppSpacing.lgx;
  static const double _listBottomPadding = AppSpacing.md;
  static const double _itemGap = AppSpacing.smd;

  void _requestLoad(BuildContext context) {
    context.read<WorkoutHistoryBloc>().add(const WorkoutHistoryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ReloadListener(
      notifier: getIt<WorkoutHistoryReloadNotifier>(),
      onReload: () => _requestLoad(context),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.l10n.historyScreenTitle),
        ),
        body: BlocBuilder<WorkoutHistoryBloc, WorkoutHistoryState>(
          builder: (context, state) => switch (state) {
            WorkoutHistoryInitial() ||
            WorkoutHistoryLoading() => const HistorySkeleton(),
            WorkoutHistorySuccess(:final groups) => _buildList(context, groups),
            WorkoutHistoryEmpty() => const HistoryEmptyView(),
            WorkoutHistoryError() => ErrorCard(
              title: context.l10n.historyErrorTitle,
              message: context.l10n.historyErrorBody,
              retryLabel: context.l10n.historyRetryLabel,
              onRetry: () => _requestLoad(context),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<HistoryMonthGroup> groups) {
    final rows = <Widget>[
      for (final group in groups) ...[
        HistoryMonthLabel(label: group.label),
        for (final session in group.sessions)
          HistoryCard.fromSession(
            key: ValueKey(session.sessionId),
            session: session,
            l10n: context.l10n,
            onTap: () => context.push(
              WorkoutHistoryDetailScreen.routePath,
              extra: session.sessionId,
            ),
          ),
      ],
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        WorkoutHistoryScreen._listHorizontalPadding,
        0,
        WorkoutHistoryScreen._listHorizontalPadding,
        WorkoutHistoryScreen._listBottomPadding,
      ),
      itemCount: rows.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: WorkoutHistoryScreen._itemGap),
      itemBuilder: (_, index) => rows[index],
    );
  }
}
