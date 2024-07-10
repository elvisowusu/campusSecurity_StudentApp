import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final String? buttonName;
  final Widget? onTap;
  final Color? buttonColor;
  final Color? textColor;

  const WelcomeButton({
    super.key,
    this.buttonName,
    this.onTap,
    this.buttonColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
        ),
        onPressed: () {
          if (onTap != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => onTap!),
            );
          }
        },
        child: Text(
          buttonName!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
