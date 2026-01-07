import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../providers/auth_state_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userProfile = authState.userProfile;
    final watchlistState = ref.watch(watchlistProvider);
    final watchlistCount = watchlistState.when(
      data: (items) => items.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to view your profile',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login
                  Navigator.pushNamed(context, '/auth/login');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: context.colorScheme.primary,
                  backgroundImage: userProfile?.avatarUrl != null
                      ? NetworkImage(userProfile!.avatarUrl!)
                      : null,
                  child: userProfile?.avatarUrl == null
                      ? Text(
                          (userProfile?.username?.isNotEmpty ?? false)
                              ? userProfile!.username![0].toUpperCase()
                              : 'U',
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: context.colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile?.username ?? 'User',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                title: 'Watchlist',
                value: watchlistCount.toString(),
                icon: Icons.bookmark,
              ),
              _StatCard(title: 'Reviews', value: '0', icon: Icons.rate_review),
              _StatCard(title: 'Following', value: '0', icon: Icons.people),
            ],
          ),
          const SizedBox(height: 32),

          // Menu Items
          _MenuItem(
            icon: Icons.bookmark_outline,
            title: 'My Watchlist',
            onTap: () {
              Navigator.pushNamed(context, '/watchlist');
            },
          ),
          _MenuItem(
            icon: Icons.rate_review_outlined,
            title: 'My Reviews',
            onTap: () {
              context.showSnackBar('Reviews feature coming soon');
            },
          ),
          _MenuItem(
            icon: Icons.people_outline,
            title: 'Friends',
            onTap: () {
              context.showSnackBar('Friends feature coming soon');
            },
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(height: 32),
          _MenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: Colors.red,
            onTap: () async {
              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldSignOut == true && context.mounted) {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  context.showSuccessSnackBar('Signed out successfully');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: iconColor != null ? TextStyle(color: iconColor) : null,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
