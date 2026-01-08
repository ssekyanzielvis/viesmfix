import 'package:flutter/material.dart';
import '../../core/constants/environment.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w < Environment.tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= Environment.tabletBreakpoint &&
        w < Environment.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= Environment.desktopBreakpoint;
  }

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static double buttonHeight(BuildContext context) =>
      value(context: context, mobile: 40, tablet: 44, desktop: 48);

  static double buttonMinWidth(BuildContext context) =>
      value(context: context, mobile: 120, tablet: 140, desktop: 160);

  static double posterWidth(BuildContext context) =>
      value(context: context, mobile: 100, tablet: 120, desktop: 140);

  static double posterHeight(BuildContext context) =>
      value(context: context, mobile: 150, tablet: 170, desktop: 200);

  static double appBarExpandedHeight(BuildContext context) =>
      value(context: context, mobile: 220, tablet: 260, desktop: 300);

  static double castListHeight(BuildContext context) =>
      value(context: context, mobile: 110, tablet: 140, desktop: 160);

  static double similarListHeight(BuildContext context) =>
      value(context: context, mobile: 180, tablet: 200, desktop: 220);
}
