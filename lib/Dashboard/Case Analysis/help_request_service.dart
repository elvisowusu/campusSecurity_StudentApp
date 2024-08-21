import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';

import '../../services/user_session.dart';

class HelpRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  String? _studentUid;
  String? _studentName;
  String? _referenceNumber;
  Timer? _locationUpdateTimer;
  String? _currentTrackingId;

  Future<void> initialize() async {
    final userSession = UserSession();
    await userSession.loadSession();
    _studentUid = userSession.studentId;
    _studentName = userSession.studentName;
    _referenceNumber = userSession.referenceNumber;
  }

  Future<void> updateLocation() async {
    await _ensureInitialized();
    try {
      Position position = await _locationService.getCurrentPosition();
      await _firestore.collection('students').doc(_studentUid!).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print("Updated location for $_studentName: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Failed to update location: $e");
      Fluttertoast.showToast(msg: "Failed to update location: $e");
      rethrow;
    }
  }

  Future<void> sendHelpRequest() async {
    await _ensureInitialized();
    try {
      Position position = await _locationService.getCurrentPosition();
      String trackingId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentTrackingId = trackingId;

      await _firestore.collection('help_requests').doc(trackingId).set({
        'studentUid': _studentUid!,
        'studentName': _studentName,
        'referenceNumber': _referenceNumber,
        'initialLocation': GeoPoint(position.latitude, position.longitude),
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'trackingId': trackingId,
        'status': 'active',
      });

      startLiveLocationUpdates(trackingId);
      print("Help request sent for $_studentName. Tracking ID: $trackingId");
      Fluttertoast.showToast(msg: "Help request sent to the police app.");
    } catch (e) {
      print("Failed to send help request: $e");
      Fluttertoast.showToast(msg: "Failed to send help request: $e");
      rethrow;
    }
  }

  void startLiveLocationUpdates(String trackingId) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await _locationService.getCurrentPosition();
        await updateLiveLocation(trackingId, position);
      } catch (e) {
        print("Error updating live location: $e");
        Fluttertoast.showToast(msg: "Error updating live location: $e");
      }
    });
  }

  Future<void> updateLiveLocation(String trackingId, Position position) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    print("Updated live location for $_studentName: ${position.latitude}, ${position.longitude}");
  }

  Stream<String> getHelpRequestStatus() {
    if (_currentTrackingId == null) {
      throw Exception('No active help request');
    }
    return _firestore
        .collection('help_requests')
        .doc(_currentTrackingId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['status'] as String? ?? 'unknown');
  }

  Future<void> endHelpRequest() async {
    if (_currentTrackingId == null) {
      throw Exception('No active help request');
    }
    await _firestore.collection('help_requests').doc(_currentTrackingId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    _locationUpdateTimer?.cancel();
    _currentTrackingId = null;
    print("Help request ended for $_studentName");
  }

  Future<void> _ensureInitialized() async {
    if (_studentUid == null) {
      await initialize();
    }
  }
}