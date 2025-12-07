import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Commands Tab Widget
/// Displays customizable control grid with touch-friendly buttons
/// for predefined actions and custom command input
class CommandsTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> commands;
  final Function(String) onCommandTap;
  final Function(int) onCommandLongPress;
  final Function(int) onCommandDelete;

  const CommandsTabWidget({
    super.key,
    required this.commands,
    required this.onCommandTap,
    required this.onCommandLongPress,
    required this.onCommandDelete,
  });

  @override
  State<CommandsTabWidget> createState() => _CommandsTabWidgetState();
}

class _CommandsTabWidgetState extends State<CommandsTabWidget> {
  final TextEditingController _customCommandController =
      TextEditingController();

  @override
  void dispose() {
    _customCommandController.dispose();
    super.dispose();
  }

  void _sendCustomCommand() {
    if (_customCommandController.text.trim().isNotEmpty) {
      widget.onCommandTap(_customCommandController.text.trim());
      _customCommandController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predefined Commands Grid
          Text(
            'Quick Commands',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.5,
            ),
            itemCount: widget.commands.length,
            itemBuilder: (context, index) {
              final command = widget.commands[index];
              return _buildCommandButton(
                context,
                command: command,
                index: index,
              );
            },
          ),

          SizedBox(height: 3.h),

          // Custom Command Input
          Text(
            'Custom Command',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customCommandController,
                  decoration: InputDecoration(
                    hintText: 'Enter command...',
                    prefixIcon: Icon(
                      Icons.terminal_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onSubmitted: (_) => _sendCustomCommand(),
                ),
              ),
              SizedBox(width: 2.w),
              SizedBox(
                height: 6.h,
                width: 6.h,
                child: ElevatedButton(
                  onPressed: _sendCustomCommand,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'send',
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandButton(
    BuildContext context, {
    required Map<String, dynamic> command,
    required int index,
  }) {
    final theme = Theme.of(context);
    final commandColor = command["color"] as Color;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showCommandOptions(context, index);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onCommandTap(command["command"] as String);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: commandColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: commandColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: commandColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: command["icon"] as String,
                    color: commandColor,
                    size: 28,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  command["name"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: commandColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommandOptions(BuildContext context, int index) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Edit Command'),
              onTap: () {
                Navigator.pop(context);
                widget.onCommandLongPress(index);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete Command',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onCommandDelete(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
