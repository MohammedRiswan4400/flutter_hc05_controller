import 'dart:developer';

import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final GetStorage _box = GetStorage();

  static const String keyPermissionGranted = 'permission_granted';

  static Future<void> setPermissionGranted(bool isGranted) async {
    log('setPermissionGranted ${isGranted.toString()}');
    await _box.write(keyPermissionGranted, isGranted);
  }

  static bool? getPermissionGranted() {
    return _box.read(keyPermissionGranted);
  }

  static Future<void> clearAllData() async {
    await _box.erase();
  }
}
