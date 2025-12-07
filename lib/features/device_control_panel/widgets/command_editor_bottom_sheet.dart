import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Command Editor Bottom Sheet
/// Allows creating and editing custom control commands
/// with name, command string, and button color selection
class CommandEditorBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? command;
  final Function(Map<String, dynamic>) onSave;

  const CommandEditorBottomSheet({
    super.key,
    this.command,
    required this.onSave,
  });

  @override
  State<CommandEditorBottomSheet> createState() =>
      _CommandEditorBottomSheetState();
}

class _CommandEditorBottomSheetState extends State<CommandEditorBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _commandController;
  Color _selectedColor = const Color(0xFF2196F3);
  String _selectedIcon = 'touch_app';

  final List<Color> _availableColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFF44336), // Red
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
  ];

  final List<String> _availableIcons = [
    'touch_app',
    'lightbulb',
    'settings',
    'power_settings_new',
    'sensors',
    'speed',
    'thermostat',
    'wifi',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.command?["name"] as String?,
    );
    _commandController = TextEditingController(
      text: widget.command?["command"] as String?,
    );
    if (widget.command != null) {
      _selectedColor = widget.command!["color"] as Color;
      _selectedIcon = widget.command!["icon"] as String;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _saveCommand() {
    if (_nameController.text.trim().isEmpty ||
        _commandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final command = {
      "id": widget.command?["id"] ?? DateTime.now().millisecondsSinceEpoch,
      "name": _nameController.text.trim(),
      "command": _commandController.text.trim(),
      "color": _selectedColor,
      "icon": _selectedIcon,
    };

    widget.onSave(command);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.command == null ? 'Add Command' : 'Edit Command',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Command Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Command Name',
                    hintText: 'e.g., Turn On LED',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                SizedBox(height: 2.h),

                // Command String
                TextField(
                  controller: _commandController,
                  decoration: const InputDecoration(
                    labelText: 'Command String',
                    hintText: 'e.g., LED_ON',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),

                SizedBox(height: 3.h),

                // Icon Selection
                Text(
                  'Icon',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),

                SizedBox(
                  height: 8.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableIcons.length,
                    separatorBuilder: (context, index) => SizedBox(width: 2.w),
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = icon == _selectedIcon;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedIcon = icon);
                        },
                        child: Container(
                          width: 8.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withValues(alpha: 0.12)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
                                  : theme.colorScheme.outline.withValues(
                                      alpha: 0.2,
                                    ),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: icon,
                              color: isSelected
                                  ? _selectedColor
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 3.h),

                // Color Selection
                Text(
                  'Color',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),

                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: _availableColors.map((color) {
                    final isSelected = color == _selectedColor;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedColor = color);
                      },
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: CustomIconWidget(
                                  iconName: 'check',
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 4.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveCommand,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Text(
                        widget.command == null ? 'Add Command' : 'Save Changes',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
