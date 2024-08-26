import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:student_app/screens/forgot_password_screen.dart';
import 'package:student_app/screens/home_screen.dart';
import 'package:student_app/screens/signup_screen.dart';
import 'package:student_app/services/user_session.dart';
import 'package:student_app/theme/theme.dart';
import 'package:student_app/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

import '../firebase_authentication/firebase_auth_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signInformKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool _isSigningIn = false;
  bool _isSigningInWithGoogle = false;

  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
                height: 18,
              )),
          Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                      key: _signInformKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                label: const Text('Email'),
                                hintText: 'Enter Email',
                                hintStyle:
                                    const TextStyle(color: Colors.black26),
                                errorText: _emailError,
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
                                )),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText:
                                !_showPassword, 
                            obscuringCharacter: '*',
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(color: Colors.black45),
                                )
                              ]),
                              const ForgotPasswordScreen()
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // SignIn button
                          GestureDetector(
                            onTap: _signIn,
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
                                    _isSigningIn
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Sign in',
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
                          // Sign in with Google
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _isSigningInWithGoogle
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            FontAwesomeIcons.google,
                                            color: Colors.white,
                                          ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Sign in with Google",
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
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.black45),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (e) =>
                                              const SignUpScreen()));
                                },
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lightColorScheme.primary),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ),
              )),
        ],
      ),
    );
  }

  void _signIn() async {
  if (_signInformKey.currentState!.validate()) {
    setState(() {
      _isSigningIn = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signIn(email, password);

    setState(() {
      _isSigningIn = false;
    });

    if (user != null) {
      Map<String, String> details = await _fetchStudentDetails(user.uid);

      if (details['referenceNumber']!.isNotEmpty) {
        await UserSession().saveSession(user.uid, details['referenceNumber']!, details['fullName']!,user.uid);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        Fluttertoast.showToast(msg: 'Sign in successful!');
      } else {
        Fluttertoast.showToast(msg: 'Error: Reference number not found!');
      }
    } else {
      Fluttertoast.showToast(msg: 'Sign in failed!');
    }
  } else {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Please enter Email' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Please enter Password' : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please complete the form and agree to the terms.'),
      ),
    );
  }
}

Future<Map<String, String>> _fetchStudentDetails(String userId) async {
  try {
    // Get details from UserSession first
    Map<String, String> sessionDetails = await UserSession().getSessionDetails();
    
    if (sessionDetails['referenceNumber']!.isNotEmpty) {
      return sessionDetails;
    }

    // If session details are not available, fetch from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      String referenceNumber = data['Reference number'] ?? '';
      String fullName = data['fullName'] ?? '';
      String assignedCounselorId = data['assgnedCounselorId']??'';
      await UserSession().saveSession(userId, referenceNumber, fullName, assignedCounselorId); // Update session
      return {
        'referenceNumber': referenceNumber,
        'fullName': fullName,
      };
    } else {
      return {
        'referenceNumber': '',
        'fullName': '',
      };
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error fetching student details: $e');
    return {
      'referenceNumber': '',
      'fullName': '',
    };
  }
}



  void _signInWithGoogle() async {
  setState(() {
    _isSigningInWithGoogle = true;
  });

  User? user = await _auth.signInWithGoogle();

  setState(() {
    _isSigningInWithGoogle = false;
  });

  if (user != null) {
    Map<String, String> details = await _fetchStudentDetails(user.uid);

    if (details['referenceNumber']!.isNotEmpty) {
      await UserSession().saveSession(user.uid, details['referenceNumber']!, details['fullName']!,user.uid);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      Fluttertoast.showToast(msg: 'Sign in successful!');
    } else {
      Fluttertoast.showToast(msg: 'Error: Reference number not found!');
    }
  } else {
    Fluttertoast.showToast(msg: 'Sign in failed!');
  }
}
}
