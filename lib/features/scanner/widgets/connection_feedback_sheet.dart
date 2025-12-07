import 'package:bluetooth_app/features/bluetooth_screen/bluetooth.dart';
import 'package:sizer/sizer.dart';

enum ConnectionStatus { connecting, success, error }

class ConnectionFeedbackSheet extends StatelessWidget {
  final ConnectionStatus status;
  final String deviceName;
  final String? errorMessage;
  final VoidCallback onAction;

  const ConnectionFeedbackSheet({
    super.key,
    required this.status,
    required this.deviceName,
    this.errorMessage,
    required this.onAction,
  });

  // Helper method to show the sheet
  static void show(
    BuildContext context, {
    required ConnectionStatus status,
    required String deviceName,
    String? errorMessage,
    required VoidCallback onAction,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectionFeedbackSheet(
        status: status,
        deviceName: deviceName,
        errorMessage: errorMessage,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    IconData statusIcon;
    String title;
    String description;
    String buttonText;

    switch (status) {
      case ConnectionStatus.connecting:
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.bluetooth_searching;
        title = 'Connecting...';
        description = 'Establishing secure connection with $deviceName';
        buttonText = 'Cancel';
        break;
      case ConnectionStatus.success:
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle_outline;
        title = 'Connected Successfully';
        description = '$deviceName is now ready to use.';
        buttonText = 'Go to Control Panel';
        break;
      case ConnectionStatus.error:
        statusColor = const Color(0xFFF44336);
        statusIcon = Icons.error_outline;
        title = 'Connection Failed';
        description =
            errorMessage ??
            'Unable to connect to $deviceName. Please check if the device is in range.';
        buttonText = 'Try Again';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 5.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 4.h),

          // Animated Icon Ring
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: status == ConnectionStatus.connecting
                ? Center(
                    child: SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: statusColor,
                      ),
                    ),
                  )
                : Icon(statusIcon, color: statusColor, size: 8.w),
          ),
          SizedBox(height: 3.h),

          // Text Content
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close sheet
                onAction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == ConnectionStatus.error
                    ? colorScheme.surface
                    : statusColor,
                foregroundColor: status == ConnectionStatus.error
                    ? statusColor
                    : Colors.white,
                side: status == ConnectionStatus.error
                    ? BorderSide(color: statusColor)
                    : null,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                elevation: status == ConnectionStatus.error ? 0 : 2,
              ),
              child: Text(buttonText),
            ),
          ),

          // Secondary Action for Error (Cancel)
          if (status == ConnectionStatus.error) ...[
            SizedBox(height: 1.5.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
