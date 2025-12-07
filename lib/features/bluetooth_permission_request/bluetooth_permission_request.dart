import 'dart:io';
import 'dart:async';

import 'package:bluetooth_app/core/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/permission_explanation_sheet.dart';
import './widgets/permission_item_widget.dart';

class BluetoothPermissionRequest extends StatefulWidget {
  const BluetoothPermissionRequest({super.key});

  @override
  State<BluetoothPermissionRequest> createState() =>
      _BluetoothPermissionRequestState();
}

class _BluetoothPermissionRequestState extends State<BluetoothPermissionRequest>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Permission states
  bool _isBluetoothPermGranted = false;
  bool _isLocationPermGranted = false;
  // bool _isStoragePermGranted = false; // REMOVED: Not needed for core flow

  // Service states (Hardware toggles)
  bool _isBluetoothEnabled = false;
  bool _isLocationEnabled = false;

  bool _isLoading = false;
  bool _allPermissionsGranted = false;

  // Animation controllers
  late AnimationController _illustrationController;
  late AnimationController _successController;
  late Animation<double> _illustrationAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkAllPermissionsAndServices();

    FlutterBluetoothSerial.instance.onStateChanged().listen((
      BluetoothState state,
    ) {
      if (mounted) {
        setState(() {
          _isBluetoothEnabled = state == BluetoothState.STATE_ON;
          _updateAllPermissionsGrantedStatus();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _illustrationController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissionsAndServices();
    }
  }

  void _initializeAnimations() {
    _illustrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _illustrationAnimation = CurvedAnimation(
      parent: _illustrationController,
      curve: Curves.easeInOut,
    );
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _illustrationController.forward();
  }

  // --- 1. FIXED CHECK LOGIC ---
  Future<void> _checkAllPermissionsAndServices() async {
    // 1. Check Permissions
    if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.status;
      final locationStatus = await Permission.locationWhenInUse.status;
      _isBluetoothPermGranted = bluetoothStatus.isGranted;
      _isLocationPermGranted = locationStatus.isGranted;
    } else {
      final btConnect = await Permission.bluetoothConnect.status;
      final btScan = await Permission.bluetoothScan.status;
      final loc = await Permission.location.status;

      // Removed Storage check here because it fails on Android 13+
      // and blocks the app even if BT/Loc are fine.
      _isBluetoothPermGranted = btConnect.isGranted && btScan.isGranted;
      _isLocationPermGranted = loc.isGranted;
    }

    // 2. Check Services (Hardware)
    final btState = await FlutterBluetoothSerial.instance.state;
    _isBluetoothEnabled = btState == BluetoothState.STATE_ON;

    final locService = await Permission.location.serviceStatus;
    _isLocationEnabled = locService.isEnabled;

    _updateAllPermissionsGrantedStatus();
  }

  void _updateAllPermissionsGrantedStatus() {
    final permissionsOK = _isBluetoothPermGranted && _isLocationPermGranted;
    final servicesOK = _isBluetoothEnabled && _isLocationEnabled;

    setState(() {
      // FIX: Only require BT + Location + Hardware
      _allPermissionsGranted = permissionsOK && servicesOK;
    });

    if (_allPermissionsGranted) {
      _triggerSuccessAnimation();
    }
  }

  // --- 2. FIXED REQUEST LOGIC ---
  Future<void> _handleGrantPermissions() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (Platform.isIOS) {
        await [Permission.bluetooth, Permission.locationWhenInUse].request();
      } else {
        await [
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.location,
          // Removed Permission.storage here too
        ].request();
      }

      await _checkAllPermissionsAndServices();

      // Try to enable Bluetooth if permissions are ok but it's off
      if (_isBluetoothPermGranted && !_isBluetoothEnabled) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      await _checkAllPermissionsAndServices();

      if (_allPermissionsGranted) {
        // Animation will trigger via _updateAllPermissionsGrantedStatus
      } else {
        if (!_isBluetoothEnabled || !_isLocationEnabled) {
          _showErrorSnackBar(
            'Please enable Bluetooth and Location/GPS in your Quick Settings.',
          );
        } else if (!_isBluetoothPermGranted || !_isLocationPermGranted) {
          _showErrorSnackBar(
            'Permissions denied. Please enable them in Settings.',
          );
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerSuccessAnimation() {
    HapticFeedback.heavyImpact();
    _successController.forward();
  }

  void _showLearnMoreSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PermissionExplanationSheet(),
    );
  }

  void _openAppSettings() async {
    HapticFeedback.lightImpact();
    await openAppSettings();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Bluetooth Access',
        variant: CustomAppBarVariant.standard,
      ),
      body: SafeArea(
        child: _allPermissionsGranted
            ? _buildSuccessState(theme)
            : _buildPermissionRequestState(theme),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    LocalStorageService.setPermissionGranted(true);
    gotoScreens();

    return Center(
      child: ScaleTransition(
        scale: _successAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                size: 80,
                color: const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'All Set!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Permissions & Services ready',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future gotoScreens() async {
    await Future.delayed(const Duration(seconds: 2));
    // Ensure this route exists in your main.dart
    if (mounted) Navigator.pushReplacementNamed(context, '/main-tab');
  }

  Widget _buildPermissionRequestState(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          _buildIllustration(theme),
          SizedBox(height: 32),
          _buildHeading(theme),
          SizedBox(height: 16),
          _buildPermissionsList(theme),
          SizedBox(height: 32),
          _buildActionButtons(theme),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return FadeTransition(
      opacity: _illustrationAnimation,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomIconWidget(
              iconName: 'bluetooth',
              size: 80,
              color: theme.colorScheme.primary,
            ),
            Positioned(
              top: 40,
              right: 40,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'smartphone',
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'headset',
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Enable Bluetooth Access',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'We need permissions & active services to connect with devices',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPermissionsList(ThemeData theme) {
    return Column(
      children: [
        PermissionItemWidget(
          icon: 'bluetooth',
          title: 'Bluetooth Permission',
          description: 'Required for app to use Bluetooth',
          isGranted: _isBluetoothPermGranted,
          onRetry: null,
        ),
        SizedBox(height: 12),

        PermissionItemWidget(
          icon: _isBluetoothEnabled
              ? 'bluetooth_connected'
              : 'bluetooth_disabled',
          title: 'Bluetooth Adapter',
          description: _isBluetoothEnabled
              ? 'Bluetooth is ON'
              : 'Please turn Bluetooth ON',
          isGranted: _isBluetoothEnabled,
          onRetry: (_isBluetoothPermGranted && !_isBluetoothEnabled)
              ? () async {
                  await FlutterBluetoothSerial.instance.requestEnable();
                }
              : null,
        ),
        SizedBox(height: 12),

        PermissionItemWidget(
          icon: 'location_on',
          title: 'Location Permission',
          description: 'Required to scan for devices',
          isGranted: _isLocationPermGranted,
          onRetry: null,
        ),
        SizedBox(height: 12),

        PermissionItemWidget(
          icon: _isLocationEnabled ? 'gps_fixed' : 'gps_off',
          title: 'Location Service (GPS)',
          description: _isLocationEnabled
              ? 'GPS is ON'
              : 'Please enable GPS/Location',
          isGranted: _isLocationEnabled,
          onRetry: (_isLocationPermGranted && !_isLocationEnabled)
              ? _openAppSettings
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    // FIXED: Removed Storage check
    final permissionsIncomplete =
        !_isBluetoothPermGranted || !_isLocationPermGranted;
    final servicesIncomplete = !_isBluetoothEnabled || !_isLocationEnabled;

    String buttonText = 'Grant Permissions';
    if (!permissionsIncomplete && servicesIncomplete) {
      buttonText = 'Enable Services';
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleGrantPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    buttonText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _showLearnMoreSheet,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Learn More',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (permissionsIncomplete || servicesIncomplete) ...[
          SizedBox(height: 12),
          TextButton(
            onPressed: _openAppSettings,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'settings',
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Open Settings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
