import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual permission item widget
/// Displays permission status with icon, title, description, and action button
class PermissionItemWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback? onRetry;

  const PermissionItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: icon,
              size: 24,
              color: isGranted
                  ? const Color(0xFF4CAF50)
                  : theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isGranted)
                      CustomIconWidget(
                        iconName: 'check_circle',
                        size: 20,
                        color: const Color(0xFF4CAF50),
                      )
                    else if (onRetry != null)
                      InkWell(
                        onTap: onRetry,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CustomIconWidget(
                            iconName: 'refresh',
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
