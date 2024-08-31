import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shake/shake.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger.dart';
import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'package:timezone/data/latest.dart' as tz;

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

      ShakeDetector detector = ShakeDetector.autoStart(
        onPhoneShake: () async {
          try {
            await helpRequestService.sendHelpRequest();
            await NotificationService.showInstantNotification(
              'Emergency Alert',
              'Help request sent due to phone shake.',
            );
          } catch (e) {
            print('Error in shake detection: $e');
          }
        },
        minimumShakeCount: 5,
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.7,
      );

      final dangerZoneNotifier = DangerZoneNotifier();
      dangerZoneNotifier.startBackgroundLocationUpdates();

      Timer.periodic(const Duration(minutes: 15), (timer) async {
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: "Safety Monitoring Active",
              content: "Monitoring for emergencies",
            );
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