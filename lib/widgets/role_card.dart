import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  const RoleCard({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alpha = 130;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withAlpha(alpha);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 36,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withAlpha(alpha),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
