import 'package:flutter/material.dart';

/// Dark theme color scheme for the app
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // Primary colors
  primary: Color(0xFFE50914), // Netflix red
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFB20710),
  onPrimaryContainer: Color(0xFFFFDAD6),

  // Secondary colors
  secondary: Color(0xFF564E4A),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF3F3933),
  onSecondaryContainer: Color(0xFFE4DDD9),

  // Tertiary colors
  tertiary: Color(0xFF705C2E),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF594722),
  onTertiaryContainer: Color(0xFFFDDFA6),

  // Error colors
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  // Background colors
  surface: Color(0xFF141414), // Netflix dark background
  onSurface: Color(0xFFE6E1E5),

  // Surface variants
  surfaceContainerHighest: Color(0xFF36302F),
  surfaceContainerHigh: Color(0xFF2B2524),
  surfaceContainer: Color(0xFF211B1A),
  surfaceContainerLow: Color(0xFF1A1C1C),
  surfaceContainerLowest: Color(0xFF0F0D0E),

  surfaceVariant: Color(0xFF52443F),
  onSurfaceVariant: Color(0xFFD8C2BC),

  // Outline colors
  outline: Color(0xFFA08C87),
  outlineVariant: Color(0xFF52443F),

  // Inverse colors
  inverseSurface: Color(0xFFEBE0DD),
  onInverseSurface: Color(0xFF362F2E),
  inversePrimary: Color(0xFFE50914),

  // Shadow and scrim
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);
