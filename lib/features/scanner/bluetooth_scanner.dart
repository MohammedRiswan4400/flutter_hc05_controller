// import 'dart:async';
// import 'package:bluetooth_app/features/scanner/widgets/connection_feedback_sheet.dart';
// import 'package:bluetooth_app/features/scanner/widgets/discovered_device_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sizer/sizer.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with WidgetsBindingObserver {
//   // --- State Variables ---
//   // List to hold unique devices found during scan or from paired list
//   List<BluetoothDiscoveryResult> _results = [];

//   // Stream to listen to the continuous flow of found devices
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

//   // Timer to force-stop scanning after 15 seconds (prevents infinite loading)
//   Timer? _discoveryTimer;

//   bool _isDiscovering = false;

//   // --- Permission & System Status Variables ---
//   bool _isBluetoothPermissionGranted = false;
//   bool _isLocationPermissionGranted = false;
//   bool _isLocationServicesEnabled = false;
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

//   @override
//   void initState() {
//     super.initState();
//     // Observer to detect when user returns from System Settings
//     WidgetsBinding.instance.addObserver(this);

//     // Step 1: Run a full check of Permissions and GPS immediately
//     _checkAllPermissionsAndServices();

//     // Step 2: Get current Bluetooth Power State (On/Off)
//     FlutterBluetoothSerial.instance.state.then((state) {
//       if (mounted) setState(() => _bluetoothState = state);
//     });

//     // Step 3: Listen for live changes to Bluetooth Power (e.g. User toggles it in Control Center)
//     FlutterBluetoothSerial.instance.onStateChanged().listen((
//       BluetoothState state,
//     ) {
//       if (mounted) {
//         setState(() {
//           _bluetoothState = state;
//           // Safety: If user turns off BT, stop any active scan immediately
//           if (_bluetoothState == BluetoothState.STATE_OFF)
//             _stopDiscoveryInternal();
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     // Clean up observers and timers to prevent memory leaks
//     WidgetsBinding.instance.removeObserver(this);
//     _discoveryTimer?.cancel();
//     _streamSubscription?.cancel();
//     super.dispose();
//   }

//   // Reload permissions when app comes back to foreground
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkAllPermissionsAndServices();
//     }
//   }

//   // --- 1. Master Check Function ---
//   // Checks all 3 critical requirements: BT Permission, Loc Permission, GPS Service
//   Future<void> _checkAllPermissionsAndServices() async {
//     final btConnect = await Permission.bluetoothConnect.status;
//     final btScan = await Permission.bluetoothScan.status;
//     final locPerm = await Permission.location.status;
//     final locService =
//         await Permission.location.serviceStatus; // Checks if GPS toggle is ON

//     if (mounted) {
//       setState(() {
//         _isBluetoothPermissionGranted = btConnect.isGranted && btScan.isGranted;
//         _isLocationPermissionGranted = locPerm.isGranted;
//         _isLocationServicesEnabled = locService.isEnabled;
//       });
//     }
//   }

//   // --- Actions for Error States ---
//   Future<void> _requestBluetoothPermissions() async {
//     // Request all related permissions at once
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//     ].request();
//     await _checkAllPermissionsAndServices();
//   }

//   Future<void> _requestLocationPermission() async {
//     await Permission.location.request();
//     await _checkAllPermissionsAndServices();
//   }

//   Future<void> _openLocationSettings() async {
//     await openAppSettings(); // Send user to settings to flip the switch
//   }

//   Future<void> _enableBluetooth() async {
//     await FlutterBluetoothSerial.instance
//         .requestEnable(); // Android Native Dialog
//   }

//   // --- 2. Scanning Logic (The Core Feature) ---
//   void _startDiscovery() {
//     if (_isDiscovering) return; // Prevent double-clicks
//     HapticFeedback.mediumImpact();

//     setState(() {
//       _results.clear(); // Clear old list
//       _isDiscovering = true;
//     });

//     // --- PHASE A: Load Paired Devices (The "Golden Path") ---
//     // We load bonded devices first because they often don't show up in scans
//     FlutterBluetoothSerial.instance.getBondedDevices().then((bondedDevices) {
//       if (mounted) {
//         setState(() {
//           for (var device in bondedDevices) {
//             // FILTER: Only show device if it is NOT connected
//             // Note: This checks if *this app* is connected to it.
//             if (!device.isConnected) {
//               _results.add(
//                 BluetoothDiscoveryResult(
//                   device: device,
//                   rssi:
//                       -50, // Fake RSSI for paired devices (they don't broadcast it)
//                 ),
//               );
//             }
//           }
//         });
//       }
//     });

