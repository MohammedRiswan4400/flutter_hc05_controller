import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom bottom navigation bar for Bluetooth device management
/// Implements Bottom Tab Bar with Modal Overlays pattern for optimal one-handed operation
/// Provides persistent access to Scanner and Connected Devices tabs
enum CustomBottomBarItem { scanner, connectedDevices }

class CustomBottomBar extends StatefulWidget {
  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is selected
  final ValueChanged<int> onTap;

  /// Whether to show badge on connected devices tab (indicates active connections)
  final bool showConnectionBadge;

  /// Number of active connections to display in badge
  final int connectionCount;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showConnectionBadge = false,
    this.connectionCount = 0,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    // Haptic feedback for tab selection
    HapticFeedback.selectionClick();

    // Scale animation for visual feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80, // Optimized for thumb reach
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // _buildNavItem(
              //   context: context,
              //   index: 0,
              //   item: CustomBottomBarItem.scanner,
              //   icon: Icons.bluetooth_searching_rounded,
              //   label: 'Scanner',
              //   route: '/bluetooth-permission-request',
              // ),
              _buildNavItem(
                context: context,
                index: 1,
                item: CustomBottomBarItem.connectedDevices,
                icon: Icons.devices_rounded,
                label: 'Connected',
                route: '/connected-devices',
                showBadge: widget.showConnectionBadge,
                badgeCount: widget.connectionCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required CustomBottomBarItem item,
    required IconData icon,
    required String label,
    required String route,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.currentIndex == index;

    final itemColor = isSelected
        ? colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: ScaleTransition(
        scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _handleTap(index);
              // Navigate to the corresponding route
              if (!isSelected) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 24, color: itemColor),
                      ),
                      if (showBadge && badgeCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                badgeCount > 9 ? '9+' : badgeCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style:
                        (isSelected
                            ? theme.bottomNavigationBarTheme.selectedLabelStyle
                            : theme
                                  .bottomNavigationBarTheme
                                  .unselectedLabelStyle) ??
                        theme.textTheme.labelSmall!.copyWith(
                          color: itemColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily add CustomBottomBar to Scaffold
extension CustomBottomBarExtension on Widget {
  Widget withCustomBottomBar({
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showConnectionBadge = false,
    int connectionCount = 0,
  }) {
    return Column(
      children: [
        Expanded(child: this),
        CustomBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          showConnectionBadge: showConnectionBadge,
          connectionCount: connectionCount,
        ),
      ],
    );
  }
}
