// import 'dart:convert';
// import 'dart:io';
// import 'package:bluetooth_app/features/device_control_panel/widgets/terminal_tab_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/custom_icon_widget.dart';
// import './widgets/command_editor_bottom_sheet.dart';
// import './widgets/commands_tab_widget.dart';
// import './widgets/data_monitor_tab_widget.dart';

// class DeviceControlPanel extends StatefulWidget {
//   const DeviceControlPanel({super.key});

//   @override
//   State<DeviceControlPanel> createState() => _DeviceControlPanelState();
// }

// class _DeviceControlPanelState extends State<DeviceControlPanel>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late TabController _tabController;
//   BluetoothConnection? connection;
//   bool isConnecting = true;
//   bool isConnectionInherited = false;

//   bool get isConnected => (connection?.isConnected ?? false);
//   String _deviceName = "Connecting...";
//   String _deviceAddress = "";
//   final int _signalStrength = 85;

//   final List<Map<String, dynamic>> _commands = [
//     {
//       "id": 1,
//       "name": "LED On",
//       "command": "1",
//       "color": const Color(0xFF4CAF50),
//       "icon": "lightbulb",
//     },
//     {
//       "id": 2,
//       "name": "LED Off",
//       "command": "0",
//       "color": const Color(0xFFF44336),
//       "icon": "lightbulb_outline",
//     },
//   ];