//     // --- PHASE B: Scan for New/Unpaired Devices ---
//     try {
//       _streamSubscription = FlutterBluetoothSerial.instance
//           .startDiscovery()
//           .listen((r) {
//             if (mounted) {
//               setState(() {
//                 // 1. Filter: Check if device is already in list (avoid duplicates)
//                 final index = _results.indexWhere(
//                   (e) => e.device.address == r.device.address,
//                 );

//                 // 2. Filter: Skip if device is currently connected
//                 if (r.device.isConnected) return;

//                 if (index >= 0) {
//                   _results[index] = r; // Update existing (e.g. new RSSI value)
//                 } else {
//                   _results.add(r); // Add new found device
//                 }
//               });
//             }
//           });

//       // Handle scan completion
//       _streamSubscription!.onDone(() => _finalizeDiscovery());

//       // --- PHASE C: Safety Timer ---
//       // Force-stop scanning after 15 seconds (Fixes "Infinite Spinner" bug on some phones)
//       _discoveryTimer?.cancel();
//       _discoveryTimer = Timer(const Duration(seconds: 15), () {
//         if (_isDiscovering) {
//           _stopDiscoveryInternal();
//           _finalizeDiscovery();
//         }
//       });
//     } catch (e) {
//       print("Error starting scan: $e");
//       _stopDiscoveryInternal();
//     }
//   }

//   // Internal helper to kill streams
//   void _stopDiscoveryInternal() {
//     _streamSubscription?.cancel();
//     FlutterBluetoothSerial.instance.cancelDiscovery();
//     if (mounted) setState(() => _isDiscovering = false);
//   }

//   // Called when scan finishes naturally or by timer
//   void _finalizeDiscovery() {
//     if (mounted) {
//       setState(() => _isDiscovering = false);
//       if (_results.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text(
//               "No devices found. Ensure GPS is ON and device is in range.",
//             ),
//             action: SnackBarAction(
//               label: 'Check Settings',
//               onPressed: _openLocationSettings,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   // --- 3. Connecting Logic ---
//   Future<void> _pairAndConnect(BluetoothDevice device) async {
//     // Show visual feedback
//     ConnectionFeedbackSheet.show(
//       context,
//       status: ConnectionStatus.connecting,
//       deviceName: device.name ?? "Unknown",
//       onAction: () {},
//     );

//     try {
//       bool bonded = false;
//       // Check if already paired
//       if (device.isBonded) {
//         bonded = true;
//       } else {
//         // Attempt to pair (pop up PIN dialog)
//         bonded =
//             (await FlutterBluetoothSerial.instance.bondDeviceAtAddress(
//               device.address,
//             )) ??
//             false;
//       }

//       // If paired successfully, Navigate!
//       if (bonded && mounted) {
//         Navigator.pop(context); // Close sheet
//         ConnectionFeedbackSheet.show(
//           context,
//           status: ConnectionStatus.success,
//           deviceName: device.name ?? "Unknown",
//           onAction: () {
//             // Switch to "Connected" tab (Index 1)
//             DefaultTabController.of(context).animateTo(1);
//           },
//         );
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context); // Close sheet on error
//       print("Connection Error: $e");
//     }
//   }

//   // --- 4. Build UI (View Controller) ---
//   @override
//   Widget build(BuildContext context) {
//     // A. Check Bluetooth Permissions
//     if (!_isBluetoothPermissionGranted) {
//       return _buildErrorState(
//         icon: Icons.bluetooth_disabled,
//         color: Colors.orange,
//         title: "Bluetooth Permission",
//         desc: "We need Bluetooth permission to scan for devices.",
//         btnText: "Grant Bluetooth",
//         onTap: _requestBluetoothPermissions,
//       );
//     }

//     // B. Check Location Permission (REQUIRED for Android Scanning)
//     if (!_isLocationPermissionGranted) {
//       return _buildErrorState(
//         icon: Icons.location_disabled,
//         color: Colors.red,
//         title: "Location Permission",
//         desc: "Android requires Location permission to find nearby devices.",
//         btnText: "Grant Location",
//         onTap: _requestLocationPermission,
//       );
//     }

