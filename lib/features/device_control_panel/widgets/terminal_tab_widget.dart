import 'package:bluetooth_app/widgets/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TerminalTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final Function(String) onSendMessage;

  const TerminalTabWidget({
    super.key,
    required this.messages,
    required this.onSendMessage,
  });

  @override
  State<TerminalTabWidget> createState() => _TerminalTabWidgetState();
}

class _TerminalTabWidgetState extends State<TerminalTabWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      // OLD: widget.onSendMessage(text);

      // NEW: Add "\n" to simulate pressing "Enter"
      widget.onSendMessage("$text\n");

      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent, // List is reversed
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // --- CHAT AREA ---
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true, // Newest messages at bottom
            padding: EdgeInsets.all(4.w),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final msg = widget.messages[index];
              final isCommand = msg['type'] == 'command'; // Sent by us

              return Align(
                alignment: isCommand
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCommand
                        ? colorScheme.primary.withAlpha(50)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomRight: isCommand ? Radius.zero : null,
                      bottomLeft: isCommand ? null : Radius.zero,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg['data'].toString().replaceFirst(
                          isCommand ? "TX: " : "RX: ",
                          "",
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      // Text(
                      //   _formatTimestamp(msg['timestamp'] as DateTime),
                      //   style: theme.textTheme.labelSmall?.copyWith(
                      //     color: colorScheme.onSurfaceVariant,
                      //     fontSize: 8.sp,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // --- INPUT AREA ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(1, 5),
                ),
              ],
            ),
            child:
                // Row(
                //   children: [
                // Expanded(
                //   child: TextField(
                //     controller: _textController,
                //     decoration: InputDecoration(
                //       hintText: "Type ASCII command...",
                //       filled: true,
                //       fillColor: colorScheme.surfaceContainerLow,
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(24),
                //         borderSide: BorderSide.none,
                //       ),
                //       contentPadding: EdgeInsets.symmetric(
                //         horizontal: 4.w,
                //         vertical: 1.5.h,
                //       ),
                //     ),
                //     onSubmitted: (_) => _handleSend(),
                //   ),
                // ),
                // SizedBox(width: 2.w),
                // IconButton.filled(
                //   onPressed: _handleSend,
                //   icon: const Icon(Icons.send_rounded),
                //   style: IconButton.styleFrom(
                //     backgroundColor: colorScheme.primary,
                //     foregroundColor: colorScheme.onPrimary,
                //   ),
                // ),
                //   ],
                // ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Enter command...',
                          prefixIcon: Icon(
                            Icons.terminal_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    SizedBox(
                      height: 6.h,
                      width: 6.h,
                      child: ElevatedButton(
                        onPressed: _handleSend,
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
          ),
        ),
      ],
    );
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Formats a DateTime object into a string in the format
  /// "HH:MM:SS", padding any single digit values with leading zeroes.
  /// Used for displaying timestamps in the Terminal tab.
  /*******  343d8aa3-4b97-45b0-87cb-77fa400790fe  *******/
  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
  }
}
