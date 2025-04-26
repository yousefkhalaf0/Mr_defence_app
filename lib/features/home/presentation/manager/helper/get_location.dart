import 'package:geolocator/geolocator.dart';
import 'dart:developer';

void getLocation({required Function(Position) onLocationUpdate}) async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      log('Location permission denied');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    log('Location permission permanently denied');
    return;
  }

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 100,
  );

  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    log('Position: $position');

    // Update the map with the new position
    onLocationUpdate(position);

    // Set up position stream for continuous updates
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((
      Position newPosition,
    ) {
      log('Position stream update: $newPosition');
      onLocationUpdate(newPosition);
    });
  } catch (e) {
    log('Error getting location: $e');
  }
}
