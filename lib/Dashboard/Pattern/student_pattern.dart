import 'package:flutter/material.dart';
import 'package:student_app/dashboard/pattern/chat_icon_button.dart';

class StudentPattern extends StatelessWidget {
  const StudentPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          ChatIconButton(), // Use the custom widget here
        ],
      ),
      body: const Column(
        children: [
          Text("We'll perform gait analysis and share live location here"),
          // Add other widgets
        ],
      ),
    );
  }
}
