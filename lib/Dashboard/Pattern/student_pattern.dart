import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/services/location_services.dart';
import 'package:student_app/services/user_session.dart';
import 'package:student_app/widgets/signout.dart';

class StudentPattern extends StatefulWidget {
  const StudentPattern({super.key});

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
    _initializeLocationService();
  }

  Future<void> _initializeLocationService() async {
    final userSession = UserSession();
    await userSession.loadSession(); // Load the session to retrieve the student ID

    _locationService = LocationService();
    await _locationService.initialize(); // Initialize LocationService to set studentUid
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void startLocationUpdates() {
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        // Update location in Firestore and send live location to the police app
        await _locationService.updateLocation();
        await _locationService
            .sendLiveLocation(await _locationService.getCurrentPosition());
        Fluttertoast.showToast(msg: "Location updated and sent successfully.");
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to update location: $e");
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

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Start location updates
          startLocationUpdates();
          // Get the current location and store it as a danger zone
          Position position = await _locationService.getCurrentPosition();
          await _locationService.storeLocationAsDangerZone(position);
          Fluttertoast.showToast(
              msg: "Location shared and added as danger zone.");
        } else {
          Fluttertoast.showToast(msg: "Location permission denied.");
          setState(() {
            _shareLocation = false;
          });
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
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
        backgroundColor: Colors.black.withOpacity(0.2), // Semi-transparent background color
        elevation: 0, // Remove shadow to enhance the glass effect
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Background color with transparency
              ),
            ),
          ),
        ),
        actions: const [
          SignOutButton()
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
