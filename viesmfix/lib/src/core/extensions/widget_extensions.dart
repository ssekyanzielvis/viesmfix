import 'package:flutter/material.dart';

/// Extensions for Widget class
extension WidgetExtensions on Widget {
  /// Adds padding to the widget
  Widget paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  /// Adds symmetric padding to the widget
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Adds only padding to the widget
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Wraps widget in a Center widget
  Widget centered() {
    return Center(child: this);
  }

  /// Wraps widget in an Expanded widget
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Wraps widget in a Flexible widget
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Adds a tap gesture to the widget
  Widget onTap(VoidCallback onTap, {bool excludeFromSemantics = false}) {
    return GestureDetector(
      onTap: onTap,
      excludeFromSemantics: excludeFromSemantics,
      child: this,
    );
  }

  /// Adds an InkWell effect to the widget
  Widget inkWell({
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      child: this,
    );
  }

  /// Wraps widget in a SizedBox with specified dimensions
  Widget sized({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  /// Wraps widget in a Container with decoration
  Widget decorated({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        gradient: gradient,
      ),
      child: this,
    );
  }

  /// Wraps widget in a Card
  Widget card({
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
  }) {
    return Card(
      color: color,
      elevation: elevation,
      shape: shape,
      margin: margin,
      child: this,
    );
  }

  /// Wraps widget in a Hero animation
  Widget hero(String tag) {
    return Hero(tag: tag, child: this);
  }

  /// Adds opacity to the widget
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Wraps widget in a ClipRRect with border radius
  Widget clipRRect({double radius = 8.0, BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      child: this,
    );
  }

  /// Wraps widget in an Align widget
  Widget align(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }

  /// Wraps widget in a FittedBox
  Widget fitted({BoxFit fit = BoxFit.contain}) {
    return FittedBox(fit: fit, child: this);
  }

  /// Adds a tooltip to the widget
  Widget tooltip(String message) {
    return Tooltip(message: message, child: this);
  }

  /// Wraps widget in a SafeArea
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }

  /// Wraps widget in a RepaintBoundary for performance optimization
  Widget repaintBoundary() {
    return RepaintBoundary(child: this);
  }

  /// Wraps widget in a ConstrainedBox
  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  /// Wraps widget in a Transform.scale
  Widget scale(double scale) {
    return Transform.scale(scale: scale, child: this);
  }

  /// Wraps widget in a Transform.rotate
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }

  /// Makes widget scrollable
  Widget scrollable({ScrollPhysics? physics, bool reverse = false}) {
    return SingleChildScrollView(
      physics: physics,
      reverse: reverse,
      child: this,
    );
  }

  /// Wraps widget in an AnimatedOpacity
  Widget animatedOpacity({
    required double opacity,
    required Duration duration,
    Curve curve = Curves.linear,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  /// Wraps widget in Visibility
  Widget visibility({
    required bool visible,
    bool maintainSize = false,
    bool maintainAnimation = false,
    bool maintainState = false,
  }) {
    return Visibility(
      visible: visible,
      maintainSize: maintainSize,
      maintainAnimation: maintainAnimation,
      maintainState: maintainState,
      child: this,
    );
  }

  /// Adds shimmer effect for loading states
  Widget shimmer({Color? baseColor, Color? highlightColor}) {
    return this; // Placeholder - would need shimmer package for full implementation
  }
}

/// Extensions for List<Widget>
extension WidgetListExtensions on List<Widget> {
  /// Wraps list in a Column
  Widget column({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Wraps list in a Row
  Widget row({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Wraps list in a Wrap
  Widget wrap({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: this,
    );
  }

  /// Wraps list in a Stack
  Widget stack({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
  }) {
    return Stack(alignment: alignment, fit: fit, children: this);
  }

  /// Wraps list in a ListView
  Widget listView({
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      children: this,
    );
  }
}
