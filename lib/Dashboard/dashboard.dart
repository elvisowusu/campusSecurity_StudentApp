import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger_zone.dart';
import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';
import 'package:student_app/Dashboard/Case%20Analysis/map.dart';
import 'package:student_app/Dashboard/speak%20to%20counsellor/chat_icon_button.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _requestLocationPermission();
    } else {
      // Permission already granted, proceed with the app logic
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
    super.dispose();
  }

  Future<void> _sendHelpRequest() async {
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

      // Store the location as a danger zone
      await _dangerZoneService.storeLocationAsDangerZone(position);

      // Simulate a delay for demonstration purposes
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      // Handle any errors that occurred during the help request
      Fluttertoast.showToast(msg: 'Error sending help request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      color: Colors.red.withOpacity(0.2),
                      spreadRadius: 10,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 15,
                      blurRadius: 30,
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
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (e) => const MapPage()));
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.emergency, size: 32, color: Colors.red),
                          Text("Danger Zones",textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (e) => ChatIconButton()));
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.chat_rounded,
                              size: 32, color: Colors.blue),
                          Text('Report Case',textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
