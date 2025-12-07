import 'package:bluetooth_app/features/connected_devices/connected_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_icon_widget.dart';
// Import your screens
import '../../features/scanner/bluetooth_scanner.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller for 3 tabs, starting at 'Connected' (Index 1)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Navigation Helpers ---
  void _goToConnectedTab() {
    _tabController.animateTo(1);
  }

  void _goToScannerTab() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Manager'),
        elevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(
            colorScheme.primary.withOpacity(0.1),
          ),
          onTap: (index) {
            HapticFeedback.selectionClick();
            if (index == 2) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon')),
              );
            }
          },
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'bluetooth_searching',
                size: 5.w,
              ),
              text: 'Scanner',
            ),
            Tab(
              icon: CustomIconWidget(iconName: 'devices', size: 5.w),
              text: 'Connected',
            ),
            Tab(
              icon: CustomIconWidget(iconName: 'history', size: 5.w),
              text: 'History',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- TAB 1: Scanner ---
          ScannerScreen(
            onConnectionSuccess: _goToConnectedTab, // Callback to switch tab
          ),

          // --- TAB 2: Connected Devices ---
          ConnectedDevicesTab(
            onRequestScan: _goToScannerTab, // Callback to switch tab
          ),

          // --- TAB 3: History ---
          const SizedBox(),
        ],
      ),
    );
  }
}
