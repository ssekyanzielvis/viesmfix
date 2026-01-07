import 'package:flutter/material.dart';

// Netflix-inspired Dark Theme Colors
const Color primaryRed = Color(0xFFE50914);
const Color darkBackground = Color(0xFF0F0F0F);
const Color darkSurface = Color(0xFF1A1A1A);
const Color darkSurfaceVariant = Color(0xFF2A2A2A);

// Light Theme Colors
const Color lightBackground = Color(0xFFFAFAFA);
const Color lightSurface = Color(0xFFFFFFFF);
const Color lightSurfaceVariant = Color(0xFFF5F5F5);

// Common Colors
const Color accentGold = Color(0xFFFFD700);
const Color successGreen = Color(0xFF4CAF50);
const Color warningOrange = Color(0xFFFF9800);
const Color errorRed = Color(0xFFE53935);

// Text Colors - Dark Theme
const Color darkTextPrimary = Color(0xFFFFFFFF);
const Color darkTextSecondary = Color(0xFFB3B3B3);
const Color darkTextTertiary = Color(0xFF808080);

// Text Colors - Light Theme
const Color lightTextPrimary = Color(0xFF000000);
const Color lightTextSecondary = Color(0xFF666666);
const Color lightTextTertiary = Color(0xFF999999);

// Color Schemes
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primaryRed,
  onPrimary: Colors.white,
  secondary: accentGold,
  onSecondary: Colors.black,
  error: errorRed,
  onError: Colors.white,
  surface: darkSurface,
  onSurface: darkTextPrimary,
  surfaceContainerHighest: darkSurfaceVariant,
  onSurfaceVariant: darkTextSecondary,
  outline: Color(0xFF404040),
  inverseSurface: Colors.white,
  onInverseSurface: Colors.black,
);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryRed,
  onPrimary: Colors.white,
  secondary: accentGold,
  onSecondary: Colors.black,
  error: errorRed,
  onError: Colors.white,
  surface: lightSurface,
  onSurface: lightTextPrimary,
  surfaceContainerHighest: lightSurfaceVariant,
  onSurfaceVariant: lightTextSecondary,
  outline: Color(0xFFE0E0E0),
  inverseSurface: Colors.black,
  onInverseSurface: Colors.white,
);
