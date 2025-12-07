import 'package:bluetooth_app/features/bluetooth_permission_request/bluetooth_permission_request.dart';
import 'package:bluetooth_app/features/connected_devices/connected_devices.dart';
import 'package:bluetooth_app/features/device_control_panel/device_control_panel.dart';
import 'package:bluetooth_app/features/main_tab/main_tab.dart';
import 'package:bluetooth_app/features/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String initial = '/';
  static const String bluetoothPermissionRequest =
      '/bluetooth-permission-request';
  static const String splash = '/splash-screen';
  static const String connectedDevices = '/connected-devices';
  static const String mainTab = '/main-tab';
  static const String deviceControlPanel = '/device-control-panel';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    bluetoothPermissionRequest: (context) => const BluetoothPermissionRequest(),
    splash: (context) => const SplashScreen(),
    mainTab: (context) => const MainTabScreen(),

    connectedDevices: (context) => ConnectedDevicesTab(onRequestScan: () {}),
    deviceControlPanel: (context) => const DeviceControlPanel(),
  };
}
