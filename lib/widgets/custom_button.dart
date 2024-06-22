import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton(
      {super.key, this.buttonName, this.onTap, this.buttonColor, this.textColor});
  final String? buttonName;
  final Widget? onTap;
  final Color? buttonColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => onTap!))
      },
      child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: buttonColor!,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
              )),
          child: Text(
            textAlign: TextAlign.center,
            buttonName!,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: textColor!),
          )),
    );
  }
}
