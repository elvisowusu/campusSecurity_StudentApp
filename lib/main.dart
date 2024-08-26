import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/screens/home_screen.dart';
import 'package:student_app/screens/splash_screen.dart';
import 'package:student_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// import 'services/notification_handler.dart';
// import 'services/notification_services.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //  await FirebaseMessaging.instance.requestPermission();
  //    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await PushNotificationService.setupNotificationChannels();
  // await NotificationHandler.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const HomeScreen(), // Add navigatorKey here
    );
  }
}
