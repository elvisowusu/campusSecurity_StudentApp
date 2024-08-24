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
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _currentTrackingId;

  Future<void> initialize() async {
    final userSession = UserSession();
    await userSession.loadSession();
    _studentUid = userSession.studentId;
    _studentName = userSession.studentName;
    _referenceNumber = userSession.referenceNumber;
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
      Fluttertoast.showToast(msg: "Help request sent for $_studentName. Tracking ID: $trackingId");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send help request: $e");
      rethrow;
    }
  }

  void startLiveLocationUpdates(String trackingId) {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      try {
        await updateLiveLocation(trackingId, position);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error updating live location: $e");
        // Implement retry logic here if needed
      }
    });
  }

  Future<void> updateLiveLocation(String trackingId, Position position) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    Fluttertoast.showToast(msg: "Updated live location for $_studentName: ${position.latitude}, ${position.longitude}");
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
    _positionStreamSubscription?.cancel();
    _currentTrackingId = null;
    Fluttertoast.showToast(msg: "Help request ended for $_studentName");
  }

  Future<void> _ensureInitialized() async {
    if (_studentUid == null) {
      await initialize();
    }
  }
}