import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';

enum SocialProvider { google, apple, facebook }

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getColor(context)),
              ),
            )
          : Icon(_getIcon(), color: _getColor(context)),
      label: Text(_getLabel(), style: TextStyle(color: _getColor(context))),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        side: BorderSide(color: _getColor(context).withOpacity(0.3)),
      ),
    );
  }

  IconData _getIcon() {
    switch (provider) {
      case SocialProvider.google:
        return Icons.g_mobiledata;
      case SocialProvider.apple:
        return Icons.apple;
      case SocialProvider.facebook:
        return Icons.facebook;
    }
  }

  String _getLabel() {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
      case SocialProvider.facebook:
        return 'Continue with Facebook';
    }
  }

  Color _getColor(BuildContext context) {
    switch (provider) {
      case SocialProvider.google:
        return const Color(0xFF4285F4);
      case SocialProvider.apple:
        return context.colorScheme.onSurface;
      case SocialProvider.facebook:
        return const Color(0xFF1877F2);
    }
  }
}
