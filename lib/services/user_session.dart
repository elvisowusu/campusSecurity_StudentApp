// user_session.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? _studentId;
  String? _referenceNumber;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('studentId');
    _referenceNumber = prefs.getString('referenceNumber');
  }

  Future<void> saveSession(String studentId, String referenceNumber) async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = studentId;
    _referenceNumber = referenceNumber;
    await prefs.setString('studentId', studentId);
    await prefs.setString('referenceNumber', referenceNumber);
  }

  String? get studentId => _studentId;
  String? get referenceNumber => _referenceNumber;

  void clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = null;
    _referenceNumber = null;
    await prefs.remove('studentId');
    await prefs.remove('referenceNumber');
  }
}
