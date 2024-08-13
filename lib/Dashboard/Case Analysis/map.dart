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
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Marker? _currentLocationMarker;
  final LatLng _initialCameraPosition = const LatLng(0.0, 0.0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocationService();
  }

  Future<void> _initializeLocationService() async {
    await _locationService.initialize();
    _loadDangerZones();
    _initializeLocationUpdates();

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
    _locationService.dispose();
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
      print("Loaded ${dangerZones.length} danger zones");
    } catch (e) {
      print("Error loading danger zones: $e");
      Fluttertoast.showToast(msg: "Error loading danger zones: $e");
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
        print("New position received: ${position.latitude}, ${position.longitude}");
        LatLng currentLatLng = LatLng(position.latitude, position.longitude);
        _updateCurrentLocationMarker(currentLatLng);
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(currentLatLng),
          );
        }
      },
      onError: (error) {
        print("Error in location updates: $error");
        Fluttertoast.showToast(msg: "Error in location updates: $error");
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
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Updated at ${DateTime.now().toString()}',
        ),
      );
      _markers.add(_currentLocationMarker!);
    });
    print("Updated current location marker: ${position.latitude}, ${position.longitude}");
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
                print("Initial position: ${position.latitude}, ${position.longitude}");
                LatLng currentLatLng = LatLng(position.latitude, position.longitude);
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(currentLatLng),
                );
                _updateCurrentLocationMarker(currentLatLng);
              }).catchError((error) {
                print("Error getting current position: $error");
                Fluttertoast.showToast(msg: "Error getting current position: $error");
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