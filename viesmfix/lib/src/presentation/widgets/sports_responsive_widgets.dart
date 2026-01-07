import 'package:flutter/material.dart';

/// Breakpoint definitions for responsive design
class SportsBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  // Desktop is anything above tablet
}

/// Responsive helper to determine device type
enum DeviceType { mobile, tablet, desktop }

class SportsResponsive {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < SportsBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < SportsBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static int getGridCrossAxisCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }
}

/// Responsive Match Grid
class ResponsiveMatchGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveMatchGrid({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = SportsResponsive.getGridCrossAxisCount(context);

    if (crossAxisCount == 1) {
      // Mobile: Use ListView
      return ListView.separated(
        padding: EdgeInsets.all(spacing),
        itemCount: children.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, index) => children[index],
      );
    } else {
      // Tablet/Desktop: Use GridView
      return GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1.5,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    }
  }
}

/// Responsive Match List that adapts to screen size
class ResponsiveMatchList extends StatelessWidget {
  final List<Widget> matches;
  final ScrollController? scrollController;

  const ResponsiveMatchList({
    super.key,
    required this.matches,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = SportsResponsive.getDeviceType(context);
    final maxWidth = SportsResponsive.getMaxContentWidth(context);

    Widget content;

    if (deviceType == DeviceType.mobile) {
      // Mobile: Simple list
      content = ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) => matches[index],
      );
    } else {
      // Tablet/Desktop: Centered content with max width
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: matches.length,
            itemBuilder: (context, index) => matches[index],
          ),
        ),
      );
    }

    return content;
  }
}

/// Responsive Two-Column Layout
/// Shows sidebar on tablet/desktop, single column on mobile
class ResponsiveTwoColumn extends StatelessWidget {
  final Widget main;
  final Widget sidebar;
  final double sidebarWidth;

  const ResponsiveTwoColumn({
    super.key,
    required this.main,
    required this.sidebar,
    this.sidebarWidth = 300,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = SportsResponsive.isMobile(context);

    if (isMobile) {
      // Mobile: Show only main content, sidebar accessible via drawer
      return main;
    } else {
      // Tablet/Desktop: Show both main and sidebar
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: main),
          SizedBox(width: sidebarWidth, child: sidebar),
        ],
      );
    }
  }
}

/// Responsive Card Padding
class ResponsiveCardPadding extends StatelessWidget {
  final Widget child;

  const ResponsiveCardPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final deviceType = SportsResponsive.getDeviceType(context);

    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = 12;
        break;
      case DeviceType.tablet:
        padding = 16;
        break;
      case DeviceType.desktop:
        padding = 20;
        break;
    }

    return Padding(padding: EdgeInsets.all(padding), child: child);
  }
}

/// Responsive Font Sizes
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle Function(TextTheme) styleSelector;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.styleSelector,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = SportsResponsive.getDeviceType(context);
    final theme = Theme.of(context);
    var style = styleSelector(theme.textTheme);

    // Scale font size based on device type
    if (deviceType == DeviceType.tablet && style.fontSize != null) {
      style = style.copyWith(fontSize: style.fontSize! * 1.1);
    } else if (deviceType == DeviceType.desktop && style.fontSize != null) {
      style = style.copyWith(fontSize: style.fontSize! * 1.2);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive Navigation Bar
/// Shows BottomNavigationBar on mobile, NavigationRail on tablet/desktop
class ResponsiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final List<AppNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const ResponsiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = SportsResponsive.isMobile(context);

    if (isMobile) {
      // Mobile: Use BottomNavigationBar
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.map((dest) {
            return NavigationDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: dest.label,
            );
          }).toList(),
        ),
      );
    } else {
      // Tablet/Desktop: Use NavigationRail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations.map((dest) {
                return NavigationRailDestination(
                  icon: dest.icon,
                  selectedIcon: dest.selectedIcon ?? dest.icon,
                  label: Text(dest.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }
  }
}

/// Navigation Destination model
class AppNavDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  const AppNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Responsive Dialog
/// Shows as bottom sheet on mobile, dialog on tablet/desktop
class ResponsiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    final isMobile = SportsResponsive.isMobile(context);

    if (isMobile) {
      // Mobile: Show as bottom sheet
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              child,
            ],
          ),
        ),
      );
    } else {
      // Tablet/Desktop: Show as dialog
      return showDialog<T>(
        context: context,
        builder: (context) => AlertDialog(
          title: title != null ? Text(title) : null,
          content: child,
        ),
      );
    }
  }
}
