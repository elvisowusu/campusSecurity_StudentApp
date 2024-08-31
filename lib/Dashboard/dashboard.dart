import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger_zone.dart';
import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';
import 'package:student_app/Dashboard/Case%20Analysis/map.dart';
import 'package:student_app/Dashboard/speak%20to%20counsellor/chat_icon_button.dart';

import '../widgets/custom_appbar.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final LocationService _locationService = LocationService();
  final DangerZoneService _dangerZoneService = DangerZoneService();
  bool _helpRequested = false;
  StreamSubscription<String>? _statusSubscription;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _initializeShakeDetector();
  }

  void _initializeShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        if (!_helpRequested) {
          await _sendHelpRequest();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Help request sent!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A help request is already active.'),
            ),
          );
        }
      },
      minimumShakeCount: 4,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _requestLocationPermission();
    }
  }

  void _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Location permission denied. Cannot send help request.");
    } else {
      Fluttertoast.showToast(msg: "Location permission granted.");
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _shakeDetector?.stopListening();
    super.dispose();
  }

  Future<void> _sendHelpRequest() async {
    if (_helpRequested) {
      Fluttertoast.showToast(msg: 'A help request is already active.');
      return;
    }

    setState(() {
      _helpRequested = true;
    });

    try {
      final helpRequestService = HelpRequestService();
      await helpRequestService.initialize();
      await helpRequestService.sendHelpRequest();

      _statusSubscription =
          helpRequestService.getHelpRequestStatus().listen((status) {
        if (status == 'resolved') {
          _statusSubscription?.cancel();
          setState(() {
            _helpRequested = false;
          });
          Fluttertoast.showToast(msg: 'Help request resolved');
        }
      });

      Position position = await _locationService.getCurrentPosition();
      await _dangerZoneService.storeLocationAsDangerZone(position);

      // Simulate a delay for demonstration purposes
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      setState(() {
        _helpRequested = false;
      });
      Fluttertoast.showToast(msg: 'Error sending help request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Campus Safety',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _sendHelpRequest,
              child: Container(
                width: 200,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _helpRequested ? Colors.green : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: _helpRequested
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      spreadRadius: 20,
                      blurRadius: 25,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: _helpRequested
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      spreadRadius: 25,
                      blurRadius: 35,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos_rounded, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text('SWIFT SOS',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 70,
              width: 90,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (e) => const MapPage()));
                  },
                  child: Container(
                    width: 150,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          214, 255, 255, 255), // Common background color
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 61, 61, 61)
                              .withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emergency, size: 32, color: Colors.red),
                          Text(
                            "Danger Zones",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ChatIconButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
