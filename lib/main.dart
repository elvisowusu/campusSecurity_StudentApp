import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger_zone.dart';
import 'package:student_app/Dashboard/Case%20Analysis/location_services.dart';
import 'package:student_app/Dashboard/dashboard.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/screens/splash_screen.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'package:student_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'Dashboard/Case Analysis/danger.dart';

// Global navigator key
final navigatorKey = GlobalKey<NavigatorState>();

// Background handler for Firebase Messaging
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('Received in the background: ${message.notification?.title}');
  }
}

// Background task for WorkManager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Instantiate your notifier and start background location updates
    final dangerZoneNotifier =
        DangerZoneNotifier(LocationService(), DangerZoneService());
    await dangerZoneNotifier.startBackgroundLocationUpdates();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging for background handling
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Initialize notification services
  await NotificationService.init();
  await NotificationService.localNotInit();

  // Initialize WorkManager for background tasks
  Workmanager().initialize(callbackDispatcher);

  // Schedule a periodic task for background location updates
  Workmanager().registerPeriodicTask(
    "backgroundLocationUpdates",
    "dangerZoneCheckTask",
    frequency: const Duration(minutes: 1), // Check every 15 minutes
  );

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

    // Start monitoring danger zones when the app starts
    ref
        .read(dangerZoneNotifierProvider.notifier)
        .startBackgroundLocationUpdates();

    // Set up Firebase Messaging for foreground notifications
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
