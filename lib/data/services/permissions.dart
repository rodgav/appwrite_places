import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class Permissions {
  Future<bool> locationPermission();
}

class PermissionsImpl implements Permissions {
  @override
  Future<bool> locationPermission() async {
    if (kIsWeb) {
      Geolocator.requestPermission();
      final permisoGPSweb = await Geolocator.checkPermission();
      return permisoGPSweb == LocationPermission.always ||
          permisoGPSweb == LocationPermission.whileInUse;
    } else {
      await Permission.location.request();
      if (await Permission.location.isPermanentlyDenied ||
          await Permission.location.isDenied) {
        openAppSettings();
        return false;
      } else {
        return await Permission.location.isGranted;
      }
    }
  }
}
