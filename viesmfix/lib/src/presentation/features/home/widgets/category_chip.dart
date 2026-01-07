import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      backgroundColor: context.colorScheme.surfaceContainerHighest,
      selectedColor: context.colorScheme.primaryContainer,
      checkmarkColor: context.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? context.colorScheme.onPrimaryContainer
            : context.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? context.colorScheme.primary : Colors.transparent,
          width: isSelected ? 1.5 : 0,
        ),
      ),
    );
  }
}
