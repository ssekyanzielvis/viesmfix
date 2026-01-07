import 'package:flutter/material.dart';

/// Light theme color scheme for the app
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary colors
  primary: Color(0xFFE50914), // Netflix red
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDAD6),
  onPrimaryContainer: Color(0xFF410002),

  // Secondary colors
  secondary: Color(0xFF77574E),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDAD6),
  onSecondaryContainer: Color(0xFF2C160F),

  // Tertiary colors
  tertiary: Color(0xFF705C2E),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFDDFA6),
  onTertiaryContainer: Color(0xFF251A00),

  // Error colors
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // Background colors
  surface: Color(0xFFFFF8F7),
  onSurface: Color(0xFF211B1A),

  // Surface variants
  surfaceContainerHighest: Color(0xFFEBE0DD),
  surfaceContainerHigh: Color(0xFFF1E5E3),
  surfaceContainer: Color(0xFFF6EBE8),
  surfaceContainerLow: Color(0xFFFCF0EE),
  surfaceContainerLowest: Color(0xFFFFFFFF),

  surfaceVariant: Color(0xFFF5DDD7),
  onSurfaceVariant: Color(0xFF52443F),

  // Outline colors
  outline: Color(0xFF85736E),
  outlineVariant: Color(0xFFD8C2BC),

  // Inverse colors
  inverseSurface: Color(0xFF362F2E),
  onInverseSurface: Color(0xFFFEEEEB),
  inversePrimary: Color(0xFFFFB4AB),

  // Shadow and scrim
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);
