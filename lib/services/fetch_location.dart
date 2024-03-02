import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
      }
      if (locationPermission == LocationPermission.deniedForever) {
        print("Location permission denied by the user.");
        // I should consider handling this case by showing a dialog to redirect user to settings?? to do later.
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      return position;
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