//     // C. Check if GPS is physically ON (The "Hidden" Requirement)
//     if (!_isLocationServicesEnabled) {
//       return _buildErrorState(
//         icon: Icons.gps_off,
//         color: Colors.red,
//         title: "GPS is Off",
//         desc: "Please turn on Location (GPS) in your control center to scan.",
//         btnText: "Open Settings",
//         onTap: _openLocationSettings,
//       );
//     }

//     // D. Check if Bluetooth is physically ON
//     if (_bluetoothState == BluetoothState.STATE_OFF) {
//       return _buildErrorState(
//         icon: Icons.bluetooth_disabled,
//         color: Colors.blue,
//         title: "Bluetooth is Off",
//         desc: "Please enable Bluetooth to start scanning.",
//         btnText: "Turn On Bluetooth",
//         onTap: _enableBluetooth,
//       );
//     }

//     // E. Empty State (Before first scan)
//     if (_results.isEmpty && !_isDiscovering) {
//       return _buildStartScanUI();
//     }

//     // F. Success State (List of Devices)
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isDiscovering ? null : _startDiscovery,
//         backgroundColor: _isDiscovering
//             ? Colors.grey
//             : Theme.of(context).primaryColor,
//         child: _isDiscovering
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : const Icon(Icons.refresh),
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
//         itemCount: _results.length,
//         itemBuilder: (context, index) {
//           final result = _results[index];
//           return DiscoveredDeviceCard(
//             device: {
//               'name': result.device.name ?? "Unknown",
//               'address': result.device.address,
//               'rssi': result.rssi,
//               'type': result.device.type == BluetoothDeviceType.classic
//                   ? 'Classic'
//                   : 'BLE',
//               'isBonded': result.device.isBonded,
//             },
//             onConnect: () => _pairAndConnect(result.device),
//           );
//         },
//       ),
//     );
//   }

