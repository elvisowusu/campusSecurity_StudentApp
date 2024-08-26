import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? _studentId;
  String? _referenceNumber;
  String? _studentName;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('studentId');
    _referenceNumber = prefs.getString('referenceNumber');
    _studentName = prefs.getString('studentName');
  }

  Future<void> saveSession(String studentId, String referenceNumber, String studentName) async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = studentId;
    _referenceNumber = referenceNumber;
    _studentName = studentName;
    await prefs.setString('studentId', studentId);
    await prefs.setString('referenceNumber', referenceNumber);
    await prefs.setString('studentName', studentName);
  }
  
  Future<Map<String, String>> getSessionDetails() async {
    await loadSession(); 
    return {
      'referenceNumber': _referenceNumber ?? '',
      'fullName': _studentName ?? '',
    };
  }

  void clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = null;
    _referenceNumber = null;
    _studentName = null;
    await prefs.remove('studentId');
    await prefs.remove('referenceNumber');
    await prefs.remove('studentName');
  }

  String? get studentId => _studentId;
  String? get referenceNumber => _referenceNumber;
  String? get studentName => _studentName;
}
