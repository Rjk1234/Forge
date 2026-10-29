import 'package:flutter/material.dart';
import 'package:forge/core/widgets/status_banner.dart';

/// Inline wrong-credentials error banner on the login screen.
class LoginErrorBanner extends StatelessWidget {
  const LoginErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => StatusBanner(message: message);
}
