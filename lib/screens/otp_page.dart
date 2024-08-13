import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:student_app/screens/home_screen.dart';

import '../firebase_authentication/firebase_auth_services.dart';
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String code = '';

  Future<void> verifyOtp() async {
    final bool success = await _authService.verifySmsCode(code);
    if (success) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar('Error', 'Failed to verify OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'images/otp_image.png',
              height: 330,
              width: 330,
            ),
            const Text(
              "OTP verification",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
              child: Text(
                "Enter OTP sent to you",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            textCode(),
            const SizedBox(height: 80),
            button(),
          ],
        ),
      ),
    );
  }

  Widget textCode() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Pinput(
        length: 6,
        onChanged: (value) {
          setState(() {
            code = value;
          });
        },
      ),
    );
  }

  Widget button() {
    return ElevatedButton(
      onPressed: verifyOtp,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(140, 178, 241, 1),
        padding: const EdgeInsets.all(16.0),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 80),
        child: Text(
          'Verify & Proceed',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}