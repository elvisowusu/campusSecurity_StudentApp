import 'package:student_app/screens/signin_screen.dart';
import 'package:student_app/screens/signup_screen.dart';
import 'package:student_app/theme/theme.dart';
import 'package:student_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:student_app/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
      image: 'assets/images/WelcomePhoto.avif',
      customContainer:Column(
          children: [
            Flexible(
              flex: 9,
              child: Center(child: RichText(
                textAlign: TextAlign.center,
                text:const TextSpan(
                  children: [
                    TextSpan(
                      text:'Welcome Back\n',
                      style: TextStyle(color: Color.fromARGB(255, 10, 160, 15), fontSize: 45, fontWeight: FontWeight.w700) ),
                    TextSpan(
                      text: '\nSign in to see live cases',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.w500)
                    )
                  ],
                ),
              ),
              
              )),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    const Expanded(child: WelcomeButton(
                      buttonName: 'Sign In',
                      onTap: SignInScreen(),
                      textColor: Colors.white,
                      buttonColor: Colors.transparent,
                    )),
                    Expanded(child: WelcomeButton(
                      buttonName: 'Sign Up',
                      onTap:const SignUpScreen(),
                      textColor: lightColorScheme.primary,
                      buttonColor: Colors.white,
                    ))
                  ],
                ),
              )
            )
          ],
      )
    );
  }
}
