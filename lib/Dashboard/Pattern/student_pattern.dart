import 'package:flutter/material.dart';
import 'package:student_app/Dashboard/Case Analysis/case_analysis.dart';
import 'package:student_app/Dashboard/Old%20Cases/report_old_case.dart';
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
          Text('Student Pattern'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OldCases()),
          );
        },
        tooltip: 'Report Case',
        child: const Icon(Icons.chat_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
