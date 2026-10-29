import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';

import '../../application/cubit/app_lock_cubit.dart';
import '../../application/cubit/app_lock_state.dart';
import '../widgets/login_error_banner.dart';

/// SCR-03 — Login / Authenticate screen.
///
/// Static local login against a hardcoded demo credential.
/// No network call, no loading state. go_router redirect handles
/// navigation to SCR-06 on AppLockStatus.unlocked.
class LoginScreen extends StatefulWidget {
  static const String routePath = '/login';
  static const String routeName = 'login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _hardcodedEmail = 'user@forge.app';
  static const String _hardcodedPassword = '';
  final _emailController = TextEditingController(text: _hardcodedEmail);
  final _passwordController = TextEditingController(text: _hardcodedPassword);
  bool _obscurePassword = true;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final enabled =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
    if (enabled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = enabled);
    }
  }

  void _onFieldChanged() {
    context.read<AppLockCubit>().clearError();
  }

  void _submit() {
    context.read<AppLockCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              Text(
                context.l10n.authWelcomeTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.authWelcomeSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _buildEmailField(context),
              const SizedBox(height: AppSpacing.lg),
              _buildPasswordField(context),
              _buildErrorBanner(),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _submit : null,
                child: Text(context.l10n.authSignInButton),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      onChanged: (_) => _onFieldChanged(),
      decoration: InputDecoration(labelText: context.l10n.authEmailLabel),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onChanged: (_) => _onFieldChanged(),
      onSubmitted: (_) {
        if (_isButtonEnabled) _submit();
      },
      decoration: InputDecoration(
        labelText: context.l10n.authPasswordLabel,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return BlocBuilder<AppLockCubit, AppLockState>(
      buildWhen: (prev, curr) => prev.error != curr.error,
      builder: (context, state) {
        if (state.error == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: LoginErrorBanner(message: context.l10n.authInvalidCredentials),
        );
      },
    );
  }
}
