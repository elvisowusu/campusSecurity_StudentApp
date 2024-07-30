import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:student_app/common/toast.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get the current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// Store the given position as a danger zone in Firestore
  Future<void> storeLocationAsDangerZone(Position position) async {
    try {
      await _firestore.collection('danger_zones').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });

      showToast(message: "Location added to Firestore as a danger zone.");
    } catch (e) {
      showToast(message:"Failed to add location to Firestore: $e");
      rethrow;
    }
  }

  /// Fetch all danger zones from Firestore
  Future<List<LatLng>> getDangerZones() async {
    try {
      final snapshot = await _firestore.collection('danger_zones').get();
      return snapshot.docs.map((doc) {
        return LatLng(doc['latitude'], doc['longitude']);
      }).toList();
    } catch (e) {
      showToast(message: "Failed to fetch danger zones: $e");
      return [];
    }
  }

  
}
