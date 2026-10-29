import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

class HomeScrollableContent extends StatelessWidget {
  const HomeScrollableContent({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
