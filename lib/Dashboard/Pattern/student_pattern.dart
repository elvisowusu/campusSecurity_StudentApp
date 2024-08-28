// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
// import 'package:student_app/widgets/signout.dart';
// import '../Case Analysis/danger_zone.dart';
// import '../Case Analysis/location_services.dart';

// class StudentPattern extends StatefulWidget {
//   const StudentPattern({super.key});

//   @override
//   State<StudentPattern> createState() => _StudentPatternState();
// }

// class _StudentPatternState extends State<StudentPattern> {
// final LocationService _locationService = LocationService();
// final DangerZoneService _dangerZoneService = DangerZoneService();
//   bool _helpRequested = false;
//   bool _isLoading = false;
//   StreamSubscription<String>? _statusSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermission();
//   }

//   Future<void> _checkLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       _requestLocationPermission();
//     } else {
//       // Permission already granted, proceed with the app logic
//     }
//   }

//   void _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(msg: "Location permission denied. Cannot send help request.");
//     } else {
//       Fluttertoast.showToast(msg: "Location permission granted.");
//     }
//   }

//   @override
//   void dispose() {
//     _statusSubscription?.cancel();
//     super.dispose();
//   }

// Future<void> _sendHelpRequest() async {
//   setState(() {
//     _helpRequested = true;
//     _isLoading = true;
//   });

//   try {
//     final helpRequestService = HelpRequestService();
//     await helpRequestService.initialize();
//     await helpRequestService.sendHelpRequest();

//     _statusSubscription = helpRequestService.getHelpRequestStatus().listen((status) {
//       if (status == 'resolved') {
//         _statusSubscription?.cancel();
//         setState(() {
//           _isLoading = false;
//           _helpRequested = false;
//         });
//         Fluttertoast.showToast(msg:'Help request resolved');
//       }
//     });
//     Position position = await _locationService.getCurrentPosition();

//     // Store the location as a danger zone
//     await _dangerZoneService.storeLocationAsDangerZone(position);

//     // Simulate a delay for demonstration purposes
//     await Future.delayed(const Duration(seconds: 3));

//     setState(() {
//       _isLoading = false;
//     });
//   } catch (e) {
//     // Handle any errors that occurred during the help request
//     Fluttertoast.showToast(msg:'Error sending help request: $e');
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Welcome'),
//         backgroundColor: Colors.black.withOpacity(0.2),
//         elevation: 0,
//         flexibleSpace: ClipRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.2),
//               ),
//             ),
//           ),
//         ),
//         actions: const [
//           SignOutButton()
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: _sendHelpRequest,
//               child: Container(
//                 color: _helpRequested ? Colors.red : Colors.yellow.shade600,
//                 padding: const EdgeInsets.all(16),
//                 child: _isLoading
//                     ? const CircularProgressIndicator()
//                     : Text(
//                         _helpRequested ? 'Help requested' : 'Tap to request help',
//                         style: const TextStyle(color: Colors.black, fontSize: 18),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _helpRequested ? 'Police have been notified and are tracking your location' : 'Tap the button above if you need help',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }