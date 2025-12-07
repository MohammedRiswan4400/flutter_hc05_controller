import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart'; // Ensure sizer is imported

class DiscoveredDeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onConnect;

  const DiscoveredDeviceCard({
    super.key,
    required this.device,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Normalize RSSI (-100 to -50) to percentage (0 to 100)
    final int rssi = device['rssi'] ?? -90;
    final int signalPercent = ((rssi + 100) * 2).clamp(0, 100);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                // 1. Icon Container
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons
                          .bluetooth, // Replace with CustomIconWidget if needed
                      color: colorScheme.secondary,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 2. Name and Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device['name'] ?? 'Unknown Device',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        device['address'] ?? '00:00:00:00:00:00',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Signal Icon
                Column(
                  children: [
                    Icon(
                      _getSignalIcon(signalPercent),
                      color: _getSignalColor(signalPercent),
                      size: 5.w,
                    ),
                    Text(
                      '${rssi}dBm',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getSignalColor(signalPercent),
                        fontSize: 8.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // 4. Tech Specs Row (Type & Signal Bar)
            Row(
              children: [
                // Type Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.widgets_outlined,
                        size: 3.5.w,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        device['type'] ?? 'BLE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),

                // Signal Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Signal Quality',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 8.sp,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            '$signalPercent%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 8.sp,
                              color: _getSignalColor(signalPercent),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: signalPercent / 100,
                          backgroundColor: colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            _getSignalColor(signalPercent),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // 5. Connect Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onConnect();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.link, size: 5.w),
                label: Text('Connect Device'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSignalColor(int strength) {
    if (strength >= 75) return const Color(0xFF4CAF50); // Green
    if (strength >= 50) return const Color(0xFF03DAC6); // Teal
    if (strength >= 25) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  IconData _getSignalIcon(int strength) {
    if (strength >= 75) return Icons.signal_cellular_alt;
    if (strength >= 50) return Icons.signal_cellular_alt_2_bar;
    if (strength >= 25) return Icons.signal_cellular_alt_1_bar;
    return Icons.signal_cellular_connected_no_internet_0_bar;
  }
}
