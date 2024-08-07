import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user_session.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _studentUid;
  Timer? _locationUpdateTimer;

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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

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

    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update location: $e");
      rethrow;
    }
  }

  // Send help request and start live location updates
  Future<void> sendHelpRequest() async {
    await _ensureInitialized();
    try {
      Position position = await getCurrentPosition();
      String trackingId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _firestore.collection('help_requests').doc(trackingId).set({
        'studentUid': _studentUid!,
        'studentName': await getStudentName(),
        'referenceNumber': await getStudentReferenceNumber(),
        'initialLocation': GeoPoint(position.latitude, position.longitude),
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'trackingId': trackingId,
        'status': 'active',
      });

      // Start sending live location updates
      startLiveLocationUpdates(trackingId);

      Fluttertoast.showToast(msg: "Help request sent to the police app.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send help request: $e");
      rethrow;
    }
  }

  void startLiveLocationUpdates(String trackingId) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        Position position = await getCurrentPosition();
        await updateLiveLocation(trackingId, position);
      } catch (e) {
        print("Error updating live location: $e");
      }
    });
  }

  Future<void> updateLiveLocation(String trackingId, Position position) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getStudentName() async {
    final userDoc = await _firestore.collection('users').doc(_studentUid!).get();
    return userDoc.data()?['name'] ?? 'Unknown Student';
  }

  Future<String> getStudentReferenceNumber() async {
    final userSession = UserSession();
    await userSession.loadSession();
    return userSession.referenceNumber ?? 'Unknown';
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

  // Cancel the location update timer when it's no longer needed
  void dispose() {
    _locationUpdateTimer?.cancel();
  }
}