import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger.dart';
import 'package:student_app/Dashboard/dashboard.dart';
import 'package:student_app/Dashboard/Case%20Analysis/help_request_service.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/screens/splash_screen.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'package:student_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shake/shake.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Function to handle background messages
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print(
        'Something received in the background: ${message.notification?.title}');
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
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

    // Initialize Firebase (if not already initialized)
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
          // Consider sending an error report or retrying
        }
      },
      minimumShakeCount: 4,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );

    // Start danger zone monitoring
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
    // Consider sending an error report
  }
}

Future<void> initializeService() async {
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

// iOS background fetch
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging and set up background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Initialize notification service
  await NotificationService.init();
  await NotificationService.localNotInit();

  // Initialize background service
  await initializeService();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Start monitoring for danger zones as soon as the app starts
    ref
        .read(dangerZoneNotifierProvider.notifier)
        .startBackgroundLocationUpdates();

    // Set up Firebase Messaging for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show a local notification using the NotificationService
        NotificationService.showInstantNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Danger Zone App',
      theme: lightMode,
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const DashBoard(),
    );
  }
}
