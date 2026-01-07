import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  // Platform checks
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  // Platform groups
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  // Get platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  // Feature support
  static bool get supportsHapticFeedback => isMobile;
  static bool get supportsShare => isMobile || isWeb;
  static bool get supportsFileSystem => !isWeb;
  static bool get supportsNotifications => !isWeb;

  // Get appropriate widget spacing based on platform
  static double get defaultPadding {
    if (isMobile) return 16.0;
    if (isDesktop) return 24.0;
    return 16.0;
  }

  // Get appropriate font size based on platform
  static double getFontSize(double baseFontSize) {
    if (isDesktop) return baseFontSize * 1.1;
    return baseFontSize;
  }
}
