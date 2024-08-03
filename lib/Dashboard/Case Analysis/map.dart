import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/services/location_services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationService _locationService; // Use the service with the required parameter
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Marker? _currentLocationMarker;
  final LatLng _initialCameraPosition = const LatLng(0.0, 0.0);

  bool _isLoading = true; // Track loading state

  _MapPageState() : _locationService = LocationService(); // Replace with actual student UID

  @override
  void initState() {
    super.initState();
    _loadDangerZones();
    _initializeLocationUpdates();

    // Set a delay to hide the loading indicator after 7 seconds
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
      Fluttertoast.showToast(msg: "Error loading danger zones: ${e.toString()}");
    }
  }

  void _initializeLocationUpdates() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen(
      (Position position) {
        LatLng currentLatLng = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker(currentLatLng);
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(currentLatLng),
          );
        }
      },
      onError: (error) {
        Fluttertoast.showToast(msg: "Error in location updates: ${error.toString()}");
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
                desiredAccuracy: LocationAccuracy.bestForNavigation,
              ).then((position) {
                LatLng currentLatLng = LatLng(position.latitude, position.longitude);
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(currentLatLng),
                );
                _updateCurrentLocationMarker(currentLatLng);
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Error getting current position: ${error.toString()}");
              });
            },
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 18.5,
            ),
            markers: _markers,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
