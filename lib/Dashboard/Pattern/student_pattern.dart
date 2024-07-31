import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:student_app/common/toast.dart';
import 'package:student_app/dashboard/pattern/chat_icon_button.dart';
import 'package:student_app/services/location_services.dart';

class StudentPattern extends StatefulWidget {
  const StudentPattern({super.key});

  @override
  State<StudentPattern> createState() => _StudentPatternState();
}

class _StudentPatternState extends State<StudentPattern> {
  bool _shareLocation = false;
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          ChatIconButton(), // Use the custom widget here
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              setState(() {
                _shareLocation = !_shareLocation;
              });

              if (_shareLocation) {
                try {
                  // Get the current location and store it as a danger zone.
                  Position position = await _locationService.getCurrentPosition();
                  await _locationService.storeLocationAsDangerZone(position);
                } catch (e) {
                  showToast(message: "Error: ${e.toString()}");
                  setState(() {
                    _shareLocation = false;
                  });
                }
              }
            },
            child: Container(
              color: Colors.yellow.shade600,
              padding: const EdgeInsets.all(8),
              child: Text(_shareLocation ? 'Location shared' : 'Share location'),
            ),
          ),
        ],
      ),
    );
  }
}
