import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/dashboard/pattern/student_pattern.dart';
import 'package:student_app/firebase_options.dart';
import 'package:student_app/screens/splash_screen.dart';
import 'package:student_app/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: FirebaseAuth.instance.currentUser==null? const SplashScreen(): StudentPattern(),
    );
  }
}
