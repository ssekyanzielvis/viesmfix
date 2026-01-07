import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterPressed,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateHasText);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search,
            color: context.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search movies...',
                hintStyle: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: _clearSearch,
              tooltip: 'Clear',
            ),
          if (widget.onFilterPressed != null) ...[
            Container(
              width: 1,
              height: 24,
              color: context.colorScheme.outline.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            IconButton(
              icon: const Icon(Icons.tune, size: 20),
              onPressed: widget.onFilterPressed,
              tooltip: 'Filters',
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
