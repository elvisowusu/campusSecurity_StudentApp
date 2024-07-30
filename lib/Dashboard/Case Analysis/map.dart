import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/common/toast.dart';
import 'package:student_app/services/location_services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Marker? _currentLocationMarker;
  final LatLng _initialCameraPosition = const LatLng(0.0, 0.0);

  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadDangerZones();
    _initializeLocationUpdates();
    
    // Set a delay to hide the loading indicator after 3 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDangerZones() async {
    try {
      List<LatLng> dangerZones = await _locationService.getDangerZones();
      setState(() {
        _markers.addAll(
          dangerZones.map(
            (latLng) => Marker(
              markerId: MarkerId(latLng.toString()),
              position: latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: 'Danger Zone',
                snippet: '${latLng.latitude}, ${latLng.longitude}',
              ),
            ),
          ),
        );
      });
    } catch (e) {
      showToast(message: "Error loading danger zones: $e");
    }
  }

  void _initializeLocationUpdates() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) {
        LatLng currentLatLng = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker(currentLatLng);
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      },
      onError: (error) {
        print("Error in position stream: $error");
      },
    );
  }

  void _updateCurrentLocationMarker(LatLng position) {
    setState(() {
      if (_currentLocationMarker != null) {
        _markers.remove(_currentLocationMarker);
      }
      _currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
      );
      _markers.add(_currentLocationMarker!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            buildingsEnabled: true,
            rotateGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;

              Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ).then((position) {
                LatLng currentLatLng = LatLng(position.latitude, position.longitude);
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(currentLatLng),
                );
                _updateCurrentLocationMarker(currentLatLng);
              });
            },
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 18.5,
            ),
            markers: _markers,
          ),
          if (_isLoading) // Show loading indicator while loading
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
