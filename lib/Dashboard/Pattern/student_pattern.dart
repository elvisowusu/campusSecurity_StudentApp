import 'package:flutter/material.dart';
import 'package:student_app/Dashboard/Case Analysis/case_analysis.dart';
import 'package:student_app/Dashboard/Old%20Cases/individual_chat_room.dart';
class StudentPattern extends StatefulWidget {
  const StudentPattern({super.key});

  @override
  State<StudentPattern> createState() => _StudentPatternState();
}

class _StudentPatternState extends State<StudentPattern> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Pattern'),
      ),
      body: const Column(
        children: [
          Text('Map will appear here'),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IndividualChatPage(contact: '1',)),
          );
        },
        tooltip: 'Report Case',
        child: const Icon(Icons.chat_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
