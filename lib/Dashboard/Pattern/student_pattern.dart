import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudentPattern extends StatelessWidget {
  const StudentPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(45.521563, -122.677433), zoom: 11.0));
  }
}
