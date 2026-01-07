import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../providers/auth_state_provider.dart';
import '../../../app_providers.dart';

/// User profile provider
final userProfileProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.userProfile;
});

/// User stats provider
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final user = ref.watch(userProfileProvider);
  if (user == null) {
    return UserStats(watchlistCount: 0, reviewsCount: 0, followingCount: 0);
  }

  final watchlistCount = ref.watch(watchlistCountProvider);

  return UserStats(
    watchlistCount: watchlistCount,
    reviewsCount: 0, // TODO: Implement reviews
    followingCount: 0, // TODO: Implement social features
  );
});

/// User stats model
class UserStats {
  final int watchlistCount;
  final int reviewsCount;
  final int followingCount;

  const UserStats({
    required this.watchlistCount,
    required this.reviewsCount,
    required this.followingCount,
  });
}

/// Profile edit mode provider
final profileEditModeProvider = StateProvider<bool>((ref) => false);

/// Profile update loading state
final profileUpdateLoadingProvider = StateProvider<bool>((ref) => false);

/// Watchlist count provider (re-export for convenience)
final watchlistCountProvider = Provider<int>((ref) {
  final watchlistState = ref.watch(watchlistStreamProvider);
  return watchlistState.when(
    data: (items) => items.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
