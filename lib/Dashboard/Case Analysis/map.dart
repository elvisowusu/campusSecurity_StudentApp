import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Location _locationController = new Location();

  //Camera position for kumasi
  static const CameraPosition _kKumasi = CameraPosition(
    target: LatLng(6.6885, -1.6244),
    zoom: 13,
  );
  LatLng? _currentPosition = null;
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
      ? const Center(
        child: Text("loading"),
      ): GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kKumasi,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        buildingsEnabled: true,
        rotateGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  //Getting current user location
  Future<void> getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentPosition);
        });
      }
    });
  }
}
