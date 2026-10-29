import 'package:flutter/material.dart';

/// ForgeApp design system color tokens (dark-only palette).
class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF131315); // page / screen background
  static const Color card = Color(0xFF201F22); // cards, rows, panels, modals
  static const Color cardAlt = Color(
    0xFF2A2A2C,
  ); // inputs, secondary buttons, nested surfaces
  static const Color border = Color(
    0xFF444933,
  ); // all card / field borders (1 dp)

  // Brand
  static const Color lime = Color(
    0xFFC3F400,
  ); // primary actions, active states, progress fills

  // Text
  static const Color white = Color(0xFFF5F6F1); // primary text, icons on dark
  static const Color textMuted = Color(
    0xFFC4C9AC,
  ); // secondary / supporting text
  static const Color textDim = Color(
    0xFF8A8F7A,
  ); // labels, timestamps, disabled state

  // Danger (errors / destructive)
  static const Color danger = Color(
    0xFFFF6B6B,
  ); // error text / icons, destructive actions
  static const Color dangerBg = Color(0xFF2A1F1F); // error card fill
  static const Color dangerBorder = Color(0xFF5C3A3A); // error card border
  static const Color onDanger = Color(
    0xFF2A1414,
  ); // text on danger-red fill (≈4.6:1 contrast on danger)
  static const Color scrimBarrier = Color(0xA00A0A0A); // dialog scrim overlay
  static const Color scrimRest = Color(0xB80A0A0A); // rest timer scrim (72%)
  static const Color onLime = Color(0xFF131315); // text on lime fill

  // Shimmer animation
  static const Color shimmerDark = Color(
    0xFF35342F,
  ); // shimmer animation dark stop (lerps with cardAlt)

  // Success (profile save toast)
  static const Color successFill = Color(0xFF1E2A12); // success toast fill
  static const Color successBorder = Color(0xFF4A5C22); // success toast border

  // Reserved — do NOT use outside their designated component
  static const Color cyan = Color(
    0xFF7DF4FF,
  ); // weighted exercise type badge ONLY
  static const Color amber = Color(0xFFD9C94A); // open-decision banners ONLY
  static const Color amberBg = Color(0xFF2A2610); // design-note banner fill
  static const Color amberBorder = Color(
    0xFF6B5F22,
  ); // design-note banner border
}
