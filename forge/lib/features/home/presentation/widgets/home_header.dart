import 'package:forge/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:forge/l10n/l10n.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            _greeting(context.l10n),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurface,
          ),
          tooltip: context.l10n.homeProfileTooltip,
          onPressed: () => context.push(ProfileScreen.routePath),
        ),
      ],
    );
  }
}
