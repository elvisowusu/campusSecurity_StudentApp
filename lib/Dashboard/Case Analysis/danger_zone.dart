import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/services/user_session.dart';

class DangerZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _studentUid;

  Future<void> initialize() async {
    final userSession = UserSession();
    await userSession.loadSession();
    _studentUid = userSession.studentId;
  }

  Future<void> storeLocationAsDangerZone(Position position, [double radius = 35.0]) async {
    await _ensureInitialized();
    try {
      await _firestore.collection('danger_zones').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': radius,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fluttertoast.showToast(msg:"Location added as danger zone: ${position.latitude}, ${position.longitude} with radius $radius");
      // Fluttertoast.showToast(msg: "Location added to Firestore as a danger zone.");
    } catch (e) {
      // Fluttertoast.showToast(msg: "Failed to add location to Firestore: $e");
      rethrow;
    }
  }

  Future<List<DangerZone>> getDangerZones() async {
    await _ensureInitialized();
    try {
      final snapshot = await _firestore.collection('danger_zones').get();
      List<DangerZone> dangerZones = snapshot.docs.map((doc) {
        return DangerZone(
          latitude: doc['latitude'],
          longitude: doc['longitude'],
          radius: doc['radius'],
        );
      }).toList();
      // Fluttertoast.showToast(msg:"Fetched ${dangerZones.length} danger zones");
      return dangerZones;
    } catch (e) {
      // Fluttertoast.showToast(msg:"Failed to fetch danger zones: $e");
      // Fluttertoast.showToast(msg: "Failed to fetch danger zones: $e");
      return [];
    }
  }

  Future<void> _ensureInitialized() async {
    if (_studentUid == null) {
      await initialize();
    }
  }
}

class DangerZone {
  final double latitude;
  final double longitude;
  final double radius;

  DangerZone({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  factory DangerZone.fromJson(Map<String, dynamic> json) {
    return DangerZone(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }
}