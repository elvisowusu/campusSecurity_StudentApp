import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'danger_zone.dart';
import 'location_services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationService _locationService = LocationService();
  final DangerZoneService _dangerZoneService = DangerZoneService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Circle> _dangerZoneCircles = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastDangerAlertTime;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDangerZones();
    _startListeningToLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      setState(() {});

      _updateCameraPosition();
    } catch (e) {
      // Fluttertoast.showToast(msg: 'Error getting current location: $e');
    }
  }

  bool _isInDangerZone(Position position) {
    for (Circle dangerZone in _dangerZoneCircles) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        dangerZone.center.latitude,
        dangerZone.center.longitude,
      );
      if (distanceInMeters <= dangerZone.radius) {
        return true;
      }
    }
    return false;
  }

  void _startListeningToLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _updateCameraPosition();

      // Check if user is in a danger zone
      if (_isInDangerZone(position)) {
        
        _showNotification();
      }
    });
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


  void _updateCameraPosition() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _loadDangerZones() async {
    try {
      List<DangerZone> dangerZones = await _dangerZoneService.getDangerZones();
      setState(() {
        _dangerZoneCircles = dangerZones
            .map((zone) => Circle(
                  circleId: CircleId(
                      'danger_zone_${zone.latitude}_${zone.longitude}'),
                  center: LatLng(zone.latitude, zone.longitude),
                  radius: zone.radius,
                  fillColor:
                      const Color.fromARGB(255, 204, 108, 101).withOpacity(0.3),
                  strokeColor: const Color.fromARGB(255, 240, 170, 165),
                  strokeWidth: 1,
                ))
            .toSet();
      });
    } catch (e) {
      // Fluttertoast.showToast(msg: 'Error fetching danger zones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition != null
          ? GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 17,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              circles: _dangerZoneCircles,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
