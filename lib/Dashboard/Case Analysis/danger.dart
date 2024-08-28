import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'danger_zone.dart';
import 'location_services.dart';
import 'package:student_app/services/local_notification_services.dart';

class DangerZoneNotifier extends StateNotifier<bool> {
  DangerZoneNotifier(this._locationService, this._dangerZoneService)
      : super(false);

  final LocationService _locationService;
  final DangerZoneService _dangerZoneService;
  List<DangerZone> _dangerZones = [];
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastDangerAlertTime;

  Future<void> startBackgroundLocationUpdates() async {
    // Load danger zones
    await _loadDangerZones();

    // Start listening to location updates
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _currentPosition = position;
      _checkDangerZoneProximity();
    });
  }

  Future<void> _loadDangerZones() async {
    try {
      _dangerZones = await _dangerZoneService.getDangerZones();
    } catch (e) {
      // Handle error while fetching danger zones
      print('Error fetching danger zones: $e');
    }
  }

  void _checkDangerZoneProximity() {
    if (_currentPosition != null) {
      for (DangerZone zone in _dangerZones) {
        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          zone.latitude,
          zone.longitude,
        );
        if (distanceInMeters <= zone.radius) {
          _showNotification();
          break;
        }
      }
    }
  }

  void _showNotification() {
    final now = DateTime.now();
    if (_lastDangerAlertTime == null ||
        now.difference(_lastDangerAlertTime!) > const Duration(minutes: 1)) {
      NotificationService.showInstantNotification(
          'Warning', "You are in a danger zone");
      _lastDangerAlertTime = now;
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

final dangerZoneNotifierProvider =
    StateNotifierProvider<DangerZoneNotifier, bool>((ref) {
  final locationService = LocationService();
  final dangerZoneService = DangerZoneService();
  return DangerZoneNotifier(locationService, dangerZoneService);
});