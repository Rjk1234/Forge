/// Shared spacing, corner radii and icon sizes for the fixed dark theme.
///
/// Widgets use these instead of per-widget numbers so every screen shares the
/// same rhythm. Add a token here only when two or more widgets need it.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double xsm = 6;
  static const double sm = 8;
  static const double smd = 10;
  static const double md = 12;
  static const double mdl = 14;
  static const double lg = 16;
  static const double lgx = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

abstract final class AppRadius {
  static const double small = 8;
  static const double control = 10;
  static const double banner = 12;
  static const double card = 14;
  static const double sheet = 16;
  static const double dialog = 18;
}

abstract final class AppIconSize {
  static const double inline = 18;
  static const double state = 40;
  static const double illustration = 52;
  static const double dialog = 36;
}

/// Minimum touch target for tappable controls.
const double kMinTouchTarget = 44;

/// Height of the primary full-width button.
const double kButtonHeight = 48;
