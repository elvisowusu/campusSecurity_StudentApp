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
  bool _isLoading = false;
  late final LocationService _locationService;
  StreamSubscription<String>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocationService();
    _checkLocationPermission();
  }

  Future<void> _initializeLocationService() async {
    final userSession = UserSession();
    await userSession.loadSession();

    _locationService = LocationService();
    await _locationService.initialize();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: const Text('This app needs location access to send help requests. Please grant location permission.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                LocationPermission permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                  Fluttertoast.showToast(msg: "Location permission denied. Cannot send help request.");
                } else {
                  Fluttertoast.showToast(msg: "Location permission granted.");
                }
              },
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendHelpRequest() async {
    if (!_helpRequested && !_isLoading) {
      try {
        setState(() {
          _isLoading = true;
        });

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          // Send help request
          await _locationService.sendHelpRequest();
          
          // Update student's location
          await _locationService.updateLocation();
          
          // Find nearest police
          Position currentPosition = await _locationService.getCurrentPosition();
          String? nearestPoliceId = await _locationService.findNearestPolice(currentPosition);
          
          if (nearestPoliceId != null) {
            Fluttertoast.showToast(msg: "Nearest police officer notified.");
          }
          
          // Mark current location as danger zone
          await _locationService.storeLocationAsDangerZone(currentPosition);

          setState(() {
            _helpRequested = true;
          });

          // Start listening to status updates
          _statusSubscription = _locationService.getHelpRequestStatus().listen((status) {
            if (status == 'resolved') {
              setState(() {
                _helpRequested = false;
              });
              Fluttertoast.showToast(msg: "Help request resolved.");
              _statusSubscription?.cancel();
            }
          });
        } else {
          Fluttertoast.showToast(msg: "Location permission denied. Cannot send help request.");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
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
              onTap: _sendHelpRequest,
              child: Container(
                color: _helpRequested ? Colors.red : Colors.yellow.shade600,
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
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
