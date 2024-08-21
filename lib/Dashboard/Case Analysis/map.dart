import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDangerZones();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      setState(() {});

      // Move the camera to the current location
      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _loadDangerZones() async {
    try {
      List<DangerZone> dangerZones = await _dangerZoneService.getDangerZones();
      setState(() {
        _dangerZoneCircles = dangerZones
            .map((zone) => Circle(
                  circleId: CircleId('danger_zone_${zone.latitude}_${zone.longitude}'),
                  center: LatLng(zone.latitude, zone.longitude),
                  radius: zone.radius,
                  fillColor: const Color.fromARGB(255, 204, 108, 101).withOpacity(0.3),
                  strokeColor: const Color.fromARGB(255, 240, 170, 165),
                  strokeWidth: 1,
                ))
            .toSet();
      });
    } catch (e) {
      print('Error fetching danger zones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition != null
          ? GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              },
              circles: _dangerZoneCircles,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}