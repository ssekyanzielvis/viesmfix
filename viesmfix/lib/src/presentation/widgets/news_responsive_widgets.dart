import 'package:flutter/material.dart';

/// Responsive layout helper for news screens
class NewsResponsiveLayout {
  /// Get grid column count based on screen width
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Desktop
    if (width >= 900) return 3; // Tablet landscape
    if (width >= 600) return 2; // Tablet portrait
    return 1; // Mobile
  }

  /// Get card style based on screen width
  static NewsCardStyle getCardStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return NewsCardStyle.detailed;
    if (width >= 600) return NewsCardStyle.standard;
    return NewsCardStyle.compact;
  }

  /// Get spacing based on screen width
  static double getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 24.0;
    if (width >= 600) return 16.0;
    return 12.0;
  }

  /// Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  /// Get optimal image height for article cards
  static double getImageHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 250.0;
    if (width >= 600) return 220.0;
    return 200.0;
  }

  /// Get text scale factor with accessibility consideration
  static double getTextScale(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaleFactor;
    // Clamp between 0.8 and 1.5 for better layout control
    return textScale.clamp(0.8, 1.5);
  }
}

enum NewsCardStyle { compact, standard, detailed }

/// Shimmer loading widget for news cards
class NewsCardShimmer extends StatelessWidget {
  final NewsCardStyle style;

  const NewsCardShimmer({super.key, this.style = NewsCardStyle.standard});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          Container(
            height: NewsResponsiveLayout.getImageHeight(context),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source shimmer
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Title shimmer
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (style == NewsCardStyle.detailed) ...[
                  const SizedBox(height: 12),
                  // Description shimmer
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid shimmer loading for desktop/tablet
class NewsGridShimmer extends StatelessWidget {
  const NewsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final columnCount = NewsResponsiveLayout.getGridColumnCount(context);
    final spacing = NewsResponsiveLayout.getSpacing(context);

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const NewsCardShimmer(),
    );
  }
}

/// Empty state widget with icon and message
class NewsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const NewsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isTablet ? 120 : 80, color: Colors.grey.shade400),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: isTablet ? 16 : 12,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget with detailed error information
class NewsErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool showDetails;

  const NewsErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);

    String title = 'Failed to load news';
    String message = 'Please try again later';
    IconData icon = Icons.error_outline;

    // Parse error message for better UX
    if (error.contains('rate limit') || error.contains('429')) {
      title = 'Rate Limit Exceeded';
      message = 'Too many requests. Please wait a moment and try again.';
      icon = Icons.timer_off;
    } else if (error.contains('network') || error.contains('timeout')) {
      title = 'Connection Error';
      message = 'Please check your internet connection and try again.';
      icon = Icons.wifi_off;
    } else if (error.contains('unauthorized') || error.contains('401')) {
      title = 'Authentication Error';
      message = 'There was a problem with your credentials.';
      icon = Icons.lock_outline;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isTablet ? 100 : 80, color: Colors.red.shade300),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade700,
              ),
            ),
            if (showDetails) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade900,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            SizedBox(height: isTablet ? 32 : 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
            if (!showDetails) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Show error details
                },
                child: const Text('Show details'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator for pagination
class NewsPaginationLoader extends StatelessWidget {
  const NewsPaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 12),
            Text(
              'Loading more articles...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive grid/list builder
class ResponsiveNewsBuilder extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;

  const ResponsiveNewsBuilder({
    super.key,
    required this.children,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = NewsResponsiveLayout.isTabletOrLarger(context);
    final columnCount = NewsResponsiveLayout.getGridColumnCount(context);
    final spacing = NewsResponsiveLayout.getSpacing(context);

    if (isTablet && columnCount > 1) {
      // Grid layout for tablets and desktop
      return GridView.builder(
        controller: controller,
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.75,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    } else {
      // List layout for mobile
      return ListView.builder(
        controller: controller,
        padding: EdgeInsets.all(spacing),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    }
  }
}
