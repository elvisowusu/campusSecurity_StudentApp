import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger_zone.dart';
import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';
import 'package:student_app/firebase_authentication/firebase_initializer.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'package:student_app/services/socktio.dart';
import 'package:student_app/services/user_session.dart';
import 'package:timezone/data/latest.dart' as tz;
// Ensure this import is added for the socket client

final DangerZoneService _dangerZoneService = DangerZoneService();
String? _studentUid;

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();

  factory AppInitializer() {
    return _instance;
  }

  AppInitializer._internal();

  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeNotifications();
    await _initializeBackgroundService();
    final userSession = UserSession();
    await userSession.loadSession();
    _studentUid = userSession.studentId;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    await NotificationService.init();
    await NotificationService.localNotInit();
  }

  Future<void> _initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  static Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      print(
          'Something received in the background: ${message.notification?.title}');
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    try {
      if (service is AndroidServiceInstance) {
        service.on('setAsForeground').listen((event) {
          service.setAsForegroundService();
        });
        service.on('setAsBackground').listen((event) {
          service.setAsBackgroundService();
        });
      }

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final helpRequestService = HelpRequestService();
      await helpRequestService.initialize();

      DateTime? lastHelpRequestTime;
      const cooldownDuration = Duration(minutes: 3);
      const requiredShakeCount = 4;
      int currentShakeCount = 0;
      DateTime? shakeStartTime;

      ShakeDetector detector = ShakeDetector.autoStart(
        onPhoneShake: () async {
          final now = DateTime.now();

          // Initialize or reset shake count if it's a new shake session
          if (shakeStartTime == null ||
              now.difference(shakeStartTime!) > const Duration(seconds: 3)) {
            currentShakeCount = 1;
            shakeStartTime = now;
          } else {
            currentShakeCount++;
          }

          if (currentShakeCount >= requiredShakeCount) {
            // Check if we're still in the cooldown period
            if (lastHelpRequestTime != null &&
                now.difference(lastHelpRequestTime!) < cooldownDuration) {
              print(
                  'Help request on cooldown. Please wait before trying again.');
              await NotificationService.showInstantNotification(
                'Cooldown Active',
                'Please wait before sending another help request.',
              );
              return;
            }
            // Store the current location as a danger zone
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            await _dangerZoneService.storeLocationAsDangerZone(position);
            try {
              await helpRequestService.sendHelpRequest();
              lastHelpRequestTime = now;
              currentShakeCount = 0;

              await NotificationService.showInstantNotification(
                'Emergency Alert',
                'Help request sent due to phone shake.',
              );
            } catch (e) {
              print('Error in shake detection: $e');
            }
          }
        },
        minimumShakeCount: 1, // We're manually counting shakes now
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.7,
      );

      final dangerZoneNotifier = DangerZoneNotifier();
      dangerZoneNotifier.startBackgroundLocationUpdates();

      // Initialize the SocketIO client
      final socketClient =
          SocketIOClient('https://prediction-model-apjr.onrender.com');
      await socketClient.connect();

      // Set up periodic location updates
      Timer.periodic(const Duration(minutes: 1), (timer) async {
        try {
          Position position = await LocationService().getCurrentPosition();
          final userSession = UserSession();
          await userSession.loadSession();
          // Update location via SocketIO
          print(userSession.studentId!);
          socketClient.updateLocation(
            studentId: userSession.studentId ??
                'STUD1234', // Replace with actual student ID
            latitude: position.latitude,
            longitude: position.longitude,
          );
          print('Location update sent successfully');
        } catch (e) {
          print('Error sending location update: $e');
        }
      });

      // Listen for alerts from the server
      socketClient.socket.on('location_alert', (data) async {
        print('Received alert: $data');
        // Here you can trigger a local notification or update the UI
        // Store the current location as a danger zone
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        await _dangerZoneService.storeLocationAsDangerZone(position);
        try {
          await helpRequestService.sendHelpRequest();

          await NotificationService.showInstantNotification(
            'Emergency Alert',
            'Help request sent due to change in pattern.',
          );
        } catch (e) {
          print('Error in pattern change alert: $e');
        }
      });

      Timer.periodic(const Duration(minutes: 5), (timer) async {
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: "Safety Monitoring Active",
              content: "Monitoring for emergencies",
            );
          }
        }

        Position position = await Geolocator.getCurrentPosition();
        List<DangerZone> dangerZones = await getDangerZones();

        for (var zone in dangerZones) {
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            zone.latitude,
            zone.longitude,
          );

          if (distance <= zone.radius) {
            await flutterLocalNotificationsPlugin.show(
              0,
              'Danger Zone Alert',
              'You are entering a danger zone',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'danger_zone_channel',
                  'Danger Zone Notifications',
                  importance: Importance.high,
                  priority: Priority.high,
                ),
              ),
            );
            break;
          }
        }

        service.invoke('update');
      });
    } catch (e) {
      print('Error in background service: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }
}

Future<List<DangerZone>> getDangerZones() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('danger_zones').get();
  return snapshot.docs.map((doc) {
    return DangerZone(
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      radius: doc['radius'],
    );
  }).toList();
}

class DangerZone {
  final double latitude;
  final double longitude;
  final double radius;

  DangerZone({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}
