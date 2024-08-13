import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../firebase_authentication/firebase_auth_services.dart';
import 'otp_page.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({super.key});

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> sendCode() async {
    try {
      await _authService.sendVerificationCode('+233${phoneController.text}');
      Get.to(() => const OtpPage());
    } catch (e) {
      Get.snackbar('Error Occurred', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Image.asset('images/otp_image.png'),
          const Center(
            child: Text(
              "Your Phone !",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          phoneText(),
          const SizedBox(height: 50),
          button(),
        ],
      ),
    );
  }

  Widget phoneText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: phoneController,
        decoration: InputDecoration(
          hintText: 'Enter your phone number',
          prefixText: '+233 ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget button() {
    return Center(
      child: ElevatedButton(
        onPressed: sendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 32, 158, 248),
          padding: const EdgeInsets.all(16.0),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 90),
          child: Text(
            'Receive OTP',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}