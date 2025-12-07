import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar for Bluetooth device management
/// Implements Technical Minimalism with connection status visibility
/// Provides consistent navigation and status indicators across screens
enum CustomAppBarVariant { standard, withConnectionStatus, withSearch, modal }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// App bar variant
  final CustomAppBarVariant variant;

  /// Whether to show back button
  final bool showBackButton;

  /// Custom leading widget (overrides back button)
  final Widget? leading;

  /// Actions to display on the right side
  final List<Widget>? actions;

  /// Connection status indicator
  final bool isConnected;

  /// Number of active connections
  final int connectionCount;

  /// Search callback for search variant
  final VoidCallback? onSearch;

  /// Background color override
  final Color? backgroundColor;

  /// Elevation override
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = CustomAppBarVariant.standard,
    this.showBackButton = false,
    this.leading,
    this.actions,
    this.isConnected = false,
    this.connectionCount = 0,
    this.onSearch,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    variant == CustomAppBarVariant.withConnectionStatus && subtitle != null
        ? 72.0
        : 56.0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      centerTitle: false,
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        tooltip: 'Back',
      );
    }

    if (variant == CustomAppBarVariant.modal) {
      return IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        tooltip: 'Close',
      );
    }

    return null;
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.withConnectionStatus:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.appBarTheme.titleTextStyle),
            if (subtitle != null || connectionCount > 0)
              const SizedBox(height: 2),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else if (connectionCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? const Color(0xFF4CAF50) // Success color
                          : const Color(0xFF9E9E9E), // Disabled color
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$connectionCount ${connectionCount == 1 ? 'device' : 'devices'} connected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
          ],
        );

      default:
        return Text(title, style: theme.appBarTheme.titleTextStyle);
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    // Add search action for search variant
    if (variant == CustomAppBarVariant.withSearch && onSearch != null) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            onSearch?.call();
          },
          tooltip: 'Search devices',
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isEmpty ? null : actionWidgets;
  }
}

/// Specialized app bar for device control panel (modal presentation)
class CustomControlPanelAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Device name
  final String deviceName;

  /// Connection status
  final bool isConnected;

  /// Signal strength (0-100)
  final int signalStrength;

  /// Actions to display
  final List<Widget>? actions;

  /// On close callback
  final VoidCallback? onClose;

  const CustomControlPanelAppBar({
    super.key,
    required this.deviceName,
    this.isConnected = true,
    this.signalStrength = 0,
    this.actions,
    this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onClose != null) {
            onClose!();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Close',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            deviceName,
            style: theme.appBarTheme.titleTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF4CAF50) // Success color
                      : const Color(0xFFF44336), // Error color
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (isConnected && signalStrength > 0) ...[
                const SizedBox(width: 8),
                Icon(
                  _getSignalIcon(signalStrength),
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '$signalStrength%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  IconData _getSignalIcon(int strength) {
    if (strength >= 75) return Icons.signal_cellular_4_bar_rounded;
    if (strength >= 50) return Icons.signal_cellular_alt_rounded;
    if (strength >= 25) return Icons.signal_cellular_alt_2_bar_rounded;
    return Icons.signal_cellular_alt_1_bar_rounded;
  }
}
