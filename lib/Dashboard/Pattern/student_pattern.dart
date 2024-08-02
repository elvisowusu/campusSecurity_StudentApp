import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/common/toast.dart';
import 'package:student_app/dashboard/pattern/chat_icon_button.dart';
import 'package:student_app/services/location_services.dart'; // Updated import

class StudentPattern extends StatefulWidget {
  final String studentUid;

  const StudentPattern({super.key, required this.studentUid});

  @override
  State<StudentPattern> createState() => _StudentPatternState();
}

class _StudentPatternState extends State<StudentPattern> {
  bool _shareLocation = false;
  Timer? _locationUpdateTimer;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(studentUid: widget.studentUid);
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      try {
        // Update location in Firestore and send live location to the police app
        await _locationService.updateLocation();
        await _locationService.sendLiveLocation(await _locationService.getCurrentPosition()); // Add this line
        showToast(message: "Location updated and sent successfully.");
      } catch (e) {
        showToast(message: "Failed to update location: $e");
        stopLocationUpdates();
      }
    });
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
  }

  Future<void> _toggleLocationSharing() async {
    setState(() {
      _shareLocation = !_shareLocation;
    });

    if (_shareLocation) {
      try {
        // Check and request location permissions if needed
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          // Start location updates
          startLocationUpdates();
          // Get the current location and store it as a danger zone
          Position position = await _locationService.getCurrentPosition();
          await _locationService.storeLocationAsDangerZone(position);
          showToast(message: "Location shared and added as danger zone.");
        } else {
          showToast(message: "Location permission denied.");
          setState(() {
            _shareLocation = false;
          });
        }
      } catch (e) {
        showToast(message: "Error: ${e.toString()}");
        setState(() {
          _shareLocation = false;
        });
        stopLocationUpdates();
      }
    } else {
      stopLocationUpdates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          ChatIconButton(), // Custom widget for chat functionality
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: _toggleLocationSharing,
          child: Container(
            color: Colors.yellow.shade600,
            padding: const EdgeInsets.all(16),
            child: Text(
              _shareLocation ? 'Location sharing active' : 'Tap to share location',
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
