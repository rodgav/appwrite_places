import 'dart:async';

import 'package:geolocator/geolocator.dart';

abstract class LocatorInfo {
  StreamSubscription<Position>? get positionStream;

  Future<Position> get currentPosition;

  closePositionStream();
}

class LocatorInfoImpl implements LocatorInfo {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );

  @override
  StreamSubscription<Position>? get positionStream =>
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((position) => position);

  @override
  Future<Position> get currentPosition => Geolocator.getCurrentPosition();

  @override
  closePositionStream() async {
    await positionStream?.cancel();
  }
}