//   // This list stores BOTH Data Monitor logs AND Terminal Chat history
//   final List<Map<String, dynamic>> _dataStream = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     // 3 Tabs: Commands, Data Monitor, Terminal
//     _tabController = TabController(length: 3, vsync: this);
//     Future.delayed(Duration.zero, _setupConnection);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       // The user minimized or closed the app -> Kill Bluetooth immediately!
//       if (isConnected) {
//         connection?.dispose();
//         connection = null;
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     if (!isConnectionInherited && isConnected) {
//       connection?.dispose();
//     }
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Future<void> _setupConnection() async {
//   //   final args =
//   //       ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//   //   if (args == null) return;

//   //   setState(() {
//   //     _deviceName = args['name'] ?? "Unknown";
//   //     _deviceAddress = args['address'];
//   //   });

//   //   if (args.containsKey('connection') && args['connection'] != null) {
//   //     setState(() {
//   //       connection = args['connection'] as BluetoothConnection;
//   //       isConnecting = false;
//   //       isConnectionInherited = true;
//   //     });
//   //     _attachListener();
//   //   } else {
//   //     _connectToDevice();
//   //   }
//   // }

//   Future<void> _setupConnection() async {
//     final args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     if (args == null) return;

//     setState(() {
//       _deviceName = args['name'] ?? "Unknown";
//       _deviceAddress = args['address'];
//     });

//     // 1. If a connection was passed, KILL IT gracefully.
//     if (args.containsKey('connection') && args['connection'] != null) {
//       try {
//         // Close the old connection
//         (args['connection'] as BluetoothConnection).dispose();
//       } catch (e) {
//         // Ignore errors if it was already closed
//       }
//     }

//     // --- THE MAGIC FIX ---
//     // Wait 300ms for the phone to fully close the old socket.
//     // This prevents the "Socket closed" error.
//     await Future.delayed(const Duration(milliseconds: 300));
//     // ---------------------

//     // 2. NOW connect fresh (The line is guaranteed to be clear)
//     _connectToDevice();
//   }

//   Future<void> _connectToDevice() async {
//     try {
//       BluetoothConnection newConnection = await BluetoothConnection.toAddress(
//         _deviceAddress,
//       );
//       setState(() {
//         connection = newConnection;
//         isConnecting = false;
//         isConnectionInherited = false;
//       });
//       _attachListener();
//     } catch (e) {
//       if (mounted) {
//         setState(() => isConnecting = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
//       }
//     }
//   }

//   void _attachListener() {
//     if (isConnected && connection != null && connection!.input != null) {
//       try {
//         print("Attaching listener to connection..."); // Debug info

//         connection!.input!
//             .listen((Uint8List data) {
//               // 1. Debug: Print raw numbers to VS Code Console
//               print('Data incoming: $data');

//               // 2. Safe Decode: Converts bytes to text without crashing on noise
//               String incomingData = String.fromCharCodes(data);

//               // 3. Update UI
//               // We use trim() to remove the extra newlines coming from Arduino
//               if (incomingData.trim().isNotEmpty) {
//                 _addToDataStream(incomingData.trim(), "sensor");
//               }
//             })
//             .onDone(() {
//               if (mounted) {
//                 setState(() => isConnecting = false);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Device Disconnected')),
//                 );
//               }
//             });
//       } catch (e) {
//         print('Error attaching listener: $e');
//       }
//     }
//   }

//   void _sendCommand(String command) async {
//     HapticFeedback.mediumImpact();
//     _addToDataStream("TX: $command", "command");

//     if (!isConnected) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Not connected'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     try {
//       connection!.output.add(utf8.encode(command + "\r\n"));
//       await connection!.output.allSent;

//       // Only show snackbar if NOT on Terminal tab (since Terminal shows the message in list)
//       if (_tabController.index != 2) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Sent: $command'),
//             duration: const Duration(milliseconds: 500),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   void _addToDataStream(String data, String type) {
//     setState(() {
//       _dataStream.insert(0, {
//         "timestamp": DateTime.now(),
//         "data": data,
//         "type": type,
//       });
//     });
//   }

//   void _addCustomCommand(Map<String, dynamic> command) {
//     setState(() {
//       _commands.add(command);
//     });
//   }

//   void _editCommand(int index) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CommandEditorBottomSheet(
//         command: _commands[index],
//         onSave: (updated) {
//           setState(() {
//             _commands[index] = updated;
//           });
//         },
//       ),
//     );
//   }

//   void _deleteCommand(int index) {
//     setState(() {
//       _commands.removeAt(index);
//     });
//   }

//   void _clearDataStream() {
//     setState(() {
//       _dataStream.clear();
//     });
//   }

//   Future<void> _exportDataStream() async {
//     if (_dataStream.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("No data to export!")));
//       return;
//     }

//     try {
//       // 1. Create the CSV Header
//       String csvContent = "Timestamp,Type,Message\n";

//       // 2. Loop through your data and format it
//       for (var log in _dataStream) {
//         // Clean up the message (remove commas so they don't break the CSV columns)
//         String cleanMessage = log['data'].toString().replaceAll(",", " ");
//         String type = log['type'].toString();
//         String time = log['timestamp'].toString();

//         // Add a new row
//         csvContent += "$time,$type,$cleanMessage\n";
//       }

//       // 3. Get a temporary folder to save the file
//       final directory = await getTemporaryDirectory();
//       final fileName =
//           "arduino_logs_${DateTime.now().millisecondsSinceEpoch}.csv";
//       final path = "${directory.path}/$fileName";

//       // 4. Write the file
//       final file = File(path);
//       await file.writeAsString(csvContent);

//       // 5. Open the Share Sheet (User can choose "Save to Files" or "Drive")
//       // We use XFile which is the modern standard for sharing
//       // ignore: deprecated_member_use
//       await Share.shareXFiles(
//         [XFile(path)],
//         text: 'Exported Arduino Logs',
//         subject: 'Arduino Log Data',
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
//     }
//   }

//   void _showCommandEditor() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CommandEditorBottomSheet(onSave: _addCustomCommand),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

//     return Scaffold(
//       appBar: CustomControlPanelAppBar(
//         deviceName: _deviceName,
//         isConnected: isConnected,
//         signalStrength: _signalStrength, // Assuming 85 for now
//         actions: [
//           IconButton(
//             icon: CustomIconWidget(
//               iconName: 'more_vert',
//               color: theme.colorScheme.onSurface,
//               size: 24,
//             ),
//             onPressed: () {},
//             tooltip: 'More options',
//           ),
//         ],
//       ),
//       body: isConnecting
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface,
//                     boxShadow: [
//                       BoxShadow(
//                         color: theme.colorScheme.shadow,
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     tabs: const [
//                       Tab(text: 'Commands'), Tab(text: 'Terminal'), // NEW TAB
//                       Tab(text: 'Data Monitor'),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       // Tab 1: Commands Grid
//                       CommandsTabWidget(
//                         commands: _commands,
//                         onCommandTap: _sendCommand,
//                         onCommandLongPress: _editCommand,
//                         onCommandDelete: _deleteCommand,
//                       ),

//                       // Tab 2: Read-Only Log
//                       TerminalTabWidget(
//                         messages: _dataStream, // Shares the same data source
//                         onSendMessage: _sendCommand, // Re-uses the send logic
//                       ),

//                       // Tab 3: Interactive Terminal (Chat Style)
//                       DataMonitorTabWidget(
//                         dataStream: _dataStream,
//                         onClear: _clearDataStream,
//                         onExport: _exportDataStream,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//       // Hide FAB if keyboard open OR if on Terminal tab (since Terminal has its own input)
//       floatingActionButton: (_tabController.index == 0 && !isKeyboardOpen)
//           ? FloatingActionButton.extended(
//               onPressed: _showCommandEditor,
//               icon: CustomIconWidget(
//                 iconName: 'add',
//                 color: theme.colorScheme.onPrimary,
//                 size: 24,
//               ),
//               label: const Text('Add Command'),
//             )
//           : null,
//     );
//   }
// }

// // import 'dart:convert';
// // import 'dart:async'; // Required for StreamSubscription
// // import 'dart:io';
// // import 'dart:typed_data';
// // import 'package:bluetooth_app/features/device_control_panel/widgets/terminal_tab_widget.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';

// // import '../../widgets/custom_app_bar.dart';
// // import '../../widgets/custom_icon_widget.dart';
// // import './widgets/command_editor_bottom_sheet.dart';
// // import './widgets/commands_tab_widget.dart';
// // import './widgets/data_monitor_tab_widget.dart';

// // class DeviceControlPanel extends StatefulWidget {
// //   const DeviceControlPanel({super.key});

// //   @override
// //   State<DeviceControlPanel> createState() => _DeviceControlPanelState();
// // }

// // class _DeviceControlPanelState extends State<DeviceControlPanel>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   BluetoothConnection? connection;

// //   // FIX 1: Track the listener so we can cancel it cleanly
// //   StreamSubscription<Uint8List>? _streamSubscription;

// //   bool isConnecting = true;
// //   bool isConnectionInherited = false;

// //   bool get isConnected => (connection?.isConnected ?? false);
// //   String _deviceName = "Connecting...";
// //   String _deviceAddress = "";
// //   final int _signalStrength = 85;

// //   final List<Map<String, dynamic>> _commands = [
// //     {
// //       "id": 1,
// //       "name": "LED On",
// //       "command": "1",
// //       "color": const Color(0xFF4CAF50),
// //       "icon": "lightbulb",
// //     },
// //     {
// //       "id": 2,
// //       "name": "LED Off",
// //       "command": "0",
// //       "color": const Color(0xFFF44336),
// //       "icon": "lightbulb_outline",
// //     },
// //   ];

// //   final List<Map<String, dynamic>> _dataStream = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     Future.delayed(Duration.zero, _setupConnection);
// //   }

// //   @override
// //   void dispose() {
// //     // FIX 2: Stop listening to the stream BEFORE we leave
// //     _streamSubscription?.cancel();
// //     _streamSubscription = null;

// //     // FIX 3: Only close the connection if WE created it.
// //     // If it was passed from the previous screen, LEAVE IT OPEN.
// //     if (!isConnectionInherited) {
// //       connection?.dispose();
// //     }

// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _setupConnection() async {
// //     final args =
// //         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
// //     if (args == null) return;

// //     setState(() {
// //       _deviceName = args['name'] ?? "Unknown";
// //       _deviceAddress = args['address'];
// //     });

// //     // FIX 4: REUSE the connection instead of killing it
// //     if (args.containsKey('connection') && args['connection'] != null) {
// //       BluetoothConnection passedConn = args['connection'];

// //       if (passedConn.isConnected) {
// //         setState(() {
// //           connection = passedConn;
// //           isConnectionInherited = true; // Mark as borrowed
// //           isConnecting = false;
// //         });
// //         _attachListener(); // Start listening
// //         return; // STOP here, don't try to connect again
// //       }
// //     }

// //     // Only connect fresh if no valid connection was passed
// //     _connectToDevice();
// //   }

// //   Future<void> _connectToDevice() async {
// //     try {
// //       BluetoothConnection newConnection = await BluetoothConnection.toAddress(
// //         _deviceAddress,
// //       );
// //       setState(() {
// //         connection = newConnection;
// //         isConnecting = false;
// //         isConnectionInherited = false;
// //       });
// //       _attachListener();
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => isConnecting = false);
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
// //       }
// //     }
// //   }

// //   void _attachListener() {
// //     // Cancel any existing subscription to avoid duplicates
// //     _streamSubscription?.cancel();

// //     if (isConnected && connection != null && connection!.input != null) {
// //       try {
// //         print("Attaching listener...");

// //         // Save the subscription to our variable
// //         _streamSubscription = connection!.input!.listen((Uint8List data) {
// //           String incomingData = String.fromCharCodes(data);
// //           if (incomingData.trim().isNotEmpty) {
// //             _addToDataStream(incomingData.trim(), "sensor");
// //           }
// //         });

// //         _streamSubscription!.onDone(() {
// //           if (mounted) {
// //             setState(() => isConnecting = false);
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               const SnackBar(content: Text('Device Disconnected')),
// //             );
// //           }
// //         });
// //       } catch (e) {
// //         print('Error attaching listener: $e');
// //       }
// //     }
// //   }

// //   void _sendCommand(String command) async {
// //     HapticFeedback.mediumImpact();
// //     _addToDataStream("TX: $command", "command");

// //     if (!isConnected) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Not connected'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     try {
// //       connection!.output.add(utf8.encode("$command\r\n"));
// //       await connection!.output.allSent;

// //       // Feedback logic...
// //       if (_tabController.index != 1) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Sent: $command'),
// //             duration: const Duration(milliseconds: 500),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Error: $e')));
// //     }
// //   }

// //   void _addToDataStream(String data, String type) {
// //     if (mounted) {
// //       setState(() {
// //         _dataStream.insert(0, {
// //           "timestamp": DateTime.now(),
// //           "data": data,
// //           "type": type,
// //         });
// //       });
// //     }
// //   }

// //   // --- Helper Functions ---
// //   void _addCustomCommand(Map<String, dynamic> command) {
// //     setState(() => _commands.add(command));
// //   }

// //   void _editCommand(int index) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => CommandEditorBottomSheet(
// //         command: _commands[index],
// //         onSave: (updated) {
// //           setState(() => _commands[index] = updated);
// //         },
// //       ),
// //     );
// //   }

// //   void _deleteCommand(int index) {
// //     setState(() => _commands.removeAt(index));
// //   }

// //   void _clearDataStream() {
// //     setState(() => _dataStream.clear());
// //   }

// //   Future<void> _exportDataStream() async {
// //     if (_dataStream.isEmpty) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text("No data to export!")));
// //       return;
// //     }
// //     try {
// //       String csvContent = "Timestamp,Type,Message\n";
// //       for (var log in _dataStream) {
// //         String cleanMessage = log['data'].toString().replaceAll(",", " ");
// //         csvContent += "${log['timestamp']},${log['type']},$cleanMessage\n";
// //       }
// //       final directory = await getTemporaryDirectory();
// //       final path =
// //           "${directory.path}/arduino_logs_${DateTime.now().millisecondsSinceEpoch}.csv";
// //       final file = File(path);
// //       await file.writeAsString(csvContent);
// //       await Share.shareXFiles([XFile(path)], text: 'Exported Arduino Logs');
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
// //     }
// //   }

// //   void _showCommandEditor() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => CommandEditorBottomSheet(onSave: _addCustomCommand),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

// //     return Scaffold(
// //       appBar: CustomControlPanelAppBar(
// //         deviceName: _deviceName,
// //         isConnected: isConnected,
// //         signalStrength: _signalStrength,
// //         actions: [
// //           IconButton(
// //             icon: CustomIconWidget(
// //               iconName: 'more_vert',
// //               color: theme.colorScheme.onSurface,
// //               size: 24,
// //             ),
// //             onPressed: () {},
// //           ),
// //         ],
// //       ),
// //       body: isConnecting
// //           ? const Center(child: CircularProgressIndicator())
// //           : Column(
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: theme.colorScheme.surface,
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: theme.colorScheme.shadow,
// //                         blurRadius: 4,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: TabBar(
// //                     controller: _tabController,
// //                     tabs: const [
// //                       Tab(text: 'Commands'),
// //                       Tab(text: 'Terminal'),
// //                       Tab(text: 'Data Monitor'),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: TabBarView(
// //                     controller: _tabController,
// //                     children: [
// //                       CommandsTabWidget(
// //                         commands: _commands,
// //                         onCommandTap: _sendCommand,
// //                         onCommandLongPress: _editCommand,
// //                         onCommandDelete: _deleteCommand,
// //                       ),
// //                       TerminalTabWidget(
// //                         messages: _dataStream,
// //                         onSendMessage: _sendCommand,
// //                       ),
// //                       DataMonitorTabWidget(
// //                         dataStream: _dataStream,
// //                         onClear: _clearDataStream,
// //                         onExport: _exportDataStream,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //       floatingActionButton: (_tabController.index == 0 && !isKeyboardOpen)
// //           ? FloatingActionButton.extended(
// //               onPressed: _showCommandEditor,
// //               icon: CustomIconWidget(
// //                 iconName: 'add',
// //                 color: theme.colorScheme.onPrimary,
// //                 size: 24,
// //               ),
// //               label: const Text('Add Command'),
// //             )
// //           : null,
// //     );
// //   }
// // }

import 'dart:convert';
import 'dart:async'; // Required for StreamSubscription
import 'dart:io';
import 'dart:typed_data';
import 'package:bluetooth_app/features/device_control_panel/widgets/terminal_tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/command_editor_bottom_sheet.dart';
import './widgets/commands_tab_widget.dart';
import './widgets/data_monitor_tab_widget.dart';

class DeviceControlPanel extends StatefulWidget {
  const DeviceControlPanel({super.key});

  @override
  State<DeviceControlPanel> createState() => _DeviceControlPanelState();
}

class _DeviceControlPanelState extends State<DeviceControlPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BluetoothConnection? connection;

  // FIX 1: We use a Subscription variable to manage the listener cleanly
  StreamSubscription<Uint8List>? _streamSubscription;

  bool isConnecting = true;
  bool isConnectionInherited = false;

  bool get isConnected => (connection?.isConnected ?? false);
  String _deviceName = "Connecting...";
  String _deviceAddress = "";
  final int _signalStrength = 85;

  final List<Map<String, dynamic>> _commands = [
    {
      "id": 1,
      "name": "LED On",
      "command": "1",
      "color": const Color(0xFF4CAF50),
      "icon": "lightbulb",
    },
    {
      "id": 2,
      "name": "LED Off",
      "command": "0",
      "color": const Color(0xFFF44336),
      "icon": "lightbulb_outline",
    },
  ];

  final List<Map<String, dynamic>> _dataStream = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild the UI when tab settles
      }
    });

    Future.delayed(Duration.zero, _setupConnection);
  }

  @override
  void dispose() {
    // FIX 2: STOP LISTENING when we leave this screen
    // This is crucial so the previous screen doesn't get confused
    _streamSubscription?.cancel();
    _streamSubscription = null;

    // FIX 3: If we borrowed the connection, DO NOT CLOSE IT.
    // We leave it open for the Main Screen.
    if (!isConnectionInherited) {
      connection?.dispose();
    }

    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setupConnection() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    setState(() {
      _deviceName = args['name'] ?? "Unknown";
      _deviceAddress = args['address'];
    });

    // FIX 4: CHECK & REUSE the passed connection (Don't kill it!)
    if (args.containsKey('connection') && args['connection'] != null) {
      BluetoothConnection passedConn = args['connection'];

      if (passedConn.isConnected) {
        setState(() {
          connection = passedConn;
          isConnectionInherited = true; // We are borrowing it
          isConnecting = false;
        });
        _attachListener(); // Start listening immediately
        return;
      }
    }

    // Only connect fresh if the passed connection was dead or missing
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    try {
      BluetoothConnection newConnection = await BluetoothConnection.toAddress(
        _deviceAddress,
      );
      setState(() {
        connection = newConnection;
        isConnecting = false;
        isConnectionInherited = false; // We created this one
      });
      _attachListener();
    } catch (e) {
      if (mounted) {
        setState(() => isConnecting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
      }
    }
  }

  void _attachListener() {
    // Cancel any old listener to avoid duplicates
    _streamSubscription?.cancel();

    if (isConnected && connection != null && connection!.input != null) {
      try {
        print("Attaching listener...");

        // Start Listening using Subscription
        _streamSubscription = connection!.input!.listen((Uint8List data) {
          String incomingData = String.fromCharCodes(data);
          // Check for data and update UI
          if (incomingData.trim().isNotEmpty) {
            _addToDataStream(incomingData.trim(), "sensor");
          }
        });

        // Handle Disconnect event
        _streamSubscription!.onDone(() {
          if (mounted) {
            setState(() => isConnecting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Device Disconnected')),
            );
          }
        });
      } catch (e) {
        print('Error attaching listener: $e');
      }
    }
  }

  // void _sendCommand(String command) async {
  //   HapticFeedback.mediumImpact();
  //   _addToDataStream("TX: $command", "command");

  //   if (!isConnected) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Not connected'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     connection!.output.add(utf8.encode("$command\r\n"));
  //     await connection!.output.allSent;

  //     // Feedback logic
  //     if (_tabController.index != 1) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Sent: $command'),
  //           duration: const Duration(milliseconds: 500),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  void _sendCommand(String command) async {
    HapticFeedback.mediumImpact();
    _addToDataStream("TX: $command", "command");

    if (!isConnected) {
      // FIX 1: Clear previous messages first
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500), // Keep it short
        ),
      );
      return;
    }

    try {
      connection!.output.add(utf8.encode("$command\r\n"));
      await connection!.output.allSent;

      // Feedback logic
      if (_tabController.index != 1) {
        // FIX 2: Clear queue before showing "Sent"
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent: $command'),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating, // Optional: Looks better
          ),
        );
      }
    } catch (e) {
      // FIX 3: Clear queue before showing Error
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addToDataStream(String data, String type) {
    if (mounted) {
      setState(() {
        _dataStream.insert(0, {
          "timestamp": DateTime.now(),
          "data": data,
          "type": type,
        });
      });
    }
  }

  // --- Helper Functions ---
  void _addCustomCommand(Map<String, dynamic> command) {
    setState(() => _commands.add(command));
  }

  void _editCommand(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommandEditorBottomSheet(
        command: _commands[index],
        onSave: (updated) {
          setState(() => _commands[index] = updated);
        },
      ),
    );
  }

  void _deleteCommand(int index) {
    setState(() => _commands.removeAt(index));
  }

  void _clearDataStream() {
    setState(() => _dataStream.clear());
  }
  // CSV FILE
  // Future<void> _exportDataStream() async {
  //   if (_dataStream.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("No data to export!")));
  //     return;
  //   }
  //   try {
  //     String csvContent = "Timestamp,Type,Message\n";
  //     for (var log in _dataStream) {
  //       String cleanMessage = log['data'].toString().replaceAll(",", " ");
  //       csvContent += "${log['timestamp']},${log['type']},$cleanMessage\n";
  //     }
  //     final directory = await getTemporaryDirectory();
  //     final path =
  //         "${directory.path}/arduino_logs_${DateTime.now().millisecondsSinceEpoch}.csv";
  //     final file = File(path);
  //     await file.writeAsString(csvContent);
  //     await Share.shareXFiles([XFile(path)], text: 'Exported Arduino Logs');
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
  //   }
  // }

  // TEXT FILE
  Future<void> _exportDataStream() async {
    if (_dataStream.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No data to export!")));
      return;
    }

    try {
      // 1. Use StringBuffer for better performance with large logs
      StringBuffer logContent = StringBuffer();

      // Add a nice header
      logContent.writeln("=== ARDUINO BLUETOOTH LOGS ===");
      logContent.writeln("Exported: ${DateTime.now().toString()}\n");
      logContent.writeln("----------------------------------------");

      // 2. Loop and format nicely
      for (var log in _dataStream) {
        String time = log['timestamp'].toString().split(
          '.',
        )[0]; // Remove milliseconds for cleaner look
        String type = log['type'].toString().toUpperCase(); // 'RX' or 'TX'
        String message = log['data'].toString();

        // Format: [2025-12-07 10:00:00] [RX] >> Hello World
        logContent.writeln("[$time] [$type] >> $message");
      }

      // 3. Save as .txt
      final directory = await getTemporaryDirectory();
      final fileName =
          "arduino_log_${DateTime.now().millisecondsSinceEpoch}.txt"; // <--- Changed extension
      final path = "${directory.path}/$fileName";

      final file = File(path);
      await file.writeAsString(logContent.toString());

      // 4. Share text file
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Here are the Arduino logs.',
        subject: 'Arduino Bluetooth Logs',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  void _showCommandEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommandEditorBottomSheet(onSave: _addCustomCommand),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: CustomControlPanelAppBar(
        deviceName: _deviceName,
        isConnected: isConnected,
        signalStrength: _signalStrength,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: isConnecting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Commands'),
                      Tab(text: 'Terminal'),
                      Tab(text: 'Data Monitor'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      CommandsTabWidget(
                        commands: _commands,
                        onCommandTap: _sendCommand,
                        onCommandLongPress: _editCommand,
                        onCommandDelete: _deleteCommand,
                      ),
                      TerminalTabWidget(
                        messages: _dataStream,
                        onSendMessage: _sendCommand,
                      ),
                      DataMonitorTabWidget(
                        dataStream: _dataStream,
                        onClear: _clearDataStream,
                        onExport: _exportDataStream,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: (_tabController.index == 0 && !isKeyboardOpen)
          ? FloatingActionButton.extended(
              onPressed: _showCommandEditor,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              label: const Text('Add Command'),
            )
          : null,
    );
  }
}
