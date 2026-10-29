import 'package:forge/features/stats/presentation/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_bloc.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_event.dart';
import 'package:forge/features/personal_bests/application/bloc/pb_state.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_card.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_empty_state.dart';
import 'package:forge/features/personal_bests/presentation/widgets/pb_skeleton.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';

class PersonalBestsScreen extends StatelessWidget {
  static const String routePath = '${StatsScreen.routePath}/personal-bests';
  static const String routeName = 'personalBests';

  const PersonalBestsScreen({super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _topPadding = AppSpacing.mdl;
  static const double _bottomPadding = 28;
  static const double _itemGap = AppSpacing.smd;

  void _requestLoad(BuildContext context) {
    context.read<PbBloc>().add(const PbLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(context.l10n.pbScreenTitle, style: textTheme.titleLarge),
      ),
      body: BlocBuilder<PbBloc, PbState>(
        builder: (context, state) => switch (state) {
          PbInitial() || PbLoading() => const PbSkeleton(),
          PbLoaded(:final records) => _buildLoaded(context, records),
          PbError() => ErrorCard(
            title: context.l10n.pbErrorTitle,
            message: context.l10n.pbErrorBody,
            onRetry: () => _requestLoad(context),
          ),
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, List<PersonalBestRecord> records) {
    if (records.isEmpty) return const PbEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        PersonalBestsScreen._horizontalPadding,
        PersonalBestsScreen._topPadding,
        PersonalBestsScreen._horizontalPadding,
        PersonalBestsScreen._bottomPadding,
      ),
      itemCount: records.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: PersonalBestsScreen._itemGap),
      itemBuilder: (_, index) => PbCard(
        key: ValueKey(
          '${records[index].exerciseName}-${records[index].type.name}',
        ),
        record: records[index],
      ),
    );
  }
}
