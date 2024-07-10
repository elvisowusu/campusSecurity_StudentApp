import 'package:flutter/services.dart';
import 'package:student_app/common/toast.dart';
import 'package:student_app/screens/signin_screen.dart';
import 'package:student_app/theme/theme.dart';
import 'package:student_app/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_authentication/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referenceNumberController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  // Define FocusNodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _referenceNumberFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  // Track error messages for fields
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _referenceNumberError;
  String? _phoneNumberError;

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

    _phoneNumberFocusNode.addListener(() {
      if (_phoneNumberFocusNode.hasFocus) {
        setState(() {
          _phoneNumberError = null;
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
    _phoneNumberController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _referenceNumberFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
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
                      // Phone Number
                      TextFormField(
                        controller: _phoneNumberController,
                        focusNode: _phoneNumberFocusNode,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number';
                          } else if (value.length != 10) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Phone Number'),
                          hintText: 'Enter Phone Number',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          errorText: _phoneNumberError,
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
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signUp,
                          //loading indicator
                          child: _isSigningUp
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // Sign up divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              'Sign up with',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 40,
                              color: Color.fromARGB(255, 57, 232, 51),
                            ),
                          ),
                        ],
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
      //loader
      setState(() {
        _isSigningUp = true;
      });

      String fullName = _fullNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String referenceNumber = _referenceNumberController.text;
      String phoneNumber = _phoneNumberController.text;

      User? user = await _auth.signUp(email, password);
      setState(() {
        _isSigningUp = false;
      });

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'Reference number': referenceNumber,
          'email': email,
          'role': 'Student',
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
        showToast(message: "Sign up successful");
        Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (e) => const SignInScreen()));
      } else {
        showToast(message: "Some error happened");
      }
    } else {
      setState(() {
        // Update error messages if form is not valid
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
}
