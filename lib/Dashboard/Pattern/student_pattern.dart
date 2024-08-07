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
  bool _helpRequested = false;
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
    _locationService.dispose(); // This will cancel any ongoing timers
    super.dispose();
  }

  Future<void> _toggleHelpRequest() async {
    if (!_helpRequested) {
      try {
        // Check and request location permissions if needed
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Send help request
          await _locationService.sendHelpRequest();
          setState(() {
            _helpRequested = true;
          });
          Fluttertoast.showToast(msg: "Help request sent. Sharing location with police.");
        } else {
          Fluttertoast.showToast(msg: "Location permission denied. Cannot send help request.");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      }
    } else {
      // If help was already requested, we'll just show a message
      // In a real app, you might want to add functionality to cancel the help request
      Fluttertoast.showToast(msg: "Help request already sent. Police have been notified.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
        ),
        actions: const [
          SignOutButton()
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleHelpRequest,
              child: Container(
                color: _helpRequested ? Colors.red : Colors.yellow.shade600,
                padding: const EdgeInsets.all(16),
                child: Text(
                  _helpRequested ? 'Help requested' : 'Tap to request help',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _helpRequested ? 'Police have been notified and are tracking your location' : 'Tap the button above if you need help',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}