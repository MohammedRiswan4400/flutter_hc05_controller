import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ConnectedDeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onControlPanel;
  final VoidCallback onDisconnect;
  final VoidCallback onSettings;
  final VoidCallback onConnect;
  final VoidCallback onRename;
  final VoidCallback onAutoReconnect;
  final VoidCallback onViewStats;
  final VoidCallback onSetPriority;
  final VoidCallback onForget; // New Callback for unpairing
  final bool isSaved;

  const ConnectedDeviceCardWidget({
    super.key,
    required this.device,
    required this.onControlPanel,
    required this.onDisconnect,
    required this.onSettings,
    required this.onConnect,
    required this.onRename,
    required this.onAutoReconnect,
    required this.onViewStats,
    required this.onSetPriority,
    required this.onForget, // Required
    required this.isSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
      child: Slidable(
        key: ValueKey(device['id']),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            if (!isSaved)
              SlidableAction(
                onPressed: (_) {
                  HapticFeedback.mediumImpact();
                  onDisconnect();
                },
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                icon: Icons.bluetooth_disabled,
                label: 'Disconnect',
                borderRadius: BorderRadius.circular(12),
              ),
            if (isSaved)
              SlidableAction(
                onPressed: (_) {
                  HapticFeedback.mediumImpact();
                  onSetPriority();
                },
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                icon: Icons.star_rounded,
                label: 'Priority',
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            // If Device is Connected (Active) -> Show Disconnect

            // Always show Forget (Unpair) option
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onForget();
              },
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              icon: Icons.delete_forever,
              label: 'Forget',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onLongPress: () {
            HapticFeedback.heavyImpact();
            // _showAdvancedOptions(context);
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              side: isSaved == true
                  ? BorderSide.none
                  : BorderSide(width: 0.3, color: colorScheme.inversePrimary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceHeader(theme, colorScheme, isSaved: isSaved),

                  // Only show detailed stats if connected
                  if (!isSaved) ...[
                    SizedBox(height: 2.h),
                    _buildConnectionInfo(theme, colorScheme),
                    SizedBox(height: 2.h),
                    _buildDataTransferIndicators(theme, colorScheme),
                    SizedBox(height: 2.h),
                    _buildSignalStrength(theme, colorScheme),
                  ],

                  SizedBox(height: 2.h),
                  _buildActionButtons(theme, colorScheme, isSaved: isSaved),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(
    ThemeData theme,
    ColorScheme colorScheme, {
    bool? isSaved,
  }) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: isSaved ?? true ? 'bluetooth' : 'bluetooth_connected',
              color: isSaved ?? true
                  ? colorScheme.inversePrimary
                  : colorScheme.primary,
              size: 6.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device['name'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                device['address'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: isSaved ?? true
                ? const Color(0xFFFF5252).withValues(alpha: 0.1)
                : const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: isSaved ?? true
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                isSaved ?? true ? 'Disconnected' : 'Connected',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSaved ?? true
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    ColorScheme colorScheme, {
    bool? isSaved,
  }) {
    return Row(
      children: [
        if (!isSaved!) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onControlPanel();
              },
              icon: CustomIconWidget(
                iconName: 'settings_remote',
                color: colorScheme.primary,
                size: 4.w,
              ),
              label: Text('Control', style: theme.textTheme.labelMedium),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSettings();
              },
              icon: CustomIconWidget(
                iconName: 'settings',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 4.w,
              ),
              label: Text('Settings', style: theme.textTheme.labelMedium),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 2.w),
        ],

        // --- CONNECT / DISCONNECT BUTTON ---
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // FIX: Check state before deciding action
              if (isSaved == true) {
                onConnect();
              } else {
                onDisconnect();
              }
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              side: BorderSide(
                color: isSaved == true
                    ? const Color(0xFF2196F3) // Blue for Connect
                    : const Color(0xFFFF5252), // Red for Disconnect
              ),
            ),
            child: isSaved == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'bluetooth',
                        color: const Color(0xFF2196F3),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Connect',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  )
                : CustomIconWidget(
                    iconName: 'bluetooth_disabled',
                    color: const Color(0xFFFF5252),
                    size: 4.w,
                  ),
          ),
        ),
      ],
    );
  }

  // ... (Keep _buildConnectionInfo, _buildDataTransferIndicators, _buildSignalStrength same as before)
  Widget _buildConnectionInfo(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            theme,
            colorScheme,
            'Duration',
            device['duration'] ?? '--',
            Icons.access_time_rounded,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildInfoItem(
            theme,
            colorScheme,
            'Type',
            device['type'] ?? 'BLE',
            Icons.category_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon
                .toString()
                .split('.')
                .last
                .replaceAll('IconData(U+', '')
                .replaceAll(')', ''),
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTransferIndicators(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDataIndicator(
            theme,
            colorScheme,
            'TX',
            '0 B',
            const Color(0xFF2196F3),
            Icons.arrow_upward_rounded,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildDataIndicator(
            theme,
            colorScheme,
            'RX',
            '0 B',
            const Color(0xFF4CAF50),
            Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildDataIndicator(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: icon
                  .toString()
                  .split('.')
                  .last
                  .replaceAll('IconData(U+', '')
                  .replaceAll(')', ''),
              color: color,
              size: 4.w,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalStrength(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'signal_cellular_4_bar',
              color: const Color(0xFF4CAF50),
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Signal Strength',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            Text(
              '100%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 1.h,
          ),
        ),
      ],
    );
  }
}
