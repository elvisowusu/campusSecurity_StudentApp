import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.customContainer,this.image});

  final Widget? customContainer;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              child: Image.asset(
                image!,
                fit: BoxFit.fitHeight,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: customContainer!,
            )
          ],
        ));
  }
}
