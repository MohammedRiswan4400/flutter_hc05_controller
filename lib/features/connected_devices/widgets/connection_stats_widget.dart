import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying connection statistics
class ConnectionStatsWidget extends StatelessWidget {
  final Map<String, dynamic> device;

  const ConnectionStatsWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Statistics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildStatCard(
            theme,
            colorScheme,
            'Total Data Transferred',
            _formatBytes(
              (device['txBytes'] as int) + (device['rxBytes'] as int),
            ),
            Icons.swap_vert_rounded,
            colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildStatCard(
            theme,
            colorScheme,
            'Connection Duration',
            device['duration'] as String,
            Icons.access_time_rounded,
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 2.h),
          _buildStatCard(
            theme,
            colorScheme,
            'Average Signal Strength',
            '${device['signalStrength']}%',
            Icons.signal_cellular_alt_rounded,
            const Color(0xFF03DAC6),
          ),
          SizedBox(height: 3.h),
          Text(
            'Data Transfer Chart',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDataChart(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: icon
                  .toString()
                  .split('.')
                  .last
                  .replaceAll('IconData(U+', '')
                  .replaceAll(')', ''),
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataChart(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Semantics(
        label: 'Data Transfer Bar Chart showing TX and RX data',
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY:
                ((device['txBytes'] as int) > (device['rxBytes'] as int)
                        ? (device['txBytes'] as int)
                        : (device['rxBytes'] as int))
                    .toDouble() *
                1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    _formatBytes(rod.toY.toInt()),
                    theme.textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final labels = ['TX', 'RX'];
                    return Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Text(
                        labels[value.toInt()],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 12.w,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatBytes(value.toInt()),
                      style: theme.textTheme.labelSmall,
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval:
                  ((device['txBytes'] as int) > (device['rxBytes'] as int)
                          ? (device['txBytes'] as int)
                          : (device['rxBytes'] as int))
                      .toDouble() /
                  5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: (device['txBytes'] as int).toDouble(),
                    color: const Color(0xFF2196F3),
                    width: 20.w,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: (device['rxBytes'] as int).toDouble(),
                    color: const Color(0xFF4CAF50),
                    width: 20.w,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
