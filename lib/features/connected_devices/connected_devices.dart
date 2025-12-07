// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:sizer/sizer.dart';

// // // // // import '../../core/app_export.dart';
// // // // // import '../../widgets/custom_app_bar.dart';
// // // // // import '../../widgets/custom_bottom_bar.dart';
// // // // // import '../../widgets/custom_icon_widget.dart';
// // // // // import './widgets/connected_device_card_widget.dart';
// // // // // import './widgets/connection_stats_widget.dart';
// // // // // import './widgets/empty_state_widget.dart';

// // // // // /// Connected Devices Screen
// // // // // /// Manages all active Bluetooth connections with multi-device support
// // // // // class ConnectedDevices extends StatefulWidget {
// // // // //   const ConnectedDevices({super.key});

// // // // //   @override
// // // // //   State<ConnectedDevices> createState() => _ConnectedDevicesState();
// // // // // }

// // // // // class _ConnectedDevicesState extends State<ConnectedDevices>
// // // // //     with TickerProviderStateMixin {
// // // // //   late TabController _tabController;
// // // // //   bool _isRefreshing = false;

// // // // //   // Mock data for connected devices
// // // // //   final List<Map<String, dynamic>> _connectedDevices = [
// // // // //     {
// // // // //       "id": 1,
// // // // //       "name": "Arduino Uno BT",
// // // // //       "address": "00:1A:7D:DA:71:13",
// // // // //       "type": "Classic",
// // // // //       "duration": "2h 34m",
// // // // //       "txBytes": 1048576,
// // // // //       "rxBytes": 2097152,
// // // // //       "signalStrength": 85,
// // // // //       "isAutoReconnect": true,
// // // // //       "priority": 1,
// // // // //     },
// // // // //     {
// // // // //       "id": 2,
// // // // //       "name": "ESP32 DevKit",
// // // // //       "address": "24:6F:28:79:42:A8",
// // // // //       "type": "BLE",
// // // // //       "duration": "45m",
// // // // //       "txBytes": 524288,
// // // // //       "rxBytes": 786432,
// // // // //       "signalStrength": 72,
// // // // //       "isAutoReconnect": false,
// // // // //       "priority": 2,
// // // // //     },
// // // // //     {
// // // // //       "id": 3,
// // // // //       "name": "HC-05 Module",
// // // // //       "address": "98:D3:31:F5:8C:2E",
// // // // //       "type": "Classic",
// // // // //       "duration": "1h 15m",
// // // // //       "txBytes": 262144,
// // // // //       "rxBytes": 524288,
// // // // //       "signalStrength": 68,
// // // // //       "isAutoReconnect": true,
// // // // //       "priority": 3,
// // // // //     },
// // // // //   ];

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _tabController.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   Future<void> _handleRefresh() async {
// // // // //     setState(() => _isRefreshing = true);
// // // // //     HapticFeedback.mediumImpact();

// // // // //     // Simulate refresh delay
// // // // //     await Future.delayed(const Duration(seconds: 1));

// // // // //     setState(() => _isRefreshing = false);

// // // // //     if (mounted) {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         SnackBar(
// // // // //           content: const Text('Connection statuses updated'),
// // // // //           behavior: SnackBarBehavior.floating,
// // // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // //           duration: const Duration(seconds: 2),
// // // // //         ),
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   void _handleDisconnectAll() {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text('Disconnect All Devices'),
// // // // //         content: const Text(
// // // // //           'Are you sure you want to disconnect all connected devices?',
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(
// // // // //             onPressed: () => Navigator.pop(context),
// // // // //             child: const Text('Cancel'),
// // // // //           ),
// // // // //           ElevatedButton(
// // // // //             onPressed: () {
// // // // //               Navigator.pop(context);
// // // // //               setState(() => _connectedDevices.clear());
// // // // //               ScaffoldMessenger.of(context).showSnackBar(
// // // // //                 SnackBar(
// // // // //                   content: const Text('All devices disconnected'),
// // // // //                   behavior: SnackBarBehavior.floating,
// // // // //                   shape: RoundedRectangleBorder(
// // // // //                     borderRadius: BorderRadius.circular(8),
// // // // //                   ),
// // // // //                 ),
// // // // //               );
// // // // //             },
// // // // //             style: ElevatedButton.styleFrom(
// // // // //               backgroundColor: const Color(0xFFF44336),
// // // // //             ),
// // // // //             child: const Text('Disconnect'),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleDisconnect(Map<String, dynamic> device) {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     setState(() => _connectedDevices.remove(device));
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Text('${device['name']} disconnected'),
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // //         action: SnackBarAction(
// // // // //           label: 'Undo',
// // // // //           onPressed: () {
// // // // //             setState(() => _connectedDevices.add(device));
// // // // //           },
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleControlPanel(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     Navigator.pushNamed(context, '/device-control-panel', arguments: device);
// // // // //   }

// // // // //   void _handleSettings(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Text('Opening settings for ${device['name']}'),
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleRename(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     final TextEditingController controller = TextEditingController(
// // // // //       text: device['name'] as String,
// // // // //     );

// // // // //     showDialog(
// // // // //       context: context,
// // // // //       builder: (context) => AlertDialog(
// // // // //         title: const Text('Rename Connection'),
// // // // //         content: TextField(
// // // // //           controller: controller,
// // // // //           decoration: const InputDecoration(
// // // // //             labelText: 'Device Name',
// // // // //             hintText: 'Enter new name',
// // // // //           ),
// // // // //           autofocus: true,
// // // // //         ),
// // // // //         actions: [
// // // // //           TextButton(
// // // // //             onPressed: () => Navigator.pop(context),
// // // // //             child: const Text('Cancel'),
// // // // //           ),
// // // // //           ElevatedButton(
// // // // //             onPressed: () {
// // // // //               if (controller.text.isNotEmpty) {
// // // // //                 setState(() {
// // // // //                   device['name'] = controller.text;
// // // // //                 });
// // // // //                 Navigator.pop(context);
// // // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // // //                   SnackBar(
// // // // //                     content: const Text('Device renamed successfully'),
// // // // //                     behavior: SnackBarBehavior.floating,
// // // // //                     shape: RoundedRectangleBorder(
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                   ),
// // // // //                 );
// // // // //               }
// // // // //             },
// // // // //             child: const Text('Rename'),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleAutoReconnect(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     setState(() {
// // // // //       device['isAutoReconnect'] = !(device['isAutoReconnect'] as bool);
// // // // //     });
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Text(
// // // // //           'Auto-reconnect ${(device['isAutoReconnect'] as bool) ? 'enabled' : 'disabled'} for ${device['name']}',
// // // // //         ),
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleViewStats(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     showModalBottomSheet(
// // // // //       context: context,
// // // // //       isScrollControlled: true,
// // // // //       shape: const RoundedRectangleBorder(
// // // // //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
// // // // //       ),
// // // // //       builder: (context) => DraggableScrollableSheet(
// // // // //         initialChildSize: 0.9,
// // // // //         minChildSize: 0.5,
// // // // //         maxChildSize: 0.95,
// // // // //         expand: false,
// // // // //         builder: (context, scrollController) => SingleChildScrollView(
// // // // //           controller: scrollController,
// // // // //           child: ConnectionStatsWidget(device: device),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleSetPriority(Map<String, dynamic> device) {
// // // // //     HapticFeedback.lightImpact();
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(
// // // // //         content: Text('${device['name']} set as priority device'),
// // // // //         behavior: SnackBarBehavior.floating,
// // // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   void _handleStartScanning() {
// // // // //     HapticFeedback.mediumImpact();
// // // // //     Navigator.pushReplacementNamed(context, '/bluetooth-permission-request');
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final theme = Theme.of(context);
// // // // //     final colorScheme = theme.colorScheme;

// // // // //     return DefaultTabController(
// // // // //       length: 3,
// // // // //       child: Scaffold(
// // // // //         appBar: CustomAppBar(
// // // // //           title: 'Connected Devices',
// // // // //           variant: CustomAppBarVariant.withConnectionStatus,
// // // // //           connectionCount: _connectedDevices.length,
// // // // //           isConnected: _connectedDevices.isNotEmpty,
// // // // //           actions: [
// // // // //             if (_connectedDevices.isNotEmpty)
// // // // //               TextButton(
// // // // //                 onPressed: _handleDisconnectAll,
// // // // //                 child: Text(
// // // // //                   'Disconnect All',
// // // // //                   style: theme.textTheme.labelMedium?.copyWith(
// // // // //                     color: const Color(0xFFF44336),
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //           ],
// // // // //         ),
// // // // //         body: Column(
// // // // //           children: [
// // // // //             Container(
// // // // //               color: colorScheme.surface,
// // // // //               child: TabBar(
// // // // //                 controller: _tabController,
// // // // //                 onTap: (index) {
// // // // //                   HapticFeedback.selectionClick();
// // // // //                   // if (index == 0) {
// // // // //                   //   // Navigator.pushReplacementNamed(
// // // // //                   //   //   context,
// // // // //                   //   //   '/bluetooth-permission-request',
// // // // //                   //   // );
// // // // //                   // }
// // // // //                   // else
// // // // //                   if (index == 2) {
// // // // //                     ScaffoldMessenger.of(context).showSnackBar(
// // // // //                       SnackBar(
// // // // //                         content: const Text('History feature coming soon'),
// // // // //                         behavior: SnackBarBehavior.floating,
// // // // //                         shape: RoundedRectangleBorder(
// // // // //                           borderRadius: BorderRadius.circular(8),
// // // // //                         ),
// // // // //                       ),
// // // // //                     );
// // // // //                   }
// // // // //                 },
// // // // //                 tabs: [
// // // // //                   Tab(
// // // // //                     icon: CustomIconWidget(
// // // // //                       iconName: 'bluetooth_searching',
// // // // //                       color: _tabController.index == 0
// // // // //                           ? colorScheme.primary
// // // // //                           : colorScheme.onSurface.withValues(alpha: 0.6),
// // // // //                       size: 5.w,
// // // // //                     ),
// // // // //                     text: 'Scanner',
// // // // //                   ),
// // // // //                   Tab(
// // // // //                     icon: CustomIconWidget(
// // // // //                       iconName: 'devices',
// // // // //                       color: _tabController.index == 1
// // // // //                           ? colorScheme.primary
// // // // //                           : colorScheme.onSurface.withValues(alpha: 0.6),
// // // // //                       size: 5.w,
// // // // //                     ),
// // // // //                     text: 'Connected',
// // // // //                   ),
// // // // //                   Tab(
// // // // //                     icon: CustomIconWidget(
// // // // //                       iconName: 'history',
// // // // //                       color: _tabController.index == 2
// // // // //                           ? colorScheme.primary
// // // // //                           : colorScheme.onSurface.withValues(alpha: 0.6),
// // // // //                       size: 5.w,
// // // // //                     ),
// // // // //                     text: 'History',
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //             Expanded(
// // // // //               child:
// // // // //                   //  _connectedDevices.isEmpty
// // // // //                   //     ? EmptyStateWidget(onStartScanning: _handleStartScanning)
// // // // //                   //     :
// // // // //                   RefreshIndicator(
// // // // //                     onRefresh: _handleRefresh,
// // // // //                     child: ListView.builder(
// // // // //                       padding: EdgeInsets.symmetric(vertical: 2),
// // // // //                       itemCount: _connectedDevices.length,
// // // // //                       itemBuilder: (context, index) {
// // // // //                         final device = _connectedDevices[index];
// // // // //                         return ConnectedDeviceCardWidget(
// // // // //                           device: device,
// // // // //                           onControlPanel: () => _handleControlPanel(device),
// // // // //                           onDisconnect: () => _handleDisconnect(device),
// // // // //                           onSettings: () => _handleSettings(device),
// // // // //                           onRename: () => _handleRename(device),
// // // // //                           onAutoReconnect: () => _handleAutoReconnect(device),
// // // // //                           onViewStats: () => _handleViewStats(device),
// // // // //                           onSetPriority: () => _handleSetPriority(device),
// // // // //                         );
// // // // //                       },
// // // // //                     ),
// // // // //                   ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         // bottomNavigationBar: CustomBottomBar(
// // // // //         //   currentIndex: 1,
// // // // //         //   onTap: (index) {
// // // // //         //     HapticFeedback.selectionClick();
// // // // //         //     if (index == 0) {
// // // // //         //       Navigator.pushReplacementNamed(
// // // // //         //         context,
// // // // //         //         '/bluetooth-permission-request',
// // // // //         //       );
// // // // //         //     }
// // // // //         //   },
// // // // //         //   showConnectionBadge: _connectedDevices.isNotEmpty,
// // // // //         //   connectionCount: _connectedDevices.length,
// // // // //         // ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:bluetooth_app/features/scanner/bluetooth_scanner.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:sizer/sizer.dart';

// // // // import '../../widgets/custom_icon_widget.dart';
// // // // import './widgets/connected_device_card_widget.dart';
// // // // import './widgets/connection_stats_widget.dart';
// // // // import './widgets/empty_state_widget.dart';
// // // // // Ensure you import your ScannerScreen here
// // // // // import '../scan/presentation/scanner_screen.dart';

// // // // class ConnectedDevices extends StatefulWidget {
// // // //   const ConnectedDevices({super.key});

// // // //   @override
// // // //   State<ConnectedDevices> createState() => _ConnectedDevicesState();
// // // // }

// // // // class _ConnectedDevicesState extends State<ConnectedDevices> {
// // // //   // Note: No TabController or TickerProvider needed anymore

// // // //   // Mock data for connected devices
// // // //   final List<Map<String, dynamic>> _connectedDevices = [
// // // //     {
// // // //       "id": 1,
// // // //       "name": "Arduino Uno BT",
// // // //       "address": "00:1A:7D:DA:71:13",
// // // //       "type": "Classic",
// // // //       "duration": "2h 34m",
// // // //       "txBytes": 1048576,
// // // //       "rxBytes": 2097152,
// // // //       "signalStrength": 85,
// // // //       "isAutoReconnect": true,
// // // //       "priority": 1,
// // // //     },
// // // //     {
// // // //       "id": 2,
// // // //       "name": "ESP32 DevKit",
// // // //       "address": "24:6F:28:79:42:A8",
// // // //       "type": "BLE",
// // // //       "duration": "45m",
// // // //       "txBytes": 524288,
// // // //       "rxBytes": 786432,
// // // //       "signalStrength": 72,
// // // //       "isAutoReconnect": false,
// // // //       "priority": 2,
// // // //     },
// // // //   ];

// // // //   Future<void> _handleRefresh() async {
// // // //     HapticFeedback.mediumImpact();
// // // //     // Simulate refresh delay
// // // //     await Future.delayed(const Duration(seconds: 1));
// // // //     if (mounted) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(
// // // //           content: const Text('Connection statuses updated'),
// // // //           behavior: SnackBarBehavior.floating,
// // // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //           duration: const Duration(seconds: 1),
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   void _handleDisconnect(Map<String, dynamic> device) {
// // // //     HapticFeedback.mediumImpact();
// // // //     setState(() => _connectedDevices.remove(device));
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(
// // // //         content: Text('${device['name']} disconnected'),
// // // //         behavior: SnackBarBehavior.floating,
// // // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// // // //         action: SnackBarAction(
// // // //           label: 'Undo',
// // // //           onPressed: () {
// // // //             setState(() => _connectedDevices.add(device));
// // // //           },
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _handleControlPanel(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //     Navigator.pushNamed(context, '/device-control-panel', arguments: device);
// // // //   }

// // // //   void _handleSettings(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //   }

// // // //   void _handleRename(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //     // Rename logic...
// // // //   }

// // // //   void _handleAutoReconnect(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //     setState(() {
// // // //       device['isAutoReconnect'] = !(device['isAutoReconnect'] as bool);
// // // //     });
// // // //   }

// // // //   void _handleViewStats(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //     showModalBottomSheet(
// // // //       context: context,
// // // //       isScrollControlled: true,
// // // //       backgroundColor: Colors.transparent,
// // // //       builder: (context) => DraggableScrollableSheet(
// // // //         initialChildSize: 0.9,
// // // //         minChildSize: 0.5,
// // // //         maxChildSize: 0.95,
// // // //         builder: (context, scrollController) => Container(
// // // //           decoration: BoxDecoration(
// // // //             color: Theme.of(context).scaffoldBackgroundColor,
// // // //             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// // // //           ),
// // // //           child: SingleChildScrollView(
// // // //             controller: scrollController,
// // // //             child: ConnectionStatsWidget(device: device),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _handleSetPriority(Map<String, dynamic> device) {
// // // //     HapticFeedback.lightImpact();
// // // //   }

// // // //   void _handleStartScanning() {
// // // //     // This now simply switches the tab to index 0 programmatically if needed,
// // // //     // or you can just let the user swipe.
// // // //     DefaultTabController.of(context).animateTo(0);
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final theme = Theme.of(context);
// // // //     final colorScheme = theme.colorScheme;

// // // //     return DefaultTabController(
// // // //       length: 3, // 1. Scanner, 2. Connected, 3. History
// // // //       initialIndex: 1, // Start on "Connected" tab by default
// // // //       child: Scaffold(
// // // //         appBar: AppBar(
// // // //           title: const Text('Bluetooth Manager'),
// // // //           elevation: 0,
// // // //           centerTitle: false,
// // // //           backgroundColor: colorScheme.surface,
// // // //           foregroundColor: colorScheme.onSurface,
// // // //           // TabBar placed in the bottom slot of AppBar
// // // //           bottom: TabBar(
// // // //             indicatorColor: colorScheme.primary,
// // // //             labelColor: colorScheme.primary,
// // // //             unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
// // // //             indicatorWeight: 3,
// // // //             dividerColor: Colors.transparent,
// // // //             overlayColor: WidgetStateProperty.all(
// // // //               colorScheme.primary.withOpacity(0.1),
// // // //             ),
// // // //             onTap: (index) {
// // // //               HapticFeedback.selectionClick();
// // // //               if (index == 2) {
// // // //                 ScaffoldMessenger.of(context).removeCurrentSnackBar();
// // // //                 ScaffoldMessenger.of(context).showSnackBar(
// // // //                   SnackBar(
// // // //                     content: const Text('History feature coming soon'),
// // // //                     behavior: SnackBarBehavior.floating,
// // // //                     shape: RoundedRectangleBorder(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                     duration: const Duration(seconds: 1),
// // // //                   ),
// // // //                 );
// // // //               }
// // // //             },
// // // //             tabs: [
// // // //               Tab(
// // // //                 icon: CustomIconWidget(
// // // //                   iconName: 'bluetooth_searching',
// // // //                   // Colors are now handled automatically by TabBar theme properties
// // // //                   size: 5.w,
// // // //                 ),
// // // //                 text: 'Scanner',
// // // //               ),
// // // //               Tab(
// // // //                 icon: CustomIconWidget(iconName: 'devices', size: 5.w),
// // // //                 text: 'Connected',
// // // //               ),
// // // //               Tab(
// // // //                 icon: CustomIconWidget(iconName: 'history', size: 5.w),
// // // //                 text: 'History',
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         body: TabBarView(
// // // //           children: [
// // // //             // --- TAB 1: Scanner Screen ---
// // // //             // Assuming ScannerScreen is defined/imported
// // // //             const ScannerScreen(),

// // // //             // --- TAB 2: Connected Devices List ---
// // // //             _connectedDevices.isEmpty
// // // //                 ? EmptyStateWidget(onStartScanning: _handleStartScanning)
// // // //                 : RefreshIndicator(
// // // //                     onRefresh: _handleRefresh,
// // // //                     child: ListView.builder(
// // // //                       padding: EdgeInsets.symmetric(vertical: 1.h),
// // // //                       itemCount: _connectedDevices.length,
// // // //                       itemBuilder: (context, index) {
// // // //                         final device = _connectedDevices[index];
// // // //                         return ConnectedDeviceCardWidget(
// // // //                           device: device,
// // // //                           onControlPanel: () => _handleControlPanel(device),
// // // //                           onDisconnect: () => _handleDisconnect(device),
// // // //                           onSettings: () => _handleSettings(device),
// // // //                           onRename: () => _handleRename(device),
// // // //                           onAutoReconnect: () => _handleAutoReconnect(device),
// // // //                           onViewStats: () => _handleViewStats(device),
// // // //                           onSetPriority: () => _handleSetPriority(device),
// // // //                         );
// // // //                       },
// // // //                     ),
// // // //                   ),

// // // //             // --- TAB 3: History Placeholder ---
// // // //             const SizedBox(),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // ---------------------------------------------------------------------------
// // // // // Placeholder for ScannerScreen if you haven't imported it yet.
// // // // // If you have a separate file, delete this class and import it.
// // // // // class ScannerScreen extends StatelessWidget {
// // // // //   const ScannerScreen({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     // Paste your ScannerScreen code here or import it
// // // // //     return Center(child: Text("Scanner Screen Content Here"));
// // // // //   }
// // // // // }

// // // import 'dart:async';
// // // import 'package:bluetooth_app/features/scanner/bluetooth_scanner.dart'; // Make sure this path is correct
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// // // import 'package:sizer/sizer.dart';

// // // import '../../core/app_export.dart';
// // // import '../../widgets/custom_icon_widget.dart';
// // // import './widgets/connected_device_card_widget.dart';
// // // import './widgets/connection_stats_widget.dart';
// // // import './widgets/empty_state_widget.dart';

// // // class ConnectedDevices extends StatefulWidget {
// // //   const ConnectedDevices({super.key});

// // //   @override
// // //   State<ConnectedDevices> createState() => _ConnectedDevicesState();
// // // }

// // // class _ConnectedDevicesState extends State<ConnectedDevices>
// // //     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
// // //   late TabController _tabController;
// // //   List<Map<String, dynamic>> _connectedDevices = [];
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //     // Initialize Manual Controller
// // //     _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

// // //     _loadConnectedDevices();
// // //     FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
// // //       if (mounted) _loadConnectedDevices();
// // //     });
// // //   }

// // //   @override
// // //   void dispose() {
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     _tabController.dispose(); // Dispose manual controller
// // //     super.dispose();
// // //   }

// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     if (state == AppLifecycleState.resumed) {
// // //       _loadConnectedDevices();
// // //     }
// // //   }

// // //   Future<void> _loadConnectedDevices() async {
// // //     if (!mounted) return;
// // //     try {
// // //       List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial
// // //           .instance
// // //           .getBondedDevices();
// // //       List<Map<String, dynamic>> tempDevices = [];
// // //       for (var device in bondedDevices) {
// // //         if (device.isConnected) {
// // //           tempDevices.add({
// // //             "id": device.address,
// // //             "name": device.name ?? "Unknown Device",
// // //             "address": device.address,
// // //             "type": device.type == BluetoothDeviceType.classic
// // //                 ? "Classic"
// // //                 : "BLE",
// // //             "duration": "Active",
// // //             "txBytes": 0,
// // //             "rxBytes": 0,
// // //             "signalStrength": 100,
// // //             "isAutoReconnect": true,
// // //             "priority": 1,
// // //             "rawDevice": device,
// // //           });
// // //         }
// // //       }
// // //       setState(() {
// // //         _connectedDevices = tempDevices;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }

// // //   void _handleStartScanning() {
// // //     _tabController.animateTo(0); // Manual switch
// // //   }

// // //   // ... (Keep other handlers: _handleRefresh, _handleDisconnect, etc.) ...
// // //   Future<void> _handleRefresh() async {
// // //     setState(() => _isLoading = true);
// // //     await _loadConnectedDevices();
// // //   }

// // //   void _handleDisconnect(Map<String, dynamic> device) async {
// // //     setState(() => _connectedDevices.remove(device));
// // //   }

// // //   void _handleControlPanel(Map<String, dynamic> device) {
// // //     Navigator.pushNamed(context, '/device-control-panel', arguments: device);
// // //   }

// // //   void _handleSettings(Map<String, dynamic> device) {}
// // //   void _handleRename(Map<String, dynamic> device) {}
// // //   void _handleAutoReconnect(Map<String, dynamic> device) {}
// // //   void _handleViewStats(Map<String, dynamic> device) {}
// // //   void _handleSetPriority(Map<String, dynamic> device) {}

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final theme = Theme.of(context);
// // //     final colorScheme = theme.colorScheme;

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Bluetooth Manager'),
// // //         elevation: 0,
// // //         centerTitle: false,
// // //         backgroundColor: colorScheme.surface,
// // //         foregroundColor: colorScheme.onSurface,
// // //         bottom: TabBar(
// // //           controller: _tabController, // Attach Controller
// // //           indicatorColor: colorScheme.primary,
// // //           labelColor: colorScheme.primary,
// // //           unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
// // //           indicatorWeight: 3,
// // //           dividerColor: Colors.transparent,
// // //           overlayColor: WidgetStateProperty.all(
// // //             colorScheme.primary.withOpacity(0.1),
// // //           ),
// // //           tabs: [
// // //             Tab(
// // //               icon: CustomIconWidget(
// // //                 iconName: 'bluetooth_searching',
// // //                 size: 5.w,
// // //               ),
// // //               text: 'Scanner',
// // //             ),
// // //             Tab(
// // //               icon: CustomIconWidget(iconName: 'devices', size: 5.w),
// // //               text: 'Connected',
// // //             ),
// // //             Tab(
// // //               icon: CustomIconWidget(iconName: 'history', size: 5.w),
// // //               text: 'History',
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //       body: TabBarView(
// // //         controller: _tabController, // Attach Controller
// // //         children: [
// // //           // TAB 1: Scanner (Pass the callback!)
// // //           ScannerScreen(
// // //             onConnectionSuccess: () {
// // //               // Switch to Connected tab when success happens
// // //               _tabController.animateTo(1);
// // //             },
// // //           ),

// // //           // TAB 2: Connected Devices
// // //           _isLoading
// // //               ? const Center(child: CircularProgressIndicator())
// // //               : _connectedDevices.isEmpty
// // //               ? EmptyStateWidget(onStartScanning: _handleStartScanning)
// // //               : RefreshIndicator(
// // //                   onRefresh: _handleRefresh,
// // //                   child: ListView.builder(
// // //                     padding: EdgeInsets.symmetric(vertical: 1.h),
// // //                     itemCount: _connectedDevices.length,
// // //                     itemBuilder: (context, index) {
// // //                       final device = _connectedDevices[index];
// // //                       return ConnectedDeviceCardWidget(
// // //                         device: device,
// // //                         onControlPanel: () => _handleControlPanel(device),
// // //                         onDisconnect: () => _handleDisconnect(device),
// // //                         onSettings: () => _handleSettings(device),
// // //                         onRename: () => _handleRename(device),
// // //                         onAutoReconnect: () => _handleAutoReconnect(device),
// // //                         onViewStats: () => _handleViewStats(device),
// // //                         onSetPriority: () => _handleSetPriority(device),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),

// // //           // TAB 3: History
// // //           const SizedBox(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }import 'dart:async';

// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// // import 'package:sizer/sizer.dart';

// // import '../../core/app_export.dart';
// // import '../../widgets/custom_icon_widget.dart';
// // import './widgets/connected_device_card_widget.dart';
// // import './widgets/connection_stats_widget.dart';
// // import './widgets/empty_state_widget.dart';

// // class ConnectedDevicesTab extends StatefulWidget {
// //   final VoidCallback onRequestScan;
// //   const ConnectedDevicesTab({super.key, required this.onRequestScan});

// //   @override
// //   State<ConnectedDevicesTab> createState() => _ConnectedDevicesTabState();
// // }

// // class _ConnectedDevicesTabState extends State<ConnectedDevicesTab>
// //     with WidgetsBindingObserver {
// //   List<Map<String, dynamic>> _activeDevices = [];
// //   List<Map<String, dynamic>> _savedDevices = [];
// //   bool _isLoading = true;

// //   final Map<String, BluetoothConnection> _connections = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _loadDevices();
// //     FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
// //       if (mounted) _loadDevices();
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     for (var conn in _connections.values) {
// //       conn.dispose();
// //     }
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }

// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       _loadDevices();
// //     }
// //   }

// //   Future<void> _loadDevices() async {
// //     if (!mounted) return;
// //     try {
// //       List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial
// //           .instance
// //           .getBondedDevices();
// //       List<Map<String, dynamic>> active = [];
// //       List<Map<String, dynamic>> saved = [];

// //       for (var device in bondedDevices) {
// //         bool isAppConnected =
// //             _connections.containsKey(device.address) &&
// //             (_connections[device.address]?.isConnected ?? false);
// //         bool isSystemConnected = device.isConnected;
// //         bool isConnected = isAppConnected || isSystemConnected;

// //         final deviceMap = {
// //           "id": device.address,
// //           "name": device.name ?? "Unknown Device",
// //           "address": device.address,
// //           "type": device.type == BluetoothDeviceType.classic
// //               ? "Classic"
// //               : "BLE",
// //           "duration": isConnected ? "Active" : "Offline",
// //           "txBytes": 0,
// //           "rxBytes": 0,
// //           "signalStrength": isConnected ? 100 : 0,
// //           "isAutoReconnect": true,
// //           "priority": 1,
// //           "rawDevice": device,
// //           "isConnected": isConnected,
// //         };

// //         if (isConnected)
// //           active.add(deviceMap);
// //         else
// //           saved.add(deviceMap);
// //       }

// //       setState(() {
// //         _activeDevices = active;
// //         _savedDevices = saved;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   // --- CONNECT LOGIC ---
// //   void _handleConnect(Map<String, dynamic> deviceMap) async {
// //     HapticFeedback.mediumImpact();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Connecting...'), duration: Duration(seconds: 1)),
// //     );

// //     try {
// //       BluetoothConnection connection = await BluetoothConnection.toAddress(
// //         deviceMap['address'],
// //       );
// //       _connections[deviceMap['address']] = connection;

// //       connection.input!.listen(null).onDone(() {
// //         if (mounted) {
// //           _connections.remove(deviceMap['address']);
// //           _loadDevices();
// //         }
// //       });

// //       if (mounted) {
// //         _loadDevices();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Connected!'), backgroundColor: Colors.green),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         // ERROR HANDLING
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Connection failed. Is device on?'),
// //             backgroundColor: Colors.red,
// //             action: SnackBarAction(
// //               label: 'Retry',
// //               onPressed: () => _handleConnect(deviceMap),
// //             ),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   // --- DISCONNECT LOGIC ---
// //   void _handleDisconnect(Map<String, dynamic> deviceMap) {
// //     HapticFeedback.mediumImpact();

// //     // 1. Close Socket
// //     if (_connections.containsKey(deviceMap['address'])) {
// //       _connections[deviceMap['address']]?.dispose();
// //       _connections.remove(deviceMap['address']);
// //     }

// //     // 2. Move to Saved List (UI Update)
// //     setState(() {
// //       _activeDevices.remove(deviceMap);
// //       _savedDevices.add(deviceMap);
// //     });

// //     ScaffoldMessenger.of(
// //       context,
// //     ).showSnackBar(SnackBar(content: Text('Disconnected from app')));
// //   }

// //   // --- FORGET LOGIC ---
// //   void _handleForget(Map<String, dynamic> deviceMap) async {
// //     HapticFeedback.mediumImpact();
// //     try {
// //       await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(
// //         deviceMap['address'],
// //       );
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Unpaired')));
// //       _loadDevices();
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Error unpairing')));
// //     }
// //   }

// //   void _handleControlPanel(Map<String, dynamic> device) {
// //     BluetoothConnection? activeConnection = _connections[device['address']];
// //    Navigator.pushNamed(
// //       context,
// //       '/device-control-panel',
// //       arguments: {
// //         ...deviceMap,
// //         'connection': activeConnection // Pass the actual socket
// //       }
// //     );
// //   }

// //   Future<void> _handleRefresh() async {
// //     setState(() => _isLoading = true);
// //     await _loadDevices();
// //   }

// //   void _handleSettings(Map<String, dynamic> device) {}
// //   void _handleRename(Map<String, dynamic> device) {}
// //   void _handleAutoReconnect(Map<String, dynamic> device) {}
// //   void _handleViewStats(Map<String, dynamic> device) {}
// //   void _handleSetPriority(Map<String, dynamic> device) {}

// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// //     if (_activeDevices.isEmpty && _savedDevices.isEmpty) {
// //       return EmptyStateWidget(onStartScanning: widget.onRequestScan);
// //     }

// //     return RefreshIndicator(
// //       onRefresh: _handleRefresh,
// //       child: CustomScrollView(
// //         slivers: [
// //           // ACTIVE DEVICES
// //           if (_activeDevices.isNotEmpty) ...[
// //             SliverToBoxAdapter(
// //               child: Padding(
// //                 padding: EdgeInsets.all(4.w),
// //                 child: Text(
// //                   "Active Connections",
// //                   style: TextStyle(
// //                     color: Colors.green,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14.sp,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SliverList(
// //               delegate: SliverChildBuilderDelegate(
// //                 (context, index) => ConnectedDeviceCardWidget(
// //                   device: _activeDevices[index],
// //                   isSaved: false, // Active
// //                   onConnect: () {},
// //                   onDisconnect: () => _handleDisconnect(_activeDevices[index]),
// //                   onForget: () => _handleForget(_activeDevices[index]),
// //                   onControlPanel: () =>
// //                       _handleControlPanel(_activeDevices[index]),
// //                   onSettings: () => _handleSettings(_activeDevices[index]),
// //                   onRename: () => _handleRename(_activeDevices[index]),
// //                   onAutoReconnect: () =>
// //                       _handleAutoReconnect(_activeDevices[index]),
// //                   onViewStats: () => _handleViewStats(_activeDevices[index]),
// //                   onSetPriority: () =>
// //                       _handleSetPriority(_activeDevices[index]),
// //                 ),
// //                 childCount: _activeDevices.length,
// //               ),
// //             ),
// //           ],

// //           // SAVED DEVICES
// //           if (_savedDevices.isNotEmpty) ...[
// //             SliverToBoxAdapter(
// //               child: Padding(
// //                 padding: EdgeInsets.all(4.w),
// //                 child: Text(
// //                   "Saved Devices",
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14.sp,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SliverList(
// //               delegate: SliverChildBuilderDelegate(
// //                 (context, index) => Opacity(
// //                   opacity: 0.9,
// //                   child: ConnectedDeviceCardWidget(
// //                     device: _savedDevices[index],
// //                     isSaved: true, // Saved
// //                     onConnect: () =>
// //                         _handleConnect(_savedDevices[index]), // Calls Connect
// //                     onDisconnect: () {},
// //                     onForget: () =>
// //                         _handleForget(_savedDevices[index]), // Calls Unpair
// //                     onControlPanel: () =>
// //                         _handleControlPanel(_savedDevices[index]),
// //                     onSettings: () => _handleSettings(_savedDevices[index]),
// //                     onRename: () => _handleRename(_savedDevices[index]),
// //                     onAutoReconnect: () =>
// //                         _handleAutoReconnect(_savedDevices[index]),
// //                     onViewStats: () => _handleViewStats(_savedDevices[index]),
// //                     onSetPriority: () =>
// //                         _handleSetPriority(_savedDevices[index]),
// //                   ),
// //                 ),
// //                 childCount: _savedDevices.length,
// //               ),
// //             ),
// //           ],
// //           SliverToBoxAdapter(child: SizedBox(height: 10.h)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// // // import 'package:sizer/sizer.dart';

// // // import './widgets/connected_device_card_widget.dart';
// // // import './widgets/empty_state_widget.dart';

// // // class ConnectedDevicesTab extends StatefulWidget {
// // //   final VoidCallback onRequestScan;
// // //   const ConnectedDevicesTab({super.key, required this.onRequestScan});

// // //   @override
// // //   State<ConnectedDevicesTab> createState() => _ConnectedDevicesTabState();
// // // }

// // // class _ConnectedDevicesTabState extends State<ConnectedDevicesTab>
// // //     with WidgetsBindingObserver {
// // //   // Lists to separate Active vs Saved devices
// // //   List<Map<String, dynamic>> _activeDevices = [];
// // //   List<Map<String, dynamic>> _savedDevices = [];
// // //   bool _isLoading = true;

// // //   // KEY: Store active connections so we can close them later
// // //   final Map<String, BluetoothConnection> _connections = {};

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addObserver(this);
// // //     _loadDevices();

// // //     // Auto-refresh if system bluetooth state changes
// // //     FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
// // //       if (mounted) _loadDevices();
// // //     });
// // //   }

// // //   @override
// // //   void dispose() {
// // //     // Safety: Close all sockets when leaving the screen
// // //     for (var conn in _connections.values) {
// // //       conn.dispose();
// // //     }
// // //     WidgetsBinding.instance.removeObserver(this);
// // //     super.dispose();
// // //   }

// // //   @override
// // //   void didChangeAppLifecycleState(AppLifecycleState state) {
// // //     if (state == AppLifecycleState.resumed) {
// // //       _loadDevices();
// // //     }
// // //   }

// // //   Future<void> _loadDevices() async {
// // //     if (!mounted) return;
// // //     try {
// // //       List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial
// // //           .instance
// // //           .getBondedDevices();
// // //       List<Map<String, dynamic>> active = [];
// // //       List<Map<String, dynamic>> saved = [];

// // //       for (var device in bondedDevices) {
// // //         // 1. Check if WE connected to it via App
// // //         bool isAppConnected =
// // //             _connections.containsKey(device.address) &&
// // //             (_connections[device.address]?.isConnected ?? false);

// // //         // 2. Check if System thinks it's connected (e.g. Headphones)
// // //         bool isSystemConnected = device.isConnected;

// // //         bool isConnected = isAppConnected || isSystemConnected;

// // //         final int rssi = isConnected ? -50 : -90;

// // //         // YOUR FORMULA:
// // //         final int signalPercent = ((rssi + 100) * 2).clamp(0, 100);

// // //         final deviceMap = {
// // //           "id": device.address,
// // //           "name": device.name ?? "Unknown Device",
// // //           "address": device.address,
// // //           "type": device.type == BluetoothDeviceType.classic
// // //               ? "Classic"
// // //               : "BLE",
// // //           "duration": isConnected ? "Active" : "Saved",
// // //           "txBytes": 0,
// // //           "rxBytes": 0,
// // //           "signalStrength": signalPercent,
// // //           "isAutoReconnect": true,
// // //           "priority": 1,
// // //           "rawDevice": device,
// // //           "isConnected": isConnected,
// // //         };

// // //         if (isConnected)
// // //           active.add(deviceMap);
// // //         else
// // //           saved.add(deviceMap);
// // //       }

// // //       setState(() {
// // //         _activeDevices = active;
// // //         _savedDevices = saved;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //     }
// // //   }

// // //   // --- CONNECT FUNCTION ---
// // //   void _handleConnect(Map<String, dynamic> deviceMap) async {
// // //     HapticFeedback.mediumImpact();
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text('Connecting to ${deviceMap['name']}...'),
// // //         duration: Duration(seconds: 1),
// // //       ),
// // //     );

// // //     try {
// // //       // 1. Close existing loose connection
// // //       if (_connections.containsKey(deviceMap['address'])) {
// // //         _connections[deviceMap['address']]?.dispose();
// // //       }

// // //       // 2. Create new Connection
// // //       BluetoothConnection connection = await BluetoothConnection.toAddress(
// // //         deviceMap['address'],
// // //       );

// // //       if (connection.isConnected) {
// // //         _connections[deviceMap['address']] = connection;

// // //         // 3. Listen for data (Keep alive)
// // //         connection.input!.listen((data) {}).onDone(() {
// // //           if (mounted) {
// // //             _connections.remove(deviceMap['address']);
// // //             _loadDevices();
// // //           }
// // //         });

// // //         // 4. Update UI
// // //         if (mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(
// // //               content: Text('Connected to ${deviceMap['name']}'),
// // //               backgroundColor: Colors.green,
// // //             ),
// // //           );
// // //           _loadDevices();
// // //         }
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         // If it fails, it might be because the device is already connected via System
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('Could not connect. Is the device on?'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //         _loadDevices(); // Refresh anyway just in case
// // //       }
// // //     }
// // //   }

// // //   // --- DISCONNECT FUNCTION ---
// // //   void _handleDisconnect(Map<String, dynamic> deviceMap) {
// // //     HapticFeedback.mediumImpact();

// // //     String address = deviceMap['address'];

// // //     if (_connections.containsKey(address)) {
// // //       // 1. We have a socket -> Close it.
// // //       _connections[address]?.dispose();
// // //       _connections.remove(address);
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('${deviceMap['name']} disconnected')),
// // //       );
// // //     } else {
// // //       // 2. We DON'T have a socket (Connected via System Settings).
// // //       // We cannot force disconnect without unpairing.
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text('System-managed device. Use "Forget" to disconnect.'),
// // //           duration: Duration(seconds: 2),
// // //         ),
// // //       );
// // //     }

// // //     // Refresh UI to reflect state
// // //     _loadDevices();
// // //   }

// // //   // --- FORGET FUNCTION (Unpair) ---
// // //   void _handleForget(Map<String, dynamic> deviceMap) async {
// // //     HapticFeedback.mediumImpact();

// // //     // Disconnect socket first
// // //     if (_connections.containsKey(deviceMap['address'])) {
// // //       _connections[deviceMap['address']]?.dispose();
// // //       _connections.remove(deviceMap['address']);
// // //     }

// // //     try {
// // //       // Unpair from Android System
// // //       await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(
// // //         deviceMap['address'],
// // //       );
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text('${deviceMap['name']} unpaired')));
// // //       await Future.delayed(Duration(milliseconds: 500));
// // //       _loadDevices();
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text('Could not unpair device')));
// // //     }
// // //   }

// // //   void _handleControlPanel(Map<String, dynamic> device) {
// // //     Navigator.pushNamed(context, '/device-control-panel', arguments: device);
// // //   }

// // //   // --- Boilerplate ---
// // //   Future<void> _handleRefresh() async {
// // //     setState(() => _isLoading = true);
// // //     await _loadDevices();
// // //   }

// // //   void _handleSettings(Map<String, dynamic> device) {}
// // //   void _handleRename(Map<String, dynamic> device) {}
// // //   void _handleAutoReconnect(Map<String, dynamic> device) {}
// // //   void _handleViewStats(Map<String, dynamic> device) {}
// // //   void _handleSetPriority(Map<String, dynamic> device) {}

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // //     if (_activeDevices.isEmpty && _savedDevices.isEmpty) {
// // //       return EmptyStateWidget(onStartScanning: widget.onRequestScan);
// // //     }

// // //     return RefreshIndicator(
// // //       onRefresh: _handleRefresh,
// // //       child: CustomScrollView(
// // //         slivers: [
// // //           // ACTIVE SECTION
// // //           if (_activeDevices.isNotEmpty) ...[
// // //             SliverToBoxAdapter(
// // //               child: Padding(
// // //                 padding: EdgeInsets.only(left: 4.w, top: 4.w),
// // //                 child: Text(
// // //                   "Active Connections",
// // //                   style: TextStyle(
// // //                     color: Colors.green,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 14.sp,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             SliverList(
// // //               delegate: SliverChildBuilderDelegate(
// // //                 (context, index) => ConnectedDeviceCardWidget(
// // //                   device: _activeDevices[index],
// // //                   isSaved: false, // Active
// // //                   onConnect: () {}, // Already connected
// // //                   onDisconnect: () => _handleDisconnect(_activeDevices[index]),
// // //                   onForget: () => _handleForget(_activeDevices[index]),
// // //                   onControlPanel: () =>
// // //                       _handleControlPanel(_activeDevices[index]),
// // //                   onSettings: () => _handleSettings(_activeDevices[index]),
// // //                   onRename: () => _handleRename(_activeDevices[index]),
// // //                   onAutoReconnect: () =>
// // //                       _handleAutoReconnect(_activeDevices[index]),
// // //                   onViewStats: () => _handleViewStats(_activeDevices[index]),
// // //                   onSetPriority: () =>
// // //                       _handleSetPriority(_activeDevices[index]),
// // //                 ),
// // //                 childCount: _activeDevices.length,
// // //               ),
// // //             ),
// // //           ],

// // //           // SAVED SECTION
// // //           if (_savedDevices.isNotEmpty) ...[
// // //             SliverToBoxAdapter(
// // //               child: Padding(
// // //                 padding: EdgeInsets.only(left: 4.w),
// // //                 child: Text(
// // //                   "Saved Devices",
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 14.sp,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             SliverList(
// // //               delegate: SliverChildBuilderDelegate(
// // //                 (context, index) => Opacity(
// // //                   opacity: 0.9,
// // //                   child: ConnectedDeviceCardWidget(
// // //                     device: _savedDevices[index],
// // //                     isSaved: true, // Saved
// // //                     onConnect: () =>
// // //                         _handleConnect(_savedDevices[index]), // Connect Button
// // //                     onDisconnect: () {},
// // //                     onForget: () => _handleForget(_savedDevices[index]),
// // //                     onControlPanel: () =>
// // //                         _handleControlPanel(_savedDevices[index]),
// // //                     onSettings: () => _handleSettings(_savedDevices[index]),
// // //                     onRename: () => _handleRename(_savedDevices[index]),
// // //                     onAutoReconnect: () =>
// // //                         _handleAutoReconnect(_savedDevices[index]),
// // //                     onViewStats: () => _handleViewStats(_savedDevices[index]),
// // //                     onSetPriority: () =>
// // //                         _handleSetPriority(_savedDevices[index]),
// // //                   ),
// // //                 ),
// // //                 childCount: _savedDevices.length,
// // //               ),
// // //             ),
// // //           ],
// // //           SliverToBoxAdapter(child: SizedBox(height: 10.h)),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:sizer/sizer.dart';

// import './widgets/connected_device_card_widget.dart';
// import './widgets/empty_state_widget.dart';

// class ConnectedDevicesTab extends StatefulWidget {
//   final VoidCallback onRequestScan;
//   const ConnectedDevicesTab({super.key, required this.onRequestScan});

//   @override
//   State<ConnectedDevicesTab> createState() => _ConnectedDevicesTabState();
// }

// class _ConnectedDevicesTabState extends State<ConnectedDevicesTab>
//     with WidgetsBindingObserver {
//   List<Map<String, dynamic>> _activeDevices = [];
//   List<Map<String, dynamic>> _savedDevices = [];
//   bool _isLoading = true;

//   // Store active connections
//   final Map<String, BluetoothConnection> _connections = {};

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _loadDevices();
//     FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
//       if (mounted) _loadDevices();
//     });
//   }

//   @override
//   void dispose() {
//     // Close connections when app closes strictly
//     for (var conn in _connections.values) {
//       conn.dispose();
//     }
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _loadDevices();
//     }
//   }

//   Future<void> _loadDevices() async {
//     if (!mounted) return;
//     try {
//       List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial
//           .instance
//           .getBondedDevices();

//       List<Map<String, dynamic>> active = [];
//       List<Map<String, dynamic>> saved = [];

//       for (var device in bondedDevices) {
//         // STRICT CHECK: Active only if WE have the connection in our map
//         bool isAppConnected =
//             _connections.containsKey(device.address) &&
//             (_connections[device.address]?.isConnected ?? false);

//         // We ignore device.isConnected because the System is too slow/glitchy
//         bool isActive = isAppConnected;

//         final int rssi = isActive ? -50 : -90;
//         final int signalPercent = ((rssi + 100) * 2).clamp(0, 100);

//         final deviceMap = {
//           "id": device.address,
//           "name": device.name ?? "Unknown Device",
//           "address": device.address,
//           "type": device.type == BluetoothDeviceType.classic
//               ? "Classic"
//               : "BLE",
//           "duration": isActive ? "Active" : "Saved",
//           "txBytes": 0,
//           "rxBytes": 0,
//           "signalStrength": signalPercent,
//           "isAutoReconnect": true,
//           "priority": 1,
//           "rawDevice": device,
//           "isConnected": isActive,
//         };

//         if (isActive)
//           active.add(deviceMap);
//         else
//           saved.add(deviceMap);
//       }

//       setState(() {
//         _activeDevices = active;
//         _savedDevices = saved;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _handleConnect(Map<String, dynamic> deviceMap) async {
//     HapticFeedback.mediumImpact();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Connecting...'), duration: Duration(seconds: 1)),
//     );

//     try {
//       if (_connections.containsKey(deviceMap['address'])) {
//         _connections[deviceMap['address']]?.dispose();
//       }

//       BluetoothConnection connection = await BluetoothConnection.toAddress(
//         deviceMap['address'],
//       );

//       if (connection.isConnected) {
//         _connections[deviceMap['address']] = connection;

//         // Listener to detect remote disconnect
//         connection.input!.listen(null).onDone(() {
//           if (mounted) {
//             _connections.remove(deviceMap['address']);
//             _loadDevices();
//           }
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Connected to ${deviceMap['name']}'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           _loadDevices();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Connection failed. Is device on?'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         _loadDevices();
//       }
//     }
//   }

//   // void _handleDisconnect(Map<String, dynamic> deviceMap) {
//   //   HapticFeedback.mediumImpact();
//   //   String address = deviceMap['address'];

//   //   if (_connections.containsKey(address)) {
//   //     _connections[address]?.dispose();
//   //     _connections.remove(address);
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('Disconnected')));
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('System-managed device. Use Forget.')),
//   //     );
//   //   }
//   //   _loadDevices();
//   // }

//   void _handleDisconnect(Map<String, dynamic> deviceMap) async {
//     HapticFeedback.mediumImpact();
//     String address = deviceMap['address'];

//     // 1. Kill the app's local connection
//     if (_connections.containsKey(address)) {
//       _connections[address]?.dispose();
//       _connections.remove(address);
//     }

//     // 2. UI UPDATE: Move to Saved List IMMEDIATELY
//     setState(() {
//       _activeDevices.removeWhere((d) => d['address'] == address);

//       Map<String, dynamic> updatedDevice = Map.from(deviceMap);
//       updatedDevice['isConnected'] = false;
//       updatedDevice['duration'] = "Saved";
//       updatedDevice['signalStrength'] = 0;

//       _savedDevices.removeWhere((d) => d['address'] == address);
//       _savedDevices.add(updatedDevice);
//     });

//     // 3. Ghost Busting (Close socket in background)
//     try {
//       BluetoothConnection tempConn = await BluetoothConnection.toAddress(
//         address,
//       );
//       tempConn.dispose();
//     } catch (e) {
//       // Ignore
//     }

//     // REMOVED: The Future.delayed timer was causing the glitch!

//     ScaffoldMessenger.of(
//       // ignore: use_build_context_synchronously
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Disconnected')));
//   }

//   void _handleForget(Map<String, dynamic> deviceMap) async {
//     HapticFeedback.mediumImpact();
//     String address = deviceMap['address'];

//     // 1. Close connection if open
//     if (_connections.containsKey(address)) {
//       _connections[address]?.dispose();
//       _connections.remove(address);
//     }

//     // 2. UI UPDATE: Remove from screen IMMEDIATELY
//     setState(() {
//       _savedDevices.removeWhere((d) => d['address'] == address);
//       _activeDevices.removeWhere((d) => d['address'] == address);
//     });

//     try {
//       // 3. System Unpair
//       await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(
//         address,
//       );

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Unpaired')));

//       // We don't call _loadDevices() here to prevent it from coming back if system is slow
//     } catch (e) {
//       // Only reload if it fails
//       _loadDevices();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Error unpairing')));
//     }
//   }

//   void _handleControlPanel(Map<String, dynamic> deviceMap) {
//     // --- FIX: PASS THE EXISTING CONNECTION OBJECT ---
//     BluetoothConnection? activeConnection = _connections[deviceMap['address']];

//     Navigator.pushNamed(
//       context,
//       '/device-control-panel',
//       arguments: {
//         ...deviceMap,
//         'connection': activeConnection, // Pass the actual socket
//       },
//     );
//   }

//   // Boilerplate
//   Future<void> _handleRefresh() async {
//     setState(() => _isLoading = true);
//     await _loadDevices();
//   }

//   void _handleSettings(Map<String, dynamic> device) {}
//   void _handleRename(Map<String, dynamic> device) {}
//   void _handleAutoReconnect(Map<String, dynamic> device) {}
//   void _handleViewStats(Map<String, dynamic> device) {}
//   void _handleSetPriority(Map<String, dynamic> device) {}

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());
//     if (_activeDevices.isEmpty && _savedDevices.isEmpty)
//       return EmptyStateWidget(onStartScanning: widget.onRequestScan);

//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: CustomScrollView(
//         slivers: [
//           if (_activeDevices.isNotEmpty) ...[
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(4.w),
//                 child: Text(
//                   "Active Connections",
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//               ),
//             ),
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) => ConnectedDeviceCardWidget(
//                   device: _activeDevices[index],
//                   isSaved: false,
//                   onConnect: () {},
//                   onDisconnect: () => _handleDisconnect(_activeDevices[index]),
//                   onForget: () => _handleForget(_activeDevices[index]),
//                   onControlPanel: () =>
//                       _handleControlPanel(_activeDevices[index]),
//                   onSettings: () => _handleSettings(_activeDevices[index]),
//                   onRename: () => _handleRename(_activeDevices[index]),
//                   onAutoReconnect: () =>
//                       _handleAutoReconnect(_activeDevices[index]),
//                   onViewStats: () => _handleViewStats(_activeDevices[index]),
//                   onSetPriority: () =>
//                       _handleSetPriority(_activeDevices[index]),
//                 ),
//                 childCount: _activeDevices.length,
//               ),
//             ),
//           ],
//           if (_savedDevices.isNotEmpty) ...[
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(4.w),
//                 child: Text(
//                   "Saved Devices",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//               ),
//             ),
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) => Opacity(
//                   opacity: 0.9,
//                   child: ConnectedDeviceCardWidget(
//                     device: _savedDevices[index],
//                     isSaved: true,
//                     onConnect: () => _handleConnect(_savedDevices[index]),
//                     onDisconnect: () {},
//                     onForget: () => _handleForget(_savedDevices[index]),
//                     onControlPanel: () =>
//                         _handleControlPanel(_savedDevices[index]),
//                     onSettings: () => _handleSettings(_savedDevices[index]),
//                     onRename: () => _handleRename(_savedDevices[index]),
//                     onAutoReconnect: () =>
//                         _handleAutoReconnect(_savedDevices[index]),
//                     onViewStats: () => _handleViewStats(_savedDevices[index]),
//                     onSetPriority: () =>
//                         _handleSetPriority(_savedDevices[index]),
//                   ),
//                 ),
//                 childCount: _savedDevices.length,
//               ),
//             ),
//           ],
//           SliverToBoxAdapter(child: SizedBox(height: 10.h)),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/connected_device_card_widget.dart';
import './widgets/connection_stats_widget.dart';
import './widgets/empty_state_widget.dart';

class ConnectedDevicesTab extends StatefulWidget {
  final VoidCallback onRequestScan;
  const ConnectedDevicesTab({super.key, required this.onRequestScan});

  @override
  State<ConnectedDevicesTab> createState() => _ConnectedDevicesTabState();
}

class _ConnectedDevicesTabState extends State<ConnectedDevicesTab>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _activeDevices = [];
  List<Map<String, dynamic>> _savedDevices = [];
  bool _isLoading = true;

  // Store active connections
  final Map<String, BluetoothConnection> _connections = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDevices();
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      if (mounted) _loadDevices();
    });
  }

  @override
  void dispose() {
    // Only close connections if the App is actually closing
    for (var conn in _connections.values) {
      conn.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDevices();
    }
  }

  Future<void> _loadDevices() async {
    if (!mounted) return;
    try {
      List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial
          .instance
          .getBondedDevices();

      List<Map<String, dynamic>> active = [];
      List<Map<String, dynamic>> saved = [];

      for (var device in bondedDevices) {
        bool isAppConnected =
            _connections.containsKey(device.address) &&
            (_connections[device.address]?.isConnected ?? false);

        bool isActive = isAppConnected;

        final int rssi = isActive ? -50 : -90;
        final int signalPercent = ((rssi + 100) * 2).clamp(0, 100);

        final deviceMap = {
          "id": device.address,
          "name": device.name ?? "Unknown Device",
          "address": device.address,
          "type": device.type == BluetoothDeviceType.classic
              ? "Classic"
              : "BLE",
          "duration": isActive ? "Active" : "Saved",
          "txBytes": 0,
          "rxBytes": 0,
          "signalStrength": signalPercent,
          "isAutoReconnect": true,
          "priority": 1,
          "rawDevice": device,
          "isConnected": isActive,
        };

        if (isActive)
          active.add(deviceMap);
        else
          saved.add(deviceMap);
      }

      setState(() {
        _activeDevices = active;
        _savedDevices = saved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleConnect(Map<String, dynamic> deviceMap) async {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      String address = deviceMap['address'];
      if (_connections.containsKey(address)) {
        _connections[address]?.dispose();
      }

      BluetoothConnection connection = await BluetoothConnection.toAddress(
        address,
      );

      if (connection.isConnected) {
        _connections[address] = connection;

        // NOTE: We do NOT listen here. We leave the stream free for the Control Panel.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connected to ${deviceMap['name']}'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDevices();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection failed'),
            backgroundColor: Colors.red,
          ),
        );
        _loadDevices();
      }
    }
  }

  void _handleDisconnect(Map<String, dynamic> deviceMap) async {
    HapticFeedback.mediumImpact();
    String address = deviceMap['address'];

    if (_connections.containsKey(address)) {
      _connections[address]?.dispose();
      _connections.remove(address);
    }

    setState(() {
      _activeDevices.removeWhere((d) => d['address'] == address);
      Map<String, dynamic> updatedDevice = Map.from(deviceMap);
      updatedDevice['isConnected'] = false;
      _savedDevices.removeWhere((d) => d['address'] == address);
      _savedDevices.add(updatedDevice);
    });

    try {
      BluetoothConnection tempConn = await BluetoothConnection.toAddress(
        address,
      );
      tempConn.dispose();
    } catch (e) {}

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Disconnected')));
  }

  // --- THE FIXED FUNCTION ---
  void _handleControlPanel(Map<String, dynamic> deviceMap) async {
    String address = deviceMap['address'];
    BluetoothConnection? activeConnection = _connections[address];

    // FIX: If connection is lost/null, Re-Connect HERE before navigating
    if (activeConnection == null || !activeConnection.isConnected) {
      // Show loading toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Re-establishing connection...'),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        activeConnection = await BluetoothConnection.toAddress(address);
        _connections[address] = activeConnection; // Store it in the parent map!
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not reconnect'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Don't navigate if connection failed
      }
    }

    // Now we navigate passing the Valid, Parent-Owned connection
    await Navigator.pushNamed(
      context,
      '/device-control-panel',
      arguments: {...deviceMap, 'connection': activeConnection},
    );

    // When we come back, we refresh to see if it's still alive
    _loadDevices();
  }

  void _handleForget(Map<String, dynamic> deviceMap) async {
    // ... (Keep your existing forget logic) ...
    // For brevity, just call disconnect logic + system unpair
    _handleDisconnect(deviceMap);
    try {
      await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(
        deviceMap['address'],
      );
    } catch (e) {}
  }

  // Boilerplate
  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _loadDevices();
  }

  // Empty handlers to prevent errors
  void _handleSettings(Map<String, dynamic> d) {}
  void _handleRename(Map<String, dynamic> d) {}
  void _handleAutoReconnect(Map<String, dynamic> d) {}
  void _handleViewStats(Map<String, dynamic> d) {}
  void _handleSetPriority(Map<String, dynamic> d) {}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_activeDevices.isEmpty && _savedDevices.isEmpty)
      return EmptyStateWidget(onStartScanning: widget.onRequestScan);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          if (_activeDevices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  "Active Connections",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ConnectedDeviceCardWidget(
                  device: _activeDevices[index],
                  isSaved: false,
                  onConnect: () {},
                  onDisconnect: () => _handleDisconnect(_activeDevices[index]),
                  onForget: () => _handleForget(_activeDevices[index]),
                  onControlPanel: () =>
                      _handleControlPanel(_activeDevices[index]),
                  onSettings: () => _handleSettings(_activeDevices[index]),
                  onRename: () => _handleRename(_activeDevices[index]),
                  onAutoReconnect: () =>
                      _handleAutoReconnect(_activeDevices[index]),
                  onViewStats: () => _handleViewStats(_activeDevices[index]),
                  onSetPriority: () =>
                      _handleSetPriority(_activeDevices[index]),
                ),
                childCount: _activeDevices.length,
              ),
            ),
          ],
          if (_savedDevices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  "Saved Devices",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Opacity(
                  opacity: 0.9,
                  child: ConnectedDeviceCardWidget(
                    device: _savedDevices[index],
                    isSaved: true,
                    onConnect: () => _handleConnect(_savedDevices[index]),
                    onDisconnect: () {},
                    onForget: () => _handleForget(_savedDevices[index]),
                    onControlPanel: () =>
                        _handleControlPanel(_savedDevices[index]),
                    onSettings: () => _handleSettings(_savedDevices[index]),
                    onRename: () => _handleRename(_savedDevices[index]),
                    onAutoReconnect: () =>
                        _handleAutoReconnect(_savedDevices[index]),
                    onViewStats: () => _handleViewStats(_savedDevices[index]),
                    onSetPriority: () =>
                        _handleSetPriority(_savedDevices[index]),
                  ),
                ),
                childCount: _savedDevices.length,
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),
        ],
      ),
    );
  }
}
