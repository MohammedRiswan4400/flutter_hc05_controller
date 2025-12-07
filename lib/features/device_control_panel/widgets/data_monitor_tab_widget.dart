import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Data Monitor Tab Widget
/// Shows real-time incoming data stream with timestamp formatting
/// and clear/export options
class DataMonitorTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> dataStream;
  final VoidCallback onClear;
  final VoidCallback onExport;

  const DataMonitorTabWidget({
    super.key,
    required this.dataStream,
    required this.onClear,
    required this.onExport,
  });

  @override
  State<DataMonitorTabWidget> createState() => _DataMonitorTabWidgetState();
}

class _DataMonitorTabWidgetState extends State<DataMonitorTabWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DataMonitorTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataStream.length > oldWidget.dataStream.length) {
      // Auto-scroll to latest entry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm:ss').format(timestamp);
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'sensor':
        return const Color(0xFF2196F3);
      case 'status':
        return const Color(0xFF4CAF50);
      case 'command':
        return const Color(0xFF9C27B0);
      case 'error':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'sensor':
        return Icons.sensors_rounded;
      case 'status':
        return Icons.check_circle_rounded;
      case 'command':
        return Icons.send_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Action Bar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${widget.dataStream.length} entries',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.dataStream.isEmpty ? null : widget.onExport,
                icon: CustomIconWidget(
                  iconName: 'download',
                  color: widget.dataStream.isEmpty
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Export'),
              ),
              SizedBox(width: 2.w),
              TextButton.icon(
                onPressed: widget.dataStream.isEmpty ? null : widget.onClear,
                icon: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: widget.dataStream.isEmpty
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.error,
                  size: 20,
                ),
                label: Text(
                  'Clear',
                  style: TextStyle(
                    color: widget.dataStream.isEmpty
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Data Stream
        Expanded(
          child: widget.dataStream.isEmpty
              ? _buildEmptyState(theme)
              : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  itemCount: widget.dataStream.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final entry = widget.dataStream[index];
                    return _buildDataEntry(context, entry: entry, index: index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'monitor_heart',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No data received yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Data from your device will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataEntry(
    BuildContext context, {
    required Map<String, dynamic> entry,
    required int index,
  }) {
    final theme = Theme.of(context);
    final timestamp = entry["timestamp"] as DateTime;
    final data = entry["data"] as String;
    final type = entry["type"] as String;
    final typeColor = _getTypeColor(type, theme);

    return Dismissible(
      key: Key('data_entry_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: theme.colorScheme.error,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        // Remove entry from list
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: _getTypeIcon(type).codePoint.toString(),
                color: typeColor,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _formatTimestamp(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
