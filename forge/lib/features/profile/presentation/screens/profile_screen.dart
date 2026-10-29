import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_event.dart';
import 'package:forge/features/profile/application/bloc/profile_state.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/features/profile/presentation/widgets/profile_form_view.dart';
import 'package:forge/features/profile/presentation/widgets/profile_skeleton.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  static const String routePath = '/profile';
  static const String routeName = 'profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.profileScreenTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileInitial() || ProfileLoading() => const ProfileSkeleton(),
          ProfileLoadError() => ErrorCard(
            title: context.l10n.profileLoadErrorTitle,
            message: context.l10n.profileLoadErrorBody,
            retryLabel: context.l10n.profileRetry,
            onRetry: () =>
                context.read<ProfileBloc>().add(const ProfileLoadRequested()),
          ),
          ProfileSaveError(:final profile) => ErrorCard(
            title: context.l10n.profileSaveErrorTitle,
            message: context.l10n.profileSaveErrorBody,
            retryLabel: context.l10n.profileRetry,
            onRetry: () => context.read<ProfileBloc>().add(
              ProfileSaveRequested(profile: profile),
            ),
          ),
          ProfileLoaded() => ProfileFormView(
            profile: state.profile,
            fitnessGoal: state.selectedFitnessGoal,
            experienceLevel: state.selectedExperienceLevel,
            hasHeightError: state.hasHeightError,
            hasWeightError: state.hasWeightError,
            isSaving: false,
            showSavedToast: state.showSavedToast,
          ),
          ProfileSaving(:final profile) => ProfileFormView(
            profile: profile,
            fitnessGoal: profile.fitnessGoal,
            experienceLevel: profile.experienceLevel,
            hasHeightError: false,
            hasWeightError: false,
            isSaving: true,
            showSavedToast: false,
          ),
        },
      ),
    );
  }
}