//   // Reusable Error Widget to keep code clean
//   Widget _buildErrorState({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String desc,
//     required String btnText,
//     required VoidCallback onTap,
//   }) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(4.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 15.w, color: color),
//             SizedBox(height: 3.h),
//             Text(
//               title,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               desc,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 4.h),
//             ElevatedButton(
//               onPressed: onTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: color,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
//               ),
//               child: Text(btnText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStartScanUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.bluetooth_searching,
//             size: 15.w,
//             color: Theme.of(context).primaryColor,
//           ),
//           SizedBox(height: 3.h),
//           const Text(
//             "Ready to Scan",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           SizedBox(height: 4.h),
//           ElevatedButton.icon(
//             onPressed: _startDiscovery,
//             icon: const Icon(Icons.search),
//             label: const Text("Start Scanning"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:bluetooth_app/features/scanner/widgets/connection_feedback_sheet.dart';
import 'package:bluetooth_app/features/scanner/widgets/discovered_device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class ScannerScreen extends StatefulWidget {
  final VoidCallback onConnectionSuccess;

  const ScannerScreen({super.key, required this.onConnectionSuccess});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  List<BluetoothDiscoveryResult> _results = [];
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  Timer? _discoveryTimer;
  bool _isDiscovering = false;

  // Permissions
  bool _isBluetoothPermissionGranted = false;
  bool _isLocationPermissionGranted = false;
  bool _isLocationServicesEnabled = false;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissionsAndServices();

    FlutterBluetoothSerial.instance.state.then((state) {
      if (mounted) setState(() => _bluetoothState = state);
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      if (mounted) {
        setState(() {
          _bluetoothState = state;
          if (_bluetoothState == BluetoothState.STATE_OFF)
            _stopDiscoveryInternal();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discoveryTimer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissionsAndServices();
    }
  }

  Future<void> _checkAllPermissionsAndServices() async {
    final btConnect = await Permission.bluetoothConnect.status;
    final btScan = await Permission.bluetoothScan.status;
    final locPerm = await Permission.location.status;
    final locService = await Permission.location.serviceStatus;

    if (mounted) {
      setState(() {
        _isBluetoothPermissionGranted = btConnect.isGranted && btScan.isGranted;
        _isLocationPermissionGranted = locPerm.isGranted;
        _isLocationServicesEnabled = locService.isEnabled;
      });
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    await _checkAllPermissionsAndServices();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
    await _checkAllPermissionsAndServices();
  }

  Future<void> _openLocationSettings() async {
    await openAppSettings();
  }

  Future<void> _enableBluetooth() async {
    await FlutterBluetoothSerial.instance.requestEnable();
  }

  // --- SCANNING LOGIC (Strict Filter for NEW Devices) ---
  void _startDiscovery() {
    if (_isDiscovering) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _results.clear();
      _isDiscovering = true;
    });

    try {
      _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((
        r,
      ) {
        if (mounted) {
          setState(() {
            // 1. Filter: Check if device is already in list (avoid duplicates)
            final index = _results.indexWhere(
              (e) => e.device.address == r.device.address,
            );

            // 2. FILTER: Only show UNPAIRED (New) devices
            // If device.isBonded is true, it means it's already paired/saved.
            if (r.device.isBonded) return;

            if (index >= 0) {
              _results[index] = r;
            } else {
              _results.add(r);
            }
          });
        }
      });

      _streamSubscription!.onDone(() => _finalizeDiscovery());

      _discoveryTimer?.cancel();
      _discoveryTimer = Timer(const Duration(seconds: 15), () {
        if (_isDiscovering) {
          _stopDiscoveryInternal();
          _finalizeDiscovery();
        }
      });
    } catch (e) {
      _stopDiscoveryInternal();
    }
  }

  void _stopDiscoveryInternal() {
    _streamSubscription?.cancel();
    FlutterBluetoothSerial.instance.cancelDiscovery();
    if (mounted) setState(() => _isDiscovering = false);
  }

  void _finalizeDiscovery() {
    if (mounted) {
      setState(() => _isDiscovering = false);
      if (_results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("No new devices found."),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: _openLocationSettings,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pairAndConnect(BluetoothDevice device) async {
    ConnectionFeedbackSheet.show(
      context,
      status: ConnectionStatus.connecting,
      deviceName: device.name ?? "Unknown",
      onAction: () {},
    );

    try {
      bool bonded = false;
      if (device.isBonded) {
        bonded = true;
      } else {
        bonded =
            (await FlutterBluetoothSerial.instance.bondDeviceAtAddress(
              device.address,
            )) ??
            false;
      }

      if (bonded && mounted) {
        Navigator.pop(context); // Close sheet
        ConnectionFeedbackSheet.show(
          context,
          status: ConnectionStatus.success,
          deviceName: device.name ?? "Unknown",
          onAction: () {
            widget.onConnectionSuccess();
          },
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    if (!_isBluetoothPermissionGranted)
      return _buildErrorState(
        icon: Icons.bluetooth_disabled,
        color: Colors.orange,
        title: "Bluetooth Permission",
        desc: "Required to scan.",
        btnText: "Grant Bluetooth",
        onTap: _requestBluetoothPermissions,
      );
    if (!_isLocationPermissionGranted)
      return _buildErrorState(
        icon: Icons.location_disabled,
        color: Colors.red,
        title: "Location Permission",
        desc: "Required to find devices.",
        btnText: "Grant Location",
        onTap: _requestLocationPermission,
      );
    if (!_isLocationServicesEnabled)
      return _buildErrorState(
        icon: Icons.gps_off,
        color: Colors.red,
        title: "GPS is Off",
        desc: "Please turn on GPS.",
        btnText: "Open Settings",
        onTap: _openLocationSettings,
      );
    if (_bluetoothState == BluetoothState.STATE_OFF)
      return _buildErrorState(
        icon: Icons.bluetooth_disabled,
        color: Colors.blue,
        title: "Bluetooth is Off",
        desc: "Enable Bluetooth to scan.",
        btnText: "Turn On",
        onTap: _enableBluetooth,
      );

    if (_results.isEmpty && !_isDiscovering) {
      return _buildStartScanUI();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _isDiscovering ? null : _startDiscovery,
        backgroundColor: _isDiscovering
            ? Colors.grey
            : Theme.of(context).primaryColor,
        child: _isDiscovering
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Icon(Icons.refresh),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Row(
              children: [
                Text(
                  "New Devices",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_results.length}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return DiscoveredDeviceCard(
                  device: {
                    'name': result.device.name ?? "Unknown",
                    'address': result.device.address,
                    'rssi': result.rssi,
                    'type': result.device.type == BluetoothDeviceType.classic
                        ? 'Classic'
                        : 'BLE',
                  },
                  onConnect: () => _pairAndConnect(result.device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String btnText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(desc),
          SizedBox(height: 20),
          ElevatedButton(onPressed: onTap, child: Text(btnText)),
        ],
      ),
    );
  }

  Widget _buildStartScanUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 15.w,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 3.h),
          const Text(
            "Ready to Scan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _startDiscovery,
            icon: const Icon(Icons.search),
            label: const Text("Start Scanning"),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sizer/sizer.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with WidgetsBindingObserver {
//   // --- State Variables ---
//   List<BluetoothDiscoveryResult> _results = [];
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   Timer? _discoveryTimer;
//   bool _isDiscovering = false;

//   // Status Checks
//   bool _isBluetoothPermissionGranted = false;
//   bool _isLocationPermissionGranted = false;
//   bool _isLocationServicesEnabled = false;
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(
//       this,
//     ); // Detect when user comes back from Settings
//     _checkAllPermissionsAndServices();

//     // Listen for Bluetooth Power State
//     FlutterBluetoothSerial.instance.state.then((state) {
//       if (mounted) setState(() => _bluetoothState = state);
//     });
//     FlutterBluetoothSerial.instance.onStateChanged().listen((
//       BluetoothState state,
//     ) {
//       if (mounted) {
//         setState(() {
//           _bluetoothState = state;
//           if (_bluetoothState == BluetoothState.STATE_OFF)
//             _stopDiscoveryInternal();
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _discoveryTimer?.cancel();
//     _streamSubscription?.cancel();
//     super.dispose();
//   }

//   // Detect when user returns to app (to re-check settings automatically)
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkAllPermissionsAndServices();
//     }
//   }

//   // --- 1. Master Check Function ---
//   Future<void> _checkAllPermissionsAndServices() async {
//     // A. Check Permissions
//     final btConnect = await Permission.bluetoothConnect.status;
//     final btScan = await Permission.bluetoothScan.status;
//     final locPerm = await Permission.location.status;

//     // B. Check Location Service (GPS)
//     final locService = await Permission.location.serviceStatus;

//     if (mounted) {
//       setState(() {
//         _isBluetoothPermissionGranted = btConnect.isGranted && btScan.isGranted;
//         _isLocationPermissionGranted = locPerm.isGranted;
//         _isLocationServicesEnabled = locService.isEnabled;
//       });
//     }
//   }

//   // --- Actions ---
//   Future<void> _requestBluetoothPermissions() async {
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//     ].request();
//     await _checkAllPermissionsAndServices();
//   }

//   Future<void> _requestLocationPermission() async {
//     await Permission.location.request();
//     await _checkAllPermissionsAndServices();
//   }

//   Future<void> _openLocationSettings() async {
//     // Opens App Settings so user can toggle permissions or find Location
//     await openAppSettings();
//     // Note: User has to manually turn on GPS in Quick Settings mostly
//   }

//   Future<void> _enableBluetooth() async {
//     await FlutterBluetoothSerial.instance.requestEnable();
//   }

//   // --- 2. Scanning Logic (Updated) ---
//   void _startDiscovery() {
//     if (_isDiscovering) return;
//     HapticFeedback.mediumImpact();

//     setState(() {
//       _results.clear();
//       _isDiscovering = true;
//     });

//     // Step A: Add Paired Devices
//     FlutterBluetoothSerial.instance.getBondedDevices().then((bondedDevices) {
//       if (mounted) {
//         setState(() {
//           for (var device in bondedDevices) {
//             _results.add(BluetoothDiscoveryResult(device: device, rssi: -50));
//           }
//         });
//       }
//     });

//     // Step B: Scan
//     try {
//       _streamSubscription = FlutterBluetoothSerial.instance
//           .startDiscovery()
//           .listen((r) {
//             if (mounted) {
//               setState(() {
//                 final index = _results.indexWhere(
//                   (e) => e.device.address == r.device.address,
//                 );
//                 if (index >= 0) {
//                   _results[index] = r;
//                 } else {
//                   _results.add(r);
//                 }
//               });
//             }
//           });

//       _streamSubscription!.onDone(() => _finalizeDiscovery());

//       _discoveryTimer?.cancel();
//       _discoveryTimer = Timer(const Duration(seconds: 15), () {
//         if (_isDiscovering) {
//           _stopDiscoveryInternal();
//           _finalizeDiscovery();
//         }
//       });
//     } catch (e) {
//       _stopDiscoveryInternal();
//     }
//   }

//   void _stopDiscoveryInternal() {
//     _streamSubscription?.cancel();
//     FlutterBluetoothSerial.instance.cancelDiscovery();
//     if (mounted) setState(() => _isDiscovering = false);
//   }

//   void _finalizeDiscovery() {
//     if (mounted) {
//       setState(() => _isDiscovering = false);
//       if (_results.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("No devices found. Ensure GPS is ON."),
//             action: SnackBarAction(
//               label: 'Settings',
//               onPressed: _openLocationSettings,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _pairAndConnect(BluetoothDevice device) async {
//     // ... (Keep your existing pairing logic unchanged) ...
//     ConnectionFeedbackSheet.show(
//       context,
//       status: ConnectionStatus.connecting,
//       deviceName: device.name ?? "Unknown",
//       onAction: () {},
//     );
//     // ... For brevity, pasting the essential bond check ...
//     try {
//       bool bonded = false;
//       if (device.isBonded) {
//         bonded = true;
//       } else {
//         bonded =
//             (await FlutterBluetoothSerial.instance.bondDeviceAtAddress(
//               device.address,
//             )) ??
//             false;
//       }
//       if (bonded && mounted) {
//         Navigator.pop(context);
//         ConnectionFeedbackSheet.show(
//           context,
//           status: ConnectionStatus.success,
//           deviceName: device.name ?? "Unknown",
//           onAction: () => DefaultTabController.of(context).animateTo(1),
//         );
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   // --- 3. Build UI ---
//   @override
//   Widget build(BuildContext context) {
//     // 1. Bluetooth Permissions
//     if (!_isBluetoothPermissionGranted) {
//       return _buildErrorState(
//         icon: Icons.bluetooth_disabled,
//         color: Colors.orange,
//         title: "Bluetooth Permission",
//         desc: "We need Bluetooth permission to scan.",
//         btnText: "Grant Bluetooth",
//         onTap: _requestBluetoothPermissions,
//       );
//     }

//     // 2. Location Permission (The Button You Asked For)
//     if (!_isLocationPermissionGranted) {
//       return _buildErrorState(
//         icon: Icons.location_disabled,
//         color: Colors.red,
//         title: "Location Permission",
//         desc: "Android requires Location permission to find devices.",
//         btnText: "Grant Location",
//         onTap: _requestLocationPermission,
//       );
//     }

//     // 3. Location Service / GPS (The likely Fix)
//     if (!_isLocationServicesEnabled) {
//       return _buildErrorState(
//         icon: Icons.gps_off,
//         color: Colors.red,
//         title: "GPS is Off",
//         desc: "Please turn on Location (GPS) in your control center.",
//         btnText: "Open Settings",
//         onTap: _openLocationSettings,
//       );
//     }

//     // 4. Bluetooth Power
//     if (_bluetoothState == BluetoothState.STATE_OFF) {
//       return _buildErrorState(
//         icon: Icons.bluetooth_disabled,
//         color: Colors.blue,
//         title: "Bluetooth is Off",
//         desc: "Please enable Bluetooth to scan.",
//         btnText: "Turn On Bluetooth",
//         onTap: _enableBluetooth,
//       );
//     }

//     // 5. Ready / Scanning
//     if (_results.isEmpty && !_isDiscovering) {
//       return _buildStartScanUI();
//     }

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isDiscovering ? null : _startDiscovery,
//         backgroundColor: _isDiscovering
//             ? Colors.grey
//             : Theme.of(context).primaryColor,
//         child: _isDiscovering
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : const Icon(Icons.refresh),
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
//         itemCount: _results.length,
//         itemBuilder: (context, index) {
//           final result = _results[index];
//           return DiscoveredDeviceCard(
//             device: {
//               'name': result.device.name ?? "Unknown",
//               'address': result.device.address,
//               'rssi': result.rssi,
//               'type': result.device.type == BluetoothDeviceType.classic
//                   ? 'Classic'
//                   : 'BLE',
//             },
//             onConnect: () => _pairAndConnect(result.device),
//           );
//         },
//       ),
//     );
//   }

//   // Helper for Error States
//   Widget _buildErrorState({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String desc,
//     required String btnText,
//     required VoidCallback onTap,
//   }) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(4.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 15.w, color: color),
//             SizedBox(height: 3.h),
//             Text(
//               title,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               desc,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 4.h),
//             ElevatedButton(
//               onPressed: onTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: color,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
//               ),
//               child: Text(btnText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStartScanUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.bluetooth_searching,
//             size: 15.w,
//             color: Theme.of(context).primaryColor,
//           ),
//           SizedBox(height: 3.h),
//           const Text(
//             "Ready to Scan",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           SizedBox(height: 4.h),
//           ElevatedButton.icon(
//             onPressed: _startDiscovery,
//             icon: const Icon(Icons.search),
//             label: const Text("Start Scanning"),
//           ),
//         ],
//       ),
//     );
//   }
// }
