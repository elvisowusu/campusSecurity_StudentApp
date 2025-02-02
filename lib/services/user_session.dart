import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? _studentId;
  String? _referenceNumber;
  String? _studentName;
  String? _assignedCounselorId;
  String? _counselorName;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('studentId');
    _referenceNumber = prefs.getString('referenceNumber');
    _studentName = prefs.getString('studentName');
    _assignedCounselorId = prefs.getString('assignedCounselorId');
    _counselorName = prefs.getString('counselorName');

    // If we have an assigned counselor ID but no valid counselor name, fetch it from Firebase
    if (_assignedCounselorId != null && (_counselorName == null || _counselorName!.isEmpty)) {
      await _fetchCounselorName();
    }
  }

  Future<void> saveSession(String studentId, String referenceNumber,
      String studentName, String assignedCounselorId) async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = studentId;
    _referenceNumber = referenceNumber;
    _studentName = studentName;
    _assignedCounselorId = assignedCounselorId;

    // Save student info to SharedPreferences
    await prefs.setString('studentId', studentId);
    await prefs.setString('referenceNumber', referenceNumber);
    await prefs.setString('studentName', studentName);
    await prefs.setString('assignedCounselorId', assignedCounselorId);

    // Fetch and save counselor name only if not already saved
    if (_counselorName == null || _counselorName!.isEmpty) {
      await _fetchCounselorName();
    }
  }

  Future<void> _fetchCounselorName() async {
    if (_assignedCounselorId != null) {
      try {
        DocumentSnapshot counselorDoc = await FirebaseFirestore.instance
            .collection('counselors')
            .doc(_assignedCounselorId)
            .get();

        if (counselorDoc.exists && counselorDoc.data() != null) {
          // Safely extract 'fullname' from Firestore document
          final data = counselorDoc.data() as Map<String, dynamic>;
          _counselorName = data['fullname'] ?? '';

          // Save counselor name if valid
          if (_counselorName != null && _counselorName!.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('counselorName', _counselorName!);
          } else {
            print('Counselor name is invalid or missing.');
          }
        } else {
          print('Counselor document does not exist.');
        }
      } catch (e) {
        print('Error fetching counselor name: $e');
      }
    }
  }

  Future<Map<String, String>> getSessionDetails() async {
    await loadSession();
    return {
      'referenceNumber': _referenceNumber ?? '',
      'fullName': _studentName ?? '',
      'counselorName': _counselorName ?? '',
    };
  }

  void clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = null;
    _referenceNumber = null;
    _studentName = null;
    _assignedCounselorId = null;
    _counselorName = null;

    await prefs.remove('studentId');
    await prefs.remove('referenceNumber');
    await prefs.remove('studentName');
    await prefs.remove('assignedCounselorId');
    await prefs.remove('counselorName');
  }

  String? get studentId => _studentId;
  String? get referenceNumber => _referenceNumber;
  String? get studentName => _studentName;
  String? get assignedCounselorId => _assignedCounselorId;
  String? get counselorName => _counselorName;
}
