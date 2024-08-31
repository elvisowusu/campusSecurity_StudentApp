import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/Dashboard/Case%20Analysis/danger.dart';
import 'package:student_app/Dashboard/dashboard.dart';

import 'package:student_app/firebase_options.dart';
import 'package:student_app/screens/splash_screen.dart';
import 'package:student_app/services/local_notification_services.dart';
import 'package:student_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();

// Function to handle background messages
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print(
        'Something received in the background: ${message.notification?.title}');
  }
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
