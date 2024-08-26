import 'dart:math';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:student_app/screens/home_screen.dart';
import 'package:student_app/screens/signin_screen.dart';
import 'package:student_app/services/user_session.dart';
import 'package:student_app/theme/theme.dart';
import 'package:student_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_authentication/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  // Loader
  bool _isSigningUp = false;
  bool _isSigningUpWithGoogle = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referenceNumberController =
      TextEditingController();
  // Define FocusNodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _referenceNumberFocusNode = FocusNode();

  // Track error messages for fields
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _referenceNumberError;

  // Flag for password visibility
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to clear errors on focus
    _fullNameFocusNode.addListener(() {
      if (_fullNameFocusNode.hasFocus) {
        setState(() {
          _fullNameError = null;
        });
      }
    });

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = null;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = null;
        });
      }
    });

    _referenceNumberFocusNode.addListener(() {
      if (_referenceNumberFocusNode.hasFocus) {
        setState(() {
          _referenceNumberError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referenceNumberController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _referenceNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image: 'assets/images/security.avif',
      customContainer: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // Get started form
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 21.0,
                      ),
                      // Full name
                      TextFormField(
                        controller: _fullNameController,
                        focusNode: _fullNameFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          errorText: _fullNameError,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Reference Number
                      TextFormField(
                        controller: _referenceNumberController,
                        focusNode: _referenceNumberFocusNode,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Reference Number';
                          } else if (value.length != 8) {
                            return 'Reference Number must be 8 digits';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Reference Number'),
                          hintText: 'Enter Reference Number',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          errorText: _referenceNumberError,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          errorText: _emailError,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText:
                            !_showPassword, // Toggle visibility based on _showPassword flag
                        obscuringCharacter: '*',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: lightColorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // I agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Signup button
                      GestureDetector(
                        onTap: _signUp,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isSigningUp
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Or',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      // Sign up social media logo
                      GestureDetector(
                        onTap: _signUpWithGoogle,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isSigningUpWithGoogle
                                    ? const CircularProgressIndicator(
                                        color: Colors.blue)
                                    : const FaIcon(FontAwesomeIcons.google,
                                        color: Colors.red),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  "Sign up with Google",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signUp() async {
  if (_signUpFormKey.currentState!.validate() && agreePersonalData) {
    setState(() {
      _isSigningUp = true;
    });

    String fullName = _fullNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String referenceNumber = _referenceNumberController.text;

    try {
      User? user = await _auth.signUp(email, password);
      setState(() {
        _isSigningUp = false;
      });

      if (user != null) {
        String defaultCounsellorId = await _getDefaultCounsellorId();

        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .set({
          'fullName': fullName,
          'Reference number': referenceNumber,
          'email': email,
          'assignedCounsellor': defaultCounsellorId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await UserSession().saveSession(
          user.uid,
          referenceNumber.trim(),
          fullName.trim(),
        );

        Fluttertoast.showToast(msg: "Sign up successful");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Some error happened");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error signing up: $e");
    }
  } else {
    setState(() {
      _fullNameError =
          _fullNameController.text.isEmpty ? 'Please enter Full name' : null;
      _referenceNumberError = _referenceNumberController.text.isEmpty
          ? 'Please enter Reference Number'
          : null;
      _emailError =
          _emailController.text.isEmpty ? 'Please enter Email' : null;
      _passwordError =
          _passwordController.text.isEmpty ? 'Please enter Password' : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Please complete the form and agree to the terms.')),
    );
  }
}

// Function to get a random counsellor ID  who has fewer than 20 students
  Future<String> _getDefaultCounsellorId() async {
    try {
      // Query all counsellors
      QuerySnapshot counsellorsSnapshot =
          await FirebaseFirestore.instance.collection('counselors').get();

      // Check if there are any counsellors available
      if (counsellorsSnapshot.docs.isEmpty) {
        Fluttertoast.showToast(msg: "No counsellors available");
        return ''; // Return an empty string or handle as needed
      }

// List to store counsellors with fewer than 20 students
      List<String> eligibleCounsellors = [];

      // Iterate through counsellors and check their student count
      for (var doc in counsellorsSnapshot.docs) {
        String counsellorId = doc.id;

        // Query the number of students assigned to the counsellor
        QuerySnapshot studentCountSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('counsellorId', isEqualTo: counsellorId)
            .get();

        if (studentCountSnapshot.size < 20) {
          eligibleCounsellors.add(counsellorId);
        }
      }

      // Check if there are any eligible counsellors
      if (eligibleCounsellors.isEmpty) {
        Fluttertoast.showToast(msg: "All counsellors are currently full");
        return ''; // Return an empty string or handle as needed
      }

      // Generate a random index to select a counsellor from eligible counsellors
      int randomIndex = Random().nextInt(eligibleCounsellors.length);
      String randomCounsellorId = eligibleCounsellors[randomIndex];

      return randomCounsellorId; // Return the ID of the randomly selected counsellor
    } catch (e) {
      Fluttertoast.showToast(msg: "Error getting random counsellor: $e");
      return ''; // Return an empty string or handle as needed
    }
  }

  // Sign up with Google
  void _signUpWithGoogle() async {
  setState(() {
    _isSigningUpWithGoogle = true;
  });

  try {
    // Perform Google sign-in
    User? user = await FirebaseAuthService().signInWithGoogle();

    if (user != null) {
      // Check if student already exists in the database
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Student already exists, handle accordingly (e.g., log in the user)
        Fluttertoast.showToast(msg: "Google account already exists!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        String defaultCounsellorId = await _getDefaultCounsellorId();
        // Add user to the database
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .set({
          'fullName': user.displayName,
          'email': user.email,
          'Reference number': _referenceNumberController.text,
          'assignedCounsellor': defaultCounsellorId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await UserSession().saveSession(
          user.uid,
          _referenceNumberController.text.trim(),
          user.displayName ?? '',
        );

        Fluttertoast.showToast(msg: "Sign up successful");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      Fluttertoast.showToast(msg: "Some error happened");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "Error signing up with Google: $e");
  } finally {
    setState(() {
      _isSigningUpWithGoogle = false;
    });
  }
}
}
