import 'package:flutter/material.dart';

class OldCases extends StatefulWidget {
  const OldCases({super.key});

  @override
  State<OldCases> createState() => _OldCasesState();
}

class _OldCasesState extends State<OldCases> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Cases'),
      ),
      body: const Column(children: [
            Text('Report Cases'),
      ]
      )
    );
  }
}