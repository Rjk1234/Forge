import 'package:flutter/material.dart';

/// Makes [child] as wide as the space its parent offers.
class FullWidth extends StatelessWidget {
  const FullWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FractionallySizedBox(widthFactor: 1, child: child);
}
