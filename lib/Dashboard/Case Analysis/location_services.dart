import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable them
      return Future.error('Location services are disabled.');
    }

    // Check if permission is granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, show an error message
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, show an error message
      return Future.error('Location permission denied forever');
    }

    // Get the current location
    return await Geolocator.getCurrentPosition();
  }
}