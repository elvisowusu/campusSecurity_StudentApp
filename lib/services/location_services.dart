import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user_session.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _studentUid;

  // Initialize LocationService
  Future<void> initialize() async {
    final userSession = UserSession();
    await userSession.loadSession();
    _studentUid = userSession.studentId;
  }

  // Get the current position
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
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  // Update student's location in Firestore
  Future<void> updateLocation() async {
    await _ensureInitialized();
    try {
      Position position = await getCurrentPosition();

      await _firestore.collection('users').doc(_studentUid!).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also send live location to Firestore
      await sendLiveLocation(position);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update location: $e");
      rethrow;
    }
  }

  // Send live location to Firestore
  Future<void> sendLiveLocation(Position position) async {
    await _ensureInitialized();
    try {
      await _firestore.collection('live_locations').add({
        'studentUid': _studentUid!,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: "Live location sent to the police app.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send live location: $e");
      rethrow;
    }
  }

  // Send a "Help Me" alert
  Future<void> sendHelpAlert() async {
    await _ensureInitialized();
    try {
      Position position = await getCurrentPosition();
      final nearestPoliceId = await findNearestPolice(position);

      if (nearestPoliceId != null) {
        await _firestore.collection('helpRequests').add({
          'studentUid': _studentUid!,
          'nearestPoliceId': nearestPoliceId,
          'timestamp': FieldValue.serverTimestamp(),
          'location': GeoPoint(position.latitude, position.longitude),
        });

        Fluttertoast.showToast(msg: "Help request sent successfully.");
      } else {
        Fluttertoast.showToast(msg: "No nearby police found.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send help alert: $e");
      rethrow;
    }
  }

  // Find the nearest police officer
  Future<String?> findNearestPolice(Position studentLocation) async {
    await _ensureInitialized();
    try {
      final policeLocations = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Police')
          .get();

      double minDistance = double.infinity;
      String? nearestPoliceId;

      for (var police in policeLocations.docs) {
        double distance = Geolocator.distanceBetween(
          studentLocation.latitude,
          studentLocation.longitude,
          police['latitude'],
          police['longitude'],
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPoliceId = police.id;
        }
      }

      return nearestPoliceId;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to find nearest police: $e");
      return null;
    }
  }

  // Store the given position as a danger zone in Firestore
  Future<void> storeLocationAsDangerZone(Position position) async {
    await _ensureInitialized();
    try {
      await _firestore.collection('danger_zones').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: "Location added to Firestore as a danger zone.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add location to Firestore: $e");
      rethrow;
    }
  }

  // Fetch all danger zones from Firestore
  Future<List<LatLng>> getDangerZones() async {
    await _ensureInitialized();
    try {
      final snapshot = await _firestore.collection('danger_zones').get();
      return snapshot.docs.map((doc) {
        return LatLng(doc['latitude'], doc['longitude']);
      }).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch danger zones: $e");
      return [];
    }
  }

  // Ensure that studentUid is initialized
  Future<void> _ensureInitialized() async {
    if (_studentUid == null) {
      await initialize();
    }
  }
}
