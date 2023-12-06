import 'dart:io';

import 'package:cursova/core/failures/file_failures/base_file_failure.dart';
import 'package:cursova/core/failures/file_failures/cant_access_storage.dart';
import 'package:cursova/core/failures/file_failures/storage_perm_denied.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static PermissionManager? _instance;

  factory PermissionManager() {
    _instance ??= PermissionManager._internal();
    return _instance!;
  }

  PermissionManager._internal();

  Future<PermissionStatus> getStorageStatus() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final info = await deviceInfo.androidInfo;
      if (info.version.sdkInt >= 33) {
        return PermissionStatus.granted;
      }
    }
    return await Permission.storage.status;
  }

  Future<PermissionStatus> requestStorageAccess() {
    return Permission.storage.request();
  }

  Future<BaseFileFailure?> resolveStorageAccess() async {
    final status = await PermissionManager().getStorageStatus();
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final info = await deviceInfo.androidInfo;
      if (info.version.sdkInt >= 33) {
        return null;
      }
    }
    switch (status) {
      case PermissionStatus.permanentlyDenied:
        return StoragePermanentlyDenied();
      case PermissionStatus.denied:
        return CantAccessStorage();
      case PermissionStatus.granted:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
    }

    if (!status.isGranted) {
      return CantAccessStorage();
    } else {
      return null;
    }
  }
}
