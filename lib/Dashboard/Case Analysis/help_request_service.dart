import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';
import '../../services/new.dart';
import '../../services/user_session.dart';

class HelpRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  String? _studentUid;
  String? _studentName;
  String? _referenceNumber;
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _currentTrackingId;
  Timer? _reconnectionTimer;

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
     // Get the FCM token for the student
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      await _firestore.collection('help_requests').doc(trackingId).set({
        'studentUid': _studentUid!,
        'studentName': _studentName!,
        'referenceNumber': _referenceNumber!,
        'initialLocation': GeoPoint(position.latitude, position.longitude),
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'trackingId': trackingId,
        'status': 'active',
        'isRead': false,
        'studentFcmToken': fcmToken,
      });
           // Instead of sending to all police officers, find the nearest one
      await _sendNotificationToNearestPoliceOfficer(position, trackingId);

      startLiveLocationUpdates(trackingId);
      Fluttertoast.showToast(
          msg: "Help request sent for $_studentName. Tracking ID: $trackingId");
    } catch (e) {
      Fluttertoast.showToast(msg: "An unknown error occurred.");
    }
  }

  Future<void> _sendNotificationToNearestPoliceOfficer(Position studentPosition, String trackingId) async {
    // Query for police officers, ordered by distance to the student
    QuerySnapshot policeOfficers = await _firestore.collection('police_officers')
        .get();
    
    double closestDistance = double.infinity;
    String? closestOfficerToken;

    for (var doc in policeOfficers.docs) {
      GeoPoint officerLocation = doc['location'];
      double distance = Geolocator.distanceBetween(
        studentPosition.latitude,
        studentPosition.longitude,
        officerLocation.latitude,
        officerLocation.longitude
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestOfficerToken = doc['fcmToken'];
      }
    }
      if (closestOfficerToken != null) {
      await NotificationServices.sendNotificationToSelectedPolice(
        closestOfficerToken,
        trackingId,
      );
    } else {
      Fluttertoast.showToast(msg: "No nearby police officers found.");
    }
  }

  // Update the read status when the notification is opened
  Future<void> updateHelpRequestReadStatus(
      String trackingId, bool isRead) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'isRead': isRead,
    });
  }

  void startLiveLocationUpdates(String trackingId) {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      try {
        await updateLiveLocation(trackingId, position);
      } catch (e) {
        Fluttertoast.showToast(msg: "Error updating live location: $e");
        _scheduleReconnection();
      }
    }, onError: (error) {
      Fluttertoast.showToast(msg: "Location stream error: $error");
      _scheduleReconnection();
    });
  }

  void _scheduleReconnection() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(const Duration(seconds: 10), () {
      if (_currentTrackingId != null) {
        startLiveLocationUpdates(_currentTrackingId!);
      }
    });
  }

  Future<void> updateLiveLocation(String trackingId, Position position) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<HelpRequestData> getHelpRequestUpdates() {
    if (_currentTrackingId == null) {
      throw Exception('No active help request');
    }
    return _firestore
        .collection('help_requests')
        .doc(_currentTrackingId)
        .snapshots()
        .map((snapshot) => HelpRequestData.fromSnapshot(snapshot));
  }

  Stream<String> getHelpRequestStatus() {
    if (_currentTrackingId == null) {
      throw Exception('No active help request');
    }
    return _firestore
        .collection('help_requests')
        .doc(_currentTrackingId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['status'] as String;
    });
  }

  Future<void> endHelpRequest() async {
    if (_currentTrackingId == null) {
      throw Exception('No active help request');
    }
    await _firestore
        .collection('help_requests')
        .doc(_currentTrackingId)
        .update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    _positionStreamSubscription?.cancel();
    _reconnectionTimer?.cancel();
    _currentTrackingId = null;
    // Fluttertoast.showToast(msg: "Help request ended for $_studentName");
  }

  Future<void> _ensureInitialized() async {
    if (_studentUid == null) {
      await initialize();
    }
  }
}

class HelpRequestData {
  final String status;
  final LatLng studentLocation;
  final LatLng? policeLocation;
  final int? estimatedArrivalTime;

  HelpRequestData({
    required this.status,
    required this.studentLocation,
    this.policeLocation,
    this.estimatedArrivalTime,
  });

  factory HelpRequestData.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final studentGeoPoint = data['currentLocation'] as GeoPoint;
    final policeGeoPoint = data['policeLocation'] as GeoPoint?;

    return HelpRequestData(
      status: data['status'] as String,
      studentLocation:
          LatLng(studentGeoPoint.latitude, studentGeoPoint.longitude),
      policeLocation: policeGeoPoint != null
          ? LatLng(policeGeoPoint.latitude, policeGeoPoint.longitude)
          : null,
      estimatedArrivalTime: data['estimatedArrivalTime'] as int?,
    );
  }
}
