import 'package:forge/app/get_it_setup.dart';
import 'package:forge/features/auth/application/cubit/app_lock_cubit.dart';
import 'package:forge/features/auth/presentation/screens/login_screen.dart';
import 'package:forge/features/profile/application/bloc/logout_bloc.dart';
import 'package:forge/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_bloc.dart';
import 'package:forge/features/profile/application/bloc/profile_event.dart';
import 'package:forge/features/profile/domain/entities/user_profile.dart';
import 'package:forge/features/profile/presentation/widgets/fitness_goal_sheet.dart';
import 'package:forge/features/profile/presentation/widgets/profile_avatar_wrap.dart';
import 'package:forge/features/profile/presentation/widgets/profile_field_group.dart';
import 'package:forge/features/profile/presentation/widgets/profile_field_input.dart';
import 'package:forge/features/profile/presentation/widgets/profile_field_row_2.dart';
import 'package:forge/features/profile/presentation/widgets/profile_field_select.dart';
import 'package:forge/features/profile/presentation/widgets/profile_logout_row.dart';
import 'package:forge/features/profile/presentation/widgets/profile_save_button.dart';
import 'package:forge/features/profile/presentation/widgets/profile_seg_row.dart';
import 'package:forge/features/profile/presentation/widgets/profile_success_toast.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

/// Editable profile form. Owns only the text controllers; every other piece
/// of form state (picker choices, validation, toast) comes from the Bloc.
class ProfileFormView extends StatefulWidget {
  const ProfileFormView({
    required this.profile,
    required this.fitnessGoal,
    required this.experienceLevel,
    required this.hasHeightError,
    required this.hasWeightError,
    required this.isSaving,
    required this.showSavedToast,
    super.key,
  });

  final UserProfile profile;
  final String fitnessGoal;
  final String experienceLevel;
  final bool hasHeightError;
  final bool hasWeightError;
  final bool isSaving;
  final bool showSavedToast;

  @override
  State<ProfileFormView> createState() => _ProfileFormViewState();
}

class _ProfileFormViewState extends State<ProfileFormView> {
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populate(widget.profile);
  }

  @override
  void didUpdateWidget(ProfileFormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _populate(widget.profile);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _populate(UserProfile profile) {
    _displayNameController.text = profile.displayName;
    _heightController.text = profile.heightCm > 0
        ? profile.heightCm.toString()
        : '';
    _weightController.text = profile.weightKg > 0
        ? profile.weightKg.toString()
        : '';
  }

  void _onSaveTap() {
    context.read<ProfileBloc>().add(
      ProfileSubmitted(
        displayName: _displayNameController.text,
        heightText: _heightController.text,
        weightText: _weightController.text,
      ),
    );
  }

  /// Asks to log out; on success the data is gone, so lock the app and return
  /// to the login screen.
  Future<void> _onLogOut() async {
    final loggedOut = await showDialog<bool>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => BlocProvider(
        create: (_) => getIt<LogoutBloc>(),
        child: const LogoutDialog(),
      ),
    );
    if (loggedOut != true || !mounted) return;
    getIt<AppLockCubit>().logout();
    context.go(LoginScreen.routePath);
  }

  void _openGoalPicker() {
    final bloc = context.read<ProfileBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FitnessGoalSheet(
        selectedGoal: widget.fitnessGoal,
        onSelect: (goal) => bloc.add(ProfileFitnessGoalSelected(goal)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileAvatarWrap(),
              const SizedBox(height: AppSpacing.xxl),
              ..._buildFields(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildActions(context),
            ],
          ),
        ),
        if (widget.showSavedToast)
          const Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: ProfileSuccessToast(),
          ),
      ],
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final l10n = context.l10n;
    final hasHeightError = widget.hasHeightError;
    final hasWeightError = widget.hasWeightError;

    return [
      ProfileFieldGroup(
        label: l10n.profileDisplayNameLabel,
        child: ProfileFieldInput(
          controller: _displayNameController,
          hint: l10n.profileDisplayNameHint,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      ProfileFieldGroup(
        label: l10n.profileFitnessGoalLabel,
        child: ProfileFieldSelect(
          value: widget.fitnessGoal,
          hint: l10n.profileFitnessGoalHint,
          onTap: _openGoalPicker,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      ProfileFieldGroup(
        label: l10n.profileExperienceLevelLabel,
        child: ProfileSegRow(
          options: l10n.profileExperienceLevelOptions,
          selected: widget.experienceLevel,
          onSelect: (level) => context.read<ProfileBloc>().add(
            ProfileExperienceLevelSelected(level),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      ProfileFieldRow2(
        leftLabel: l10n.profileHeightLabel,
        leftController: _heightController,
        leftHint: l10n.profileHeightHint,
        leftHasError: hasHeightError,
        leftErrorText: hasHeightError ? l10n.profileInvalidNumber : null,
        rightLabel: l10n.profileWeightLabel,
        rightController: _weightController,
        rightHint: l10n.profileWeightHint,
        rightHasError: hasWeightError,
        rightErrorText: hasWeightError ? l10n.profileInvalidNumber : null,
      ),
    ];
  }

  Widget _buildActions(BuildContext context) {
    final hasValidationError = widget.hasHeightError || widget.hasWeightError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSaveButton(
          onTap: widget.isSaving ? null : _onSaveTap,
          isEnabled: !widget.isSaving && !hasValidationError,
          showHelper: hasValidationError,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(height: 1, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: AppSpacing.xl),
        ProfileLogoutRow(onTap: _onLogOut),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
