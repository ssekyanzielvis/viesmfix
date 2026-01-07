import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_entity.dart';

/// Auth guard that redirects to login if user is not authenticated
class AuthGuard {
  final UserEntity? user;

  const AuthGuard(this.user);

  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final isPublicRoute =
        state.matchedLocation == '/' ||
        state.matchedLocation.startsWith('/movie/');

    // If not logged in and trying to access protected route
    if (user == null && !isAuthRoute && !isPublicRoute) {
      return '/auth/login';
    }

    // If logged in and trying to access auth route
    if (user != null && isAuthRoute) {
      return '/';
    }

    return null;
  }
}

/// Admin guard for future admin features
class AdminGuard {
  final UserEntity? user;

  const AdminGuard(this.user);

  String? redirect(BuildContext context, GoRouterState state) {
    // TODO: Implement admin check when user roles are added
    // For now, allow all authenticated users
    if (user == null) {
      return '/auth/login';
    }

    return null;
  }
}

/// Onboarding guard to check if user completed onboarding
class OnboardingGuard {
  final bool hasCompletedOnboarding;

  const OnboardingGuard(this.hasCompletedOnboarding);

  String? redirect(BuildContext context, GoRouterState state) {
    final isOnboardingRoute = state.matchedLocation == '/onboarding';

    if (!hasCompletedOnboarding && !isOnboardingRoute) {
      return '/onboarding';
    }

    if (hasCompletedOnboarding && isOnboardingRoute) {
      return '/';
    }

    return null;
  }
}
