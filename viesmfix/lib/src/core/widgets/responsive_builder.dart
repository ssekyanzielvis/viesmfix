import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 480,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop?.call(context, constraints) ??
              tablet?.call(context, constraints) ??
              mobile(context, constraints);
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet?.call(context, constraints) ??
              mobile(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1024 && desktop != null) {
      return desktop!;
    } else if (width >= 480 && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
